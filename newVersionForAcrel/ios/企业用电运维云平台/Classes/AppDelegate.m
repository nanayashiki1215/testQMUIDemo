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
#import "MainViewController.h"
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

#define CLIENT_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define WXAppId @"wx3e0b2d7e2d2bbc62"

BMKMapManager* _mapManager;
@implementation AppDelegate

- (id)init
{
  /** If you need to do any extra app-specific initialization, you can do it here
   *  -jm
   **/
  NSHTTPCookieStorage* cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
  
  [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
  
  int cacheSizeMemory = 8 * 1024 * 1024; // 8MB
  int cacheSizeDisk = 32 * 1024 * 1024; // 32MB
#if __has_feature(objc_arc)
  NSURLCache* sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
#else
  NSURLCache* sharedCache = [[[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"] autorelease];
#endif
  [NSURLCache setSharedURLCache:sharedCache];
  
  self = [super init];
  return self;
}

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
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [QDUIHelper qmuiEmotions];
    });
    
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
        NSLog(@"经纬度类型设置成功");
    } else {
        NSLog(@"经纬度类型设置失败");
    }
    
    //启动引擎并设置AK并设置delegate
    BOOL result = [_mapManager start:BGBaiduMapApi generalDelegate:self];
    if (!result) {
        NSLog(@"启动引擎失败");
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
@end
