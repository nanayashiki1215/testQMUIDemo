//
//  BGLogSecondViewController.m
//  企业用电运维云平台
//
//  Created by Acrel on 2020/7/2.
//

#import "BGLogSecondViewController.h"
#import "Masonry.h"
#import "BGLogFirstViewController.h"
#import "QMUIConfigurationTemplate.h"
#import <CloudPushSDK/CloudPushSDK.h>
#import "UIColor+BGExtension.h"
#import "BGCheckAppVersionMgr.h"
#import "QDTabBarViewController.h"

@interface BGLogSecondViewController ()<QMUITextFieldDelegate>
@property (nonatomic, strong) QMUITextField * usenameTextField;//账户
@property (nonatomic, strong) QMUITextField * pwdTextField;//密码
@property (nonatomic, strong) UIView *loginBgView;//登录层背景
@property (nonatomic, strong) UIImageView *imageV;//图标1
@property (nonatomic, strong) UIImageView *imageVPwd;//图标2
@property (nonatomic, strong) QMUIButton *loginInBtn;//登录按钮
@property (nonatomic, strong) QMUIButton *settingIPBtn;//设置按钮
@property (nonatomic, strong) UIView *bgView;//背景层 可切换
@property (nonatomic, strong) QMUIPopupMenuView *popupByWindow;
@property (nonatomic, strong) UIButton *checkBtn;
@property (nonatomic, strong) UIButton *selectAddress;
@property (nonatomic, strong) QMUIButton *settingBtn;
@property (nonatomic, copy) NSArray<NSObject<QDThemeProtocol> *> *themes;
@property (nonatomic, strong) UIImageView *logoImageV;//logo
@property (nonatomic, strong) QMUILabel *logoLabel;//logoName
@property (nonatomic, strong) UIImageView *bglogoPic;//半屏背景图

@end

@implementation BGLogSecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createView];
//     [self addDynamicView];
//     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    //    [self.pwdTextField addTarget:self action:@selector(keyboardWillChangeFrame:) forControlEvents:UIControlEventEditingDidBegin];
        //输入结束
//        [self.pwdTextField addTarget:self action:@selector(textFieldEditEnd) forControlEvents:UIControlEventEditingDidEnd];

   //检查版本升级 迭代更新
      [[BGCheckAppVersionMgr sharedInstance] isUpdataApp:kAppleId andCompelete:^(NSString * _Nonnull respObjc) {
          
      }];
      [self setTheme];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    UserManager *user = [UserManager manager];
       self.usenameTextField.delegate = self;
       self.pwdTextField.delegate = self;
     if (user.account.length) {
        self.usenameTextField.text = user.account;
     }
//     if (user.orderListUrl.length) {
//         self.addressTextField.text = user.orderListUrl;
//     }
     if (user.password.length && user.isSavePwd) {
         self.pwdTextField.text = user.password;
     }else{
         self.pwdTextField.text = @"";
     }
     self.pwdTextField.secureTextEntry = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    //    [self.pwdTextField addTarget:self action:@selector(keyboardWillChangeFrame:) forControlEvents:UIControlEventEditingDidBegin];
        //输入结束
//    [self.pwdTextField addTarget:self action:@selector(textFieldEditEnd) forControlEvents:UIControlEventEditingDidEnd];
       
}

-(void)createView{
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor lightGrayColor];
    
    UIView *lineView2 = [[UIView alloc] init];
    lineView2.backgroundColor = [UIColor lightGrayColor];
    
    UserManager *user = [UserManager manager];
     if(user.isSavePwd){
         self.checkBtn.selected = YES;
         self.checkBtn.layer.borderWidth = 0;
         user.isSavePwd = YES;
     }
    
    UIButton *label12 = [[UIButton alloc] init];

    [label12 setTitle:DefLocalizedString(@"savePassword") forState:UIControlStateNormal];
    label12.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [label12 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [label12 addTarget:self action:@selector(labelClick:) forControlEvents:UIControlEventTouchUpInside];
    self.bglogoPic = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBgImage"]];
    self.bglogoPic.frame =CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH*4/5);
    [self.view addSubview:self.bglogoPic];
    
    
    //配置内画面 loginTest loginLogo
    self.logoImageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginLogo"]];
    self.logoImageV.contentMode = UIViewContentModeScaleAspectFit;
    self.logoLabel = [[QMUILabel alloc] init];
