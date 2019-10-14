//
//  MainViewController.m
//  EZUIKit
//
//  Created by linyong on 2017/2/17.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "BGVideoStartViewController.h"
#import "EZUIKitViewController.h"
#import "EZUIKitPlaybackViewController.h"
//#import "QRCodeScanViewController.h"
#import "EZOpenSDK.h"
#import "EZUIPlayer.h"
#import "Toast+UIView.h"
#import "EZUIKit.h"
#import "WSDatePickerView.h"
#import "BGHttpService.h"
#import "NSString+BGChangeNoNull.h"

#define MAIN_TITLE @"EZUIKitTestDemo"

@implementation MainNavigationController

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

@end

@interface BGVideoStartViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UITextField *appKeyInput;
@property (weak, nonatomic) IBOutlet UITextField *accessTokenInput;
@property (weak, nonatomic) IBOutlet UITextField *urlInput;
@property (weak, nonatomic) IBOutlet UISwitch *playerSwitch;
@property (weak, nonatomic) IBOutlet UIButton *clearBtn;
@property (weak, nonatomic) IBOutlet UIButton *scanBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *playBarLabel;
@property (weak, nonatomic) IBOutlet UILabel *globalLabel;
@property (weak, nonatomic) IBOutlet UILabel *ezopenUrlLabel;
@property (weak, nonatomic) IBOutlet UILabel *globalApiUrlLabel;
@property (weak, nonatomic) IBOutlet UITextField *apiInput;
@property (weak,nonatomic) UITextField *currentInput;
@property (weak, nonatomic) IBOutlet UIButton *startTime;
@property (weak, nonatomic) IBOutlet UIButton *endTime;
@property (strong, nonatomic) NSString *startTimeStr;
@property (strong, nonatomic) NSString *endTimeStr;

@end

@implementation BGVideoStartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = MAIN_TITLE;

    //开启调试模式
    [EZUIKit setDebug:YES];
    
    [self initViews];
    [self addTouch];
    [self addNotification];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initParamsWithCache];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self requestCamera];
}

- (void) initViews
{
    self.appKeyInput.delegate = self;
    self.accessTokenInput.delegate = self;
    self.urlInput.delegate = self;
    self.apiInput.delegate = self;

    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *sdkVersion = [EZOpenSDK getVersion];
    self.versionLabel.text = [NSString stringWithFormat:@"v%@(SDK %@)",version,sdkVersion];
    
    [self.clearBtn setTitle:NSLocalizedString(@"清除参数", @"清除参数") forState:UIControlStateNormal];
    [self.scanBtn setTitle:NSLocalizedString(@"扫一扫", @"扫一扫") forState:UIControlStateNormal];
    [self.playBtn setTitle:NSLocalizedString(@"开始播放", @"开始播放") forState:UIControlStateNormal];
    self.playBarLabel.text = NSLocalizedString(@"开启回放开关", @"回放进度条开关");
    self.globalLabel.text = NSLocalizedString(@"海外版", @"海外版");
    self.ezopenUrlLabel.text = NSLocalizedString(@"url_ezopen_protocal", @"3.Url (ezopen协议):");
    self.apiInput.hidden = !self.globalMode;
    self.globalApiUrlLabel.hidden = !self.globalMode;
}

- (void) initParamsWithCache
{
    NSString *appKey = [self readStringWithKey:EZUIKitAppKey];
    NSString *accessToken = [self readStringWithKey:EZUIKitAccessToken];
    NSString *urlStr = [self readStringWithKey:EZUIKitUrlStr];
    NSString *urlStrOther = [self readStringWithKey:EZUIKitUrlStrOhter];
    NSString *apiUrl = [self readStringWithKey:EZUIKitApiUrl];
    
    if (appKey)
    {
        self.appKeyInput.text = appKey;
    }else{
        self.appKeyInput.text = @"cec0dca73dfc4782bc84375a57cd8170";
    }
    
    if (accessToken)
    {
        self.accessTokenInput.text = accessToken;
    }else{
        self.accessTokenInput.text = @"at.4ph79psl4eozxqe7038ze11p1396or4u-8ohib48934-00k8xx5-knvrj9znc";
    }
    //时间计划
    [self timeCheckUpdateNetworkAccessToken];
    
    if (urlStr)
    {
        if (urlStrOther)
        {
            self.urlInput.text = [NSString stringWithFormat:@"%@,%@",urlStr,urlStrOther];
        }
        else
        {
            self.urlInput.text = urlStr;
            
        }
    }else{
        self.urlInput.text = @"ezopen://open.ys7.com/183414608/1.rec?";
    }
    
    [self stroeAppkey:self.appKeyInput.text accessToken:self.accessTokenInput.text url:self.urlInput.text urlStrOther:nil apiUrl:nil mode:nil];
//    self.urlInput.text = @"ezopen://open.ys7.com/183414608/1.live";
    self.apiInput.text = apiUrl;
}

