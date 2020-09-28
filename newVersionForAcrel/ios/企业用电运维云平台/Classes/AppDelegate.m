/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

//
//  AppDelegate.m
//  x5
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "AppDelegate.h"
#import "JustepURLProtocol.h"

#import "BGLoginViewController.h"
#import "CustomNavigationController.h"
//#import <AMapFoundationKit/AMapFoundationKit.h>
#import <BMKLocationKit/BMKLocationComponent.h>
#import "QDUIHelper.h"
#import "QDCommonUI.h"
#import "QDTabBarViewController.h"
#import "QDNavigationController.h"
#import "QDUIKitViewController.h"
#import "QDComponentsViewController.h"
#import "QDLabViewController.h"
#import "BGQMHomeViewController.h"
#import "BGQMAlarmViewController.h"
#import "BGQMElectViewController.h"
#import "BGQMUIInspectViewController.h"
#import "BGQMUserViewController.h"
#import "BGQMNewHomeTableViewController.h"
#import <Bugly/Bugly.h>

//#import "WXApi.h"
//#import "WXAuth.h"
#import "NSBundle+Language.h"
#import <CloudPushSDK/CloudPushSDK.h>
#import "BGUIWebViewController.h"
#import "NSString+BGExtension.h"
#import "BGDistributeMessage.h"
// iOS 10 notification
#import <UserNotifications/UserNotifications.h>
#import "LZLPushMessage.h"
#import "YYServiceManager.h"
#import "BGLogFirstViewController.h"
#import "BGLogSecondViewController.h"


#define CLIENT_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define WXAppId @"wx3e0b2d7e2d2bbc62"

BMKMapManager* _mapManager;

static NSString *const EMASAppKey = @"28124642";
static NSString *const EMASAppSecret = @"6a5c22ea980d2687ec851f7cc109d3d2";
//static NSString *const EMASAppKey = @"28138725";
//static NSString *const EMASAppSecret = @"b09811ee7cc07441dc4e999f7b82b16b";

@interface AppDelegate () <UNUserNotificationCenterDelegate>
@property (nonatomic, strong)CLLocationManager *locationManager;
@end

@implementation AppDelegate{
    // iOS 10通知中心
    UNUserNotificationCenter *_notificationCenter;
}

//- (id)init
//{
  /** If you need to do any extra app-specific initialization, you can do it here
   *  -jm
   **/
//  NSHTTPCookieStorage* cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//
//  [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
//
//  int cacheSizeMemory = 8 * 1024 * 1024; // 8MB
//  int cacheSizeDisk = 32 * 1024 * 1024; // 32MB
//#if __has_feature(objc_arc)
//  NSURLCache* sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
//#else
//  NSURLCache* sharedCache = [[[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"] autorelease];
//#endif
//  [NSURLCache setSharedURLCache:sharedCache];
  
//  self = [super init];
//  return self;
//}

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    
    //切换语言
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"myLanguage"] && ![[[NSUserDefaults standardUserDefaults] objectForKey:@"myLanguage"] isEqualToString:@""]) {
        [NSBundle setLanguage:[[NSUserDefaults standardUserDefaults] objectForKey:@"myLanguage"]];
    }

    // QMUIConsole 默认只在 DEBUG 下会显示，作为 Demo，改为不管什么环境都允许显示
//    [QMUIConsole sharedInstance].canShow = NO;
    
    // QD自定义的全局样式渲染
//    [QDCommonUI renderGlobalAppearances];
    
    // 预加载 QQ 表情，避免第一次使用时卡顿
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [QDUIHelper qmuiEmotions];
//    });
   
    // APNs注册，获取deviceToken并上报
    [self registerAPNS:application];
   // 监听推送通道打开动作
    [self listenerOnChannelOpened];
   // 监听推送消息到达
    [self registerMessageReceive];
    
    //配置数据库 升级
    [self reloadRealm];
    // 点击通知将App从关闭状态启动时，将通知打开回执上报
    // [CloudPushSDK handleLaunching:launchOptions];(Deprecated from v1.8.1)
    [CloudPushSDK sendNotificationAck:launchOptions];
    
    //配置bugly上传
    [Bugly startWithAppId:BGBuglyApi];
    //配置微信sdk
