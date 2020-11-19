//
//  BGCheckAppVersionMgr.m
//  变电所运维
//
//  Created by Acrel on 2019/5/27.
//

#import "BGCheckAppVersionMgr.h"
#import "BGUIWebViewController.h"

@interface BGCheckAppVersionMgr ()<UIAlertViewDelegate>

@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *isConstraints;
@property (nonatomic, strong) NSString *fVersion;

@end

@implementation BGCheckAppVersionMgr

+ (BGCheckAppVersionMgr *)sharedInstance
{
    static BGCheckAppVersionMgr *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[BGCheckAppVersionMgr alloc] init];
        
    });
    
    return instance;
}

- (void)isUpdataApp:(NSString *)appId andCompelete:(BGCheckAppVersionBlock)checkSuccess
{
    
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    BGWeakSelf;
    [NetService bg_getWithUpdatePath:@"sys/getAndroidVersion" params:@{@"fId":BGVersionNo,@"version":currentVersion} success:^(id respObjc) {
        weakSelf.isConstraints = [NSString changgeNonulWithString:respObjc[@"fConstraints"]];
        weakSelf.fVersion = [NSString changgeNonulWithString:respObjc[@"fVersion"]];
        NSString *updateNo = [NSString changgeNonulWithString:respObjc[@"update"]];
        if (weakSelf.fVersion) {
            [weakSelf getAndroidVersionData:appId withCheckSuccess:checkSuccess];
        }else if ([updateNo isEqualToString:@"No"] && ![UserManager manager].isShowNewVersion){
            [weakSelf showNewVersionExplian];
        }
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
//        [weakSelf getAndroidVersionData:appId withCheckSuccess:checkSuccess];
    }];
//    [NetService bg_getWithUpdatePath:@"sys/getAndroidVersionErrorTest" params:@{@"fId":@"iose70eeb320a58230925c02e7",@"version":currentVersion} success:^(id respObjc) {
//            weakSelf.isConstraints = [NSString changgeNonulWithString:respObjc[@"fConstraints"]];
//            weakSelf.fVersion = [NSString changgeNonulWithString:respObjc[@"fVersion"]];
//            [weakSelf getAndroidVersionData:appId withCheckSuccess:checkSuccess];
//        } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
//    //        [weakSelf getAndroidVersionData:appId withCheckSuccess:checkSuccess];
//        }];
}

-(void)getAndroidVersionData:(NSString *)appId withCheckSuccess:(BGCheckAppVersionBlock)checkSuccess{
    
//    NSString *applePath = [NSString stringWithFormat:@"http://itunes.apple.com/cn/lookup?id=%@",appId];
//
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//
//    [NetService bg_httpPostWithPath:applePath params:nil success:^(id respObjc) {
//        NSArray *array = respObjc[@"results"];
//        if (array.count < 1) {
//            DefLog(@"此APPID为未上架的APP或者查询不到");
//            return;
//        }
//        NSDictionary *dic = array[0];
//        NSString *appStoreVersion = dic[@"version"];
        //    float currentVersionFloat = [currentVersion floatValue];//使用中的版本号
        
        //打印版本号
//        DefLog(@"当前版本号:%@\n商店版本号:%@",currentVersion,appStoreVersion);
        // 当前版本号小于商店版本号,就更新
        if (!self.fVersion) {
            return;
        }
        self.fVersion  = [self.fVersion stringByReplacingOccurrencesOfString:@"."withString:@""];
        currentVersion = [currentVersion stringByReplacingOccurrencesOfString:@"."withString:@""];
        if([currentVersion floatValue] < [self.fVersion floatValue]) {
            self.appId = appId;
            [UserManager manager].isShowNewVersion = NO;
            if ([self.isConstraints isEqualToString:@"true"]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:DefLocalizedString(@"Tip") message:DefLocalizedString(@"Newversion") delegate:self cancelButtonTitle:DefLocalizedString(@"ToUpdate") otherButtonTitles:nil];
                [alertView show];
            }else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:DefLocalizedString(@"Tip") message:DefLocalizedString(@"Newversion") delegate:self cancelButtonTitle:DefLocalizedString(@"ToUpdate") otherButtonTitles:DefLocalizedString(@"Nexttime"), nil];
                [alertView show];
            }
        }

//    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
//        checkSuccess(@"网络监测失败，请检查网络链接是否正常。");
//    }];
    
}

-(void)showNewVersionExplian{
    //一次设置
    [UserManager manager].isShowNewVersion = YES;
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    QMUIAlertAction *action = [QMUIAlertAction actionWithTitle:DefLocalizedString(@"Sure") style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController * _Nonnull aAlertController, QMUIAlertAction * _Nonnull action) {
      
         NSString *urlStr = @"versionHistoryView";
         BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
         NSString *filePath = [[NSBundle mainBundle] pathForResource:urlStr ofType:@"html" inDirectory:@"aDevices"];
         nomWebView.isUseOnline = NO;
         nomWebView.localUrlString = filePath;
         nomWebView.pathParamStr = @"1";
         nomWebView.showWebType = showWebTypeWithPush;
//                nomWebView.titleName = DefLocalizedString(@"versionIntroduce");
        [[self findCurrentViewController].navigationController pushViewController:nomWebView animated:YES];
    }];
    QMUIAlertAction *action2 = [QMUIAlertAction actionWithTitle:DefLocalizedString(@"Cancel") style:QMUIAlertActionStyleCancel handler:^(__kindof QMUIAlertController * _Nonnull aAlertController, QMUIAlertAction * _Nonnull action) {
       
    }];
    QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@%@",DefLocalizedString(@"updateExplain"),currentVersion]  message:DefLocalizedString(@"updateConsult") preferredStyle:QMUIAlertControllerStyleAlert];
    [alertController addAction:action];
    [alertController addAction:action2];
    
    QMUIVisualEffectView *visualEffectView = [[QMUIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    visualEffectView.foregroundColor = UIColorMakeWithRGBA(255, 255, 255, .7);// 一般用默认值就行，不用主动去改，这里只是为了展示用法
    alertController.mainVisualEffectView = visualEffectView;
    alertController.alertHeaderBackgroundColor = nil;// 当你需要磨砂的时候请自行去掉这几个背景色，不然这些背景色会盖住磨砂
    alertController.alertButtonBackgroundColor = nil;
    [alertController showWithAnimated:YES];
}

- (NSDictionary *)jsonStringToDictionary:(NSString *)jsonStr
{
    if (jsonStr == nil)
    {
        return nil;
    }
    
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&error];
    if (error)
    {
        //DefLog(@"json格式string解析失败:%@",error);
        return nil;
    }
    
    return dict;
}

-(UIViewController *)findCurrentViewController
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

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/app/id%@",self.appId]]];
        return;
    }
    
//    if (buttonIndex==2)
//    {
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IS_ALERT_AGAIN"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        return;
//    }
}

//- (BOOL)isAlertUpdataAgain
//{
//    BOOL res = [[NSUserDefaults standardUserDefaults] objectForKey:@"IS_ALERT_AGAIN"];
//    return res;
//}

@end
