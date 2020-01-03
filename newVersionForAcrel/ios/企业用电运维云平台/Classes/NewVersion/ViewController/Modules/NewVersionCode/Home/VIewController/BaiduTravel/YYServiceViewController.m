//
//  YYServiceViewController.m
//  YYObjCDemo
//
//  Created by Daniel Bey on 2017年06月16日.
//  Copyright © 2017 百度鹰眼. All rights reserved.
//

#import "YYServiceViewController.h"
#import "YYServiceParamSetViewController.h"
#import "YYServiceParam.h"
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "YYServiceManager.h"
#import "YYHistoryTrackViewController.h"

@interface YYServiceViewController ()
@property (nonatomic, strong) BMKMapView *mapView;
@property (nonatomic, strong) UIBarButtonItem *configurationSetUpButton;

@property (nonatomic, strong) UIBarButtonItem *serviceButton;
@property (nonatomic, strong) UIBarButtonItem *gatherButton;

/**
 使用点标注表示最新位置的坐标位置
 */
@property (nonatomic, strong) BMKPointAnnotation *locationPointAnnotation;
/**
 使用圆形覆盖物表示最新位置的定位精度
 */
@property (nonatomic, strong) BMKCircle *locationAccuracyCircle;


@property (nonatomic, strong) YYServiceParam *serviceBasicInfo;
@property (nonatomic, assign) BOOL serviceBasicInfoAlreadySetted;

@property (nonatomic, copy) ServiceParamBlock block;
@property (nonatomic, strong) YYServiceParamSetViewController *vc;

@property (nonatomic, strong) NSTimer *timer;
@end



@implementation YYServiceViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.mapView];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    [self setupUI];
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.toolbarHidden = FALSE;
    self.navigationController.navigationBarHidden = NO;
    [super viewWillAppear:animated];
    [self.mapView viewWillAppear];
    self.mapView.delegate = self;
    [self resumeTimer];
    NSData *locationData = [USER_DEFAULTS objectForKey:LATEST_LOCATION];
    if (locationData) {
        CLLocation *position = [NSKeyedUnarchiver unarchiveObjectWithData:locationData];
        [self updateMapViewWithLocation:position];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.toolbarHidden = YES;
    [self.mapView viewWillDisappear];
    self.mapView.delegate = nil;
    [self pauseTimer];
}

-(instancetype)init {
    self = [super init];
    if (self) {
        _serviceBasicInfoAlreadySetted = FALSE;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serviceOperationResultHandler:) name:YYServiceOperationResultNotification object:nil];
    }
    return self;
}

-(void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
    self.mapView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:YYServiceOperationResultNotification object:nil];
}

#pragma mark - BMKMapViewDelegate
-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation {
    if (annotation != self.locationPointAnnotation) {
        return nil;
    }
    static NSString * latestPointAnnotationViewID = @"latestPointAnnotationViewID";
    BMKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:latestPointAnnotationViewID];
    if (nil == annotationView) {
        annotationView = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:latestPointAnnotationViewID];
    }
    annotationView.image = [UIImage imageNamed:@"icon_center_point"];
    return annotationView;
}

-(BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay {
    if (FALSE == [overlay isMemberOfClass:[BMKCircle class]]) {
        return nil;
    }
    BMKCircleView *circleView = [[BMKCircleView alloc] initWithOverlay:overlay];
    circleView.fillColor = [[UIColor alloc] initWithRed:0 green:1 blue:0 alpha:0.3];
    circleView.strokeColor = [[UIColor alloc] initWithRed:0 green:0 blue:1 alpha:0];
    return circleView;
}

-(void)onQueryTrackLatestPoint:(NSData *)response {
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:nil];
    if (nil == dict) {
        NSLog(@"Entity List查询格式转换出错");
        return;
    }
    if (0 != [dict[@"status"] intValue]) {
        NSLog(@"实时位置查询返回错误");
        return;
    }
    
    NSDictionary *latestPoint = dict[@"latest_point"];
    double latitude = [latestPoint[@"latitude"] doubleValue];
    double longitude = [latestPoint[@"longitude"] doubleValue];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    double horizontalAccuracy = [latestPoint[@"radius"] doubleValue];
    double loctime = [latestPoint[@"loc_time"] doubleValue];
    NSDate *timestamp = [NSDate dateWithTimeIntervalSince1970:loctime];
    CLLocation *latestLocation = [[CLLocation alloc] initWithCoordinate:coordinate altitude:0 horizontalAccuracy:horizontalAccuracy verticalAccuracy:0 timestamp:timestamp];
    // 存储最新的实时位置只是为了在地图底图一开始加载的时候，以上一次最新的实时位置作为底图的中心点
    [USER_DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:latestLocation] forKey:LATEST_LOCATION];
    [USER_DEFAULTS synchronize];
    [self updateMapViewWithLocation:latestLocation];
}