- (void)timeCheckUpdateNetworkAccessToken{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    //    DefLog(@"之前时间：%@", [userDefault objectForKey:@"nowDate"]);//之前存储的时间
    //    DefLog(@"现在时间%@",[NSDate date]);//现在的时间
    NSDate *now = [NSDate date];
    NSDate *agoDate = [userDefault objectForKey:@"nowDate"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *ageDateString = [dateFormatter stringFromDate:agoDate];
    NSString *nowDateString = [dateFormatter stringFromDate:now];
    DefLog(@"日期比较：之前：%@ 现在：%@",ageDateString,nowDateString);
    
    if ([ageDateString isEqualToString:nowDateString]) {
        DefLog(@"一天就显示一次");
        
    }else{
        __weak typeof(self) weakSelf = self;
        NSString *param = [NSString stringWithFormat:@"https://open.ys7.com/api/lapp/token/get?appKey=%@&appSecret=%@",@"cec0dca73dfc4782bc84375a57cd8170",@"ded9a969ec3abc6de7f675e04fa549a8"];
        [BGHttpService bg_httpPostWithPath:param params:nil success:^(id respObjc) {
            NSString *code = [NSString bg_changgeNullStringWithString:respObjc[@"code"]];
            if(code && [code isEqualToString:@"200"]){
                weakSelf.accessTokenInput.text = respObjc[@"data"][@"accessToken"];
            }
            // 需要执行的方法写在这里
            NSDate *nowDate = [NSDate date];
            NSUserDefaults *dataUser = [NSUserDefaults standardUserDefaults];
            [dataUser setObject:nowDate forKey:@"nowDate"];
            [dataUser synchronize];
        } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
            //        返回码    返回消息    描述
            //        200    操作成功    请求成功
            //        10001    参数错误    参数为空或格式不正确
            //        10005    appKey异常    appKey被冻结
            //        10017    appKey不存在    确认appKey是否正确
            //        10030    appkey和appSecret不匹配
            //        49999    数据异常    接口调用异常
        }];
    }
}

- (void) addTouch
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchCallback:)];
    
    [self.view addGestureRecognizer:tap];
}