//    self.logoLabel.text = @"航天股份有限公奥术大师司企业用电运维云平台";
    self.logoLabel.text = NSLocalizedString(@"LoginText",nil);
    self.logoLabel.textAlignment = NSTextAlignmentCenter;
    [self.logoLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:23]];
//    self.logoLabel.textColor = COLOR_TEXT;

   
    [self.view addSubview:self.loginBgView];
    [self.loginBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        //卡片位置判断
        if((480+SCREEN_WIDTH*4/5-50)>SCREEN_HEIGHT){
           make.bottom.equalTo(self.view.mas_bottom).offset(-50);
        }else{
           make.top.equalTo(self.bglogoPic.mas_bottom).offset(-50);
        }
        make.left.mas_equalTo(@25);
        make.right.mas_equalTo(@-25);
        make.height.mas_offset(480);
    }];
    [self.loginBgView addSubview:self.logoImageV];
    [self.loginBgView addSubview:self.logoLabel];
    [self.loginBgView addSubview:self.imageV];
    [self.loginBgView addSubview:lineView];
    [self.loginBgView addSubview:self.usenameTextField];
    [self.loginBgView addSubview:self.imageVPwd];
    [self.loginBgView addSubview:lineView2];
    [self.loginBgView addSubview:self.pwdTextField];
    [self.loginBgView addSubview:self.loginInBtn];
    [self.loginBgView addSubview:self.checkBtn];
    [self.loginBgView addSubview:label12];
    [self.loginBgView addSubview:self.settingBtn];
    
    [self.logoImageV mas_makeConstraints:^(MASConstraintMaker *make) {
           make.top.equalTo(self.loginBgView.mas_top).offset(15);
           make.centerX.equalTo(self.loginBgView);
//            make.width.mas_offset(100);
           make.height.mas_offset(100);
           
    }];
    
    [self.logoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                 make.top.equalTo(self.logoImageV.mas_bottom).offset(5);
//                 make.centerY.equalTo(self.view);
                 make.left.equalTo(self.loginBgView.mas_left).offset(5);
                 make.right.equalTo(self.loginBgView.mas_right).offset(-5);
                 make.height.mas_offset(50);
        
    }];
         
     [self.imageV mas_makeConstraints:^(MASConstraintMaker *make) {
 //        make.left.mas_equalTo(@15);
         //内左边距
         make.left.equalTo(self.loginBgView.mas_left).offset(30);
         make.top.equalTo(self.logoLabel.mas_bottom).offset(25);
         make.width.mas_offset(18);
         make.height.mas_offset(20);
     }];
     
     [self.usenameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
         make.centerY.equalTo(self.imageV);
         make.left.equalTo(self.imageV.mas_right).offset(3);
         make.right.equalTo(self.loginBgView.mas_right).offset(-30);
         make.height.mas_offset(50);
     }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imageV.mas_left).offset(0);
        make.top.equalTo(self.usenameTextField.mas_bottom).offset(0);
        make.right.equalTo(self.usenameTextField.mas_right).offset(0);
        make.height.mas_offset(1);
    }];
    
    [self.imageVPwd mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.left.mas_equalTo(@15);
            make.left.equalTo(self.imageV.mas_left).offset(0);
            make.top.equalTo(lineView.mas_bottom).offset(30);
            make.width.mas_offset(18);
            make.height.mas_offset(20);
    }];
        
    [self.pwdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.imageVPwd);
        make.left.equalTo(self.imageV.mas_right).offset(3);
        make.right.equalTo(self.usenameTextField.mas_right).offset(0);
        make.height.mas_offset(50);
    }];
    
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
           make.left.equalTo(self.imageV.mas_left).offset(0);
           make.top.equalTo(self.pwdTextField.mas_bottom).offset(0);
           make.right.equalTo(self.pwdTextField.mas_right).offset(0);
           make.height.mas_offset(1);
    }];
    
    //      self.checkBtn = [[UIButton alloc] initWithFrame:CGRectMake(32, self.loginInBtn.frame.origin.y - 40, 16, 16)];
    [self.checkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imageV.mas_left).offset(0);
        make.top.equalTo(lineView2.mas_bottom).offset(25);
        make.width.mas_offset(16);
        make.height.mas_offset(16);
    }];
    
    //      UIButton *label12 = [[UIButton alloc]initWithFrame:CGRectMake(self.checkBtn.frame.size.width+5+32, self.loginInBtn.frame.origin.y-47, 70, 30)];
    [label12 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.checkBtn.mas_right).offset(5);
        make.centerY.equalTo(self.checkBtn);
