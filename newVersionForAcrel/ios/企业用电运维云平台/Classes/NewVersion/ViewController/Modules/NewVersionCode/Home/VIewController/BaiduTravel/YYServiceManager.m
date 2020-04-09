//
//  YYServiceManager.m
//  YYObjCDemo
//
//  Created by Daniel Bey on 2017年06月21日.
//  Copyright © 2017 百度鹰眼. All rights reserved.
//

#import "YYServiceManager.h"
#import <UserNotifications/UserNotifications.h>
#import "YYServiceParam.h"

static NSString * const YYPushMessageNotificationIdentifier = @"YYPushMessageNotificationIdentifier";

@implementation YYServiceManager

+(YYServiceManager *)defaultManager {
    static YYServiceManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YYServiceManager alloc] init];
    });
    return manager;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        _isServiceStarted = FALSE;
        _isGatherStarted = FALSE;
    }
    return self;
}

#pragma mark private function
-(void)startServiceWithOption:(BTKStartServiceOption *)startServiceOption {
    __weak __typeof(self)weakSelf = self;
    dispatch_async(GLOBAL_QUEUE, ^{
        [[BTKAction sharedInstance] startService:startServiceOption delegate:self];
        [[BTKAction sharedInstance] changeGatherAndPackIntervals:[YYServiceParam serviceParamManager].gatherInterval packInterval:[YYServiceParam serviceParamManager].packInterval delegate:self];
        //
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf startGather];
        });
     
    });
}

-(void)stopService {
    dispatch_async(GLOBAL_QUEUE, ^{
        [[BTKAction sharedInstance] stopService:self];
    });
}

-(void)startGather {
    dispatch_async(GLOBAL_QUEUE, ^{
        [[BTKAction sharedInstance] startGather:self];
    });
}

-(void)stopGather {
    __weak __typeof(self)weakSelf = self;
    dispatch_async(GLOBAL_QUEUE, ^{
        [[BTKAction sharedInstance] stopGather:self];
        //
       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           [weakSelf stopService];
       });
    });
}

#pragma mark - BTKTraceDelegate
// 需要保活以及后台轨迹追踪时，需要在Info.plist文件中增加后台定位相关配置，同时实现此回调
- (void)onRequestAlwaysLocationAuthorization:(CLLocationManager *)locationManager {
    [locationManager requestAlwaysAuthorization];
}

-(void)onChangeGatherAndPackIntervals:(BTKChangeIntervalErrorCode)error{
    DefLog(@"%@",error);
}

-(void)onStartService:(BTKServiceErrorCode)error {
    // 维护状态标志
    if (error == BTK_START_SERVICE_SUCCESS ||
        error == BTK_START_SERVICE_SUCCESS_BUT_OFFLINE ||
        error == BTK_START_SERVICE_SUCCESS_BUT_NO_AUTH_TO_KEEP_ALIVE) {
        NSLog(@"轨迹服务开启成功");
        self.isServiceStarted = TRUE;
    } else {
        NSLog(@"轨迹服务开启失败");
    }
    // 构造广播内容
    NSString *title = nil;
    NSString *message = nil;
    switch (error) {
        case BTK_START_SERVICE_SUCCESS:
            title = @"轨迹服务开启成功";
            message = @"成功登录到服务端";
            break;
        case BTK_START_SERVICE_SUCCESS_BUT_OFFLINE:
            title = @"轨迹服务开启成功";
            message = @"当前网络不畅，未登录到服务端。网络恢复后SDK会自动重试";
            break;
        case BTK_START_SERVICE_PARAM_ERROR:
            title = @"轨迹服务开启失败";
            message = @"参数错误,点击右上角设置按钮设置参数";
            break;
        case BTK_START_SERVICE_INTERNAL_ERROR:
            title = @"轨迹服务开启失败";
            message = @"SDK服务内部出现错误";
            break;
        case BTK_START_SERVICE_NETWORK_ERROR:
            title = @"轨迹服务开启失败";
            message = @"网络异常";
            break;
        case BTK_START_SERVICE_AUTH_ERROR:
            title = @"轨迹服务开启失败";
            message = @"鉴权失败，请检查AK和MCODE等配置信息";
            break;
        case BTK_START_SERVICE_IN_PROGRESS:
            title = @"轨迹服务开启失败";
            message = @"正在开启服务，请稍后再试";
            break;
        case BTK_SERVICE_ALREADY_STARTED_ERROR:
            title = @"轨迹服务开启失败";
            message = @"已经成功开启服务，请勿重复开启";
            break;
        case BTK_START_SERVICE_SUCCESS_BUT_NO_AUTH_TO_KEEP_ALIVE:
            title = @"轨迹服务开启成功";
            message = @"轨迹服务开启成功，要求开启保活，但没有定位权限导致无法保活";
            break;
        default:
            title = @"通知";
            message = @"轨迹服务开启结果未知";
            break;
    }
    NSDictionary *info = @{@"type":@(YY_SERVICE_OPERATION_TYPE_START_SERVICE),
                           @"title":title,
                           @"message":message,
                           };
    // 发送广播
    [[NSNotificationCenter defaultCenter] postNotificationName:YYServiceOperationResultNotification object:nil userInfo:info];
}

