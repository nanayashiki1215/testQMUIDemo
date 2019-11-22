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
#import "BGQMloginViewController.h"
#import "BGQMHomeViewController.h"
#import "BGQMAlarmViewController.h"
#import "BGQMElectViewController.h"
#import "BGQMUIInspectViewController.h"
#import "BGQMUserViewController.h"
#import "BGQMNewHomeTableViewController.h"
#import <Bugly/Bugly.h>
#import "WXApi.h"
#import "WXAuth.h"
#import "NSBundle+Language.h"
#import <CloudPushSDK/CloudPushSDK.h>
#import "BGUIWebViewController.h"
// iOS 10 notification
#import <UserNotifications/UserNotifications.h>
#import "LZLPushMessage.h"

#define CLIENT_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define WXAppId @"wx3e0b2d7e2d2bbc62"

BMKMapManager* _mapManager;

static NSString *const EMASAppKey = @"28124642";
static NSString *const EMASAppSecret = @"6a5c22ea980d2687ec851f7cc109d3d2";
//static NSString *const EMASAppKey = @"28138725";
//static NSString *const EMASAppSecret = @"b09811ee7cc07441dc4e999f7b82b16b";

@interface AppDelegate () <UNUserNotificationCenterDelegate>

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
    //self.viewController = [[MainViewController alloc] init];
    //return [super application:application didFinishLaunchingWithOptions:launchOptions];
  //
//  if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"clientVersion"] isEqualToString:CLIENT_VERSION]) {
//    //
//  }
//  else{
//    //
//    [[NSUserDefaults standardUserDefaults] setObject:CLIENT_VERSION forKey:@"clientVersion"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString* libPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
//    NSString* libPathNoSync = [libPath stringByAppendingPathComponent:@"NoCloud"];
//    NSString* localURI = [libPathNoSync stringByAppendingPathComponent:@"www"];
//    NSString *bakURI = [libPathNoSync stringByAppendingPathComponent:@"www_bak"];
//    if([fileManager fileExistsAtPath:localURI]){
//      if ([fileManager fileExistsAtPath:bakURI]) {
//        [fileManager removeItemAtPath:bakURI error:nil];
//      }
//      [fileManager moveItemAtPath:localURI toPath:bakURI error:nil];
//      NSLog(@"%@%@",localURI,bakURI);
//    }
//  }
//  CGRect screenBounds = [[UIScreen mainScreen] bounds];
//    //注册高德地图服务
//    [self registerAMapAPIKey];
//    //注册百度地图服务
//    [self registerBaiduMapApi];
//#if __has_feature(objc_arc)
//  self.window = [[UIWindow alloc] initWithFrame:screenBounds];
//#else
//  self.window = [[[UIWindow alloc] initWithFrame:screenBounds] autorelease];
//#endif
//  self.window.autoresizesSubviews = YES;
    
    //切换语言
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"myLanguage"] && ![[[NSUserDefaults standardUserDefaults] objectForKey:@"myLanguage"] isEqualToString:@""]) {
        [NSBundle setLanguage:[[NSUserDefaults standardUserDefaults] objectForKey:@"myLanguage"]];
    }

    // QMUIConsole 默认只在 DEBUG 下会显示，作为 Demo，改为不管什么环境都允许显示
    [QMUIConsole sharedInstance].canShow = YES;
    
    // QD自定义的全局样式渲染
    [QDCommonUI renderGlobalAppearances];
    
    // 预加载 QQ 表情，避免第一次使用时卡顿
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [QDUIHelper qmuiEmotions];
//    });
    
   
    // APNs注册，获取deviceToken并上报
    [self registerAPNS:application];
    // 初始化SDK
    [self initCloudPush];
    // 监听推送通道打开动作
    [self listenerOnChannelOpened];
    // 监听推送消息到达
    [self registerMessageReceive];
    
    //数据库升级
    [self reloadRealm];
    // 点击通知将App从关闭状态启动时，将通知打开回执上报
    // [CloudPushSDK handleLaunching:launchOptions];(Deprecated from v1.8.1)
    [CloudPushSDK sendNotificationAck:launchOptions];
    
    //配置bugly上传
    [Bugly startWithAppId:BGBuglyApi];
    //配置微信sdk
    [WXApi registerApp:WXAppId];
    //配置百度地图
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
    
    //启动引擎并设置AK并设置delegate
    BOOL result = [_mapManager start:BGBaiduMapApi generalDelegate:self];
    if (!result) {
        DefLog(@"启动引擎失败");
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UserManager *user = [UserManager manager];
    
    if (user.autoLogin) {
        //获取功能权限
        // 界面
        [self createTabBarController];
        
    }else{
//        BGQMloginViewController *loginVC = [[BGQMloginViewController alloc] init];
        //设置状态栏颜色
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        BGLoginViewController *loginVC = [[BGLoginViewController alloc] initWithNibName:@"BGLoginViewController" bundle:nil];
//           UINavigationController *naVC = [[CustomNavigationController alloc] initWithRootViewController:loginVC];
        self.window.rootViewController = loginVC;
        [self.window makeKeyAndVisible];
    }
    // 启动动画
//    [self startLaunchingAnimation];
//   BGLoginViewController *loginVC = [[BGLoginViewController alloc] initWithNibName:@"BGLoginViewController" bundle:nil];
//   UINavigationController *naVC = [[CustomNavigationController alloc] initWithRootViewController:loginVC];
//   self.window.rootViewController = naVC;
//
//  [self.window makeKeyAndVisible];
  return YES;
}