//    [WXApi registerApp:WXAppId];
    
    //配置百度地图
    // 每次调用startService开启轨迹服务之前，可以重新设置这些信息。
    BTKServiceOption *basicInfoOption = [[BTKServiceOption alloc] initWithAK:BGBaiduMapApi mcode:[[NSBundle mainBundle] bundleIdentifier] serviceID:BGSERVICEID keepAlive:FALSE];
    [[BTKAction sharedInstance] initInfo:basicInfoOption];
       
    // 初始化定位SDK
    [[BMKLocationAuth sharedInstance] checkPermisionWithKey:BGBaiduMapApi authDelegate:self];
    //要使用百度地图，请先启动BMKMapManager
    _mapManager = [[BMKMapManager alloc] init];
    
    /**
     百度地图SDK所有API均支持百度坐标（BD09）和国测局坐标（GCJ02），用此方法设置您使用的坐标类型.
     默认是BD09（BMK_COORDTYPE_BD09LL）坐标.
     如果需要使用GCJ02坐标，需要设置CoordinateType为：BMK_COORDTYPE_COMMON.
     */
    if ([BMKMapManager setCoordinateTypeUsedInBaiduMapSDK:BMK_COORDTYPE_BD09LL]) {
        DefLog(@"经纬度类型设置成功");
    } else {
        DefLog(@"经纬度类型设置失败");
    }
    //判断定位服务权限是否开通
    [self initCLLocationManager];
    //启动引擎并设置AK并设置delegate
    BOOL result = [_mapManager start:BGBaiduMapApi generalDelegate:self];
    if (!result) {
        DefLog(@"启动引擎失败");
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UserManager *user = [UserManager manager];
    
    if (user.autoLogin) {
        //已登录 获取功能权限「」「」
        __weak __typeof(self)weakSelf = self;
        [NetService bg_getWithTokenWithPath:@"/getMessagePushInfo" params:@{} success:^(id respObjc) {
            DefLog(@"%@",respObjc);
            if ([respObjc[kdata] isKindOfClass:[NSDictionary class]] && [respObjc[kdata] objectForKey:@"messagePushInfo"]) {
                NSDictionary *pushInfo = respObjc[kdata][@"messagePushInfo"];
                if ([pushInfo objectForKey:@"messageIOSKey"] && [pushInfo objectForKey:@"messageIOSSecret"]) {
                    NSString *messageIOSKey = [pushInfo bg_StringForKeyNotNull:@"messageIOSKey"];
                    NSString *messageIOSSecret = [pushInfo bg_StringForKeyNotNull:@"messageIOSSecret"];
                    if (messageIOSKey.length && messageIOSSecret.length) {
                        user.emasAppKey = messageIOSKey;
                        user.emasAppSecret = messageIOSSecret;
                    }
                    // 初始化SDK
                    NSString *uniqueProjectip = GetBaseURL;
                    if (uniqueProjectip) {
                        if([uniqueProjectip containsString:@"https:"]){
                            uniqueProjectip = [uniqueProjectip stringByReplacingOccurrencesOfString:@"https://" withString:@""];
                        }else if ([uniqueProjectip containsString:@"http:"]){
                            uniqueProjectip = [uniqueProjectip stringByReplacingOccurrencesOfString:@"http://" withString:@""];
                        }
                        if ([uniqueProjectip containsString:@":"]) {
                            NSRange range = [uniqueProjectip rangeOfString:@":" options:NSBackwardsSearch];
                            uniqueProjectip = [uniqueProjectip substringToIndex:range.location];
                        }
                    }
                    NSString *aliasId = [NSString stringWithFormat:@"%@-%@",uniqueProjectip,user.bguserId];
                    [weakSelf initCloudPush];
                    [weakSelf addAlias:aliasId];
                }
            }
        } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
            // 失败如果有则补偿初始化SDK
            if (user.emasAppKey && user.emasAppSecret) {
                [weakSelf initCloudPush];
                NSString *uniqueProjectip = GetBaseURL;
                if (uniqueProjectip) {
                    if([uniqueProjectip containsString:@"https:"]){
                        uniqueProjectip = [uniqueProjectip stringByReplacingOccurrencesOfString:@"https://" withString:@""];
                    }else if ([uniqueProjectip containsString:@"http:"]){
                        uniqueProjectip = [uniqueProjectip stringByReplacingOccurrencesOfString:@"http://" withString:@""];
                    }
                    if ([uniqueProjectip containsString:@":"]) {
                        NSRange range = [uniqueProjectip rangeOfString:@":" options:NSBackwardsSearch];
                        uniqueProjectip = [uniqueProjectip substringToIndex:range.location];
                    }
                }
                NSString *aliasId = [NSString stringWithFormat:@"%@-%@",uniqueProjectip,user.bguserId];
                [weakSelf addAlias:aliasId];
            }
        }];
        // 界面
        [self createTabBarController];
        [self getAppBasicConfig];
    }else{
        //设置状态栏颜色
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//        BGLoginViewController *loginVC = [[BGLoginViewController alloc] initWithNibName:@"BGLoginViewController" bundle:nil];
//           UINavigationController *naVC = [[CustomNavigationController alloc] initWithRootViewController:loginVC];
        UserManager *user = [UserManager manager];
        if (user.orderListUrl) {
           BGLogSecondViewController *loginSVC = [[BGLogSecondViewController alloc] init];
           UINavigationController *navi = [[CustomNavigationController alloc] initWithRootViewController:loginSVC];
           self.window.rootViewController = navi;
           [self.window makeKeyAndVisible];
        }else{
            BGLogFirstViewController *loginFVC = [[BGLogFirstViewController alloc] init];
            QMUINavigationController *navi = [[QMUINavigationController alloc] initWithRootViewController:loginFVC];
            self.window.rootViewController = navi;
            [self.window makeKeyAndVisible];
        }
    }
    // 启动动画
//    [self startLaunchingAnimation];
    
  return YES;
}

- (void)addAlias:(NSString *)alias {
    [CloudPushSDK addAlias:alias withCallback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            DefLog(@"别名添加成功,别名：%@",alias);
        } else {
            DefLog(@"别名添加失败，错误: %@", res.error);
        }
    }];
}

#pragma mark - PushAPI 通知
/**
 *    向APNs注册，获取deviceToken用于推送
 *
 *    @param     application
 */
- (void)registerAPNS:(UIApplication *)application {
    float systemVersionNum = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersionNum >= 10.0) {
        // iOS 10 notifications
        _notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
        // 创建category，并注册到通知中心
        [self createCustomNotificationCategory];
        _notificationCenter.delegate = self;
        // 请求推送权限
        [_notificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                // granted
                NSLog(@"User authored notification.");
                // 向APNs注册，获取deviceToken
                dispatch_async(dispatch_get_main_queue(), ^{
                    [application registerForRemoteNotifications];
                });
            } else {
                // not granted
                NSLog(@"User denied notification.");
            }
        }];
    } else if (systemVersionNum >= 8.0) {
        // iOS 8 Notifications
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        [application registerUserNotificationSettings:
         [UIUserNotificationSettings settingsForTypes:
          (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                           categories:nil]];
        [application registerForRemoteNotifications];
#pragma clang diagnostic pop
    } else {
        // iOS < 8 Notifications
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
#pragma clang diagnostic pop
    }
}

