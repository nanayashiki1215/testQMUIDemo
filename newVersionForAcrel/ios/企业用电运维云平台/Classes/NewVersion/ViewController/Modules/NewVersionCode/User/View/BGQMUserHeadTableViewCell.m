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
//    [self.quitOutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
//    [self.quitOutBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:19.f]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)loginOutClickEvent:(UIButton *)sender {
    QMUIAlertAction *action = [QMUIAlertAction actionWithTitle:@"确定" style:QMUIAlertActionStyleDestructive handler:^(__kindof QMUIAlertController * _Nonnull aAlertController, QMUIAlertAction * _Nonnull action) {
           //清空NSUserDefaults 退出登录
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
               }
               else{
                   [defatluts removeObjectForKey:key];
                   [defatluts synchronize];
               }
           }
           BGLoginViewController *loginVC = [[BGLoginViewController alloc] initWithNibName:@"BGLoginViewController" bundle:nil];
           UINavigationController *naVC = [[CustomNavigationController alloc] initWithRootViewController:loginVC];
           [UIApplication sharedApplication].keyWindow.rootViewController = naVC;
       }];
    
        QMUIAlertAction *action2 = [QMUIAlertAction actionWithTitle:@"取消" style:QMUIAlertActionStyleCancel handler:^(__kindof QMUIAlertController * _Nonnull aAlertController, QMUIAlertAction * _Nonnull action) {
      
        }];
    
       QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:@"退出登录" message:@"确定退出登录吗？" preferredStyle:QMUIAlertControllerStyleAlert];
    
       [alertController addAction:action];
       [alertController addAction:action2];
       
       QMUIVisualEffectView *visualEffectView = [[QMUIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
       visualEffectView.foregroundColor = UIColorMakeWithRGBA(255, 255, 255, .7);// 一般用默认值就行，不用主动去改，这里只是为了展示用法
       alertController.mainVisualEffectView = visualEffectView;
       alertController.alertHeaderBackgroundColor = nil;// 当你需要磨砂的时候请自行去掉这几个背景色，不然这些背景色会盖住磨砂
       alertController.alertButtonBackgroundColor = nil;
       [alertController showWithAnimated:YES];
    
}

@end
