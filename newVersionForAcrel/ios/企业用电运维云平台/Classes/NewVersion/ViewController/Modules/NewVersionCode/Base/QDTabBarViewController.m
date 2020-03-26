//
//  QDTabBarViewController.m
//  qmuidemo
//
//  Created by QMUI Team on 15/6/2.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "QDTabBarViewController.h"
#import "BGQMHomeViewController.h"
#import "BGQMAlarmViewController.h"
#import "BGQMElectViewController.h"
#import "BGQMUIInspectViewController.h"
#import "BGQMUserViewController.h"
#import "QDNavigationController.h"
#import "QDUIHelper.h"
#import "BGQMCategoryListConViewController.h"
#import "BGQMNewHomeTableViewController.h"
#import "BGUIWebViewController.h"
#import "BGLoginViewController.h"
#import "CustomNavigationController.h"
#import "YYServiceManager.h"
#import "EZLivePlayViewController.h"
#import "EZPlaybackViewController.h"

//#import "JXCategoryTitleView.h"
//#import "JXCategoryIndicatorLineView.h"
@interface QDTabBarViewController ()

@end

@implementation QDTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UserManager *user = [UserManager manager];
    NSArray *uiArray = [user.rootMenuData objectForKeyNotNull:@"rootMenu"];
    if (uiArray.count>0) {
        [self createViewControllers];
        [self updateHomeData];
    }else{
        [self makeRootMenu];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

//    [self changeRootMenu];
}

-(void)makeRootMenu{
    BGWeakSelf;
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    UserManager *user = [UserManager manager];
    NSNumber *language = [NSNumber numberWithBool:NO];
    NSString *languageId = @"1";
    if (user.selectlanageArr && user.selectlanageArr.count>0) {
        for (NSDictionary *dic in user.selectlanageArr) {
                if ([dic[@"click"] integerValue] == 1) {
                    languageId = dic[@"id"];
                }
            }
            if ([languageId integerValue] == 1) {
                language = [NSNumber numberWithBool:NO];
            } else {
                language = [NSNumber numberWithBool:YES];
            }
    }
        
    [NetService bg_getWithTokenWithPath:BGGetRootMenu params:@{@"english":language} success:^(id respObjc) {
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UserManager *user = [UserManager manager];
        NSDictionary *rootData = [respObjc objectForKeyNotNull:kdata];
        if (rootData) {
            NSArray *menuArr = [rootData objectForKeyNotNull:@"rootMenu"];
            if (!menuArr || !menuArr.count) {
                DefQuickAlert(@"为确保正常显示，请前往网页端配置APP菜单功能，并至少添加一个tab页功能", nil);
                NSUserDefaults *defatluts = [NSUserDefaults standardUserDefaults];
                NSDictionary *dictionary = [defatluts dictionaryRepresentation];
                for (NSString *key in [dictionary allKeys]){
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
               }
                BGLoginViewController *loginVC = [[BGLoginViewController alloc] initWithNibName:@"BGLoginViewController" bundle:nil];
                UINavigationController *naVC = [[CustomNavigationController alloc] initWithRootViewController:loginVC];
                [UIApplication sharedApplication].keyWindow.rootViewController = naVC;
                
                return ;
            }
            user.rootMenuData = respObjc[kdata];
            NSString *imageSysBaseUrl = respObjc[kdata][@"iconUrl"];
            [DefNSUD setObject:imageSysBaseUrl forKey:@"systemImageUrlstr"];
            DefNSUDSynchronize
            [weakSelf createViewControllers];
        }else{
            DefQuickAlert(@"为确保正常显示，请前往网页端配置APP菜单功能，并至少添加一个tab页功能", nil);
        }
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
    }];
}

