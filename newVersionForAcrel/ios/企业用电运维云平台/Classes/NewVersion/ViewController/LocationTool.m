//
//  LocationTool.m
//  BackgroundLocation
//
//  Created by long on 2017/6/16.
//  Copyright © 2017年 long. All rights reserved.
//

#import "LocationTool.h"
#import <CoreLocation/CoreLocation.h>
#import <UserNotifications/UserNotifications.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocationManager.h>
#import <BMKLocationKit/BMKLocationComponent.h>

@interface LocationTool () <CLLocationManagerDelegate,BMKLocationManagerDelegate>
{
    NSTimeInterval _interval;
}

//@property (nonatomic, strong) CLLocationManager *locManager;
@property (nonatomic, strong) BMKLocationManager *locManager; //定位对象

@property (nonatomic, assign) NSTimeInterval lastUpdateTime;

@end

@implementation LocationTool


+ (instancetype)shareInstance
{
    static LocationTool *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LocationTool alloc] init];
        instance->_interval = 60;
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static LocationTool *instance = nil;
   static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{   //onceToken是GCD用来记录是否执行过 ，如果已经执行过就不再执行(保证执行一次）
        instance = [super allocWithZone:zone];
        instance->_interval = 60;
    });
    return instance;
}

#pragma mark - Lazy loading

- (BMKLocationManager *)locManager {
    if (!_locManager) {
        //初始化BMKLocationManager类的实例
        _locManager = [[BMKLocationManager alloc] init];
        //设置定位管理类实例的代理
        _locManager.delegate = self;
        //设定定位坐标系类型，默认为 BMKLocationCoordinateTypeGCJ02
        _locManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
        //设定定位精度，默认为 kCLLocationAccuracyBest
        _locManager.desiredAccuracy = kCLLocationAccuracyBest;
        //设定定位类型，默认为 CLActivityTypeAutomotiveNavigation
        _locManager.activityType = CLActivityTypeAutomotiveNavigation;
        //指定定位是否会被系统自动暂停，默认为NO
        _locManager.pausesLocationUpdatesAutomatically = NO;
        /**
         是否允许后台定位，默认为NO。只在iOS 9.0及之后起作用。
         设置为YES的时候必须保证 Background Modes 中的 Location updates 处于选中状态，否则会抛出异常。
         由于iOS系统限制，需要在定位未开始之前或定位停止之后，修改该属性的值才会有效果。
         */
        _locManager.allowsBackgroundLocationUpdates = YES;
        /**
         指定单次定位超时时间,默认为10s，最小值是2s。注意单次定位请求前设置。
         注意: 单次定位超时时间从确定了定位权限(非kCLAuthorizationStatusNotDetermined状态)
         后开始计算。
         */
        _locManager.locationTimeout = 10;
    }
    return _locManager;
}

- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didFailWithError:(NSError * _Nullable)error {
    DefLog(@"定位失败");
}

- (void)setUploadInterval:(NSTimeInterval)interval
{
    _interval = interval;
}

- (void)startLocation
{
    NSLog(@"startLocationTracking");
    
    if ([CLLocationManager locationServicesEnabled] == NO) {
        NSLog(@"locationServicesEnabled false");
    } else {
        CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
        
        if(authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted) {
            NSLog(@"authorizationStatus failed");
            QMUIAlertAction *action = [QMUIAlertAction actionWithTitle:DefLocalizedString(@"Sure") style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController * _Nonnull aAlertController, QMUIAlertAction * _Nonnull action) {
              NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
              if ([[UIApplication sharedApplication] canOpenURL:url]) {
                  [[UIApplication sharedApplication] openURL:url];
              }
             [UserManager manager].isContinueShowTJ = YES;
            }];
            QMUIAlertAction *action2 = [QMUIAlertAction actionWithTitle:DefLocalizedString(@"Cancel") style:QMUIAlertActionStyleCancel handler:^(__kindof QMUIAlertController * _Nonnull aAlertController, QMUIAlertAction * _Nonnull action) {
               
            }];
            QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:DefLocalizedString(@"alert_title")  message:@"使用定位与上传功能，需要设置APP位置访问权限为\"始终\"。iOS12及以上系统初次设置可能没有该选项，则优先选择\"使用App期间\"，后续在APP置为后台期间会再次提示，届时请再选择\"始终\"，谢谢配合。" preferredStyle:QMUIAlertControllerStyleAlert];
            [alertController addAction:action];
            [alertController addAction:action2];
            
            QMUIVisualEffectView *visualEffectView = [[QMUIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
            visualEffectView.foregroundColor = UIColorMakeWithRGBA(255, 255, 255, .7);// 一般用默认值就行，不用主动去改，这里只是为了展示用法
            alertController.mainVisualEffectView = visualEffectView;
            alertController.alertHeaderBackgroundColor = nil;// 当你需要磨砂的时候请自行去掉这几个背景色，不然这些背景色会盖住磨砂
            alertController.alertButtonBackgroundColor = nil;
            [alertController showWithAnimated:YES];
        } else {
            NSLog(@"authorizationStatus authorized");
            self.locManager.delegate = self;
            
//            [self.locManager requestAlwaysAuthorization];
//            [self.locManager requestWhenInUseAuthorization];
            [self.locManager startUpdatingLocation];
        }
    }
}