/**
 *  创建并注册通知category(iOS 10+)
 */
- (void)createCustomNotificationCategory {
    // 自定义`action1`和`action2`
    UNNotificationAction *action1 = [UNNotificationAction actionWithIdentifier:@"action1" title:@"test1" options: UNNotificationActionOptionNone];
    UNNotificationAction *action2 = [UNNotificationAction actionWithIdentifier:@"action2" title:@"test2" options: UNNotificationActionOptionNone];
    // 创建id为`test_category`的category，并注册两个action到category
    // UNNotificationCategoryOptionCustomDismissAction表明可以触发通知的dismiss回调
    UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"test_category" actions:@[action1, action2] intentIdentifiers:@[] options:
                                        UNNotificationCategoryOptionCustomDismissAction];
    // 注册category到通知中心
    [_notificationCenter setNotificationCategories:[NSSet setWithObjects:category, nil]];
}

/**
 *  处理iOS 10通知(iOS 10+)
 */
- (void)handleiOS10Notification:(UNNotification *)notification {
    UNNotificationRequest *request = notification.request;
    UNNotificationContent *content = request.content;
    NSDictionary *userInfo = content.userInfo;
    // 通知时间
    NSDate *noticeDate = notification.date;
    // 标题
    NSString *title = content.title;
    // 副标题
    NSString *subtitle = content.subtitle;
    // 内容
    NSString *body = content.body;
    // 角标
    int badge = [content.badge intValue];
    // 取得通知自定义字段内容，例：获取key为"Extras"的内容
    NSString *extras = [userInfo valueForKey:@"Extras"];
    // 通知角标数清0
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // 同步角标数到服务端
    [self syncBadgeNum:0];
    // 取得通知自定义字段内容，例：获取key为"Extras"的内容
    if (userInfo) {
        [self pushViewControllerWithType:userInfo];
    }
    // 通知打开回执上报
    [CloudPushSDK sendNotificationAck:userInfo];
    
    NSLog(@"Notification, date: %@, title: %@, subtitle: %@, body: %@, badge: %d, extras: %@.", noticeDate, title, subtitle, body, badge, extras);
}