-(void)onStopService:(BTKServiceErrorCode)error {
    // 维护状态标志
    if (error == BTK_STOP_SERVICE_NO_ERROR) {
        NSLog(@"轨迹服务停止成功");
        self.isServiceStarted = FALSE;
    } else {
        NSLog(@"轨迹服务停止失败");
    }
    // 构造广播内容
    NSString *title = nil;
    NSString *message = nil;
    switch (error) {
        case BTK_STOP_SERVICE_NO_ERROR:
            title = @"轨迹服务停止成功";
            message = @"SDK已停止工作";
            break;
        case BTK_STOP_SERVICE_NOT_YET_STARTED_ERROR:
            title = @"轨迹服务停止失败";
            message = @"还没有开启服务，无法停止服务";
            break;
        case BTK_STOP_SERVICE_IN_PROGRESS:
            title = @"轨迹服务停止失败";
            message = @"正在停止服务，请稍后再试";
            break;
        default:
            title = @"通知";
            message = @"轨迹服务停止结果未知";
            break;
    }
    NSDictionary *info = @{@"type":@(YY_SERVICE_OPERATION_TYPE_STOP_SERVICE),
                           @"title":title,
                           @"message":message,
                           };
    // 发送广播
    [[NSNotificationCenter defaultCenter] postNotificationName:YYServiceOperationResultNotification object:nil userInfo:info];
}

-(void)onStartGather:(BTKGatherErrorCode)error {
    // 维护状态标志
    if (error == BTK_START_GATHER_SUCCESS) {
        NSLog(@"开始采集成功");
        self.isGatherStarted = TRUE;
    } else {
        NSLog(@"开始采集失败");
    }
    // 构造广播内容
    NSString *title = nil;
    NSString *message = nil;
    switch (error) {
        case BTK_START_GATHER_SUCCESS:
            title = @"开始采集成功";
            message = @"开始采集成功";
            break;
        case BTK_GATHER_ALREADY_STARTED_ERROR:
            title = @"开始采集失败";
            message = @"已经在采集轨迹，请勿重复开始";
            break;
        case BTK_START_GATHER_BEFORE_START_SERVICE_ERROR:
            title = @"开始采集失败";
            message = @"开始采集必须在开始服务之后调用";
            break;
        case BTK_START_GATHER_LOCATION_SERVICE_OFF_ERROR:
            title = @"开始采集失败";
            message = @"没有开启系统定位服务";
            break;
        case BTK_START_GATHER_LOCATION_ALWAYS_USAGE_AUTH_ERROR:
            title = @"开始采集失败";
            message = @"没有开启后台定位权限";
            break;
        case BTK_START_GATHER_INTERNAL_ERROR:
            title = @"开始采集失败";
            message = @"SDK服务内部出现错误";
            break;
        default:
            title = @"通知";
            message = @"开始采集轨迹的结果未知";
            break;
    }
    NSDictionary *info = @{@"type":@(YY_SERVICE_OPERATION_TYPE_START_GATHER),
                           @"title":title,
                           @"message":message,
                           };
    // 发送广播
    [[NSNotificationCenter defaultCenter] postNotificationName:YYServiceOperationResultNotification object:nil userInfo:info];
}