//        make.top.equalTo(lineView2.mas_bottom).offset(15);
        make.width.mas_offset(70);
        make.height.mas_offset(30);
    }];
    
    [self.loginInBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.loginBgView);
        make.top.equalTo(label12.mas_bottom).offset(30);
        make.width.mas_offset(SCREEN_WIDTH/2+80);
        make.height.mas_offset(50);
    }];
    
    [self.settingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(15);
        make.right.mas_offset(-5);
        make.width.mas_offset(80);
        make.height.mas_offset(30);
    }];
    
//    [self.loginInBtn.layer addSublayer:[UIColor setGradualChangingColor:self.loginInBtn  fromColor:COLOR_LightLWithChangeIn16 toColor:COLOR_DeepLWithChangeIn16]];
}

-(void)pushLoginViewC{
    if (self.usenameTextField.text && self.usenameTextField.text.length>0) {
        BGLogSecondViewController *secVC = [[BGLogSecondViewController alloc] init];
        [self.navigationController pushViewController:secVC animated:YES];
    }else{
       
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
      
}

#pragma mark - MainEvent

-(void)addDynamicView{
    if(/* DISABLES CODE */ (1)){
        //全屏背景
        self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
         [self.bgView.layer addSublayer:[UIColor setGradualChangingColor:self.bgView fromColor:COLOR_LightLWithChangeIn16 toColor:COLOR_DeepLWithChangeIn16]];
         UIImageView *imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login-p"]];
         imageV.frame = CGRectMake((SCREEN_WIDTH-imageV.frame.size.width)/2, 80, imageV.frame.size.width, imageV.frame.size.height);
         UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageV.frame.size.height+95, SCREEN_WIDTH, 50)];
         label.text = NSLocalizedString(@"LoginText",nil);
         label.textAlignment = NSTextAlignmentCenter;
         [label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:23]];
         label.textColor = [UIColor whiteColor];
         [self.bgView addSubview:imageV];
         [self.bgView addSubview:label];
         [self.view addSubview:self.bgView];
//         [self.view bringSubviewToFront:self.settingBtn];
//         [self.view bringSubviewToFront:self.loginBgView];
    }else{
        //半屏背景
        self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 300)];
       [self.bgView.layer addSublayer:[UIColor setGradualChangingColor:self.bgView fromColor:COLOR_LightLWithChangeIn16 toColor:COLOR_DeepLWithChangeIn16]];
       UIImageView *imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login-p"]];
       imageV.frame = CGRectMake((SCREEN_WIDTH-imageV.frame.size.width)/2, 80, imageV.frame.size.width, imageV.frame.size.height);
       UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageV.frame.size.height+95, SCREEN_WIDTH, 50)];
       label.text = NSLocalizedString(@"LoginText",nil);
       label.textAlignment = NSTextAlignmentCenter;
       [label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:23]];
       label.textColor = [UIColor whiteColor];
       [self.bgView addSubview:imageV];
       [self.bgView addSubview:label];
       [self.view addSubview:self.bgView];
//       [self.view bringSubviewToFront:self.settingBtn];
//       [self.view bringSubviewToFront:self.loginBgView];
    }
}

-(void)pushSetIPViewC{
    BGLogFirstViewController *logFirstVC = [[BGLogFirstViewController alloc] init];
    logFirstVC.isPush = YES;
    [self.navigationController pushViewController:logFirstVC animated:YES];
}

