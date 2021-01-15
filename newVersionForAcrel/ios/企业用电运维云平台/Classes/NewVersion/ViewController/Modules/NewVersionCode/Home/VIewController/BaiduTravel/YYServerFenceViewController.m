//
//  YYServerFenceViewController.m
//  YYObjCDemo
//
//  Created by Daniel Bey on 2017年06月16日.
//  Copyright © 2017 百度鹰眼. All rights reserved.
//

#import "YYServerFenceViewController.h"
#import "YYServerFenceModificationViewController.h"

/// 展示所有的服务端地理围栏，并可以新建、删除、更改围栏。
/// 篇幅所限，本DEMO中仅展示圆形围栏的用法
@interface YYServerFenceViewController ()

/**
 地图，用于展示围栏
 */
@property (nonatomic, strong) BMKMapView *mapView;

/**
 点击刷新按钮，发起一次围栏实体的查询请求
 */
@property (nonatomic, strong) UIBarButtonItem *refreshButton;

/**
 点击加号按钮进入新建围栏的页面
 */
@property (nonatomic, strong) UIBarButtonItem *addButton;

/**
 存储Annotation到FenceID的映射，删除围栏、查询围栏状态、查询历史报警需要用到
 字典中的key是annotation对象，value是围栏ID
 */
@property (nonatomic, strong) NSMutableDictionary *annotationMapToFenceID;

/**
 存储Annotation到Fence对象的映射，更改、删除围栏状态需要用到
 字典中的key是annotation对象，value是BTKServerCircleFence类型的围栏对象
 */
@property (nonatomic, strong) NSMutableDictionary *annotationMapToFenceObject;

@end

@implementation YYServerFenceViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.mapView viewWillAppear];
    self.mapView.delegate = self;
    // 页面出现之前，先查询所有的服务端地理围栏
    [self queryServerFence];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.mapView viewWillDisappear];
    self.mapView.delegate = nil;
}

-(void)dealloc {
    self.mapView = nil;
}

#pragma mark - BMKMapViewDelegate
-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation {
    if (FALSE == [annotation isMemberOfClass:[BMKPointAnnotation class]]) {
        return nil;
    }
    static NSString * fenceCenterAnnotationViewID = @"fenceCenterAnnotationViewID";
    BMKPinAnnotationView *annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:fenceCenterAnnotationViewID];
    if (nil == annotationView) {
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:fenceCenterAnnotationViewID];
    }
    annotationView.pinColor = BMKPinAnnotationColorPurple;
    annotationView.animatesDrop = YES;
    return annotationView;
}

