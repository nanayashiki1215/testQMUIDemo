//
//  BGTools.m
//  ZSKSalesAide
//
//  Created by feitian on 2017/11/22.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "BGTools.h"
#import "BGUUIDTool.h"

@implementation BGTools

+(NSMutableDictionary *)bg_deviceMessage{
    NSMutableDictionary *mutBackParam = [NSMutableDictionary dictionary];
    
    //设备唯一标识符
//    NSString *identifierStr = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
//    //手机别名： 用户定义的名称
//    NSString* name = [[UIDevice currentDevice] name];
//    //设备名称
//    NSString* systemName = [[UIDevice currentDevice] systemName];
//    //手机系统版本
//    NSString* systemVersion = [[UIDevice currentDevice] systemVersion];
//    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    // 当前应用软件版本  比如：1.0.1
//    NSString *shortVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
//    // 当前应用版本号码   int类型
//    NSString *bundleVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
//    //手机尺寸
//    CGRect rect = [[UIScreen mainScreen] bounds];
//    CGSize size = rect.size;
//    NSString *sizeStr = NSStringFromCGSize(size);
    
    NSString *deviceToken = [BGUUIDTool bg_deviceUUID];
    
    [mutBackParam setNotNullObject:deviceToken ForKey:@"token"];
//    [mutBackParam setNotNullObject:identifierStr ForKey:@"deviceId"];
    
    return mutBackParam;
}

//获取当前屏幕显示的viewcontroller
+ (UIViewController *)bg_getCurrentTopVC {
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    UIViewController *rootViewController = window.rootViewController;
    UIViewController *currentVC = [BGTools bg_getCurrentTopVCFromVC:rootViewController];
    return currentVC;
}

+ (UIViewController *)bg_getCurrentTopVCFromVC:(UIViewController *)rootVC {
    UIViewController *currentVC;
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }
    NSLog(@"\n%@\n",rootVC);
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [self bg_getCurrentTopVCFromVC:[(UITabBarController *)rootVC selectedViewController]];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [self bg_getCurrentTopVCFromVC:[(UINavigationController *)rootVC visibleViewController]];
    } else {
        // 根视图为非导航类
        if ([rootVC presentedViewController]) {
            // 视图是被presented出来的
            currentVC = [self bg_getCurrentTopVCFromVC:rootVC];
        }else{
            currentVC = rootVC;
        }
    }
    return currentVC;
}


+ (UIViewController *)bg_getRootViewController{
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    UIViewController *topRootViewController = window.rootViewController;
    while (topRootViewController.presentedViewController)
    {
        // 这里固定写法
        topRootViewController = topRootViewController.presentedViewController;
    }
    return topRootViewController;
}

//垂直push跳转
+ (void)bg_wantToPushWithVerticalWay:(UIViewController *)vc{
    UIViewController *topRootViewController = [self bg_getRootViewController];
//    if ([topRootViewController isKindOfClass:[UITabBarController class]]) {
//        UITabBarController *tabVC = (UITabBarController *)topRootViewController;
//        [tabVC setSelectedIndex:BGSETTABBARINDEX];
//        UINavigationController *naVC =(UINavigationController *) tabVC.selectedViewController;
//        CATransition* transition = [CATransition animation];
//        transition.type = kCATransitionMoveIn;//可更改为其他方式
//        transition.subtype = kCATransitionFromTop;//可更改为其他方式
//        [naVC.view.layer addAnimation:transition forKey:kCATransition];
//        [naVC pushViewController:vc animated:NO];
//    }else if([topRootViewController isKindOfClass:[UINavigationController class]]){
//        UINavigationController *naviVC = (UINavigationController *)topRootViewController;
//        CATransition* transition = [CATransition animation];
//        transition.type = kCATransitionMoveIn;//可更改为其他方式
//        transition.subtype = kCATransitionFromTop;//可更改为其他方式
//        [naviVC.view.layer addAnimation:transition forKey:kCATransition];
//        [naviVC pushViewController:vc animated:NO];
//    }else{
//        UIViewController *nomalVC = (UIViewController *)topRootViewController;
//        UINavigationController *naVC = [[UINavigationController alloc] initWithRootViewController:nomalVC];
//        CATransition* transition = [CATransition animation];
//        transition.type = kCATransitionMoveIn;//可更改为其他方式
//        transition.subtype = kCATransitionFromTop;//可更改为其他方式
//        [naVC.view.layer addAnimation:transition forKey:kCATransition];
//        [naVC pushViewController:vc animated:NO];
//    }
}


+ (NSTimeInterval)AudioDurationFromFilePath:(NSString *)filePath {
    //只有这个方法获取时间是准确的 audioPlayer.duration获得的时间不准
//    AVURLAsset* audioAsset = nil;
//    NSDictionary *dic = @{AVURLAssetPreferPreciseDurationAndTimingKey:@(YES)};
//    if ([filePath hasPrefix:@"http"]) {
//        audioAsset =[AVURLAsset URLAssetWithURL:[NSURL URLWithString:filePath] options:dic];
//    }else {//播放本机录制的文件
//        audioAsset =[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:filePath] options:dic];
//    }
//    CMTime audioDuration = audioAsset.duration;
//    float audioDurationSeconds =CMTimeGetSeconds(audioDuration);
//    return audioDurationSeconds;
}

@end