-(void)signInClickEvent:(UIButton *)sender{
    __weak __typeof(self)weakSelf = self;
//    if (!self.addressTextField.text.length) {
//        [MBProgressHUD showError:DefLocalizedString(@"Domain name cannot be empty")];
//        return;
//    }
    if (!self.usenameTextField.text.length) {
        [MBProgressHUD showError:DefLocalizedString(@"User name cannot be empty")];
        return;
    }
    if (!self.pwdTextField.text.length) {
        [MBProgressHUD showError:DefLocalizedString(@"Password cannot be empty")];
        return;
    }
//    NSString *regex = @"((https?)://)?[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]";
//    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
//    if (![pred evaluateWithObject:self.addressTextField.text]) {
//        [MBProgressHUD showError:DefLocalizedString(@"Domain name filling out is not standard")];
//        return;
//    }
//    if ([self.addressTextField.text containsString:@"："] || [self.addressTextField.text containsString:@" "] || [self.addressTextField.text containsString:@"。"]) {
//           NSString *newStr = self.addressTextField.text;
//           newStr = [newStr stringByReplacingOccurrencesOfString:@"：" withString:@":"];
//           newStr = [newStr stringByReplacingOccurrencesOfString:@"。" withString:@"."];
//           newStr = [newStr stringByReplacingOccurrencesOfString:@" " withString:@""];
//           self.addressTextField.text = newStr;
//    }
//    NSString *orderListUrl;
//    if (![self.addressTextField.text hasPrefix:@"http"]) {
//        orderListUrl = [NSString stringWithFormat:@"http://%@",self.addressTextField.text];
//    }else{
//        orderListUrl = self.addressTextField.text;
//    }
//    NSString *lastString = [orderListUrl substringFromIndex:orderListUrl.length-1];
//   if([lastString isEqualToString:@"/"] || [lastString isEqualToString:@"、"] ){
//       orderListUrl = [orderListUrl substringToIndex:[orderListUrl length]-1];
//   }
   
//    [DefNSUD setObject:orderListUrl forKey:kBaseUrlString];
//    DefNSUDSynchronize
    
    UserManager *user = [UserManager manager];
    user.account = self.usenameTextField.text;
    if (user.isSavePwd) {
        user.password = self.pwdTextField.text;
    }else{
        user.password = @"";
    }
    NSString *orderListUrl = user.orderListUrl;
//    user.orderListUrl = orderListUrl;
    NSString *uniqueProjectip = user.orderListUrl;
//    if (uniqueProjectip) {
//        if([uniqueProjectip containsString:@"https:"]){
//            uniqueProjectip = [uniqueProjectip stringByReplacingOccurrencesOfString:@"https://" withString:@""];
//        }else if ([uniqueProjectip containsString:@"http:"]){
//            uniqueProjectip = [uniqueProjectip stringByReplacingOccurrencesOfString:@"http://" withString:@""];
//        }
//        if ([uniqueProjectip containsString:@":"]) {
//            NSRange range = [uniqueProjectip rangeOfString:@":" options:NSBackwardsSearch];
//            uniqueProjectip = [uniqueProjectip substringToIndex:range.location];
//        }
//    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *param = @{@"fLoginname":self.usenameTextField.text,
                            @"fPassword":self.pwdTextField.text,
                            @"deviceType":@"IOS",
                            @"uniqueProjectip":uniqueProjectip
                          };
    [NetService bg_postWithPath:BGUserLoginAddress params:param success:^(id respObjc) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UserManager *user = [UserManager manager];
        user.loginData = respObjc[kdata];
        user.token = respObjc[kdata][@"authorization"];
        user.versionURLForEnergy = respObjc[kdata][@"versionURL3"];
        DefLog(@"%@",respObjc);
        //给IP地址存入
        NSMutableArray *orderUrlMutArr = nil;
        if (user.orderUrlArray.count>0) {
            orderUrlMutArr = [user.orderUrlArray mutableCopy];
            BOOL isNeedAdd = YES;
            for (NSDictionary *ipdic in user.orderUrlArray) {
                NSString *url = [NSString changgeNonulWithString:ipdic[@"ipAddress"]];
                if ([url isEqualToString:orderListUrl]) {
                    isNeedAdd = NO;
                }
            }
            if (isNeedAdd) {
                NSString *isSave = user.isSavePwd?@"YES":@"NO";
                NSDictionary *orderObject = @{@"ipAddress":orderListUrl,@"account":weakSelf.usenameTextField.text,@"pwd":weakSelf.pwdTextField.text,@"isSavePwd":isSave};
                [orderUrlMutArr addObject:orderObject];
            }
        }else{
            orderUrlMutArr = [NSMutableArray new];
            NSString *isSave = user.isSavePwd?@"YES":@"NO";
            NSDictionary *orderObject = @{@"ipAddress":orderListUrl,@"account":weakSelf.usenameTextField.text,@"pwd":weakSelf.pwdTextField.text,@"isSavePwd":isSave};
            [orderUrlMutArr addObject:orderObject];
        }
        user.orderUrlArray = [orderUrlMutArr copy];
        //存userid
        NSString *userId = [NSString changgeNonulWithString:respObjc
                            [kdata][@"userId"]];
        if (userId) {
            user.bguserId = userId;
//            [self setDefaultRealmForUser:userId];
        }
        NSString *verStr = [NSString changgeNonulWithString:respObjc[kdata][@"webAPIInfo"][@"fVersion"]];
        if (verStr.length) {
            user.versionNo = verStr;
            user.autoLogin = YES;
            [weakSelf makeRootMenu];
        }else{
            [MBProgressHUD showError:@"登录失败，未获取到版本号"];
        }
        
        //能耗管理
        NSDictionary *partyInfo = respObjc[kdata][@"partyUserInfo"];
        if (partyInfo) {
            NSDictionary *energy = partyInfo[@"energy"];
            if (energy) {
                NSString *dns = [energy objectForKeyNotNull:@"dns"];
                NSString *accountNum = [energy objectForKeyNotNull:@"accountNum"];
                NSString *password = [energy objectForKeyNotNull:@"password"];
                user.energyDns = dns;
                user.energyPassword = password;
                user.energyAccountNum = accountNum;
            }
        }
        
        //动态配置视频
        if ([respObjc[kdata] isKindOfClass:[NSDictionary class]] && [respObjc[kdata] objectForKey:@"messagePushInfo"]) {
            NSDictionary *pushInfo = respObjc[kdata][@"messagePushInfo"];
            if ([pushInfo objectForKey:@"messageIOSKey"] && [pushInfo objectForKey:@"messageIOSSecret"]) {
               NSString *messageIOSKey = [pushInfo bg_StringForKeyNotNull:@"messageIOSKey"];
               NSString *messageIOSSecret = [pushInfo bg_StringForKeyNotNull:@"messageIOSSecret"];
               if (messageIOSKey.length && messageIOSSecret.length) {
                   user.emasAppKey = messageIOSKey;
                   user.emasAppSecret = messageIOSSecret;
               }
               // 初始化推送SDK
               [weakSelf initCloudPush];
               NSString *aliasId = [NSString stringWithFormat:@"%@-%@",uniqueProjectip,user.bguserId];
               user.userIdForAlias = aliasId;
               [weakSelf addAlias:user.userIdForAlias];
           }
        }
        
        //配置百度鹰眼轨迹
        NSDictionary *trajectory = respObjc[kdata][@"trajectory"];
        if (trajectory) {
            user.yytjBaiduDic = trajectory;
            NSString *isOpenBaidu = [NSString changgeNonulWithString:trajectory[@"tjIsUsing"]];
            if ([isOpenBaidu isEqualToString:@"1"]) {
                user.isOpenTjBaidu = YES;
            }else{
                user.isOpenTjBaidu = NO;
            }
        }
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (errorMsg) {
            [MBProgressHUD showError:errorMsg toView:self.view withAfterDelay:2.0f];
        }else{
            [MBProgressHUD showError:@"请求失败,请检查网络链接或域名地址" toView:self.view withAfterDelay:2.0f];
        }
    }];
}

