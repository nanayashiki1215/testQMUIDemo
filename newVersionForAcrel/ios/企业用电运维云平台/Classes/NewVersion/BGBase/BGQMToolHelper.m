//
//  BGQMToolHelper.m
//  变电所运维
//
//  Created by Acrel on 2019/6/3.
//

#import "BGQMToolHelper.h"
#import "QDTabBarViewController.h"
#import "UITabBar+BGbadge.h"

@implementation BGQMToolHelper

+ (BGQMToolHelper *)bg_sharedInstance{
    static BGQMToolHelper *global = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        global = [[self alloc] init];
//        NSString *path = [[NSBundle mainBundle] pathForResource:BGConfigFileName ofType:@"plist"];
//        NSDictionary *configInfo = [[NSDictionary alloc] initWithContentsOfFile:path];
//        global.bgTabBarItemIndexSetting = [configInfo objectForKey:@"BGTabBarItemIndexSetting"];
    });
    return global;
}


#pragma mark - BGFWApiProtocol

-(void)bg_updateTabbarBadge:(BOOL)isShow withTypeCode:(NSString *)typeCode withShowText:(NSString *)showText{
    UIViewController *mainVc = [UIApplication sharedApplication].delegate.window.rootViewController;
    if (mainVc && [mainVc isKindOfClass:[QDTabBarViewController class]]) {
        
//        NSNumber *tabItemindex = [self.bgTabBarItemIndexSetting objectForKey:typeCode];
//        if (tabItemindex && [tabItemindex isKindOfClass:[NSNumber class]]) {
            QDTabBarViewController *mainTBVC =(QDTabBarViewController *) mainVc;
//        mainTBVC.tabBar.tabBarItemqmui_shouldShowUpdatesIndicator = YES;
//        mainTBVC.tabBarItem.qmui_shouldShowUpdatesIndicator = YES;
//        mainTBVC.tabBarItem.qmui_badgeInteger = [showText integerValue];
//            [mainTBVC.tabBar bg_updateTabbarBadge:isShow onItemIndex:[typeCode integerValue] showText:showText];
//        }
    }
}

- (void)bg_setTabbarBadge:(BOOL)isShow withItemsNumber:(NSUInteger)itemnumber withShowText:(NSString *)showText{
    UIViewController *mainVc = [UIApplication sharedApplication].delegate.window.rootViewController;
    if (mainVc && [mainVc isKindOfClass:[QDTabBarViewController class]]) {
//        UITabBar *tabbar = mainVc.tabBarController.tabBar;
//        tabbar.tintColor = TabBarTintColor;
        QDTabBarViewController *mainTBVC =(QDTabBarViewController *) mainVc;
        mainTBVC.tabBar.items[itemnumber].qmui_shouldShowUpdatesIndicator = isShow;
        mainTBVC.tabBar.items[itemnumber].qmui_badgeInteger = [showText integerValue];
    }
}

@end
