//
//  YYHistoryViewModel.m
//  YYObjCDemo
//
//  Created by Daniel Bey on 2017年06月16日.
//  Copyright © 2017 百度鹰眼. All rights reserved.
//

#import "YYHistoryViewModel.h"
#import "YYHistoryTrackPoint.h"

@interface YYHistoryViewModel ()
@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, strong) dispatch_group_t historyDispatchGroup;
@property (nonatomic, assign) NSUInteger firstResponseSize;
@property (nonatomic, assign) NSUInteger total;
@property (nonatomic, strong) YYHistoryTrackParam *param;
@end

// 轨迹查询每页的上限为5000条，但是若请求纠偏甚至绑路后的轨迹，比较耗时。综合考虑，我们选取每页1000条
static NSUInteger const kHistoryTrackPageSize = 1000;

@implementation YYHistoryViewModel

-(instancetype)init {
    self = [super init];
    if (self) {
        _points = [NSMutableArray array];
        _historyDispatchGroup = dispatch_group_create();
    }
    return self;
}

- (void)queryHistoryWithParam:(YYHistoryTrackParam *)param {
    // 清空已有数据
    [self.points removeAllObjects];
    self.param = param;
    // 发送第一次请求，确定size和total，以决定后续是否还需要发请求，以及发送请求的pageSize和pageIndex
    dispatch_async(GLOBAL_QUEUE, ^{
        BTKQueryHistoryTrackRequest *request = [[BTKQueryHistoryTrackRequest alloc] initWithEntityName:param.entityName startTime:param.startTime endTime:param.endTime isProcessed:param.isProcessed processOption:param.processOption supplementMode:param.supplementMode outputCoordType:BTK_COORDTYPE_BD09LL sortType:BTK_TRACK_SORT_TYPE_ASC pageIndex:1 pageSize:kHistoryTrackPageSize serviceID:BGSERVICEID tag:1];
        [[BTKTrackAction sharedInstance] queryHistoryTrackWith:request delegate:self];
    });
}

-(void)onQueryHistoryTrack:(NSData *)response {
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:nil];
    if (nil == dict) {
//        NSLog(@"HISTORY TRACK查询格式转换出错");
        DefQuickAlert(@"HISTORY TRACK查询格式转换出错",nil);
        return;
    }
    if (0 != [dict[@"status"] intValue]) {
        NSString *msg = [NSString changgeNonulWithString:dict[@"message"]];
        if (msg) {
            DefQuickAlert(msg,nil);
        }else{
            DefQuickAlert(@"HISTORY TRACK查询返回错误",nil);
        }
        return;
    }

    // 每次回调得到的历史轨迹点，都加到数组中
    for (NSDictionary *point in dict[@"points"]) {
        YYHistoryTrackPoint *p = [[YYHistoryTrackPoint alloc] init];
        p.coordinate = CLLocationCoordinate2DMake([point[@"latitude"] doubleValue], [point[@"longitude"] doubleValue]);
        p.loctime = [point[@"loc_time"] unsignedIntValue];
        p.direction = [point[@"direction"] unsignedIntValue];
        [self.points addObject:p];
    }

    // 对于第一次回调结果，根据total和size，确认还需要发送几次请求，并行发送这些请求
    // 使用dispatch_group同步多次请求，当所有请求均收到响应后，points属性中存储的就是所有的轨迹点了
    // 根据请求的是否是纠偏后的结果，处理方式稍有不同：
    // 若是纠偏后的轨迹，直接使用direction字段即可，该方向是准确的；
    // 若是原始的轨迹，direction字段可能不准，我们自己根据相邻点计算出方向。
    // 最好都是请求纠偏后的轨迹，简化客户端处理步骤
    if ([dict[@"tag"] unsignedIntValue] == 1) {
        self.firstResponseSize = [dict[@"size"] unsignedIntValue];
        self.total = [dict[@"total"] unsignedIntValue];
        for (size_t i = 0; i < self.total / self.firstResponseSize; i++) {
            dispatch_group_enter(self.historyDispatchGroup);
            BTKQueryHistoryTrackRequest *request = [[BTKQueryHistoryTrackRequest alloc] initWithEntityName:self.param.entityName startTime:self.param.startTime endTime:self.param.endTime isProcessed:self.param.isProcessed processOption:self.param.processOption supplementMode:self.param.supplementMode outputCoordType:BTK_COORDTYPE_BD09LL sortType:BTK_TRACK_SORT_TYPE_ASC pageIndex:(2 + i) pageSize:kHistoryTrackPageSize serviceID:BGSERVICEID tag:(2 + i)];
            [[BTKTrackAction sharedInstance] queryHistoryTrackWith:request delegate:self];
        }
        //没有查到轨迹的容错
        if (!self.points.count) {
            DefQuickAlert(@"该时间段内未查询到相应轨迹", nil);
            return ;
       }
        dispatch_group_notify(self.historyDispatchGroup, GLOBAL_QUEUE, ^{
            // 将所有查询到的轨迹点，按照loc_time升序排列，注意是稳定排序。
            // 因为绑路时会补充道路形状点，其loc_time与原始轨迹点一样，相同的loc_time在排序后必须保持原始的顺序，否则direction不准。
            [self.points sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(YYHistoryTrackPoint *  _Nonnull obj1, YYHistoryTrackPoint *  _Nonnull obj2) {
                if (obj1.loctime < obj2.loctime) {
                    return NSOrderedAscending;
                } else if (obj1.loctime > obj2.loctime) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedSame;
                }
            }];
            // 如果我们请求的是原始轨迹，最好自己计算每个轨迹点的方向，因为此时返回的direction字段可能不准确。
            if (FALSE == self.param.isProcessed) {
                // 根据相邻两点之间的坐标，计算方向
                for (size_t i = 0; i < self.points.count - 1; i++) {
                    YYHistoryTrackPoint *point1 = (YYHistoryTrackPoint *)self.points[i];
                    YYHistoryTrackPoint *point2 = (YYHistoryTrackPoint *)self.points[i + 1];
                    double lat1 = [self getRadianFromDegree:point1.coordinate.latitude];
                    double lon1 = [self getRadianFromDegree:point1.coordinate.longitude];
                    double lat2 = [self getRadianFromDegree:point2.coordinate.latitude];
                    double lon2 = [self getRadianFromDegree:point2.coordinate.longitude];
                    double deltaOfLon = lon2 - lon1;
                    double y = sin(deltaOfLon) * cos(lat2);
                    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaOfLon);
                    double radianDirection = atan2(y, x);
                    double degreeDirection = [self getDegreeFromRadian:radianDirection];
                    ((YYHistoryTrackPoint *)self.points[i]).direction = [self mapGeometryDirectionToGPSDirection:degreeDirection];
                }
            }
            if (self.completionHandler) {
                self.completionHandler(self.points);
            }
        });
    } else {
        dispatch_group_leave(self.historyDispatchGroup);
    }
}

- (double)getRadianFromDegree:(double)degree {
    return degree * M_PI / 180.0;
}

- (double)getDegreeFromRadian:(double)radian {
    return radian * 180.0 / M_PI;
}

- (double)mapGeometryDirectionToGPSDirection:(double)geometryDirection {
    double gpsDirection = geometryDirection;
    if (geometryDirection < 0) {
        gpsDirection = geometryDirection + 360.0;
    }
    return gpsDirection;
}

@end