//savePwd
-(void)checkBtnEvent:(UIButton *)btn12{
    UserManager *user = [UserManager manager];
    btn12.selected = !btn12.selected;
    if (btn12.selected) {
        btn12.layer.borderWidth = 0;
        user.isSavePwd = YES;
    }else{
        btn12.layer.borderWidth = 1;
        user.isSavePwd = NO;
    }
}

-(void)labelClick:(UIButton *)label{
    UserManager *user = [UserManager manager];
    self.checkBtn.selected = !self.checkBtn.selected;
    if (self.checkBtn.selected) {
        self.checkBtn.layer.borderWidth = 0;
        user.isSavePwd = YES;
    }else{
        self.checkBtn.layer.borderWidth = 1;
        user.isSavePwd = NO;
    }
}

#pragma mark - OtherMethod

-(void)setTheme{
    NSMutableArray<NSObject<QDThemeProtocol> *> *themes = [[NSMutableArray alloc] init];
    NSArray<NSString *> *allThemeClassName = @[NSStringFromClass([QMUIConfigurationTemplate class])];
    [allThemeClassName enumerateObjectsUsingBlock:^(NSString * _Nonnull className, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([QDThemeManager sharedInstance].currentTheme && [className isEqualToString:NSStringFromClass([QDThemeManager sharedInstance].currentTheme.class)]) {
            [themes addObject:[QDThemeManager sharedInstance].currentTheme];
        } else {
            [themes addObject:[[NSClassFromString(className) alloc] init]];
        }
    }];
    self.themes = [themes copy];
    
    [QDThemeManager sharedInstance].currentTheme = self.themes.firstObject;
    [[NSUserDefaults standardUserDefaults] setObject:NSStringFromClass(self.themes.firstObject.class) forKey:QDSelectedThemeClassName];
}