-(BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay {
    if (FALSE == [overlay isMemberOfClass:[BMKCircle class]]) {
        return nil;
    }
    BMKCircleView *circleView = [[BMKCircleView alloc] initWithOverlay:overlay];
    circleView.fillColor = [[UIColor alloc] initWithRed:0 green:0 blue:1 alpha:0.3];
    circleView.strokeColor = [[UIColor alloc] initWithRed:0 green:0 blue:1 alpha:0];
    return circleView;
}

-(void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view {
    //选中某个围栏时，弹出Action Sheet
    NSValue *annotationKey = [NSValue valueWithNonretainedObject:view.annotation];
    // 该Annotation对应的围栏对象
    BTKServerCircleFence *fence = [self.annotationMapToFenceObject objectForKey:annotationKey];
    // 该Annotation对应的围栏ID
    NSNumber *ID = [self.annotationMapToFenceID objectForKey:annotationKey];
    NSUInteger fenceID = [ID unsignedIntValue];
    NSString *monitoredObject = fence.monitoredObject;
    dispatch_async(MAIN_QUEUE, ^{
        NSString *title = [NSString stringWithFormat:@"选择对围栏ID: %@ 的操作", ID];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *updateAction = [UIAlertAction actionWithTitle:@"更改" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self updateServerFenceWithID:fenceID OriginalFenceObject:fence];
        }];
        UIAlertAction *queryStatusAction = [UIAlertAction actionWithTitle:@"实时状态" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self queryStatusWithMonitoredObject:monitoredObject ID:fenceID];
        }];
        UIAlertAction *historyAlarmAction = [UIAlertAction actionWithTitle:@"历史报警" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self queryHistoryAlarmWithMonitoredObject:monitoredObject ID:fenceID];
        }];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^
            (UIAlertAction * _Nonnull action) {
            [self deleteServerFenceWithMonitoredObject:monitoredObject ID:fenceID];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:updateAction];
        [alertController addAction:queryStatusAction];
        [alertController addAction:historyAlarmAction];
        [alertController addAction:deleteAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

#pragma mark - BTKFenceDelegate
-(void)onQueryServerFence:(NSData *)response {
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:nil];
    if (nil == dict) {
        DefLog(@"Server Fence List查询格式转换出错");
        return;
    }
    // 如果查询成功，则将这些服务端围栏显示在地图上
    // 如果查询失败，则弹窗告知用户
    if (0 != [dict[@"status"] intValue]) {
        DefLog(@"服务端地理围栏查询返回错误");
        NSString *message = dict[@"message"];
        if (2 == [dict[@"status"] intValue]) {
            message = @"请到轨迹追踪设置页面，设置当前设备的终端名称，DEMO中的围栏均以该名称作为监控对象";
        }
        dispatch_async(MAIN_QUEUE, ^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"围栏查询失败" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:defaultAction];
            [self presentViewController:alertController animated:YES completion:nil];
        });
        return;
    }
    NSInteger size = [dict[@"size"] intValue];
    if (size == 0) {
        dispatch_async(MAIN_QUEUE, ^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"还没有创建过服务端围栏" message:@"点击导航栏上的 + 号创建围栏" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:defaultAction];
            [self presentViewController:alertController animated:YES completion:nil];
        });
        return;
    }
    // 解析响应

    // 使用Annotaion代表圆形围栏的圆心
    NSMutableArray *centerAnnotations = [NSMutableArray arrayWithCapacity:size];
    // 使用填充圆代表圆形围栏的覆盖范围
    NSMutableArray *radiusOverlays = [NSMutableArray arrayWithCapacity:size];
    // 存储所有围栏的圆心位置，是为了确定地图的显示范围
    NSMutableArray *coordinates = [NSMutableArray arrayWithCapacity:size];
    for (NSDictionary *fence in dict[@"fences"]) {
        // 篇幅所限，这里仅筛选出圆形围栏，在地图上展示。
        if (FALSE == [fence[@"shape"] isEqualToString:@"circle"]) {
            continue;
        }

        // 解析数据
        CLLocationCoordinate2D fenceCenter = CLLocationCoordinate2DMake([fence[@"latitude"] doubleValue], [fence[@"longitude"] doubleValue]);
        double fenceRadius = [fence[@"radius"] doubleValue];
        NSString *fenceName = fence[@"fence_name"];
        NSUInteger denoiseAccuracy = [fence[@"denoise"] unsignedIntValue];
        NSString *monitoredObject = fence[@"monitored_person"];
        
        // 存储圆心位置
        NSValue *coordinateValue = [NSValue valueWithBytes:&fenceCenter objCType:@encode(CLLocationCoordinate2D)];
        [coordinates addObject:coordinateValue];
        
        // 构造Annotation标注
        BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc] init];
        annotation.coordinate = fenceCenter;
        annotation.title = [NSString stringWithFormat:@"名称: %@", fenceName];
        annotation.subtitle = [NSString stringWithFormat:@"半径: %d米; 去噪精度: %d米", (unsigned int)fenceRadius, (unsigned int)denoiseAccuracy];
        [centerAnnotations addObject:annotation];

        // 围栏的覆盖范围
        BMKCircle *coverageArea = [[BMKCircle alloc] init];
        coverageArea.coordinate = fenceCenter;
        coverageArea.radius = fenceRadius;
        [radiusOverlays addObject:coverageArea];
        
        NSValue *annotationKey = [NSValue valueWithNonretainedObject:annotation];
        // 存储标注到围栏的映射
        BTKServerCircleFence *fenceObject = [[BTKServerCircleFence alloc] initWithCenter:fenceCenter radius:fenceRadius coordType:BTK_COORDTYPE_BD09LL denoiseAccuracy:denoiseAccuracy fenceName:fenceName monitoredObject:monitoredObject];
        [self.annotationMapToFenceObject setObject:fenceObject forKey:annotationKey];
        
        // 存储标注到围栏ID的映射
        NSNumber *fenceID = fence[@"fence_id"];
        [self.annotationMapToFenceID setObject:fenceID forKey:annotationKey];
    }
    // 在地图上展示这些围栏
    dispatch_async(MAIN_QUEUE, ^{
        // 清空原有的标注和覆盖物
        [self.mapView removeOverlays:self.mapView.overlays];
        [self.mapView removeAnnotations:self.mapView.annotations];
        // 添加新的标注和覆盖物
        [self.mapView addAnnotations:centerAnnotations];
        [self.mapView addOverlays:radiusOverlays];
        // 设置地图的显示范围
        [self mapViewFitForCoordinates:coordinates];
    });
}