#pragma mark - private function
-(void)setupUI {
    self.navigationController.toolbarHidden = FALSE;
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    self.toolbarItems = @[flexSpace, self.serviceButton, flexSpace, self.gatherButton, flexSpace];
    self.navigationItem.rightBarButtonItem = self.configurationSetUpButton;
}

-(void)updateServiceButtonStyle {
    dispatch_async(MAIN_QUEUE, ^{
        if ([YYServiceManager defaultManager].isServiceStarted) {
            self.serviceButton.title = @"停止服务";
            self.serviceButton.tintColor = [UIColor darkGrayColor];
        } else {
            self.serviceButton.title = @"开启服务";
            self.serviceButton.tintColor = [UIColor blueColor];
        }
    });
}

-(void)updateGatherButtonStyle {
    dispatch_async(MAIN_QUEUE, ^{
//        if ([YYServiceManager defaultManager].isGatherStarted) {
//            self.gatherButton.title = @"查看记录";
//            self.gatherButton.tintColor = [UIColor darkGrayColor];
//        } else {
            self.gatherButton.title = @"查看记录";
            self.gatherButton.tintColor = [UIColor blueColor];
//        }
    });
}

-(void)updateMapViewWithLocation:(CLLocation *)latestLocation {
    CLLocationCoordinate2D centerCoordinate = latestLocation.coordinate;
    // 原点代表最新位置
    dispatch_async(MAIN_QUEUE, ^{
        self.locationPointAnnotation.coordinate = centerCoordinate;
        self.locationPointAnnotation.title = self.serviceBasicInfo.entityName;
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView addAnnotation:self.locationPointAnnotation];
    });
    
    // 填充圆代表定位精度
    dispatch_async(MAIN_QUEUE, ^{
        self.locationAccuracyCircle.coordinate = centerCoordinate;
        self.locationAccuracyCircle.radius = latestLocation.horizontalAccuracy;
        [self.mapView removeOverlays:self.mapView.overlays];
        [self.mapView addOverlay:self.locationAccuracyCircle];
    });
    
    // 移动地图中心点
    dispatch_async(MAIN_QUEUE, ^{
        [self.mapView setCenterCoordinate:centerCoordinate animated:TRUE];
    });
}

-(void)pauseTimer {
    [self.timer invalidate];
    self.timer = nil;
}

-(void)resumeTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.serviceBasicInfo.gatherInterval target:self selector:@selector(queryLatestPosition) userInfo:nil repeats:YES];
}

-(void)showStartServiceResultWithTitle:(NSString *)title message:(NSString *)message {
    dispatch_async(MAIN_QUEUE, ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self updateServiceButtonStyle];
        }];
        [alertController addAction:defaultAction];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

-(void)showStopServiceResultWithTitle:(NSString *)title message:(NSString *)message {
    dispatch_async(MAIN_QUEUE, ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self updateServiceButtonStyle];
        }];
        [alertController addAction:defaultAction];
        if (self.presentedViewController == nil) {
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            [self dismissViewControllerAnimated:YES completion:^{
                dispatch_async(MAIN_QUEUE, ^{
                    [self presentViewController:alertController animated:YES completion:nil];
                    [self updateGatherButtonStyle];
                    [self updateServiceButtonStyle];
                });
            }];
        }
    });
}

-(void)showStartGatherResultWithTitle:(NSString *)title message:(NSString *)message {
    dispatch_async(MAIN_QUEUE, ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self updateGatherButtonStyle];
        }];
        [alertController addAction:defaultAction];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

