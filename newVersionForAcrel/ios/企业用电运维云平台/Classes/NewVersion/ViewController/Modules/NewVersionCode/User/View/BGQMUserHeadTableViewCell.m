//
//  BGQMTableViewCell.m
//  变电所运维
//
//  Created by Acrel on 2019/7/31.
//

#import "BGQMUserHeadTableViewCell.h"
#import "BGLogSecondViewController.h"
#import "CustomNavigationController.h"
#import "UIColor+BGExtension.h"
#import "YYServiceManager.h"
#import <CloudPushSDK/CloudPushSDK.h>

@implementation BGQMUserHeadTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    [self.quitOutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.quitOutBtn.layer.cornerRadius = self.quitOutBtn.frame.size.height/2;
    self.quitOutBtn.layer.masksToBounds = YES;
    [self.quitOutBtn.layer addSublayer:[UIColor setGradualChangingColor:self.quitOutBtn fromColor:COLOR_LightLWithChangeIn16 toColor:COLOR_DeepLWithChangeIn16]];
    self.signoutlabel.text = DefLocalizedString(@"SignOut");
//    [self.quitOutBtn setTitle:DefLocalizedString(@"SignOut") forState:UIControlStateNormal];
//    [self.quitOutBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:19.f]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//退出登录 登出
- (IBAction)loginOutClickEvent:(UIButton *)sender {
    QMUIAlertAction *action = [QMUIAlertAction actionWithTitle:DefLocalizedString(@"Sure") style:QMUIAlertActionStyleDestructive handler:^(__kindof QMUIAlertController * _Nonnull aAlertController, QMUIAlertAction * _Nonnull action) {
           //清空NSUserDefaults 退出登录
    ;
           __weak __typeof(self)weakSelf = self;
        [weakSelf getLocationWithLoginVersionNo:[UserManager manager].versionNo andToken:[UserManager manager].token];
           [weakSelf removeAlias:nil];
           NSUserDefaults *defatluts = [NSUserDefaults standardUserDefaults];
           NSDictionary *dictionary = [defatluts dictionaryRepresentation];
           for(NSString *key in [dictionary allKeys]){
               if ([key isEqualToString:@"orderListUrl"]) {
                   continue;
               }else if ([key isEqualToString:kaccount]) {
                   continue;
               }else if ([key isEqualToString:kpassword]) {
                   continue;
               }else if ([key isEqualToString:@"isSavePwd"]){
                   continue;
               }else if ([key isEqualToString:@"orderUrlArray"]){
                   continue;
               }else if ([key isEqualToString:@"selectlanageArr"]){
                   continue;
               }else if ([key isEqualToString:@"myLanguage"]){
                   continue;
               }else if ([key isEqualToString:@"isOpenBoxInApp"] || [key isEqualToString:@"isAlwaysUploadPosition"]){
                   continue;
               }else if ([key isEqualToString:@"APPLoginImageUrl"] || [key isEqualToString:@"appIndexSet"] || [key isEqualToString:kBaseUrlString]){
                   continue;
               }
               else{
                   [defatluts removeObjectForKey:key];
                   [defatluts synchronize];
               }
           }
             // 停止采集轨迹
            if ([YYServiceManager defaultManager].isGatherStarted) {
                [YYServiceManager defaultManager].isGatherStarted = NO;
               
                [[YYServiceManager defaultManager] stopGather];
                [weakSelf generateTrackRecords];
            }
        
           BGLogSecondViewController *loginVC = [[BGLogSecondViewController alloc] init];
           UINavigationController *naVC = [[CustomNavigationController alloc] initWithRootViewController:loginVC];
           [UIApplication sharedApplication].keyWindow.rootViewController = naVC;
       }];
    
        QMUIAlertAction *action2 = [QMUIAlertAction actionWithTitle:DefLocalizedString(@"Cancel") style:QMUIAlertActionStyleCancel handler:^(__kindof QMUIAlertController * _Nonnull aAlertController, QMUIAlertAction * _Nonnull action) {
      
        }];
    
       QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:DefLocalizedString(@"SignOut") message:DefLocalizedString(@"SureSignOut") preferredStyle:QMUIAlertControllerStyleAlert];
    
       [alertController addAction:action];
       [alertController addAction:action2];
       
       QMUIVisualEffectView *visualEffectView = [[QMUIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
       visualEffectView.foregroundColor = UIColorMakeWithRGBA(255, 255, 255, .7);// 一般用默认值就行，不用主动去改，这里只是为了展示用法
       alertController.mainVisualEffectView = visualEffectView;
       alertController.alertHeaderBackgroundColor = nil;// 当你需要磨砂的时候请自行去掉这几个背景色，不然这些背景色会盖住磨砂
       alertController.alertButtonBackgroundColor = nil;
       [alertController showWithAnimated:YES];
    
}

-(void)removeAlias:(NSString *)alias{
    [CloudPushSDK removeAlias:alias withCallback:^(CloudPushCallbackResult *res) {
           if (res.success) {
               DefLog(@"别名移除成功,别名：%@",alias);
           } else {
               DefLog(@"别名移除失败，错误: %@", res.error);
           }
    }];
}

-(void)generateTrackRecords{
    NSMutableDictionary *mutparam = [NSMutableDictionary new];
    NSString *Projectip = GetBaseURL;
    [mutparam setObject:Projectip forKey:@"fProjectip"];
    UserManager *user = [UserManager manager];
    NSString *startTime = user.startTJtime;
    if (startTime.length) {
         [mutparam setObject:startTime forKey:@"fTrackstarttime"];
    }
    NSString *taskNumber = user.taskID;
    if (taskNumber && taskNumber.length) {
        [mutparam setObject:taskNumber forKey:@"fTaskNumber"];
    }
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
    NSString *endTime = [formatter stringFromDate:date];
    [mutparam setObject:endTime forKey:@"fTrackendtime"];
    //设置采集周期 30秒
    NSDictionary *baiduDic = user.yytjBaiduDic;
    NSString *tjGetherInterval =[NSString changgeNonulWithString:baiduDic[@"tjGetherInterval"]];
    NSString *tjPackInterval =[NSString changgeNonulWithString:baiduDic[@"tjPackInterval"]];
    if (tjGetherInterval && tjPackInterval) {
        [mutparam setObject:tjGetherInterval forKey:@"tjGetherInterval"];
        [mutparam setObject:tjPackInterval forKey:@"tjPackInterval"];
    } else {
        tjGetherInterval = @"5";
        tjPackInterval = @"30";
    }
    NSDictionary *param = user.loginData;
    NSString *projectname = [NSString changgeNonulWithString:param[@"fProjectname"]];
    NSString *userid = [NSString changgeNonulWithString:param[@"userId"]];
    NSString *username = [NSString changgeNonulWithString:param[@"username"]];
    //组织机构编号
    NSString *coaccountno = [NSString changgeNonulWithString:param[@"fCoaccountNo"]];
    //组织机构名
    NSString *coname = [NSString changgeNonulWithString:param[@"fConame"]];
    if (projectname) {
        [mutparam setObject:projectname forKey:@"fProjectname"];
    }
    if (userid) {
        [mutparam setObject:userid forKey:@"fUserid"];
    }
    if (username) {
        [mutparam setObject:username forKey:@"fUsername"];
    }
    if (coaccountno) {
        [mutparam setObject:coaccountno forKey:@"fCoaccountno"];
    }
    if (coname) {
        [mutparam setObject:coname forKey:@"fConame"];
    }
//    [NetService bg_getWithTokenWithPath:@"/generateTrackRecords" params:mutparam success:^(id respObjc) {
//        [UserManager manager].startTJtime = @"";
//
//    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
//        [UserManager manager].startTJtime = @"";
//
//    }];
    //阿里云特殊接口 http://www.acrelcloud.cn
    [NetService bg_getWithTestPath:@"sys/generateTrackRecords" params:mutparam success:^(id respObjc) {
        [UserManager manager].startTJtime = @"";
        
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
        [UserManager manager].startTJtime = @"";
       
    }];
}

#pragma mark - 上传定位
-(void)getLocationWithLoginVersionNo:(NSString *)versionNo andToken:(NSString *)token{
    if ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)) {
    //            [self performSelectorOnMainThread:@selector(getLoation) withObject:nil waitUntilDone:YES];
                //定位功能可用
        [self getLoationWithversionNo:versionNo andToken:token];

    }else{
        NSString *sktoolsStr = [SKControllerTools getCurrentDeviceModel];
        NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
        NSString *userIP = [NSString stringWithFormat:@"%@,%@",sktoolsStr,phoneVersion];
        NSDictionary *param = @{@"deviceType":@"IOS",@"userIp":userIP,@"userAddress":@""};
        [self uploadLogininMsg:param andVersionNo:versionNo andToken:token];
    }
}

