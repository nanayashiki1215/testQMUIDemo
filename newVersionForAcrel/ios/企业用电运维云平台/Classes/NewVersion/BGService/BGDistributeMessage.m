//
//  BGDistributeMessage.m
//  企业用电运维云平台
//
//  Created by Acrel on 2019/11/28.
//

#import "BGDistributeMessage.h"
#import "NSString+BGExtension.h"
#import "BGTopNoticeView.h"
#import "BGUIWebViewController.h"

@implementation BGDistributeMessage

+(void)distributeMessage:(LZLPushMessage *)message{
    if (message.messageContent) {
        id dict = [message.messageContent jsonObjectFromString];
        if ([dict isKindOfClass:[NSDictionary class]] && [dict objectForKey:@"pushType"]) {
            NSString *pushType = [dict bg_StringForKeyNotNull:@"pushType"];
            if([pushType isEqualToString:@"alarm"]){
                 [self JudgeWhetherGetUnreadWarningMessage];
                NSNotification *notification = [NSNotification notificationWithName:@"RefreshWebData" object:nil userInfo:dict];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
//                "pushType":"alarm","fAlarmeventlogid":"2020092814372751671281900","SpecificType":"light","subId":"10100389"}
//                 NSString *logid = [dict bg_StringForKeyNotNull:@"fAlarmeventlogid"];
//               //调用接口查询 显示顶部推送消息
//               if (logid && [UserManager manager].isOpenBoxInApp) {
//                   [self showTopNoticeView:dict];
//                   }
                   
                   //                 BGWeakSelf;
//                   [NetService bg_getWithTokenWithPath:@"/getAlarmEventLogById" params:@{@"fAlarmeventlogid":logid} success:^(id respObjc) {
//                       NSDictionary *data = [respObjc objectForKeyNotNull:kdata];
//                       NSDictionary *alarmEventLogById = data[@"alarmEventLogById"];
//                       if (alarmEventLogById) {
//                           NSMutableDictionary * mutiData = [data mutableCopy];
//                           [mutiData setValue:@"alarm" forKey:@"pushType"];
//                           [weakSelf showTopNoticeView:mutiData];
//                       }
//                    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
//
//                    }];
               
              }else if ([pushType isEqualToString:@"communication"]){
                 [self JudgeWhetherGetUnreadWarningMessage];
//                  BGWeakSelf;
//                  NSString *logid = [dict bg_StringForKeyNotNull:@"fAlarmeventlogid"];
                  //调用接口查询 显示顶部推送消息
//                  if (logid && [UserManager manager].isOpenBoxInApp) {
//                      [self showTopNoticeView:dict];
//                  }
              }else if ([pushType isEqualToString:@"work"]){
                 NSInteger num = [[UserManager manager].privateUnreadNumStr integerValue];
                  NSString *workNum = [NSString stringWithFormat:@"%ld",(long)num+1];
                 [UserManager manager].privateUnreadNumStr = workNum;
                 [[BGQMToolHelper bg_sharedInstance] bg_setTabbarBadge:YES withItemsNumber:0 withShowText:workNum];
                  
                 [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0]; //清除角标
//                BGWeakSelf;
                NSString *taskID = [dict bg_StringForKeyNotNull:@"fTaskid"];
                if (taskID && [UserManager manager].isOpenBoxInApp) {
                     [self showTopNoticeView:dict];

                   }
              }
        }else{
            
        }
       
    }
       
        
       
 
}

+(void)showTopNoticeView:(NSDictionary *)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        [BGTopNoticeView share].data =data;
        [[BGTopNoticeView share].dataArray addObject:data];
        [[BGTopNoticeView share] show];
        [[BGTopNoticeView share] didConfirm:^(UIButton *button,NSDictionary *data) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (data) {
                     //现场报警
                         NSString *pushType = [data bg_StringForKeyNotNull:@"pushType"];
                        if([pushType isEqualToString:@"alarm"]){
                             NSString *fAlarmeventlogid = [data bg_StringForKeyNotNull:@"fAlarmeventlogid"];
                            //
//                            NSDictionary *alarmEvent = data[@"alarmEventLogById"];
//                            NSString *fAlarmeventlogid = [alarmEvent bg_StringForKeyNotNull:@"fAlarmeventlogid"];
                            if (fAlarmeventlogid) {
                                
                                [self pushNoYYWebview:fAlarmeventlogid andHtmlName:@"alarmDetailView"];
                            }
                   
                        }else if ([pushType isEqualToString:@"communication"]){
                            //通讯状态
                            NSString *fAlarmeventlogid = [data bg_StringForKeyNotNull:@"fAlarmeventlogid"];
//                            NSDictionary *alarmEvent = data[@"alarmEventLogById"];
//                            NSString *fAlarmeventlogid = [alarmEvent bg_StringForKeyNotNull:@"fAlarmeventlogid"];
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
                            NSString *isOrder = [NSString changgeNonulWithString:data[@"isOrder"]];
                            if (isOrder && [isOrder isEqualToString:@"1"]) {
                                DefLog(@"heiheihei");
                                if (homeList.count>0) {
                                        //357 抢单
                                        NSString *taskid = [data bg_StringForKeyNotNull:@"fTaskid"];
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
                                    NSString *taskid = [data bg_StringForKeyNotNull:@"fTaskid"];
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
            });
        }];
    });
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

#pragma mark - pushNoYYWebView
+(void)pushNoYYWebview:(NSString *)jumpid andHtmlName:(NSString *)htmlName{
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
