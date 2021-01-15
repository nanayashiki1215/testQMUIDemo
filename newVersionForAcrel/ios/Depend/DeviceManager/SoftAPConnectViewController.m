//
//  testView.m
//  LCOpenSDKDemo
//
//  Created by Fizz on 2019/5/31.
//  Copyright © 2019 lechange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SoftAPConnectViewController.h"
#import "UIAlertController+supportedInterfaceOrientations.h"
#import "LCOpenSDK_SoftAP.h"
#import "LCOpenSDK_DeviceInit.h"
//#import "LCOpenSDK_Prefix.h"
#import "AddDeviceViewController.h"

typedef NS_ENUM(NSInteger, DeviceListState) {
    Normal = 0,
    HasChanged,
};

@interface SoftAPConnectViewController()
{
    LCOpenSDK_SoftAP* m_softAP;
    LCOpenSDK_DeviceInit* m_deviceInit;
    DeviceListState deviceListState;
}
@end

@implementation SoftAPConnectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UINavigationItem* item = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(ADD_DEVICE_TITLE_TXT, nil)];

    UIButton* left = [UIButton buttonWithType:UIButtonTypeCustom];
    [left setFrame:CGRectMake(0, 0, 50, 30)];
    UIImage* imgLeft = [UIImage leChangeImageNamed:Back_Btn_Png];

    [left setBackgroundImage:imgLeft forState:UIControlStateNormal];
    [left addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* leftBtn = [[UIBarButtonItem alloc] initWithCustomView:left];
    [item setLeftBarButtonItem:leftBtn animated:NO];
    [super.m_navigationBar pushNavigationItem:item animated:NO];
    
    [self.view addSubview:super.m_navigationBar];
    
    self.m_lblHint.layer.masksToBounds = YES;
    self.m_lblHint.numberOfLines = 0;
    self.m_lblHint.textAlignment = NSTextAlignmentCenter;
    
    [self.m_softAPConnect setTitle:NSLocalizedString(SOFTAP_CONNECT_TXT, nil) forState:UIControlStateNormal];
    [self.m_bindDevice setTitle:NSLocalizedString(BIND_DEVICE_TXT, nil) forState:UIControlStateNormal];
    
    self.m_SoftAPInstructLab1.text = NSLocalizedString(OPEN_DEVICE_HOTSPOT_TXT, nil);
    self.m_SoftAPInstructLab2.text = NSLocalizedString(CONNECT_DEVICE_HOTSPOT_TXT, nil);
    self.m_SoftAPInstructLab3.text = NSLocalizedString(START_SOFTAP_CONNECT_TXT, nil);
    self.m_SoftAPInstructLab4.text = NSLocalizedString(INPUT_POPWIN_INFO_TXT, nil);
    self.m_SoftAPInstructLab5.text = NSLocalizedString(CHANGE_WIFI_TXT, nil);
    self.m_SoftAPInstructLab6.text = NSLocalizedString(START_BIND_DEVICE_TXT, nil);

    //self.m_lblHint.text = NSLocalizedString(ACCOUNT_NOTICE_TIP_TXT, nil);
}

