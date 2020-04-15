//
//  BGQMTableViewCell.m
//  变电所运维
//
//  Created by Acrel on 2019/7/31.
//

#import "BGQMUserHeadTableViewCell.h"
#import "BGLoginViewController.h"
#import "CustomNavigationController.h"
#import "UIColor+BGExtension.h"
#import "YYServiceManager.h"
#import <CloudPushSDK/CloudPushSDK.h>

@implementation BGQMUserHeadTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    [self.quitOutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.quitOutBtn.layer.cornerRadius = self.quitOutBtn.frame.size.height/2;
    self.quitOutBtn.layer.masksToBounds = YES;
    [self.quitOutBtn.layer addSublayer:[UIColor setGradualChangingColor:self.quitOutBtn fromColor:COLOR_LightLWithChangeIn16 toColor:COLOR_DeepLWithChangeIn16]];
    self.signoutlabel.text = DefLocalizedString(@"SignOut");
//    [self.quitOutBtn setTitle:DefLocalizedString(@"SignOut") forState:UIControlStateNormal];
//    [self.quitOutBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:19.f]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)loginOutClickEvent:(UIButton *)sender {
    QMUIAlertAction *action = [QMUIAlertAction actionWithTitle:DefLocalizedString(@"Sure") style:QMUIAlertActionStyleDestructive handler:^(__kindof QMUIAlertController * _Nonnull aAlertController, QMUIAlertAction * _Nonnull action) {
           //清空NSUserDefaults 退出登录
           __weak __typeof(self)weakSelf = self;
           [weakSelf removeAlias:nil];
           NSUserDefaults *defatluts = [NSUserDefaults standardUserDefaults];
           NSDictionary *dictionary = [defatluts dictionaryRepresentation];
           for(NSString *key in [dictionary allKeys]){
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
                [weakSelf generateTrackRecords];
            }
        
           BGLoginViewController *loginVC = [[BGLoginViewController alloc] initWithNibName:@"BGLoginViewController" bundle:nil];
           UINavigationController *naVC = [[CustomNavigationController alloc] initWithRootViewController:loginVC];
           [UIApplication sharedApplication].keyWindow.rootViewController = naVC;
       }];
    
        QMUIAlertAction *action2 = [QMUIAlertAction actionWithTitle:DefLocalizedString(@"Cancel") style:QMUIAlertActionStyleCancel handler:^(__kindof QMUIAlertController * _Nonnull aAlertController, QMUIAlertAction * _Nonnull action) {
      
        }];
    
       QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:DefLocalizedString(@"SignOut") message:DefLocalizedString(@"SureSignOut") preferredStyle:QMUIAlertControllerStyleAlert];
    
       [alertController addAction:action];
       [alertController addAction:action2];
       
       QMUIVisualEffectView *visualEffectView = [[QMUIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
       visualEffectView.foregroundColor = UIColorMakeWithRGBA(255, 255, 255, .7);// 一般用默认值就行，不用主动去改，这里只是为了展示用法
       alertController.mainVisualEffectView = visualEffectView;
       alertController.alertHeaderBackgroundColor = nil;// 当你需要磨砂的时候请自行去掉这几个背景色，不然这些背景色会盖住磨砂
       alertController.alertButtonBackgroundColor = nil;
       [alertController showWithAnimated:YES];
    
}

-(void)removeAlias:(NSString *)alias{
    [CloudPushSDK removeAlias:alias withCallback:^(CloudPushCallbackResult *res) {
           if (res.success) {
               DefLog(@"别名移除成功,别名：%@",alias);
           } else {
               DefLog(@"别名移除失败，错误: %@", res.error);
           }
    }];
}

-(void)generateTrackRecords{
    NSMutableDictionary *mutparam = [NSMutableDictionary new];
    NSString *Projectip = GetBaseURL;
    [mutparam setObject:Projectip forKey:@"fProjectip"];
    UserManager *user = [UserManager manager];
    NSString *startTime = user.startTJtime;
    if (startTime.length) {
         [mutparam setObject:startTime forKey:@"fTrackstarttime"];
    }
    NSString *taskNumber = user.taskID;
    if (taskNumber && taskNumber.length) {
        [mutparam setObject:taskNumber forKey:@"fTaskNumber"];
    }
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
    NSString *endTime = [formatter stringFromDate:date];
    [mutparam setObject:endTime forKey:@"fTrackendtime"];
    //设置采集周期 30秒
    NSDictionary *baiduDic = user.yytjBaiduDic;
    NSString *tjGetherInterval =[NSString changgeNonulWithString:baiduDic[@"tjGetherInterval"]];
    NSString *tjPackInterval =[NSString changgeNonulWithString:baiduDic[@"tjPackInterval"]];
    if (tjGetherInterval && tjPackInterval) {
        [mutparam setObject:tjGetherInterval forKey:@"tjGetherInterval"];
        [mutparam setObject:tjPackInterval forKey:@"tjPackInterval"];
    } else {
        tjGetherInterval = @"5";
        tjPackInterval = @"30";
    }
    NSDictionary *param = user.loginData;
    NSString *projectname = [NSString changgeNonulWithString:param[@"fProjectname"]];
    NSString *userid = [NSString changgeNonulWithString:param[@"userId"]];
    NSString *username = [NSString changgeNonulWithString:param[@"username"]];
    //组织机构编号
    NSString *coaccountno = [NSString changgeNonulWithString:param[@"fCoaccountNo"]];
    //组织机构名
    NSString *coname = [NSString changgeNonulWithString:param[@"fConame"]];
    if (projectname) {
        [mutparam setObject:projectname forKey:@"fProjectname"];
    }
    if (userid) {
        [mutparam setObject:userid forKey:@"fUserid"];
    }
    if (username) {
        [mutparam setObject:username forKey:@"fUsername"];
    }
    if (coaccountno) {
        [mutparam setObject:coaccountno forKey:@"fCoaccountno"];
    }
    if (coname) {
        [mutparam setObject:coname forKey:@"fConame"];
    }
//    [NetService bg_getWithTokenWithPath:@"/generateTrackRecords" params:mutparam success:^(id respObjc) {
//        [UserManager manager].startTJtime = @"";
//
//    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
//        [UserManager manager].startTJtime = @"";
//
//    }];
    //阿里云特殊接口 http://www.acrelcloud.cn
    [NetService bg_getWithTestPath:@"sys/generateTrackRecords" params:mutparam success:^(id respObjc) {
        [UserManager manager].startTJtime = @"";
        
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
        [UserManager manager].startTJtime = @"";
       
    }];
}
@end
