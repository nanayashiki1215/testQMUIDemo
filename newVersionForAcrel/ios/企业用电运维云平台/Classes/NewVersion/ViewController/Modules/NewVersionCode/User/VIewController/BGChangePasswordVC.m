//
//  BGChangePasswordVC.m
//  BusinessUCSDK
//
//  Created by Beryl on 2018/6/12.
//  Copyright © 2018年 com.Ideal. All rights reserved.
//

#import "BGChangePasswordVC.h"
#import "YYServiceManager.h"
#import "BGLogSecondViewController.h"
#import "CustomNavigationController.h"
#import "UIColor+BGExtension.h"
#import <CloudPushSDK/CloudPushSDK.h>

@interface BGChangePasswordVC ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *topLabelText;
@property (weak, nonatomic) IBOutlet UITextField *accountName;
@property (weak, nonatomic) IBOutlet UITextField *oldPassWord;
@property (weak, nonatomic) IBOutlet UITextField *nowPassWord;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassWord;
@property (nonatomic,strong)UIButton *rightItemButton;

@property (nonatomic,copy)NSString *oldPassWordStr;
@property (nonatomic,copy)NSString *nowPassWordStr;
@property (nonatomic,copy)NSString *confirmPassWordStr;
@end


@implementation BGChangePasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = DefLocalizedString(@"changePwd");
    self.accountName.text = [UserManager manager].account;
//    self.topLabelText.text =[NSString stringWithFormat:@"设置账号密码后可以通过账号+密码登录 %@",[BGFWGlobal bg_sharedInstance].appDisplayName];
}

- (void)initNavigationBarButtonItems {
    [super initNavigationBarButtonItems];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.rightItemButton];
}

-(void)backButtonAction:(UIButton *)backBtn{
    [self.view endEditing:YES];
    [self popViewControllerAnimation:YES];
}

-(void)moreButtonAction:(UIButton *)moreBtn{
    if (moreBtn.selected) {
        if (self.nowPassWord.text.length && [self equalToOldPassWord]) {
            DefQuickAlert(@"新旧密码不能为同一个，请重新设置！", self);
        }else if (self.nowPassWord.text.length && ![self.nowPassWord.text isEqualToString:self.confirmPassWord.text]){
            DefQuickAlert(@"两次输入的新密码不一致！", self);
        }else{
            if ([self isValidPasswordString:self.confirmPassWord.text]) {
                [self changePassWord];
            }else{
             DefQuickAlert(@"密码必须是8-16位英文字母、数字、字符组合（不能是纯数字）", self);
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITextFieldDelegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([textField isEqual:self.oldPassWord]) {
        self.oldPassWordStr = [self.oldPassWord.text stringByReplacingCharactersInRange:range withString:string];
    }else if ([textField isEqual:self.nowPassWord]){
        self.nowPassWordStr = [self.nowPassWord.text stringByReplacingCharactersInRange:range withString:string];
    }else{
        self.confirmPassWordStr = [self.confirmPassWord.text stringByReplacingCharactersInRange:range withString:string];
    }
    [self refreshRightItem];
    return YES;
}

- (void)refreshRightItem{
    if (self.oldPassWordStr.length && self.nowPassWordStr.length && self.confirmPassWordStr.length) {
        self.rightItemButton.selected = YES;
    }else{
        self.rightItemButton.selected = NO;
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if ([textField isEqual:self.nowPassWord]) {
        if (textField.text.length &&[self equalToOldPassWord]) {
            DefQuickAlert(@"新旧密码不能相同，请重新设置！", self);
        }
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField isEqual:self.oldPassWord]) {
        [self.oldPassWord resignFirstResponder];
        [self.nowPassWord becomeFirstResponder];
    }else if ([textField isEqual:self.nowPassWord]){
        [self.nowPassWord resignFirstResponder];
        [self.confirmPassWord becomeFirstResponder];
    }else{
        [self.view endEditing:YES];
        if ([self.nowPassWord.text isEqualToString:self.confirmPassWord.text]) {
            if ([self isValidPasswordString:self.confirmPassWord.text]) {
                [self changePassWord];
            }else{
                DefQuickAlert(@"密码必须是8-16位英文字母、数字、字符组合（不能是纯数字）", self);
            }
        }else{
            DefQuickAlert(@"两次填写的密码不一致", self);
        }
    }
    return YES;
}
//新旧密码是否相同
-(BOOL)equalToOldPassWord{
    return [self.nowPassWord.text isEqualToString:self.oldPassWord.text];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

-(UIButton *)rightItemButton{
    if (!_rightItemButton) {
        _rightItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightItemButton.frame = CGRectMake(0, 0, 44, 44);
        [_rightItemButton setTitle:DefLocalizedString(@"complete") forState:UIControlStateNormal];
        [_rightItemButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_rightItemButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_rightItemButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightItemButton;
}

#pragma mark 密码判断
-(BOOL)isValidPasswordString:(NSString *)passWordString
{
    //开闭此功能
    BOOL result = YES;
//    if ([passWordString length] >= 8 && [passWordString length] <= 16){
//        //数字条件
//        NSRegularExpression *tNumRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:NSRegularExpressionCaseInsensitive error:nil];
//
//        //符合数字条件的有几个
//        NSUInteger tNumMatchCount = [tNumRegularExpression numberOfMatchesInString:passWordString
//                                                                           options:NSMatchingReportProgress
//                                                                             range:NSMakeRange(0, passWordString.length)];
//
//        //英文字条件
//        NSRegularExpression *tLetterRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]" options:NSRegularExpressionCaseInsensitive error:nil];
//
//        //符合英文字条件的有几个
//        NSUInteger tLetterMatchCount = [tLetterRegularExpression numberOfMatchesInString:passWordString
//                                                                                 options:NSMatchingReportProgress
//                                                                                   range:NSMakeRange(0, passWordString.length)];
//
//        if(tNumMatchCount >= 1 && tLetterMatchCount >= 1){
//            result = YES;
//        }
//
//    }
    return result;
}

#pragma mark - 修改密码

- (void)changePassWord{
    UserManager *loginUserModel = [UserManager manager];
    if(self.oldPassWord.text.length && self.nowPassWord.text.length){
          NSString *oldPassword = self.oldPassWord.text;
          NSString *nowPassWord = self.nowPassWord.text;
          NSString *oldNewPwd = [oldPassword qmui_md5];
          NSString *nowNewPwd = [nowPassWord qmui_md5];
          DefLog(@"nowNewPwd");
          NSDictionary *params = @{@"oldPwd":oldNewPwd,@"newPwd":nowNewPwd};
          [NetService bg_postWithTokenWithPath:@"/modifyUserPwd" params:params success:^(id respObjc) {
              DefLog(@"respObjc:%@",%@);
            
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
                            }else if ([key isEqualToString:@"isOpenBoxInApp"]){
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
                  
          } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
              DefLog(@"errorCode:%@",errorCode);
              
          }];
    }
  
    
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

-(void)removeAlias:(NSString *)alias{
    [CloudPushSDK removeAlias:alias withCallback:^(CloudPushCallbackResult *res) {
           if (res.success) {
               DefLog(@"别名移除成功,别名：%@",alias);
           } else {
               DefLog(@"别名移除失败，错误: %@", res.error);
           }
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