-(void)pushViewControllerWithType:(NSDictionary *)userInfo{
    DefLog(@"pushType:%@",pushType);
    //现场报警
     NSString *pushType = [userInfo bg_StringForKeyNotNull:@"pushType"];
    if([pushType isEqualToString:@"alarm"]){
        //现场报警
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        UITabBarController *tabViewController = (UITabBarController *) appDelegate.window.rootViewController;
        //跳转到报警页面
        [tabViewController setSelectedIndex:1];
        //
        NSString *fAlarmeventlogid = [userInfo bg_StringForKeyNotNull:@"fAlarmeventlogid"];
        if (fAlarmeventlogid) {
            [self pushNoYYWebview:fAlarmeventlogid andHtmlName:@"alarmDetailView"];
        }
//        [self pushNoYYWebview:@"2020052014050488767568712" andHtmlName:@"alarmDetailView"];
    }else if ([pushType isEqualToString:@"communication"]){
        //通讯状态
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        UITabBarController *tabViewController = (UITabBarController *) appDelegate.window.rootViewController;
        //跳转到报警
        [tabViewController setSelectedIndex:1];

        NSString *fAlarmeventlogid = [userInfo bg_StringForKeyNotNull:@"fAlarmeventlogid"];
        if (fAlarmeventlogid) {
            [self pushNoYYWebview:@"2" andHtmlName:@"alarmsDetailNew"];
        }
    }else if ([pushType isEqualToString:@"work"]){
        NSArray *homeList;
        UserManager *user = [UserManager manager];
        NSString *versionURL = [user.rootMenuData objectForKeyNotNull:@"H5_2"];
        NSArray *uiArray = user.rootMenuData[@"rootMenu"];
        for (NSDictionary *homeDic in uiArray) {
            NSString *fCode = [NSString changgeNonulWithString:homeDic[@"fCode"]];
            if ([fCode isEqualToString:@"homePage"]) {
                homeList = homeDic[@"nodes"];
            }
        }
        NSString *isOrder = [NSString changgeNonulWithString:userInfo[@"isOrder"]];
        if (isOrder && [isOrder isEqualToString:@"1"]) {
            if (homeList.count>0) {
                //357 抢单
                NSString *taskid = [userInfo bg_StringForKeyNotNull:@"fTaskid"];
                if(taskid){
                   NSString *fAction;
                   NSString *fFunctionurl;
                   for (NSDictionary *nodeDic in homeList) {
                       if ([nodeDic[@"fCode"] isEqualToString:@"357"]) {
                           fAction = [NSString changgeNonulWithString:nodeDic[@"fActionurl"]];
                           fFunctionurl = [NSString changgeNonulWithString:nodeDic[@"fFunctionfield"]];
                       }
                   }
                   if (fFunctionurl.length>0) {
                      BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
                              NSString *filePath = [[NSBundle mainBundle] pathForResource:@"RobBillLocation" ofType:@"html" inDirectory:@"aDevices"];
                      nomWebView.isUseOnline = NO;
                      nomWebView.localUrlString = filePath;
                      nomWebView.showWebType = showWebTypeWithPush;
                      nomWebView.pathParamStr = taskid;
                      [[self findCurrentViewController].navigationController pushViewController:nomWebView animated:YES];
                   }else{
                       BGUIWebViewController *urlWebView = [[BGUIWebViewController alloc] init];
                       urlWebView.isUseOnline = YES;
                       if (versionURL.length>0) {
                           NSString *urlstring = [NSString stringWithFormat:@"/%@/",versionURL];
                           NSString *str = [GetBaseURL stringByAppendingString:urlstring];
                           NSString *urlStr = [str stringByAppendingString:@"RobBillLocation.html"];
                           urlWebView.onlineUrlString = urlStr;
                           urlWebView.showWebType = showWebTypeWithPush;
                           urlWebView.pathParamStr = taskid;
                          [[self findCurrentViewController].navigationController pushViewController:urlWebView animated:YES];
                        }
                   }
                }else{
                    NSString *fAction;
                                NSString *fFunctionurl;
                                for (NSDictionary *nodeDic in homeList) {
                                    if ([nodeDic[@"fCode"] isEqualToString:@"357"]) {
                                        fAction = [NSString changgeNonulWithString:nodeDic[@"fActionurl"]];
                                        fFunctionurl = [NSString changgeNonulWithString:nodeDic[@"fFunctionfield"]];
                                    }
                                }
                                if (fFunctionurl.length>0) {
                                   BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
                                           NSString *filePath = [[NSBundle mainBundle] pathForResource:@"RobBillRecord" ofType:@"html" inDirectory:@"aDevices"];
                                   nomWebView.isUseOnline = NO;
                                   nomWebView.localUrlString = filePath;
                                   nomWebView.showWebType = showWebTypeDevice;
                                   //        self.tabBarController.hidesBottomBarWhenPushed = YES;
                    //               [self.navigationController pushViewController:nomWebView animated:YES];
                                     [[self findCurrentViewController].navigationController pushViewController:nomWebView animated:YES];
                                }else{
                                    BGUIWebViewController *urlWebView = [[BGUIWebViewController alloc] init];
                                    urlWebView.isUseOnline = YES;
                                    if (versionURL.length>0) {
                                        NSString *urlstring = [NSString stringWithFormat:@"/%@/",versionURL];
                                        NSString *str = [GetBaseURL stringByAppendingString:urlstring];
                                        NSString *urlStr = [str stringByAppendingString:fAction];
                                        urlWebView.onlineUrlString = urlStr;
                                        urlWebView.showWebType = showWebTypeDevice;
                                       [[self findCurrentViewController].navigationController pushViewController:urlWebView animated:YES];
                                     }
                                }
                }
            }
        }else{
            if (homeList.count>0) {
                //347 待办事项
                NSString *taskid = [userInfo bg_StringForKeyNotNull:@"fTaskid"];
                if(taskid){
                   NSString *fAction;
                   NSString *fFunctionurl;
                   for (NSDictionary *nodeDic in homeList) {
                       if ([nodeDic[@"fCode"] isEqualToString:@"347"]) {
                           fAction = [NSString changgeNonulWithString:nodeDic[@"fActionurl"]];
                           fFunctionurl = [NSString changgeNonulWithString:nodeDic[@"fFunctionfield"]];
                       }
                   }
                   if (fFunctionurl.length>0) {
                      BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
                              NSString *filePath = [[NSBundle mainBundle] pathForResource:@"missionDetail" ofType:@"html" inDirectory:@"aDevices"];
                      nomWebView.isUseOnline = NO;
                      nomWebView.localUrlString = filePath;
                      nomWebView.showWebType = showWebTypeWithPush;
                      nomWebView.pathParamStr = taskid;
                      [[self findCurrentViewController].navigationController pushViewController:nomWebView animated:YES];
                   }else{
                       BGUIWebViewController *urlWebView = [[BGUIWebViewController alloc] init];
                       urlWebView.isUseOnline = YES;
                       if (versionURL.length>0) {
                           NSString *urlstring = [NSString stringWithFormat:@"/%@/",versionURL];
                           NSString *str = [GetBaseURL stringByAppendingString:urlstring];
                           NSString *urlStr = [str stringByAppendingString:@"missionDetail.html"];
                           urlWebView.onlineUrlString = urlStr;
                           urlWebView.showWebType = showWebTypeWithPush;
                           urlWebView.pathParamStr = taskid;
                          [[self findCurrentViewController].navigationController pushViewController:urlWebView animated:YES];
                        }
                   }
                }else{
                    NSString *fAction;
                                NSString *fFunctionurl;
                                for (NSDictionary *nodeDic in homeList) {
                                    if ([nodeDic[@"fCode"] isEqualToString:@"347"]) {
                                        fAction = [NSString changgeNonulWithString:nodeDic[@"fActionurl"]];
                                        fFunctionurl = [NSString changgeNonulWithString:nodeDic[@"fFunctionfield"]];
                                    }
                                }
                                if (fFunctionurl.length>0) {
                                   BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
                                           NSString *filePath = [[NSBundle mainBundle] pathForResource:@"todoItems" ofType:@"html" inDirectory:@"aDevices"];
                                   nomWebView.isUseOnline = NO;
                                   nomWebView.localUrlString = filePath;
                                   nomWebView.showWebType = showWebTypeDevice;
                                   //        self.tabBarController.hidesBottomBarWhenPushed = YES;
                    //               [self.navigationController pushViewController:nomWebView animated:YES];
                                     [[self findCurrentViewController].navigationController pushViewController:nomWebView animated:YES];
                                }else{
                                    BGUIWebViewController *urlWebView = [[BGUIWebViewController alloc] init];
                                    urlWebView.isUseOnline = YES;
                                    if (versionURL.length>0) {
                                        NSString *urlstring = [NSString stringWithFormat:@"/%@/",versionURL];
                                        NSString *str = [GetBaseURL stringByAppendingString:urlstring];
                                        NSString *urlStr = [str stringByAppendingString:fAction];
                                        urlWebView.onlineUrlString = urlStr;
                                        urlWebView.showWebType = showWebTypeDevice;
                                       [[self findCurrentViewController].navigationController pushViewController:urlWebView animated:YES];
                                     }
                                }
                }
            }
        }
        
    }
}