-(void)getLoationWithversionNo:(NSString *)versionNo andToken:(NSString *)token{
//    __weak __typeof(self)weakSelf = self;
    [self.locationManager requestLocationWithReGeocode:YES withNetworkState:YES completionBlock:^(BMKLocation * _Nullable location, BMKLocationNetworkState state, NSError * _Nullable error) {
             //获取经纬度和该定位点对应的位置信息
        DefLog(@"%@ %d",location,state);
        NSString *sktoolsStr = [SKControllerTools getCurrentDeviceModel];
        NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
        NSString *userIP = [NSString stringWithFormat:@"%@,%@",sktoolsStr,phoneVersion];
        if(location){
            NSString *addressStr = [NSString stringWithFormat:@"%@%@%@%@%@%@",location.rgcData.country,location.rgcData.province,location.rgcData.city,location.rgcData.district,location.rgcData.street,location.rgcData.streetNumber];
//            NSString *locationStr = [NSString stringWithFormat:@"%f;%f;%@",location.location.coordinate.latitude,location.location.coordinate.longitude,addressStr];
            NSDictionary *param = @{@"deviceType":@"IOS",@"userIp":userIP,@"userAddress":addressStr};
            [self uploadLogininMsg:param andVersionNo:versionNo andToken:token];
        }else{
           NSDictionary *param = @{@"deviceType":@"IOS",@"userIp":userIP,@"userAddress":@""};
           [self uploadLogininMsg:param andVersionNo:versionNo andToken:token];
        }
        
    }];
}

