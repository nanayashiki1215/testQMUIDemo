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

//#import "JXCategoryTitleView.h"
//#import "JXCategoryIndicatorLineView.h"
@interface QDTabBarViewController ()

@end

@implementation QDTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UserManager *user = [UserManager manager];
    NSArray *uiArray = user.rootMenuData[@"rootMenu"];
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
    [NetService bg_getWithTokenWithPath:BGGetRootMenu params:nil success:^(id respObjc) {
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UserManager *user = [UserManager manager];
        user.rootMenuData = respObjc[kdata];
        NSArray *menuArr = user.rootMenuData[@"rootMenu"];
        if (!menuArr.count) {
            DefQuickAlert(@"为确保正常显示，请至少添加一个tab页功能", nil);
            
        }
        NSString *imageSysBaseUrl = respObjc[kdata][@"iconUrl"];
        [DefNSUD setObject:imageSysBaseUrl forKey:@"systemImageUrlstr"];
        DefNSUDSynchronize
        [weakSelf createViewControllers];
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
    }];
}

-(void)updateHomeData{
    [NetService bg_getWithTokenWithPath:BGGetRootMenu params:nil success:^(id respObjc) {
        UserManager *user = [UserManager manager];
        user.rootMenuData = respObjc[kdata];
        NSArray *menuArr = user.rootMenuData[@"rootMenu"];
        if (!menuArr.count) {
            DefQuickAlert(@"为确保正常显示，请至少添加一个tab页功能", nil);
        }
        NSString *imageSysBaseUrl = respObjc[kdata][@"iconUrl"];
        [DefNSUD setObject:imageSysBaseUrl forKey:@"systemImageUrlstr"];
        DefNSUDSynchronize
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
//
//    //报警
//    BGUIWebViewController *componentViewController = [[BGUIWebViewController alloc] init];
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"alarms" ofType:@"html" inDirectory:@"aDevices"];
//    componentViewController.isUseOnline = NO;
//    componentViewController.localUrlString = filePath;
//    componentViewController.showWebType = showWebTypeAlarm;
//    //        self.tabBarController.hidesBottomBarWhenPushed = YES;
//    componentViewController.hidesBottomBarWhenPushed = NO;
//    QDNavigationController *componentNavController = [[QDNavigationController alloc] initWithRootViewController:componentViewController];
//    componentNavController.tabBarItem = [QDUIHelper tabBarItemWithTitle:NSLocalizedString(@"Alarm",nil) image:[UIImageMake(@"bgbaojing") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:UIImageMake(@"bgbaojingselect") tag:1];
//    AddAccessibilityHint(componentNavController.tabBarItem, @"实时报警系统");
//
//    // 我的
//    BGQMUserViewController *ownVC = [[BGQMUserViewController alloc] init];
//    ownVC.hidesBottomBarWhenPushed = NO;
//    QDNavigationController *ownNavController = [[QDNavigationController alloc] initWithRootViewController:ownVC];
//    ownNavController.tabBarItem = [QDUIHelper tabBarItemWithTitle:NSLocalizedString(@"About",nil) image:[UIImageMake(@"bgperson") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:UIImageMake(@"bgpersonselect") tag:3];
//
    
//    self.viewControllers = @[uikitNavController, componentNavController,ownNavController];
    self.viewControllers = [mainControllers copy];
}
@end