- (UIViewController *)findCurrentViewController
{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    UIViewController *topViewController = [window rootViewController];
    
    while (true) {
        
        if (topViewController.presentedViewController) {
            
            topViewController = topViewController.presentedViewController;
            
        } else if ([topViewController isKindOfClass:[UINavigationController class]] && [(UINavigationController*)topViewController topViewController]) {
            
            topViewController = [(UINavigationController *)topViewController topViewController];
            
        } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            
            UITabBarController *tab = (UITabBarController *)topViewController;
            topViewController = tab.selectedViewController;
            
        } else {
            break;
        }
    }
    return topViewController;
}

#pragma mark - pushNoYYWebView
-(void)pushNoYYWebview:(NSString *)jumpid andHtmlName:(NSString *)htmlName{
    UserManager *user = [UserManager manager];
    NSArray *uiArray = user.rootMenuData[@"rootMenu"];
     for (NSDictionary *dic in uiArray) {
            NSString *fCode = [NSString changgeNonulWithString:dic[@"fCode"]];
            if ([fCode isEqualToString:@"alarmPage"]) {
               BGUIWebViewController *componentViewController = [[BGUIWebViewController alloc] init];
               NSString *fFunctionfield = [NSString changgeNonulWithString:dic[@"fFunctionfield"]];
               if (fFunctionfield.length>0) {
                   NSString *filePath = [[NSBundle mainBundle] pathForResource:htmlName ofType:@"html" inDirectory:@"aDevices"];
                   componentViewController.isUseOnline = NO;
                   componentViewController.menuId = @"342";
                   componentViewController.localUrlString = filePath;
                   componentViewController.showWebType = showWebTypeWithPushNoYY;
                   componentViewController.pathParamStr = jumpid;
                   [[self findCurrentViewController].navigationController pushViewController:componentViewController animated:YES];
               }else{
                   componentViewController.isUseOnline = YES;
                   UserManager *user = [UserManager manager];
                   //外链H5
                   if (user.rootMenuData) {
                      NSString *versionURL = [user.rootMenuData objectForKeyNotNull:@"H5_2"];
                      componentViewController.showWebType = showWebTypeWithPushNoYY;
//                          componentViewController.menuId = [NSString changgeNonulWithString:dic[@"fMenuid"]];
                      NSString *urlstring = [NSString stringWithFormat:@"/%@/",versionURL];
                      NSString *str = [GetBaseURL stringByAppendingString:urlstring];
                      NSString *urlStr = [str stringByAppendingString:[NSString stringWithFormat:@"%@.html",htmlName]];
                      componentViewController.menuId = @"342";
                      componentViewController.onlineUrlString = urlStr;
//                           componentViewController.isFromAlarm = @"1";
                        componentViewController.pathParamStr = jumpid;
//                          componentViewController .hidesBottomBarWhenPushed = NO;
                      [[self findCurrentViewController].navigationController pushViewController:componentViewController animated:YES];
                   }
               }
            }
        }
}


/**
 *  App处于前台时收到通知(iOS 10+)
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSLog(@"Receive a notification in foregound.");
    // 处理iOS 10通知，并上报通知打开回执
//    [self handleiOS10Notification:notification];
    // 通知不弹出
    completionHandler(UNNotificationPresentationOptionNone);
    // 通知弹出，且带有声音、内容和角标
    //completionHandler(UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge);
}

/**
 *  触发通知动作时回调，比如点击、删除通知和点击自定义action(iOS 10+)
 */

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSString *userAction = response.actionIdentifier;
    // 点击通知打开
    if ([userAction isEqualToString:UNNotificationDefaultActionIdentifier]) {
        NSLog(@"User opened the notification.");
        // 处理iOS 10通知，并上报通知打开回执
        [self handleiOS10Notification:response.notification];
    }
    // 通知dismiss，category创建时传入UNNotificationCategoryOptionCustomDismissAction才可以触发
    if ([userAction isEqualToString:UNNotificationDismissActionIdentifier]) {
        NSLog(@"User dismissed the notification.");
    }
    NSString *customAction1 = @"action1";
    NSString *customAction2 = @"action2";
    // 点击用户自定义Action1
    if ([userAction isEqualToString:customAction1]) {
        NSLog(@"User custom action1.");
    }
    
    // 点击用户自定义Action2
    if ([userAction isEqualToString:customAction2]) {
        NSLog(@"User custom action2.");
    }
    completionHandler();
}

- (void)initCloudPush {
    // 正式上线建议关闭
//    [CloudPushSDK turnOnDebug];
    // SDK初始化，手动输出appKey和appSecret
    UserManager *user = [UserManager manager];
//    user.emasAppSecret = EMASAppSecret;
//    user.emasAppKey = EMASAppKey;
    if (user.emasAppKey.length && user.emasAppSecret.length) {
        [CloudPushSDK asyncInit:user.emasAppKey appSecret:user.emasAppSecret callback:^(CloudPushCallbackResult *res) {
            if (res.success) {
                NSLog(@"Push SDK init success, deviceId: %@. ", [CloudPushSDK getDeviceId]);
            } else {
                NSLog(@"Push SDK init failed, error: %@", res.error);
            }
        }];
    }
    
    
    // SDK初始化，无需输入配置信息
    // 请从控制台下载AliyunEmasServices-Info.plist配置文件，并正确拖入工程
//    [CloudPushSDK autoInit:^(CloudPushCallbackResult *res) {
//        if (res.success) {
//            NSLog(@"Push SDK init success, deviceId: %@.", [CloudPushSDK getDeviceId]);
//        } else {
//            NSLog(@"Push SDK init failed, error: %@", res.error);
//        }
//    }];
}