-(void)makeRootMenu{
    BGWeakSelf;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UserManager *user = [UserManager manager];
        NSDictionary *rootData = [respObjc objectForKeyNotNull:kdata];
       if (rootData) {
           NSArray *menuArr = [rootData objectForKeyNotNull:@"rootMenu"];
           if (!menuArr || !menuArr.count) {
               DefQuickAlert(@"为确保正常显示，请前往网页端配置APP菜单功能，并至少添加一个tab页功能", nil);
               return ;
           }
           user.rootMenuData = respObjc[kdata];
           NSString *imageSysBaseUrl = respObjc[kdata][@"iconUrl"];
           [DefNSUD setObject:imageSysBaseUrl forKey:@"systemImageUrlstr"];
           DefNSUDSynchronize
           [weakSelf createTabBarController];
       }else{
           DefQuickAlert(@"为确保正常显示，请前往网页端配置APP菜单功能，并至少添加一个tab页功能", nil);
       }
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
    }];
}



- (void)initCloudPush {
    // 正式上线建议关闭
//    [CloudPushSDK turnOnDebug];
    // SDK初始化，手动输出appKey和appSecret
    UserManager *user = [UserManager manager];
//    user.emasAppSecret = EMASAppSecret;
//    user.emasAppKey = EMASAppKey;
    if (user.emasAppKey.length && user.emasAppSecret.length) {
        [CloudPushSDK asyncInit:user.emasAppKey appSecret:user.emasAppSecret callback:^(CloudPushCallbackResult *res) {
            if (res.success) {
                NSLog(@"Push SDK init success, deviceId: %@. ", [CloudPushSDK getDeviceId]);
            } else {
                NSLog(@"Push SDK init failed, error: %@", res.error);
            }
        }];
    }
    
    
    // SDK初始化，无需输入配置信息
    // 请从控制台下载AliyunEmasServices-Info.plist配置文件，并正确拖入工程
//    [CloudPushSDK autoInit:^(CloudPushCallbackResult *res) {
//        if (res.success) {
//            NSLog(@"Push SDK init success, deviceId: %@.", [CloudPushSDK getDeviceId]);
//        } else {
//            NSLog(@"Push SDK init failed, error: %@", res.error);
//        }
//    }];
}

- (void)createTabBarController {
    QDTabBarViewController *tabBarViewController = [[QDTabBarViewController alloc] init];
    [UIApplication sharedApplication].keyWindow.rootViewController = tabBarViewController;
}

- (void)addAlias:(NSString *)alias {
    [CloudPushSDK removeAlias:nil withCallback:^(CloudPushCallbackResult *res) {
              if (res.success) {
                  DefLog(@"别名移除成功,别名：%@",alias);
              } else {
                  DefLog(@"别名移除失败，错误: %@", res.error);
              }
            [CloudPushSDK addAlias:alias withCallback:^(CloudPushCallbackResult *res) {
                if (res.success) {
                    DefLog(@"别名添加成功,别名：%@",alias);
                } else {
                    DefLog(@"别名添加失败，错误: %@", res.error);
                }
            }];
    }];
}