-(void)uploadLogininMsg:(NSDictionary *)param andVersionNo:(NSString *)versionNo andToken:(NSString *)token{
    [BGHttpService bg_httpPostWithTokenWithLogout:@"/logout" withVersionNo:versionNo andToken:token params:param success:^(id respObjc) {
         DefLog(@"%@",respObjc);
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
        
    }];
}

- (BMKLocationManager *)locationManager {
    if (!_locationManager) {
        //初始化BMKLocationManager类的实例
        _locationManager = [[BMKLocationManager alloc] init];
        //设置定位管理类实例的代理
        _locationManager.delegate = self;
        //设定定位坐标系类型，默认为 BMKLocationCoordinateTypeGCJ02
        _locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
        //设定定位精度，默认为 kCLLocationAccuracyBest
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        //设定定位类型，默认为 CLActivityTypeAutomotiveNavigation
        _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        //指定定位是否会被系统自动暂停，默认为NO
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        /**
         是否允许后台定位，默认为NO。只在iOS 9.0及之后起作用。
         设置为YES的时候必须保证 Background Modes 中的 Location updates 处于选中状态，否则会抛出异常。
         由于iOS系统限制，需要在定位未开始之前或定位停止之后，修改该属性的值才会有效果。
         */
        _locationManager.allowsBackgroundLocationUpdates = YES;
        /**
         指定单次定位超时时间,默认为10s，最小值是2s。注意单次定位请求前设置。
         注意: 单次定位超时时间从确定了定位权限(非kCLAuthorizationStatusNotDetermined状态)
         后开始计算。
         */
        _locationManager.locationTimeout = 10;
    }
    return _locationManager;
}

- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didFailWithError:(NSError * _Nullable)error {
    DefLog(@"定位失败");
}
@end