-(void)onDeleteServerFence:(NSData *)response {
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:nil];
    if (nil == dict) {
        DefLog(@"Server Fence Delete格式转换出错");
        return;
    }
    if (0 != [dict[@"status"] intValue]) {
        DefLog(@"服务端地理围栏删除返回错误");
        dispatch_async(MAIN_QUEUE, ^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"围栏删除失败" message:dict[@"message"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:defaultAction];
            [self presentViewController:alertController animated:YES completion:nil];
        });
        return;
    }
    [self queryServerFence];
}

-(void)onQueryServerFenceStatus:(NSData *)response {
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:nil];
    if (nil == dict) {
        DefLog(@"Query Server Fence Status格式转换出错");
        return;
    }
    if (0 != [dict[@"status"] intValue]) {
        DefLog(@"Query Server Fence Status 返回错误");
        dispatch_async(MAIN_QUEUE, ^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"状态查询失败" message:dict[@"message"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:defaultAction];
            [self presentViewController:alertController animated:YES completion:nil];
        });
        return;
    }
    // 解析数据
    NSArray *statuses = dict[@"monitored_statuses"];
    // 因为我们查询的都是某一个围栏的状态，所以这里返回结果一定是只有一项的
    NSString *status = [[statuses firstObject] objectForKey:@"monitored_status"];
    NSString *message = nil;
    if ([status isEqualToString:@"out"]) {
        message = @"终端在围栏外";
    } else if ([status isEqualToString:@"in"]) {
        message = @"终端在围栏内";
    } else {
        message = @"终端和围栏的位置关系未知";
    }
    dispatch_async(MAIN_QUEUE, ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"状态查询结果" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:defaultAction];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

-(void)onQueryServerFenceHistoryAlarm:(NSData *)response {
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:nil];
    if (nil == dict) {
        DefLog(@"Query Server Fence History Alarm格式转换出错");
        return;
    }
    if (0 != [dict[@"status"] intValue]) {
        DefLog(@"Query Server Fence History Alarm 返回错误");
        dispatch_async(MAIN_QUEUE, ^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"历史报警查询失败" message:dict[@"message"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:defaultAction];
            [self presentViewController:alertController animated:YES completion:nil];
        });
        return;
    }
    if (0 == [dict[@"size"] intValue]) {
        dispatch_async(MAIN_QUEUE, ^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"历史报警查询结果" message:@"过去24小时内没有报警信息" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:defaultAction];
            [self presentViewController:alertController animated:YES completion:nil];
        });
        return;
    }
    // 解析数据
    NSMutableArray *alarmInfoText = [NSMutableArray arrayWithCapacity:[dict[@"size"] intValue]];
    for (NSDictionary *alarm in dict[@"alarms"]) {
        NSString *fenceName = alarm[@"fence_name"];
        NSString *monitoredObject = alarm[@"monitored_person"];
        NSString *action = nil;
        if ([alarm[@"action"] isEqualToString:@"enter"]) {
            action = @"进入";
        } else if ([alarm[@"action"] isEqualToString:@"exit"]) {
            action = @"离开";
        }
        NSDate *locDate = [NSDate dateWithTimeIntervalSince1970:[alarm[@"alarm_point"][@"loc_time"] doubleValue]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *timestamp = [dateFormatter stringFromDate:locDate];
        NSString *message = [NSString stringWithFormat:@"终端 「%@」 在 %@ %@ 围栏 「%@」", monitoredObject, timestamp, action, fenceName];
        [alarmInfoText addObject:message];
    }
    dispatch_async(MAIN_QUEUE, ^{
        NSString *message = [alarmInfoText componentsJoinedByString:@"\n"];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"历史报警查询结果" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:defaultAction];
        [self presentViewController:alertController animated:YES completion:nil];
    });
    return;
}