-(void)showStopGatherResultWithTitle:(NSString *)title message:(NSString *)message {
    dispatch_async(MAIN_QUEUE, ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self updateGatherButtonStyle];
        }];
        [alertController addAction:defaultAction];
        if (self.presentedViewController == nil) {
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            [self dismissViewControllerAnimated:NO completion:^{
                dispatch_async(MAIN_QUEUE, ^{
                    [self presentViewController:alertController animated:YES completion:nil];
                    [self updateGatherButtonStyle];
                    [self updateServiceButtonStyle];
                });
            }];
        }
    });
}

#pragma mark - event response
-(void)serviceOperationResultHandler:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    ServiceOperationType type = (ServiceOperationType)[info[@"type"] unsignedIntValue];
    NSString *title = info[@"title"];
    NSString *message = info[@"message"];
    switch (type) {
        case YY_SERVICE_OPERATION_TYPE_START_SERVICE:
            [self showStartServiceResultWithTitle:title message:message];
            break;
        case YY_SERVICE_OPERATION_TYPE_STOP_SERVICE:
            [self showStopServiceResultWithTitle:title message:message];
            break;
        case YY_SERVICE_OPERATION_TYPE_START_GATHER:
            [self showStartGatherResultWithTitle:title message:message];
            break;
        case YY_SERVICE_OPERATION_TYPE_STOP_GATHER:
            [self showStopGatherResultWithTitle:title message:message];
            break;
        default:
            break;
    }
}


/**
 点击Service服务按钮触发的事件
 */
-(void)serviceButtonTapped {
    // 如果已经开启服务就停止服务；否则就开启服务
    if ([YYServiceManager defaultManager].isServiceStarted) {
         [YYServiceManager defaultManager].isGatherStarted = NO;
        // 停止采集
        [[YYServiceManager defaultManager] stopGather];
        // 停止服务
//        [[YYServiceManager defaultManager] stopService];
    } else {
        // 开启服务之间先配置轨迹服务的基础信息
        BTKServiceOption *basicInfoOption = [[BTKServiceOption alloc] initWithAK:BGBaiduMapApi mcode:[[NSBundle mainBundle] bundleIdentifier] serviceID:BGSERVICEID keepAlive:self.serviceBasicInfo.keepAlive];
        [[BTKAction sharedInstance] initInfo:basicInfoOption];
        // 开启服务
        BTKStartServiceOption *startServiceOption = [[BTKStartServiceOption alloc] initWithEntityName:self.serviceBasicInfo.entityName];
        [[YYServiceManager defaultManager] startServiceWithOption:startServiceOption];
        [YYServiceManager defaultManager].isGatherStarted = YES;
        // 开始采集
//        [[YYServiceManager defaultManager] startGather];
    }
}

/**
 点击查看记录
 
 */
-(void)gatherButtonTapped {
    // 如果已经开始采集就停止采集；否则就开始采集
//    if ([YYServiceManager defaultManager].isGatherStarted) {
//        // 停止采集
//        [[YYServiceManager defaultManager] stopGather];
//    } else {
//        // 开始采集
//        [[YYServiceManager defaultManager] startGather];
//    }
    
    YYHistoryTrackViewController *historyVC = [[YYHistoryTrackViewController alloc] init];
    historyVC.title = @"轨迹记录";
    [self.navigationController pushViewController:historyVC animated:YES];
}


-(void)showParamSettings {
    YYServiceParamSetViewController *paramSetVC = [[YYServiceParamSetViewController alloc] init];
    paramSetVC.block = ^(YYServiceParam *paramInfo) {
        self.serviceBasicInfo = paramInfo;
    };
    [self.navigationController pushViewController:paramSetVC animated:YES];
}

/// 本方法查询实时位置，只是为了在轨迹服务的控制页面展示当前的位置，所以这里不设置纠偏选项。
/// 关于SDK中的queryTrackLatestPointWith方法，在其他页面中有详细介绍。
-(void)queryLatestPosition {
    dispatch_async(GLOBAL_QUEUE, ^{
        BTKQueryTrackLatestPointRequest *request = [[BTKQueryTrackLatestPointRequest alloc] initWithEntityName:self.serviceBasicInfo.entityName processOption:nil outputCootdType:BTK_COORDTYPE_BD09LL serviceID:BGSERVICEID tag:0];
        [[BTKTrackAction sharedInstance] queryTrackLatestPointWith:request delegate:self];
    });
}