- (void)restApiBind:(NSString*)devId deviceKey:(NSString*)devKey
{
    RestApiService* restApiService = [RestApiService shareMyInstance];
    __block NSString* errMsg;
    
    self.m_lblHint.text = @"check device bind or not...";
    [restApiService checkDeviceBindOrNot:devId Msg:&errMsg];
    if (![errMsg isEqualToString:[MSG_DEVICE_NOT_BIND mutableCopy]]) {
        self.m_lblHint.text = errMsg;
        return;
    }
    
    self.m_lblHint.text = @"check device online or not...";
    time_t lBegin, lCur;
    NSInteger lTimeout = 60;
    time(&lBegin);
    lCur = lBegin;
    BOOL bOnline = NO;
    while (lCur >= lBegin && lCur - lBegin < lTimeout) {
        [restApiService checkDeviceOnline:devId Msg:&errMsg];
        if ([errMsg isEqualToString:[MSG_DEVICE_ONLINE mutableCopy]]) {
            bOnline = YES;
            break;
        }
        else if ([errMsg isEqualToString:[MSG_DEVICE_OFFLINE mutableCopy]]) {
            NSString* hintLabelText = [NSLocalizedString(WAIT_TIME_TXT, nil) stringByAppendingFormat:@"%ld", lCur - lBegin];
            hintLabelText = [hintLabelText stringByAppendingString:NSLocalizedString(SECOND_TXT, nil)];
            self.m_lblHint.text = hintLabelText;
            usleep(5 * 1000 * 1000);
            time(&lCur);
            continue;
        }
        else {
            self.m_lblHint.text = errMsg;
            return;
        }
    }
    if (NO == bOnline) {
        self.m_lblHint.text = NSLocalizedString(DEVICE_OFFLINE_TXT, nil);
        return;
    }
    
    //国内
    if ([NSLocalizedString(LANGUAGE_TXT, nil) isEqualToString:@"zh"]) {
        NSString* devAbility = nil;
        [restApiService unBindDeviceInfo:devId Ability:&devAbility Msg:&errMsg];
        if (![errMsg isEqualToString:[MSG_SUCCESS mutableCopy]]) {
            self.m_lblHint.text = errMsg;
            return;
        }
        
        if ([devAbility rangeOfString:@"Auth"].location != NSNotFound) {
            [restApiService bindDevice:devId Code:devKey Msg:&errMsg];
            if (![errMsg isEqualToString:[MSG_SUCCESS mutableCopy]]) {
                self.m_lblHint.text = errMsg;
                return;
            }
            self.m_lblHint.text = NSLocalizedString(BIND_SUCCESS_TXT, nil);
            deviceListState = HasChanged;
        }
        else if ([devAbility rangeOfString:@"RegCode"].location != NSNotFound)
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Please Input Device Safe Code" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:nil];
            UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _Nonnull action) {
                NSString* devCode = alert.textFields[0].text;
                [restApiService bindDevice:devId Code:devCode Msg:&errMsg];
                if (![errMsg isEqualToString:[MSG_SUCCESS mutableCopy]]) {
                    self.m_lblHint.text = errMsg;
                    return;
                }
                self.m_lblHint.text = NSLocalizedString(BIND_SUCCESS_TXT, nil);
                deviceListState = HasChanged;
            }];
            UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:confirmAction];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            [restApiService bindDevice:devId Code:@"" Msg:&errMsg];
            if (![errMsg isEqualToString:[MSG_SUCCESS mutableCopy]]) {
                self.m_lblHint.text = errMsg;
                return;
            }
            self.m_lblHint.text = NSLocalizedString(BIND_SUCCESS_TXT, nil);
            deviceListState = HasChanged;
        }
    }
    //海外
    else
    {
        [restApiService bindDevice:devId Code:devKey Msg:&errMsg];
        if (![errMsg isEqualToString:[MSG_SUCCESS mutableCopy]]) {
            self.m_lblHint.text = errMsg;
            return;
        }
        self.m_lblHint.text = NSLocalizedString(BIND_SUCCESS_TXT, nil);
        deviceListState = HasChanged;
    }
}