/**
 *  主动获取设备通知是否授权(iOS 10+)
 */
- (void)getNotificationSettingStatus {
    [_notificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
            NSLog(@"User authed.");
        } else {
            NSLog(@"User denied.");
        }
    }];
}

/*
 *  APNs注册成功回调，将返回的deviceToken上传到CloudPush服务器
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Upload deviceToken to CloudPush server.");
    [CloudPushSDK registerDevice:deviceToken withCallback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            NSLog(@"Register deviceToken success, deviceToken: %@", [CloudPushSDK getApnsDeviceToken]);
        } else {
            NSLog(@"Register deviceToken failed, error: %@", res.error);
        }
    }];
}
/*
 *  APNs注册失败回调
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError %@", error);
}

#pragma mark Receive Message 消息
/**
 *    注册推送通道打开监听
 */
- (void)listenerOnChannelOpened {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onChannelOpened:)
                                                 name:@"CCPDidChannelConnectedSuccess"
                                               object:nil];
}

/**
 *    推送通道打开回调
 *
 *    @param     notification
 */
- (void)onChannelOpened:(NSNotification *)notification {
//    [MsgToolBox showAlert:@"温馨提示" content:@"消息通道建立成功"];
    NSLog(@"消息通道建立成功");
}

/**
 *    @brief    注册推送消息到来监听
 */
- (void)registerMessageReceive {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onMessageReceived:)
                                                 name:@"CCPDidReceiveMessageNotification"
                                               object:nil];
}

/**
 *    处理到来推送消息
 *
 *    @param     notification
 */
- (void)onMessageReceived:(NSNotification *)notification {
    NSLog(@"Receive one message!");
    
    CCPSysMessage *message = [notification object];
    NSString *title = [[NSString alloc] initWithData:message.title encoding:NSUTF8StringEncoding];
    NSString *body = [[NSString alloc] initWithData:message.body encoding:NSUTF8StringEncoding];
    NSLog(@"Receive message title: %@, content: %@.", title, body);
    
    LZLPushMessage *tempVO = [[LZLPushMessage alloc] init];
    tempVO.messageContent = body;
    tempVO.messageTitle = title;
    tempVO.isRead = 0;
    
    if(![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(tempVO.messageContent != nil) {
                [self insertPushMessage:tempVO];
            }
        });
    } else {
        if(tempVO.messageContent != nil) {
            [self insertPushMessage:tempVO];
        }
    }
}

- (void)insertPushMessage:(LZLPushMessage *)model {
//    tempVO.messageContent
//    {"pushType":"alarm","fAlarmeventlogid":"2020060815025061968996393"}
//
//    tempVO.messageTitle
//    报警恢复
    //任务未读数
    [BGDistributeMessage distributeMessage:model];
//    PushMessageDAO *dao = [[PushMessageDAO alloc] init];
//    [dao insert:model];
}

/* 同步通知角标数到服务端 */
- (void)syncBadgeNum:(NSUInteger)badgeNum {
    [CloudPushSDK syncBadgeNum:badgeNum withCallback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            NSLog(@"Sync badge num: [%lu] success.", (unsigned long)badgeNum);
        } else {
            NSLog(@"Sync badge num: [%lu] failed, error: %@", (unsigned long)badgeNum, res.error);
        }
    }];
}

#pragma mark Notification Open
/*
 *  App处于启动状态时，通知打开回调
 */
- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo {
    NSLog(@"Receive one notification.");
    // 取得APNS通知内容
    NSDictionary *aps = [userInfo valueForKey:@"aps"];
    // 内容
    NSString *content = [aps valueForKey:@"alert"];
    // badge数量
    NSInteger badge = [[aps valueForKey:@"badge"] integerValue];
    // 播放声音
    NSString *sound = [aps valueForKey:@"sound"];
    // 取得通知自定义字段内容，例：获取key为"Extras"的内容
    NSString *Extras = [userInfo valueForKey:@"Extras"]; //服务端中Extras字段，key是自己定义的
    NSLog(@"content = [%@], badge = [%ld], sound = [%@], Extras = [%@]", content, (long)badge, sound, Extras);
    // iOS badge 清0
    application.applicationIconBadgeNumber = 0;
    // 同步通知角标数到服务端
    [self syncBadgeNum:0];
   
    // 通知打开回执上报
    // [CloudPushSDK handleReceiveRemoteNotification:userInfo];(Deprecated from v1.8.1)
    [CloudPushSDK sendNotificationAck:userInfo];
}

#pragma mark - AMapAPI
- (void)registerAMapAPIKey{
//    NSString *APIKey = @"2344c9b2271cd4a26f1b86cb4deee2cb";
//    if ([APIKey length] == 0){
//        NSString *reason = [NSString stringWithFormat:@"apiKey为空，请检查key是否正确设置。"];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:reason delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//    }
//    [AMapServices sharedServices].apiKey = (NSString *)APIKey;
}

#pragma mark - BaiduMapAPI
- (void)registerBaiduMapApi{
    // 要使用百度地图，请先启动BaiduMapManager
//    _mapManager = [[BMKMapManager alloc]init];
//    [[BMKLocationAuth sharedInstance] checkPermisionWithKey:BGBaiduMapApi authDelegate:self];
//    BOOL ret = [_mapManager start:BGBaiduMapApi generalDelegate:self];
//    if (!ret) {
//        NSLog(@"manager start failed!");
//    }
}