#pragma mark - setter & getter
- (BMKMapView *)mapView {
    if (_mapView == nil) {
        CGFloat heightOfNavigationBar = self.navigationController.navigationBar.bounds.size.height;
        //高度 蜜汁问题 可能是历史涉及过导航
        CGRect mapRect = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - heightOfNavigationBar);
        _mapView = [[BMKMapView alloc] initWithFrame:mapRect];
        _mapView.zoomLevel = 19;
    }
    return _mapView;
}

//配置轨迹相关参数
-(YYServiceParam *)serviceBasicInfo {
    if (_serviceBasicInfo == nil) {
        _serviceBasicInfo = [[YYServiceParam alloc] init];
        // 配置默认值
        //设置采集周期
        _serviceBasicInfo.gatherInterval = 30;
        //设置上传周期
        _serviceBasicInfo.packInterval = 60;
        // @[@"步行、骑行、跑步", @"驾车", @"火车、飞机", @"其他类型"];
        _serviceBasicInfo.activityType = CLActivityTypeAutomotiveNavigation;
        // @[@"最高精度（插电才有效）", @"米级", @"十米级别", @"百米级别", @"公里级别", @"最低精度"];
        _serviceBasicInfo.desiredAccuracy = kCLLocationAccuracyBest;
        //设置触发定位的距离阈值@[@1, @10, @100, @500];
        _serviceBasicInfo.distanceFilter = kCLDistanceFilterNone;
        //开启保活
        _serviceBasicInfo.keepAlive = YES;
        //设置唯一id 利用ip地址+userid的方式
        NSString *entityName = [UserManager manager].bguserId;
        if (entityName != nil && entityName.length != 0) {
            _serviceBasicInfo.entityName = entityName;
        }
    }
    return _serviceBasicInfo;
}

- (UIBarButtonItem *)configurationSetUpButton {
    if (_configurationSetUpButton == nil) {
        UIImage *setupIcon = [UIImage imageNamed:@"settings"];
        _configurationSetUpButton = [[UIBarButtonItem alloc] initWithImage:setupIcon style:UIBarButtonItemStylePlain target:self action:@selector(showParamSettings)];
    }
    return _configurationSetUpButton;
}

-(UIBarButtonItem *)serviceButton {
    if (_serviceButton == nil) {
        NSString *title = nil;
        UIColor *tintColor = nil;
        if ([YYServiceManager defaultManager].isServiceStarted) {
            title = @"结束服务";
            tintColor = [UIColor darkGrayColor];
        } else {
            title = @"开启服务";
            tintColor = [UIColor blueColor];
        }
        _serviceButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(serviceButtonTapped)];
        _serviceButton.tintColor = tintColor;
    }
    return _serviceButton;
}

-(UIBarButtonItem *)gatherButton {
    if (_gatherButton == nil) {
        NSString *title = nil;
        UIColor *tintColor = nil;
//        if ([YYServiceManager defaultManager].isGatherStarted) {
//            title = @"查看记录";
//            tintColor = [UIColor darkGrayColor];
//        } else {
            title = @"查看记录";
            tintColor = [UIColor blueColor];
//        }
        _gatherButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(gatherButtonTapped)];
        _gatherButton.tintColor = tintColor;
    }
    return _gatherButton;
}

-(NSTimer *)timer {
    if (_timer == nil) {
        _timer = [NSTimer timerWithTimeInterval:self.serviceBasicInfo.gatherInterval target:self selector:@selector(queryLatestPosition) userInfo:nil repeats:YES];
    }
    return _timer;
}

-(BMKPointAnnotation *)locationPointAnnotation {
    if (_locationPointAnnotation == nil) {
        _locationPointAnnotation = [[BMKPointAnnotation alloc] init];
    }
    return _locationPointAnnotation;
}

-(BMKCircle *)locationAccuracyCircle {
    if (_locationAccuracyCircle == nil) {
        _locationAccuracyCircle = [[BMKCircle alloc] init];
    }
    return _locationAccuracyCircle;
}

     
@end