- (void) addNotification
{
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
- (void) showQRCodeScanController
{
//    [QRCodeScanViewController showQRCodeScanFrom:self resultBlock:^(NSDictionary *jsonInfo){
//
//        DefLog(@"=====url json info:%@",jsonInfo);
//
//        NSString *appKey = jsonInfo[@"AppKey"];
//        NSString *accessToken = jsonInfo[@"AccessToken"];
//        id urlObjc =jsonInfo[@"Url"];
//        NSString *urlStr = nil,*urlStrOther = nil;
//        NSString *apiUrl = jsonInfo[@"apiUrl"];
//        NSString *modeStr = jsonInfo[@"Type"];
//
//        if ([urlObjc isKindOfClass:[NSArray class]])
//        {
//            urlStr = [(NSArray*)urlObjc firstObject];
//            urlStrOther = [(NSArray*)urlObjc lastObject];
//        }
//        else
//        {
//            urlStr = (NSString*)urlObjc;
//        }
//
//        [self stroeAppkey:appKey accessToken:accessToken url:urlStr urlStrOther:urlStrOther apiUrl:apiUrl mode:modeStr];
//
//        if (appKey)
//        {
//            self.appKeyInput.text = appKey;
//        }
//
//        if (accessToken)
//        {
//            self.accessTokenInput.text = accessToken;
//        }
//
//        if (urlStr)
//        {
//            self.urlInput.text = urlStr;
//        }
//
//        self.apiInput.text = apiUrl;
//    }];
}

- (void) showPlayerControllerWithAppKey:(NSString *) appKey
                                 access:(NSString *) accessToken
                                    url:(NSString *) urlStr
                                 apiUrl:(NSString *) apiUrl
                                   mode:(NSString *) modeStr
{
    NSString *alertMsg = nil;
    if (!appKey || appKey.length == 0)
    {
        alertMsg = NSLocalizedString(@"app_key_msg", @"AppKey不能为空");
    }
    
    if (!accessToken || accessToken.length == 0)
    {
        if (!alertMsg)
        {
            alertMsg =NSLocalizedString(@"access_token_msg", @"accessToken不能为空");
        }
    }
    
    if (!urlStr || urlStr.length == 0)
    {
        if (!alertMsg)
        {
            alertMsg = NSLocalizedString(@"url_msg", @"播放url不能为空");
        }
    }
    
    if (self.globalMode &&(!apiUrl || apiUrl.length == 0))
    {
        if (!alertMsg)
        {
            alertMsg = NSLocalizedString(@"api_url_msg", @"服务器地址不能为空");
        }
    }
    
    if (alertMsg)
    {
        [self.view makeToast:alertMsg duration:1.5 position:@"center"];
        return;
    }
    
    NSString *urlStrOther = nil;
    NSArray *tempArr = [urlStr componentsSeparatedByString:@","];
    if (tempArr.count == 2)
    {
        urlStr = [tempArr firstObject];
        urlStrOther = [tempArr lastObject];
    }

    [self stroeAppkey:appKey accessToken:accessToken url:urlStr urlStrOther:urlStrOther apiUrl:apiUrl mode:modeStr];

    if (self.playerSwitch.on && [EZUIPlayer getPlayModeWithUrl:urlStr] == EZUIKIT_PLAYMODE_REC)
    {
        EZUIKitPlaybackViewController *vc = [[EZUIKitPlaybackViewController alloc] init];
        vc.appKey = appKey;
        vc.accessToken = accessToken;
        vc.urlStr = urlStr;
        if (self.globalMode)
        {
            vc.apiUrl = apiUrl;
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        EZUIKitViewController *vc = [[EZUIKitViewController alloc] init];
        vc.appKey = appKey;
        vc.accessToken = accessToken;
        vc.urlStr = urlStr;
        vc.urlStrOhter = urlStrOther;
        if (self.globalMode)
        {
            vc.apiUrl = apiUrl;
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSString *) readStringWithKey:(NSString *) key
{
    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return value;
}

- (void) storeString:(NSString *) value key:(NSString *) key
{
    if (!value || !key || key.length <= 0)
    {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
}

- (void) clearCache
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:EZUIKitAppKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:EZUIKitAccessToken];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:EZUIKitUrlStr];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:EZUIKitUrlStrOhter];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:EZUIKitApiUrl];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:EZUIKitMode];
}

- (void) stroeAppkey:(NSString *) appKey
         accessToken:(NSString *) token
                 url:(NSString *) urlStr
         urlStrOther:(NSString *) urlStrOther
              apiUrl:(NSString *) apiUrl
                mode:(NSString *) modeStr
{
    [self storeString:appKey key:EZUIKitAppKey];
    [self storeString:token key:EZUIKitAccessToken];
    [self storeString:urlStr key:EZUIKitUrlStr];
    
    if (urlStrOther)
    {
        [self storeString:urlStrOther key:EZUIKitUrlStrOhter];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:EZUIKitUrlStrOhter];
    }
    
    if (apiUrl)
    {
        [self storeString:apiUrl key:EZUIKitApiUrl];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:EZUIKitApiUrl];
    }
    
    if (modeStr)
    {
        [self storeString:modeStr key:EZUIKitMode];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:EZUIKitMode];
    }
}

- (void) requestCamera
{
    NSString * mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus  authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    //摄像头已授权
    if (authorizationStatus == AVAuthorizationStatusAuthorized)
    {
        return;
    }
    
    //摄像头未授权
    if (authorizationStatus == AVAuthorizationStatusNotDetermined)
    {
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            
        }];
        return;
    }
    
    //摄像头受限
    if (authorizationStatus == AVAuthorizationStatusRestricted|| authorizationStatus == AVAuthorizationStatusDenied)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"allow_phone_camera", @"摄像头访问受限")
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];

        [self presentViewController:alert animated:YES completion:nil];
        
        UIAlertAction * action = [UIAlertAction actionWithTitle:NSLocalizedString(@"know", @"知道了")
                                                          style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction *action) {
                                                            [self dismissViewControllerAnimated:YES completion:nil];
                                                        }];
        [alert addAction:action];
    }
}

#pragma mark - notifications

//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat height = keyboardRect.size.height;
    CGFloat offset = CGRectGetMaxY(self.apiInput.frame) + 10 - (CGRectGetMaxY(self.view.bounds) - height);
    
    NSNumber *durationNum = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    CGFloat duration = [durationNum floatValue];
    
    if (offset > 0)
    {
        [UIView animateWithDuration:duration animations:^{
            self.view.frame = CGRectMake(0,-offset, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        }];
    }
}