- (void)stopLocation
{
    self.locManager.delegate = nil;
    [self.locManager stopUpdatingLocation];
}

//static int i = 0;
//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
//{
//    if (![self canUpload]) return;
//
//    CLLocation *loc = locations.firstObject;
//
//    NSLog(@"----- i = %d, 维度: %f, 经度: %f", i++, loc.coordinate.latitude, loc.coordinate.longitude);
//
//    [self sendNotifycation:loc.coordinate];
//
//    [self uploadLocation:loc.coordinate];
//}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"定位失败: %@", error);
}

#pragma mark - privite
- (BOOL)canUpload
{
    CFTimeInterval t = CACurrentMediaTime();
    if (t - self.lastUpdateTime > _interval) {
        self.lastUpdateTime = t;
        return YES;
    }
    return NO;
}

//- (void)uploadLocation:(CLLocationCoordinate2D)coor
//{
//    //上传定位
//    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (!error) {
//            NSLog(@"请求百度成功 %d", i);
//        } else {
//            NSLog(@"请求百度失败 %d", i);
//        }
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"uploadSuc" object:nil userInfo:@{@"message": !error?[NSString stringWithFormat:@"请求百度成功 %d", i]:[NSString stringWithFormat:@"请求百度失败 %d", i]}];
//    }];
//    [task resume];
//}

//- (void)sendNotifycation:(CLLocationCoordinate2D)coor
//{
//    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
//    content.badge = @(1);
//    content.body = [NSString stringWithFormat:@"定位成功 %d ", i];
//    content.title = [NSString stringWithFormat:@"WGS84 维度:%.6f, 经度:%.6f", coor.latitude, coor.longitude];
//    //推送类型
//    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:3 repeats:NO];
//
//    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"Test" content:content trigger:trigger];
//    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
//        NSLog(@"iOS 10 发送推送， error：%@", error);
//    }];
//
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"locationSuc" object:nil userInfo:@{@"message": [content.body stringByAppendingString:content.title]}];
//}

#pragma mark - 持续定位地址
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didUpdateLocation:(BMKLocation * _Nullable)location orError:(NSError * _Nullable)error
{
    if (error)
    {
        NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
    } if (location) {//得到定位信息，添加annotation
        if (![self canUpload]) return;
        //
//        static dispatch_once_t onceToken;
//               dispatch_once(&onceToken, ^{
        
           if (location.location) {
               NSLog(@"LOC = %@",location.location);
           }
           if (location.rgcData) {
               NSLog(@"rgc = %@",[location.rgcData description]);
           }
           [self uploadCurrentTime:location];
        
//               });
        
//                if (self.timer == nil) {
//                    self.timer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(uploadCurrentTime:) userInfo:location repeats:YES];
//                }
                
//                if (location.rgcData.poiRegion) {
//
//                }

            }
}

//定时任务
-(void)uploadCurrentTime:(BMKLocation * _Nullable)location{
    NSMutableDictionary *locParam = [NSMutableDictionary new];
    if (location.location && location.location.coordinate.latitude) {
        [locParam setObject:[NSString stringWithFormat:@"%f",location.location.coordinate.longitude] forKey:@"fLongitude"];
        [locParam setObject:[NSString stringWithFormat:@"%f",location.location.coordinate.latitude] forKey:@"fLatitude"];
    }
    if(location.rgcData){
        NSString *addressStr = [NSString stringWithFormat:@"%@%@%@%@%@%@",location.rgcData.country,location.rgcData.province,location.rgcData.city,location.rgcData.district,location.rgcData.street,location.rgcData.streetNumber];
        [locParam setObject:addressStr forKey:@"address"];
    }
    [NetService bg_getWithTokenWithPathAndNoTips:@"/v5/updateUserLocation" params:locParam success:^(id respObjc) {
        
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
        
    }];
//    NSLog(@"当前的时间是---%@---",[self getCurrentTime]);
}


-(NSString *)getCurrentTime{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-DD HH:mm:ss"];
    NSString *dateTime=[dateFormatter stringFromDate:[NSDate date]];
    return  dateTime;
}
@end