- (void)createTabBarController {
    QDTabBarViewController *tabBarViewController = [[QDTabBarViewController alloc] init];
    self.window.rootViewController = tabBarViewController;
    [self.window makeKeyAndVisible];
}


//闪屏切换启动页
- (void)startLaunchingAnimation {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    UIViewController *viewController = [[UIStoryboard storyboardWithName:@"CDVLaunchScreen" bundle:nil] instantiateViewControllerWithIdentifier:@"LaunchScreen"];
    UIView *launchScreenView = viewController.view;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"uspicture"]];
    launchScreenView.bounds = window.bounds;
    imageView.frame = launchScreenView.bounds;
    [launchScreenView addSubview:imageView];
//    UIView *launchScreenView = [[NSBundle mainBundle] loadNibNamed:@"CDVLaunchScreen" owner:self options:nil].firstObject;
//    launchScreenView.bounds = window.bounds;
    [window addSubview:launchScreenView];
    
    UIImageView *backgroundImageView = launchScreenView.subviews[0];
    backgroundImageView.clipsToBounds = YES;
    
    UIImageView *logoImageView = launchScreenView.subviews[1];
    UILabel *copyrightLabel = launchScreenView.subviews.lastObject;
    
    UIView *maskView = [[UIView alloc] initWithFrame:launchScreenView.bounds];
    maskView.backgroundColor = UIColorWhite;
    [launchScreenView insertSubview:maskView belowSubview:backgroundImageView];
    
    [launchScreenView layoutIfNeeded];
    
    [launchScreenView.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.identifier isEqualToString:@"bottomAlign"]) {
            obj.active = NO;
            [NSLayoutConstraint constraintWithItem:backgroundImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:launchScreenView attribute:NSLayoutAttributeTop multiplier:1 constant:NavigationContentTop].active = YES;
            *stop = YES;
        }
    }];
    
//    [UIView animateWithDuration:.15 delay:0.9 options:QMUIViewAnimationOptionsCurveOut animations:^{
//        [launchScreenView layoutIfNeeded];
//        logoImageView.alpha = 0.0;
//        copyrightLabel.alpha = 0;
//    } completion:nil];
    //展示多久
    [UIView animateWithDuration:2.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        maskView.alpha = 0;
        backgroundImageView.alpha = 0;
    } completion:^(BOOL finished) {
        [launchScreenView removeFromSuperview];
    }];
}

#pragma mark - application



//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
//    return [WXAUTH handleOpenURL:url];
//}

//- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    
//    return [WXAUTH handleOpenURL:url];
//}

//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
//    return [WXAUTH handleOpenURL:url];
//}

//- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window {
//    return UIInterfaceOrientationMaskPortrait;
//}

//程序将被杀死
-(void)applicationWillTerminate:(UIApplication *)application{
    if ([YYServiceManager defaultManager].isServiceStarted){
        [YYServiceManager defaultManager].isGatherStarted = NO;
        // 停止采集
        [[YYServiceManager defaultManager] stopGather];
        //传给后台
        [self generateTrackRecords];
    }
}
-(void)generateTrackRecords{
    NSMutableDictionary *mutparam = [NSMutableDictionary new];
    NSString *Projectip = GetBaseURL;
    if([Projectip containsString:@"http:"]){
        Projectip = [Projectip stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    }else if ([Projectip containsString:@"https:"]){
        Projectip = [Projectip stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    }
    [mutparam setObject:Projectip forKey:@"fProjectip"];
     
    UserManager *user = [UserManager manager];
    NSString *startTime = user.startTJtime;
    if (startTime.length) {
         [mutparam setObject:startTime forKey:@"fTrackstarttime"];
    }
    NSString *taskNumber = user.taskID;
    if (taskNumber && taskNumber.length) {
        [mutparam setObject:taskNumber forKey:@"fTasknumber"];
    }
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
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
    //阿里云特殊接口 http://www.acrelcloud.cn
    [NetService bg_getWithTestPath:@"sys/generateTrackRecords" params:mutparam success:^(id respObjc) {
        [UserManager manager].startTJtime = @"";
        
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
        [UserManager manager].startTJtime = @"";
       
    }];
    
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // 实现如下代码，才能使程序处于后台时被杀死，调用applicationWillTerminate:方法
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(){}];
}

//-(BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler{
//
//}


#pragma mark - Realm

//数据迁移，添加数据库迁移方法，数据库数据改变时增加版本号
-(void)reloadRealm{
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    // 设置新的架构版本。这个版本号必须高于之前所用的版本号（如果您之前从未设置过架构版本，那么这个版本号设置为 0）
    config.schemaVersion = 3;
    
    // 设置闭包，这个闭包将会在打开低于上面所设置版本号的 Realm 数据库的时候被自动调用
    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        // 目前我们还未进行数据迁移，因此 oldSchemaVersion == 0
        if (oldSchemaVersion < 1) {
            // 什么都不要做！Realm 会自行检测新增和需要移除的属性，然后自动更新硬盘上的数据库架构
        }
    };
    
    // 告诉 Realm 为默认的 Realm 数据库使用这个新的配置对象
    [RLMRealmConfiguration setDefaultConfiguration:config];
    // 现在我们已经告诉了 Realm 如何处理架构的变化，打开文件之后将会自动执行迁移
    [RLMRealm defaultRealm];
}

-(void)applicationDidBecomeActive:(UIApplication *)application {
    // 每次进入应用时将角标清零
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}