//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    NSNumber *durationNum = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    CGFloat duration = [durationNum floatValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    }];
}

#pragma mark - override

//只支持竖屏
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - actions

- (void) touchCallback:(id) sender
{
    if (!self.currentInput)
    {
        return;
    }
    
    [self.currentInput resignFirstResponder];
    self.currentInput = nil;
}

- (IBAction)scanBtnClick:(id)sender
{
    [self showQRCodeScanController];
}

//点击播放
- (IBAction)playBtnClick:(id)sender
{
    
//    NSString *urlStr = [self readStringWithKey:EZUIKitUrlStr];
//    if (!urlStr) {
     NSString *urlStr = @"ezopen://open.ys7.com/183414608/1.rec?";
//    }
    NSString *urlInputString = [NSString stringWithFormat:@"%@begin=%@&end=%@",urlStr,self.startTimeStr,self.endTimeStr];
//    self.urlInput.text = @"ezopen://open.ys7.com/183414608/1.rec?begin=20190509000000&end=20190509235959";
    DefLog(@"输入的时间段为：%@",urlInputString);
    NSString *modeStr = [self readStringWithKey:EZUIKitMode];
    [self showPlayerControllerWithAppKey:self.appKeyInput.text
                                  access:self.accessTokenInput.text
                                     url:urlInputString
                                  apiUrl:self.apiInput.text
                                    mode:modeStr];
}

- (IBAction)clearBtnClick:(id)sender
{
    self.appKeyInput.text = nil;
    self.accessTokenInput.text = nil;
    self.urlInput.text = nil;
    self.apiInput.text = nil;
    
    [self clearCache];
}

#pragma mark - delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.currentInput = textField;
}

#pragma mark - setTime

- (IBAction)startTime:(UIButton *)sender {
//    yyyyMMddhhmmss&end= yyyyMMddhhmmss
    //年-月-日-时-分
    __weak typeof(self) weakSelf = self;
    WSDatePickerView *datepicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDayHourMinute CompleteBlock:^(NSDate *selectDate) {
        
        NSString *dateString = [selectDate stringWithFormat:@"yyyy-MM-dd HH:mm"];
        DefLog(@"选择的日期：%@",dateString);
        [sender setTitle:dateString forState:UIControlStateNormal];
        weakSelf.startTimeStr = [selectDate stringWithFormat:@"yyyyMMddHHmmss"];
//        [weakSelf setTimeWithDateStr:dateStrWithSet andIsOrNotBeginTime:YES];
    }];
    datepicker.dateLabelColor = [UIColor orangeColor];//年-月-日-时-分 颜色
    datepicker.datePickerColor = [UIColor blackColor];//滚轮日期颜色
    datepicker.doneButtonColor = [UIColor orangeColor];//确定按钮的颜色
    [datepicker show];
}

- (IBAction)endTImeEvent:(UIButton *)sender {
    //年-月-日-时-分
    __weak typeof(self) weakSelf = self;
    WSDatePickerView *datepicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDayHourMinute CompleteBlock:^(NSDate *selectDate) {
        
        NSString *dateString = [selectDate stringWithFormat:@"yyyy-MM-dd HH:mm"];
        DefLog(@"选择的日期：%@",dateString);
        [sender setTitle:dateString forState:UIControlStateNormal];
        weakSelf.endTimeStr = [selectDate stringWithFormat:@"yyyyMMddHHmmss"];
//        [weakSelf setTimeWithDateStr:dateStrWithSet andIsOrNotBeginTime:NO];
    }];
    datepicker.dateLabelColor = [UIColor orangeColor];//年-月-日-时-分 颜色
    datepicker.datePickerColor = [UIColor blackColor];//滚轮日期颜色
    datepicker.doneButtonColor = [UIColor orangeColor];//确定按钮的颜色
    [datepicker show];
}

//-(void)setTimeWithDateStr:(NSString *)dateString andIsOrNotBeginTime:(BOOL)isBegin{
////    ezopen://open.ys7.com/183414608/1.rec?begin=20190509000000&end=20190509235959
//    NSString *urlStr = [self readStringWithKey:EZUIKitUrlStr];
//    if (isBegin) {
//        if ([urlStr rangeOfString:@"begin"].location == NSNotFound && [urlStr rangeOfString:@"begin"].location == NSNotFound) {
//            //无begin与end
//
//        }else if([urlStr rangeOfString:@"begin"].location == NSNotFound && [urlStr rangeOfString:@"begin"].location != NSNotFound){
//            //无begin 有end
//
//        }else{
//            //有begin 有end
//
//        }
//    }
//
//}

@end