- (void)initDevice:(int)timeout
{
    NSString *deviceID = _m_deviceId;
    DefLog(@"LCOpen_SoftAP deviceID[%s]\n", [deviceID UTF8String]);
    if (!deviceID || 0 == deviceID.length || [deviceID isEqualToString:NSLocalizedString(DEVICE_ID_TIP_TXT, nil)]) {
        self.m_lblHint.text = NSLocalizedString(DEVICE_ID_TIP_TXT, nil);
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.m_lblHint.text = @"Searching device...";
    });
    __block NSString *theMac = nil;
    __block NSString *theIp = nil;
    __block int thePort = 0;
    __block int theInitStatus = 0;
    __block LCOpenSDK_DeviceInit *deviceInit = [[LCOpenSDK_DeviceInit alloc] init];
    [deviceInit searchDeviceInitInfo:deviceID timeOut:timeout success:^(LCOPENSDK_DEVICE_INIT_INFO info) {
        theMac = [NSString stringWithUTF8String:info.mac];
        theIp = [NSString stringWithUTF8String:info.ip];
        thePort = info.port;
        theInitStatus = info.status;
    }];
    if (!theMac || !theIp) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.m_lblHint.text = @"Search device init info failed!";
        });
        return;
    }
    
    if (0 == theInitStatus && [NSLocalizedString(LANGUAGE_TXT, nil) isEqualToString:@"zh"]) {
        //基于“不支持设备初始化的设备肯定也不支持Auth能力集”的断定
        dispatch_async(dispatch_get_main_queue(), ^{
            self.m_lblHint.text = @"Bind device...";
            [self restApiBind:deviceID deviceKey:nil];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* alertControllerTitle = nil;
            /*if (1 == theInitStatus) {
                alertControllerTitle = @"Please Input Device Init Key";
            }
            else {
                alertControllerTitle = @"Please Input Device Key";
            }
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:alertControllerTitle message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:nil];
            UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _Nonnull action) {
                NSString* deviceKey = alert.textFields[0].text;*/
            
                NSString* deviceKey = _m_deviceKey;
            
                if (1 == theInitStatus) {
                    self.m_lblHint.text = @"try multicast init device...";
                    int ret = [deviceInit initDevice:theMac password:deviceKey];
                    if (-2 == ret) {
                        self.m_lblHint.text = @"try unicast init device...";
                        int ret = [deviceInit initDevice:theMac password:deviceKey ip:theIp];
                        if (-2 == ret) {
                            self.m_lblHint.text = @"Init device failed!";
                            return;
                        }
                        else{
                            self.m_lblHint.text = @"unicast init device succeed!";
                        }
                    }
                    else{
                        self.m_lblHint.text = @"multicast init device succeed!";
                    }
                } else if ((0 == theInitStatus || 2 == theInitStatus) && [NSLocalizedString(LANGUAGE_TXT, nil) isEqualToString:@"en"]) {
                    if (!deviceKey || 0 == deviceKey.length || [deviceKey isEqualToString:NSLocalizedString(DEVICE_KEY_TIP_TXT, nil)]) {
                        self.m_lblHint.text = NSLocalizedString(DEVICE_KEY_TIP_TXT, nil);
                        return;
                    }
                    self.m_lblHint.text = @"Check device password...";
                    int ret = [deviceInit checkPwdValidity:deviceID ip:theIp port:thePort password:deviceKey];
                    if (0 != ret) {
                        self.m_lblHint.text = @"Check device password failed!";
                        return;
                    }
                    else{
                        self.m_lblHint.text = @"Check device password succeed!";
                    }
                }
                
                [self restApiBind:deviceID deviceKey:deviceKey];
           // }];
            /*UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:confirmAction];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:nil];*/
        });
    }
}

-(void)onBtn:(id)sender
{
    /* 检查设备是否初始化过 */
    if(!m_deviceInit){
        m_deviceInit = [[LCOpenSDK_DeviceInit alloc] init];
    }
    [m_deviceInit searchDeviceInitInfo:_m_deviceId timeOut:10*1000 success:^(LCOPENSDK_DEVICE_INIT_INFO info) {
        _m_initDevStatus = info.status;
         DefLog(@"sqtest _m_initDevStatus[%ld]\n", _m_initDevStatus);
    }];
    
    if(!m_softAP){
        m_softAP = [[LCOpenSDK_SoftAP alloc]init];
    }
    
    static NSInteger softAPResult = -1;
    if (0 == _m_initDevStatus && [NSLocalizedString(LANGUAGE_TXT, nil) isEqualToString:@"zh"]){
        softAPResult = [m_softAP startSoftAPConfig:_m_wifiName wifiPwd:_m_wifiPwd deviceId:_m_deviceId devicePwd:_m_deviceKey];
        //[self initDevice:10000];
    }
    else{
        /* 需要初始化或者初始化过的弹窗输入设备密码 */
        NSString* alertControllerTitle = @"Please Input Device Init Key";
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:alertControllerTitle message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:nil];
        UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _Nonnull action){
            _m_deviceKey = alert.textFields[0].text;
            //_m_deviceKey = @"qwerty1234";
            if (!_m_deviceKey || 0 == _m_deviceKey.length) {
                DefLog(@"sqtest m_deviceKey has not been input");
                return;
            }
            softAPResult = [m_softAP startSoftAPConfig:_m_wifiName wifiPwd:_m_wifiPwd deviceId:_m_deviceId devicePwd:_m_deviceKey];
            //[self initDevice:30000];
        }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:confirmAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    return;
}

-(IBAction)onBack:(UIStoryboardSegue *)sender
{
    DefLog(@"sqtest onBack");
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:NO];
    return;
}

-(IBAction)onBindDeivce:(id)sender
{
    [self restApiBind:_m_deviceId deviceKey:_m_deviceKey ?: @""];
}

@end