#pragma mark - PushAPI
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
    NSString *pushType = [userInfo valueForKey:@"pushType"];
    [self pushViewControllerWithType:pushType];
    // 通知打开回执上报
    [CloudPushSDK sendNotificationAck:userInfo];
    
    NSLog(@"Notification, date: %@, title: %@, subtitle: %@, body: %@, badge: %d, extras: %@.", noticeDate, title, subtitle, body, badge, extras);
}

-(void)pushViewControllerWithType:(NSString *)pushType{
    DefLog(@"pushType:%@",pushType);
    //现场报警
    if([pushType isEqualToString:@"alarm"]){
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        UITabBarController *tabViewController = (UITabBarController *) appDelegate.window.rootViewController;
        //跳转到报警页面
        [tabViewController setSelectedIndex:1];
    }else if ([pushType isEqualToString:@"communication"]){
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        UITabBarController *tabViewController = (UITabBarController *) appDelegate.window.rootViewController;
        //跳转到报警页面
        [tabViewController setSelectedIndex:1];
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
        if (homeList.count>0) {
            //347 待办事项
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
    user.emasAppSecret = EMASAppSecret;
    user.emasAppKey = EMASAppKey;
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

#pragma mark Channel Opened
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


#pragma mark Receive Message
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
    tempVO.messageContent = [NSString stringWithFormat:@"title: %@, content: %@", title, body];
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
    //任务未读数
    NSInteger num = [[UserManager manager].privateUnreadNumStr integerValue];
    [UserManager manager].privateUnreadNumStr = [NSString stringWithFormat:@"%ld",(long)num+1];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0]; //清除角标
    
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
    
    [UIView animateWithDuration:.15 delay:0.9 options:QMUIViewAnimationOptionsCurveOut animations:^{
        [launchScreenView layoutIfNeeded];
        logoImageView.alpha = 0.0;
        copyrightLabel.alpha = 0;
    } completion:nil];
    [UIView animateWithDuration:1.2 delay:0.9 options:UIViewAnimationOptionCurveEaseOut animations:^{
        maskView.alpha = 0;
        backgroundImageView.alpha = 0;
    } completion:^(BOOL finished) {
        [launchScreenView removeFromSuperview];
    }];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    return [WXAUTH handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    
    return [WXAUTH handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    return [WXAUTH handleOpenURL:url];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
}

//程序被杀死
-(void)applicationWillTerminate:(UIApplication *)application{
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // 实现如下代码，才能使程序处于后台时被杀死，调用applicationWillTerminate:方法
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(){}];
}


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

@end