-(void)onStopGather:(BTKGatherErrorCode)error {
    // 维护状态标志
    if (error == BTK_STOP_GATHER_NO_ERROR) {
        NSLog(@"停止采集成功");
        self.isGatherStarted = FALSE;
    } else {
        NSLog(@"停止采集失败");
    }
    // 构造广播内容
    NSString *title = nil;
    NSString *message = nil;
    switch (error) {
        case BTK_STOP_GATHER_NO_ERROR:
            title = @"停止采集成功";
            message = @"SDK停止采集本设备的轨迹信息";
            break;
        case BTK_STOP_GATHER_NOT_YET_STARTED_ERROR:
            title = @"开始采集失败";
            message = @"还没有开始采集，无法停止";
            break;
        default:
            title = @"通知";
            message = @"停止采集轨迹的结果未知";
            break;
    }
    NSDictionary *info = @{@"type":@(YY_SERVICE_OPERATION_TYPE_STOP_GATHER),
                           @"title":title,
                           @"message":message,
                           };
    // 发送广播
    [[NSNotificationCenter defaultCenter] postNotificationName:YYServiceOperationResultNotification object:nil userInfo:info];
}

-(void)onGetPushMessage:(BTKPushMessage *)message {
    // 不是地理围栏的报警，不解析
    if (message.type != 0x03 && message.type != 0x04) {
        return;
    }
    BTKPushMessageFenceAlarmContent *content = (BTKPushMessageFenceAlarmContent *)message.content;
    NSString *fenceName = [NSString stringWithFormat:@"「%@」", content.fenceName];
    NSString *monitoredObject = [NSString stringWithFormat:@"「%@」", content.monitoredObject];
    NSString *action = nil;
    if (content.actionType == BTK_FENCE_MONITORED_OBJECT_ACTION_TYPE_ENTER) {
        action = @"进入";
    } else {
        action = @"离开";
    }
    NSString *fenceType = nil;
    if (message.type == 0x03) {
        fenceType = @"服务端围栏";
    } else {
        fenceType = @"客户端围栏";
    }
    // 通过触发报警的轨迹点，解析出触发报警的时间
    BTKFenceAlarmLocationPoint *currentPoint = content.currentPoint;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *alarmDate = [NSDate dateWithTimeIntervalSince1970:currentPoint.loctime];
    NSString *alarmDateStr = [dateFormatter stringFromDate:alarmDate];
    
    NSString *pushMessage = [NSString stringWithFormat:@"终端 %@ 在 %@ %@ %@%@", monitoredObject, alarmDateStr, action, fenceType, fenceName];
    NSLog(@"推送消息: %@", pushMessage);
    // 简单起见，DEMO只处理iOS10以上的情况
    if (CURRENT_IOS_VERSION >= 10.0) {
        // 发送本地通知
        UNMutableNotificationContent *notificationContent = [[UNMutableNotificationContent alloc] init];
        notificationContent.title = [NSString stringWithFormat:@"%@ 报警", fenceType];
        notificationContent.body = pushMessage;
        notificationContent.sound = [UNNotificationSound defaultSound];
        UNTimeIntervalNotificationTrigger *notificationTrigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.1 repeats:NO];
        NSString *idd = [NSString stringWithFormat:@"%@%@",YYPushMessageNotificationIdentifier, pushMessage];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:idd content:notificationContent trigger:notificationTrigger];
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"地理围栏报警通知发送失败: %@", error);
            } else {
                NSLog(@"通知发送成功");
                [UIApplication sharedApplication].applicationIconBadgeNumber += 1;
            }
        }];
    }
}


@end