-(void)updateHomeData{
    UserManager *user = [UserManager manager];
    NSNumber *language = [NSNumber numberWithBool:NO];
    NSString *languageId = @"1";
    if (user.selectlanageArr && user.selectlanageArr.count>0) {
        for (NSDictionary *dic in user.selectlanageArr) {
                if ([dic[@"click"] integerValue] == 1) {
                    languageId = dic[@"id"];
                }
            }
            if ([languageId integerValue] == 1) {
                language = [NSNumber numberWithBool:NO];
            } else {
                language = [NSNumber numberWithBool:YES];
            }
    }
    [NetService bg_getWithTokenWithPath:BGGetRootMenu params:@{@"english":language} success:^(id respObjc) {
        UserManager *user = [UserManager manager];
        NSDictionary *rootData = [respObjc objectForKeyNotNull:kdata];
        if (rootData) {
            NSArray *menuArr = [rootData objectForKeyNotNull:@"rootMenu"];
            if (!menuArr || !menuArr.count) {
                DefQuickAlert(@"为确保正常显示，请前往网页端配置APP菜单功能，并至少添加一个tab页功能", nil);
                //确认处理
                return ;
            }
            user.rootMenuData = rootData;
            NSString *imageSysBaseUrl = respObjc[kdata][@"iconUrl"];
            [DefNSUD setObject:imageSysBaseUrl forKey:@"systemImageUrlstr"];
            DefNSUDSynchronize
        }
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
        
    }];
}