#pragma mark - event response
- (void)queryServerFence {
    // 查询所有以当前登录Entity为监控对象的服务端地理围栏
    NSString *monitoredObject = [USER_DEFAULTS objectForKey:ENTITY_NAME];
    dispatch_async(GLOBAL_QUEUE, ^{
        BTKQueryServerFenceRequest *request = [[BTKQueryServerFenceRequest alloc] initWithMonitoredObject:monitoredObject fenceIDs:nil outputCoordType:BTK_COORDTYPE_BD09LL serviceID:BGSERVICEID tag:1];
        [[BTKFenceAction sharedInstance] queryServerFenceWith:request delegate:self];
    });
}

- (void)addServerFence {
    // 点击 + 按钮后，进入创建圆形地理围栏的界面
    YYServerFenceModificationViewController *fenceAddVC = [[YYServerFenceModificationViewController alloc] initWithModificationType:YY_SERVER_FENCE_MODIFICATION_TYPE_CREATE];
    // 如果是新建围栏，则将新页面中的地图中心设置为当前地图的中心
    fenceAddVC.mapCenter = self.mapView.region.center;
    dispatch_async(MAIN_QUEUE, ^{
        [self.navigationController pushViewController:fenceAddVC animated:YES];
    });
}

- (void)updateServerFenceWithID:(NSUInteger)fenceID OriginalFenceObject:(BTKServerCircleFence *)fence {
    YYServerFenceModificationViewController *fenceUpdateVC = [[YYServerFenceModificationViewController alloc] initWithModificationType:YY_SERVER_FENCE_MODIFICATION_TYPE_UPDATE fenceID:fenceID fenceObject:fence];
    fenceUpdateVC.mapCenter = self.mapView.region.center;
    dispatch_async(MAIN_QUEUE, ^{
        [self.navigationController pushViewController:fenceUpdateVC animated:YES];
    });
}

- (void)deleteServerFenceWithMonitoredObject:(NSString *)monitoredObject ID:(NSUInteger)fenceID {
    dispatch_async(GLOBAL_QUEUE, ^{
        NSArray *ids = @[@(fenceID)];
        BTKDeleteServerFenceRequest *request = [[BTKDeleteServerFenceRequest alloc] initWithMonitoredObject:monitoredObject fenceIDs:ids serviceID:BGSERVICEID tag:1];
        [[BTKFenceAction sharedInstance] deleteServerFenceWith:request delegate:self];
    });
}

- (void)queryStatusWithMonitoredObject:(NSString *)monitoredObject ID:(NSUInteger)fenceID {
    dispatch_async(GLOBAL_QUEUE, ^{
        NSArray *ids = @[@(fenceID)];
        BTKQueryServerFenceStatusRequest *request = [[BTKQueryServerFenceStatusRequest alloc] initWithMonitoredObject:monitoredObject fenceIDs:ids ServiceID:BGSERVICEID tag:1];
        [[BTKFenceAction sharedInstance] queryServerFenceStatusWith:request delegate:self];
    });
}

