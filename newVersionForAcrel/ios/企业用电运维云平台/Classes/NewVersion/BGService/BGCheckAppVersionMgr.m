//
//  BGCheckAppVersionMgr.m
//  变电所运维
//
//  Created by Acrel on 2019/5/27.
//

#import "BGCheckAppVersionMgr.h"

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
    [NetService bg_getWithUpdatePath:@"sys/getAndroidVersion" params:@{@"fId":@"iose70eeb320a58230925c02e7",@"version":currentVersion} success:^(id respObjc) {
        weakSelf.isConstraints = [NSString changgeNonulWithString:respObjc[@"fConstraints"]];
        weakSelf.fVersion = [NSString changgeNonulWithString:respObjc[@"fVersion"]];
        [weakSelf getAndroidVersionData:appId withCheckSuccess:checkSuccess];
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
//        [weakSelf getAndroidVersionData:appId withCheckSuccess:checkSuccess];
    }];
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
        if([currentVersion floatValue] < [self.fVersion floatValue]) {
            self.appId = appId;
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
