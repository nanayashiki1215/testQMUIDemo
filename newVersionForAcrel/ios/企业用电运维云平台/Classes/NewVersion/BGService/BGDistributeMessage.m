//
//  BGDistributeMessage.m
//  企业用电运维云平台
//
//  Created by Acrel on 2019/11/28.
//

#import "BGDistributeMessage.h"
#import "NSString+BGExtension.h"

@implementation BGDistributeMessage

+(void)distributeMessage:(id)message{
       id dict = [message jsonObjectFromString];
       if ([dict isKindOfClass:[NSDictionary class]] && [dict objectForKey:@"pushType"]) {
           NSString *pushType = [dict bg_StringForKeyNotNull:@"pushType"];
           if([pushType isEqualToString:@"alarm"]){
                [self JudgeWhetherGetUnreadWarningMessage];
             }else if ([pushType isEqualToString:@"communication"]){
                [self JudgeWhetherGetUnreadWarningMessage];
             }else if ([pushType isEqualToString:@"work"]){
                NSInteger num = [[UserManager manager].privateUnreadNumStr integerValue];
                [UserManager manager].privateUnreadNumStr = [NSString stringWithFormat:@"%ld",(long)num+1];
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0]; //清除角标
             }
       }else{
           
       }
}

+(UIViewController *)findCurrentViewController
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

+(void)JudgeWhetherGetUnreadWarningMessage{
    UserManager *user = [UserManager manager];
    if (!user.versionNo) {
        return;
    }
    if ([user.versionNo isEqualToString:ISVersionNo]) {
        [NetService bg_getWithTokenWithPath:@"/getUnConfirmedEventsNum" params:@{} success:^(id respObjc) {
               DefLog(@"%@",respObjc);
            NSDictionary *dict = [respObjc objectForKeyNotNull:kdata];
            NSArray *array = [dict objectForKeyNotNull:@"unConfirmedEventsNum"];
               if (array) {
                   NSInteger sum = 0;
                   for (NSDictionary *warningDic in array) {
                       NSString *infotype = [warningDic bg_StringForKeyNotNull:@"fMessinfotypeid"];
                       if ([infotype isEqualToString:@"1"]) {
                          continue;
                       }else{
                           
                           NSInteger count = [[warningDic bg_StringForKeyNotNull:@"unConfirmNum"] integerValue];
                           sum += count;
                       }
                   }
                if (sum>0) {
                     UserManager *user = [UserManager manager];
                     NSArray *uiArray = user.rootMenuData[@"rootMenu"];
                     if (uiArray.count>0) {
                         for (int index = 0; index<uiArray.count; index++) {
                             NSDictionary *dic = uiArray[index];
                             NSString *fCode = [NSString changgeNonulWithString:dic[@"fCode"]];
                             if ([fCode isEqualToString:@"alarmPage"]){
                                 [[BGQMToolHelper bg_sharedInstance] bg_setTabbarBadge:YES withItemsNumber:index withShowText:[NSString stringWithFormat:@"%ld",(long)sum]];
                             }
                         }
                     }else{
                        [[BGQMToolHelper bg_sharedInstance] bg_setTabbarBadge:YES withItemsNumber:1 withShowText:[NSString stringWithFormat:@"%ld",(long)sum]];
                     }
                 }else{
                     [[BGQMToolHelper bg_sharedInstance] bg_setTabbarBadge:NO withItemsNumber:1 withShowText:@""];
                 }
               }
           } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
               
           }];
    }else{
        [NetService bg_getWithTokenWithPath:@"/getUnreadWarningMessage" params:@{} success:^(id respObjc) {
            DefLog(@"%@",respObjc);
            NSArray *array = [respObjc objectForKeyNotNull:kdata];
            if (array) {
                NSInteger sum = 0;
                for (NSDictionary *warningDic in array) {
                    NSInteger count = [[warningDic bg_StringForKeyNotNull:@"count"] integerValue];
                    sum += count;
                }
                 if (sum>0) {
                                      UserManager *user = [UserManager manager];
                                      NSArray *uiArray = user.rootMenuData[@"rootMenu"];
                                      if (uiArray.count>0) {
                                          for (int index = 0; index<uiArray.count; index++) {
                                              NSDictionary *dic = uiArray[index];
                                              NSString *fCode = [NSString changgeNonulWithString:dic[@"fCode"]];
                                              if ([fCode isEqualToString:@"alarmPage"]){
                                                  [[BGQMToolHelper bg_sharedInstance] bg_setTabbarBadge:YES withItemsNumber:index withShowText:[NSString stringWithFormat:@"%ld",(long)sum]];
                                              }
                                          }
                                      }else{
                                         [[BGQMToolHelper bg_sharedInstance] bg_setTabbarBadge:YES withItemsNumber:1 withShowText:[NSString stringWithFormat:@"%ld",(long)sum]];
                                      }
                                  }else{
                                      [[BGQMToolHelper bg_sharedInstance] bg_setTabbarBadge:NO withItemsNumber:1 withShowText:@""];
                                  }
            }
        } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
            
        }];
    }
}

+ (UIViewController *)jsd_findVisibleViewController {
    
    UIViewController* currentViewController = [self jsd_getRootViewController];

    BOOL runLoopFind = YES;
    while (runLoopFind) {
        if (currentViewController.presentedViewController) {
            currentViewController = currentViewController.presentedViewController;
        } else {
            if ([currentViewController isKindOfClass:[UINavigationController class]]) {
                currentViewController = ((UINavigationController *)currentViewController).visibleViewController;
            } else if ([currentViewController isKindOfClass:[UITabBarController class]]) {
                currentViewController = ((UITabBarController* )currentViewController).selectedViewController;
            } else {
                break;
            }
        }
    }
    
    return currentViewController;
}

+ (UIViewController *)jsd_getRootViewController{

    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    NSAssert(window, @"The window is empty");
    return window.rootViewController;
}
@end