#pragma mark - BMKGeneralDelegate
-(void)onGetNetworkState:(int)iError {
    if (0 == iError) {
        DefLog(@"联网成功");
    } else{
        DefLog(@"onGetNetworkState %d",iError);
    }
}

- (void)onGetPermissionState:(int)iError {
    if (0 == iError) {
        DefLog(@"授权成功");
    } else {
        DefLog(@"onGetPermissionState %d",iError);
    }
}


-(void)getAppBasicConfig{
    __weak __typeof(self)weakSelf = self;
    [NetService bg_getWithTokenWithPathAndNoTips:@"/getAppBasicConfig" params:@{} success:^(id respObjc) {
        if(!respObjc){
            return ;
        }
        UserManager *user = [UserManager manager];
        user.versionURLForEnergy = respObjc[kdata][@"versionURL3"];
        NSDictionary *datadic = respObjc[kdata];
        NSString *newToken = [NSString changgeNonulWithString:datadic[@"newToken"]];
        if (newToken && newToken.length>0) {
            user.token = newToken;
        }
        //能耗管理
        NSDictionary *partyInfo = respObjc[kdata][@"partyUserInfo"];
        if (partyInfo) {
            NSDictionary *energy = partyInfo[@"energy"];
            if (energy) {
                NSString *dns = [energy objectForKeyNotNull:@"dns"];
                NSString *accountNum = [energy objectForKeyNotNull:@"accountNum"];
                NSString *password = [energy objectForKeyNotNull:@"password"];
                user.energyDns = dns;
                user.energyPassword = password;
                user.energyAccountNum = accountNum;
            }
        }
        //配置百度鹰眼轨迹
        NSDictionary *trajectory = respObjc[kdata][@"trajectoryConfig"];
        if (trajectory) {
            user.yytjBaiduDic = trajectory;
            NSString *isOpenBaidu = [NSString changgeNonulWithString:trajectory[@"tjIsUsing"]];
            if ([isOpenBaidu isEqualToString:@"1"]) {
                user.isOpenTjBaidu = YES;
            }else{
                user.isOpenTjBaidu = NO;
            }
        }
        NSString *verStr = [NSString changgeNonulWithString:respObjc[kdata][@"webAPIInfo"][@"fVersion"]];
       if (verStr && verStr.length) {
           user.versionNo = verStr;
       }
         NSString *sizeStr = [weakSelf folderSize];
        if (![sizeStr isEqualToString:@"0.0KB"]) {
             [weakSelf clearCache];
         }
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
        
    }];
}
-(void)clearCache{
    //===============清除缓存==============
    //获取路径
    NSString*cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES)objectAtIndex:0];
    
    //返回路径中的文件数组
    NSArray*files = [[NSFileManager defaultManager]subpathsAtPath:cachePath];
    
    DefLog(@"文件数：%ld",[files count]);
    for(NSString *p in files){
        NSError*error;
        
        NSString*path = [cachePath stringByAppendingString:[NSString stringWithFormat:@"/%@",p]];
        
        if([[NSFileManager defaultManager]fileExistsAtPath:path])
        {
            BOOL isRemove = [[NSFileManager defaultManager]removeItemAtPath:path error:&error];
            if(isRemove) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"postSucceed" object:nil userInfo:nil];
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    // 需要在主线程执行的代码
//                    [MBProgressHUD showSuccess:@"清除成功"];
//                });
                
                //这里发送一个通知给外界，外界接收通知，可以做一些操作（比如UIAlertViewController）
            }else{
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    // 需要在主线程执行的代码
//                    [MBProgressHUD showError:@"清除失败"];
//                });
               
            }
        }
    }
}

// 缓存大小
- (NSString *)folderSize{
    CGFloat folderSize = 0.0;
    //获取路径
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES)firstObject];
    
    //获取所有文件的数组
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachePath];
    
    DefLog(@"文件数：%ld",files.count);
    
    for(NSString *path in files) {
        
        NSString*filePath = [cachePath stringByAppendingString:[NSString stringWithFormat:@"/%@",path]];
        
        //累加
        folderSize += [[NSFileManager defaultManager]attributesOfItemAtPath:filePath error:nil].fileSize;
    }
    NSString *sizeStr;
    CGFloat size = folderSize / (1024 *1024);
    if (size<1) {
        CGFloat kbSize = folderSize/1024;
        if (kbSize < 0.2) {
            sizeStr = @"0.0KB";
        }else{
            sizeStr = [NSString stringWithFormat:@"%.1fKB",kbSize];
        }
    }else{
        sizeStr = [NSString stringWithFormat:@"%.1fMB",size];
    }
    return sizeStr;
}

- (void)initCLLocationManager
{
    BOOL enable=[CLLocationManager locationServicesEnabled];
    NSInteger status=[CLLocationManager authorizationStatus];
    if(!enable || status<3)
    {
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8)
        {
            self.locationManager = [[CLLocationManager alloc] init];
            if ([self.locationManager respondsToSelector:@selector(allowsBackgroundLocationUpdates)]) {
                self.locationManager.allowsBackgroundLocationUpdates = YES;
            }
            [self.locationManager requestAlwaysAuthorization];
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
}


- (BOOL)shouldAutorotate{
    if(isPad){
        return NO;
    }else{
        return YES;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if(isPad){
        return UIInterfaceOrientationMaskPortrait;
    }else{
        return UIInterfaceOrientationMaskAll;
    }
}
 
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)nowWindow {
    if(isPad){
           return UIInterfaceOrientationMaskPortrait;
       }else{
           return UIInterfaceOrientationMaskAll;
       }
}
@end