// 创建分栏控制器管理的视图控制器数据
- (void)createViewControllers{
    UserManager *user = [UserManager manager];
    NSArray *uiArray = user.rootMenuData[@"rootMenu"];
    NSMutableArray *mainControllers = [NSMutableArray new];
    if (uiArray.count>0) {
        for (NSDictionary *dic in uiArray) {
            NSString *homePageText = [NSString changgeNonulWithString:dic[@"fMenuname"]];
            NSString *fCode = [NSString changgeNonulWithString:dic[@"fCode"]];
            if ([fCode isEqualToString:@"homePage"]) {
                BGQMHomeViewController *uikitViewController = [[BGQMHomeViewController alloc] init];
                uikitViewController.hidesBottomBarWhenPushed = NO;
                QDNavigationController *uikitNavController = [[QDNavigationController alloc] initWithRootViewController:uikitViewController];
                uikitNavController.tabBarItem = [QDUIHelper tabBarItemWithTitle:homePageText image:[UIImageMake(@"bghome") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:UIImageMake(@"bghomeselect") tag:0];
                AddAccessibilityHint(uikitNavController.tabBarItem, @"首页");
                [mainControllers addObject:uikitNavController];
            }else if ([fCode isEqualToString:@"alarmPage"]){
                BGUIWebViewController *componentViewController = [[BGUIWebViewController alloc] init];
//                fActionurl = "alarms.html";
                NSString *fFunctionfield = [NSString changgeNonulWithString:dic[@"fFunctionfield"]];
                NSString *fActionurl = [NSString changgeNonulWithString:dic[@"fActionurl"]];
                if (fFunctionfield.length>0) {
                    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"alarms" ofType:@"html" inDirectory:@"aDevices"];
                    componentViewController.isUseOnline = NO;
                    componentViewController.localUrlString = filePath;
                    componentViewController.showWebType = showWebTypeAlarm;
                    componentViewController.menuId = [NSString changgeNonulWithString:dic[@"fMenuid"]];
                    //        self.tabBarController.hidesBottomBarWhenPushed = YES;
                    componentViewController.hidesBottomBarWhenPushed = NO;
                    QDNavigationController *componentNavController = [[QDNavigationController alloc] initWithRootViewController:componentViewController];
                    componentNavController.tabBarItem = [QDUIHelper tabBarItemWithTitle:homePageText image:[UIImageMake(@"bgbaojing") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:UIImageMake(@"bgbaojingselect") tag:1];
                    AddAccessibilityHint(componentNavController.tabBarItem, @"实时报警系统");
                    [mainControllers addObject:componentNavController];
                }else{
                    componentViewController.isUseOnline = YES;
                    UserManager *user = [UserManager manager];
                    //外链H5
                    if (user.rootMenuData) {
                       NSString *versionURL = [user.rootMenuData objectForKeyNotNull:@"H5_2"];
                       componentViewController.showWebType = showWebTypeAlarm;
                       componentViewController.menuId = [NSString changgeNonulWithString:dic[@"fMenuid"]];
                       NSString *urlstring = [NSString stringWithFormat:@"/%@/",versionURL];
                       NSString *str = [GetBaseURL stringByAppendingString:urlstring];
                       NSString *urlStr = [str stringByAppendingString:fActionurl];
                       componentViewController.onlineUrlString = urlStr;
                        componentViewController.isFromAlarm = @"1";
                       componentViewController .hidesBottomBarWhenPushed = NO;
                       QDNavigationController *componentNavController = [[QDNavigationController alloc] initWithRootViewController:componentViewController];
                       componentNavController.tabBarItem = [QDUIHelper tabBarItemWithTitle:homePageText image:[UIImageMake(@"bgbaojing") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:UIImageMake(@"bgbaojingselect") tag:1];
                       AddAccessibilityHint(componentNavController.tabBarItem, @"实时报警系统");
                       [mainControllers addObject:componentNavController];
                    }
                }
            }else if ([fCode isEqualToString:@"userPage"]){
                BGQMUserViewController *ownVC = [[BGQMUserViewController alloc] init];
                ownVC.hidesBottomBarWhenPushed = NO;
                QDNavigationController *ownNavController = [[QDNavigationController alloc] initWithRootViewController:ownVC];
                ownNavController.tabBarItem = [QDUIHelper tabBarItemWithTitle:homePageText image:[UIImageMake(@"bgperson") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:UIImageMake(@"bgpersonselect") tag:3];
                 [mainControllers addObject:ownNavController];
            }else{
                BGUIWebViewController *componentViewController = [[BGUIWebViewController alloc] init];
                componentViewController.isUseOnline = YES;
                UserManager *user = [UserManager manager];
//                NSString *urlstring = [NSString stringWithFormat:@"/fileSystem/app/%@/H5/",user.versionNo];
                NSString *versionURL = [user.singleSubFullData objectForKeyNotNull:@"versionURL"];
                NSString *urlstring = [NSString stringWithFormat:@"/%@/",versionURL];
                NSString *str = [GetBaseURL stringByAppendingString:urlstring];
                NSString *urlStr = [str stringByAppendingString:[NSString changgeNonulWithString:dic[@"fActionurl"]]];
                
                componentViewController.onlineUrlString = urlStr;
                componentViewController.showWebType = showWebTypeAlarm;
                componentViewController.hidesBottomBarWhenPushed = NO;
                QDNavigationController *componentNavController = [[QDNavigationController alloc] initWithRootViewController:componentViewController];
                UIImageView *webimage = [UIImageView new];
                NSString *iconImage = [NSString changgeNonulWithString:dic[@"fIconUrl"]];
                if (iconImage.length>0) {
                    [webimage sd_setImageWithURL:[NSURL URLWithString:dic[@"fIconUrl"]] placeholderImage:[UIImage imageNamed:@""]];
                    componentNavController.tabBarItem = [QDUIHelper tabBarItemWithTitle:homePageText image:webimage.image selectedImage:webimage.image tag:1];
                }
                [mainControllers addObject:componentNavController];
            }
        }
    }
//    // 首页
//    BGQMHomeViewController *uikitViewController = [[BGQMHomeViewController alloc] init];
//    uikitViewController.hidesBottomBarWhenPushed = NO;
//    QDNavigationController *uikitNavController = [[QDNavigationController alloc] initWithRootViewController:uikitViewController];
//    uikitNavController.tabBarItem = [QDUIHelper tabBarItemWithTitle:NSLocalizedString(@"Home",nil) image:[UIImageMake(@"bghome") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:UIImageMake(@"bghomeselect") tag:0];
//    AddAccessibilityHint(uikitNavController.tabBarItem, @"首页");

    
//    self.viewControllers = @[uikitNavController, componentNavController,ownNavController];
    self.viewControllers = [mainControllers copy];
}

//单独判断页面
-(BOOL)shouldAutorotate{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    UINavigationController *navCtl = self.viewControllers[0];
    if ([navCtl.topViewController isKindOfClass:[EZLivePlayViewController class]] || [navCtl.topViewController isKindOfClass:[EZPlaybackViewController class]]) {
        return UIInterfaceOrientationMaskAll;
    }else{
        return UIInterfaceOrientationMaskPortrait;
    }
}

@end