#pragma mark 键盘处理
- (void)keyboardWillChangeFrame:(NSNotification *)note{
    UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
    if ([keywindow performSelector:@selector(firstResponder)] == self.pwdTextField ) {
        if (SCREEN_HEIGHT < 700) {
            // 取出键盘最终的frame
           CGRect rect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
           // 取出键盘弹出需要花费的时间
           double duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
           // 修改transform
           [UIView animateWithDuration:duration animations:^{
               CGFloat ty = [UIScreen mainScreen].bounds.size.height - rect.origin.y;
               self.view.transform = CGAffineTransformMakeTranslation(0, - ty);
           }];
        }
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame =CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == self.pwdTextField){
        [textField resignFirstResponder];
        [self signInClickEvent:self.loginInBtn];
    }else{
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark - Lazy
-(QMUITextField *)usenameTextField{
    if (!_usenameTextField) {
        _usenameTextField = [[QMUITextField alloc] init];
        _usenameTextField.placeholder = DefLocalizedString(@"usernameText");
    }
    return _usenameTextField;
}

-(QMUITextField *)pwdTextField{
    if (!_pwdTextField) {
        _pwdTextField = [[QMUITextField alloc] init];
        _pwdTextField.placeholder = DefLocalizedString(@"passwordText");
    }
    return _pwdTextField;
}

-(UIView *)loginBgView{
    if (!_loginBgView) {
        _loginBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _loginBgView.backgroundColor = [UIColor whiteColor];
        [_loginBgView.layer setMasksToBounds:NO];
        [_loginBgView.layer setCornerRadius:10.0];
//        [_loginBgView.layer setBorderWidth:1.0];
        // 阴影颜色
        _loginBgView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
           // 阴影偏移，默认(0, -3)
           _loginBgView.layer.shadowOffset = CGSizeMake(0,0);
           // 阴影透明度，默认0
           _loginBgView.layer.shadowOpacity = 0.9f;
           // 阴影半径，默认3
           _loginBgView.layer.shadowRadius = 5;
    }
    return _loginBgView;
}

-(UIImageView *)imageV{
    if (!_imageV) {
        _imageV =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login-icon1"]];
    }
    return _imageV;
}

-(UIImageView *)imageVPwd{
    if (!_imageVPwd) {
        _imageVPwd =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login-icon2"]];
    }
    return _imageVPwd;
}
-(QMUIButton *)settingBtn{
    if (!_settingBtn) {
            _settingBtn = [[QMUIButton alloc] init];
            _settingBtn.backgroundColor = UIColorWhite;
            [_settingBtn setImage:[UIImage imageNamed:@"settingIP"] forState:UIControlStateNormal];
            [_settingBtn setTitle:@"IP配置" forState:UIControlStateNormal];
            [_settingBtn setTitleColor:COLOR_TEXT forState:UIControlStateNormal];
            [_settingBtn addTarget:self action:@selector(pushSetIPViewC) forControlEvents:UIControlEventTouchUpInside];
            _settingBtn.imagePosition = QMUIButtonImagePositionLeft;
            _settingBtn.spacingBetweenImageAndTitle = 0.5f;
            _settingBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
//            [_settingBtn.layer setMasksToBounds:YES];
//            [_settingBtn.layer setCornerRadius:10.0];
//            [_settingBtn.layer setBorderWidth:1.0];
        }
        return _settingBtn;
}

-(QMUIButton *)loginInBtn{
    if (!_loginInBtn) {
        _loginInBtn = [[QMUIButton alloc] init];
        _loginInBtn.backgroundColor = COLOR_TEXT;
        [_loginInBtn setTitle:DefLocalizedString(@"SignIn") forState:UIControlStateNormal];
        [_loginInBtn addTarget:self action:@selector(signInClickEvent:) forControlEvents:UIControlEventTouchUpInside];
        [_loginInBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginInBtn.layer setMasksToBounds:YES];
        [_loginInBtn.layer setCornerRadius:25.0];
//        [_loginInBtn.layer setBorderWidth:1.0];
    }
    return _loginInBtn;
}

-(UIButton *)checkBtn{
    if (!_checkBtn) {
        _checkBtn = [[UIButton alloc] init];
        [_checkBtn.layer setMasksToBounds:YES];
        _checkBtn.layer.borderWidth = 1;
        _checkBtn.layer.borderColor = [[UIColor grayColor]CGColor];
        _checkBtn.layer.cornerRadius = 2;
        [_checkBtn addTarget:self action:@selector(checkBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
        [_checkBtn setBackgroundImage:[UIImage imageNamed:@"dc.png"] forState:UIControlStateSelected];
    }
    return _checkBtn;
}


@end