- (void)queryHistoryAlarmWithMonitoredObject:(NSString *)monitoredObject ID:(NSUInteger)fenceID {
    dispatch_async(GLOBAL_QUEUE, ^{
        NSArray *ids = @[@(fenceID)];
        // 查询过去24小时内的历史报警信息
        NSUInteger endTime = [[NSDate date] timeIntervalSince1970];
        NSUInteger startTime = endTime - 24 * 60 * 60;
        BTKQueryServerFenceHistoryAlarmRequest *request = [[BTKQueryServerFenceHistoryAlarmRequest alloc] initWithMonitoredObject:monitoredObject fenceIDs:ids startTime:startTime endTime:endTime outputCoordType:BTK_COORDTYPE_BD09LL ServiceID:BGSERVICEID tag:1];
        [[BTKFenceAction sharedInstance] queryServerFenceHistoryAlarmWith:request delegate:self];
    });
}

#pragma mark - private function
- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.mapView];
    // 配置导航栏
    NSArray *rightButtons = [NSArray arrayWithObjects:self.refreshButton, self.addButton, nil];
    [self.navigationItem setRightBarButtonItems:rightButtons];
    self.navigationItem.title = @"服务端地理围栏";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"返回";
    self.navigationItem.backBarButtonItem = backButton;
    // 如果有之前的定位点，则将地图中心设置在定位点，如果没有的话，就保持地图中心点在默认的天安门
    NSData *locationData = [USER_DEFAULTS objectForKey:LATEST_LOCATION];
    if (locationData == nil) {
        return;
    }
    CLLocation *position = [NSKeyedUnarchiver unarchiveObjectWithData:locationData];
    dispatch_async(MAIN_QUEUE, ^{
        [self.mapView setCenterCoordinate:position.coordinate];
        self.mapView.zoomLevel = 19;
    });
}

-(void)mapViewFitForCoordinates:(NSArray *)points {
    double minLat = 90.0;
    double maxLat = -90.0;
    double minLon = 180.0;
    double maxLon = -180.0;
    for (size_t i = 0; i < points.count; i++) {
        CLLocationCoordinate2D coord;
        [points[i] getValue:&coord];
        minLat = fmin(minLat, coord.latitude);
        maxLat = fmax(maxLat, coord.latitude);
        minLon = fmin(minLon, coord.longitude);
        maxLon = fmax(maxLon, coord.longitude);
    }
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((minLat + maxLat) * 0.5, (minLon + maxLon) * 0.5);
    BMKCoordinateSpan span;
    span.latitudeDelta = (maxLat - minLat) + 0.01;
    span.longitudeDelta = (maxLon - minLon) + 0.01;
    BMKCoordinateRegion region;
    region.center = center;
    region.span = span;
    [self.mapView setRegion:region animated:YES];
}

#pragma mark - setter & getter
-(NSMutableDictionary *)annotationMapToFenceID {
    if (_annotationMapToFenceID == nil) {
        _annotationMapToFenceID = [[NSMutableDictionary alloc] init];
    }
    return _annotationMapToFenceID;
}

-(NSMutableDictionary *)annotationMapToFenceObject {
    if (_annotationMapToFenceObject == nil) {
        _annotationMapToFenceObject = [[NSMutableDictionary alloc] init];
    }
    return _annotationMapToFenceObject;
}

-(BMKMapView *)mapView {
    if (_mapView == nil) {
        CGFloat heightOfNavigationBar = self.navigationController.navigationBar.bounds.size.height;
        CGRect mapRect = CGRectMake(0, heightOfNavigationBar, SCREEN_WIDTH, SCREEN_HEIGHT - heightOfNavigationBar);
        _mapView = [[BMKMapView alloc] initWithFrame:mapRect];
        _mapView.zoomLevel = 19;
    }
    return _mapView;
}

-(UIBarButtonItem *)refreshButton {
    if (_refreshButton == nil) {
        _refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(queryServerFence)];
    }
    return _refreshButton;
}

-(UIBarButtonItem *)addButton {
    if (_addButton == nil) {
        _addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addServerFence)];
    }
    return _addButton;
}
@end
