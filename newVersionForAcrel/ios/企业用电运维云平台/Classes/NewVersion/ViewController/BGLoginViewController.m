//
//  BGLoginViewController.m
//  变电所运维
//
//  Created by Acrel on 2019/5/16.
//

#import "BGLoginViewController.h"
#import "UIColor+BGExtension.h"
#import "CustomMainTBViewController.h"
#import "BGCheckAppVersionMgr.h"
#import "QDTabBarViewController.h"
#import "QDUIKitViewController.h"
#import "QDNavigationController.h"
#import "QDComponentsViewController.h"
#import "QDLabViewController.h"

#import "BGQMHomeViewController.h"
#import "BGQMAlarmViewController.h"
#import "BGQMElectViewController.h"
#import "BGQMUIInspectViewController.h"
#import "BGQMUserViewController.h"
#import "QMUIConfigurationTemplate.h"
#import <CloudPushSDK/CloudPushSDK.h>

#import "BGLogFirstViewController.h"

//首先导入头文件信息
//#include <ifaddrs.h>
//#include <arpa/inet.h>
//#include <net/if.h>
//#define IOS_CELLULAR    @"pdp_ip0"
////有些分配的地址为en0 有些分配的en1
//#define IOS_WIFI2       @"en2"
//#define IOS_WIFI1       @"en1"
//#define IOS_WIFI        @"en0"
////#define IOS_VPN       @"utun0"  vpn很少用到可以注释
//#define IP_ADDR_IPv4    @"ipv4"
//#define IP_ADDR_IPv6    @"ipv6"

@interface BGLoginViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *hbgView;//上半部背景
@property (weak, nonatomic) IBOutlet UIButton *signInBtn;//登录按钮
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;//域名
@property (weak, nonatomic) IBOutlet UITextField *usenameTextField;//用户名
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;//密码
@property (weak, nonatomic) IBOutlet UIView *pwdBottomLine;
@property (weak, nonatomic) IBOutlet UIView *ipAddressView;
@property (nonatomic, copy) NSArray<NSObject<QDThemeProtocol> *> *themes;
@property (nonatomic, strong) QMUIPopupMenuView *popupByWindow;
@property (nonatomic, strong)UIButton *checkBtn;
@property (nonatomic, strong)UIButton *selectAddress;

@end

@implementation BGLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    //初始化页面
    // Do any additional setup after loading the view from its nib.
}

- (void)creatView{
    self.navigationController.navigationBar.hidden = YES;
    // - 初始化
    //渐变色：87 178 247   57 124 207
    self.hbgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 250);
//    self.hbgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.hbgView.layer addSublayer:[UIColor setGradualChangingColor:self.hbgView fromColor:COLOR_LightLWithChangeIn16 toColor:COLOR_DeepLWithChangeIn16]];
    UIImageView *imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login-p"]];
    imageV.frame = CGRectMake((SCREEN_WIDTH-imageV.frame.size.width)/2, 40, imageV.frame.size.width, imageV.frame.size.height);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageV.frame.size.height+45, SCREEN_WIDTH, 50)];
    
    label.text = NSLocalizedString(@"LoginText",nil);
    label.textAlignment = NSTextAlignmentCenter;
    [label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:23]];
    label.textColor = [UIColor whiteColor];
    [self.hbgView addSubview:imageV];
    [self.hbgView addSubview:label];
    [self.signInBtn.layer addSublayer:[UIColor setGradualChangingColor:self.signInBtn fromColor:COLOR_LightLWithChangeIn16 toColor:COLOR_DeepLWithChangeIn16]];
    [self.signInBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:19.f]];
    self.signInBtn.layer.cornerRadius = self.signInBtn.frame.size.height/2;
    self.signInBtn.layer.masksToBounds = YES;
    [self.signInBtn setTitle:DefLocalizedString(@"SignIn") forState:UIControlStateNormal];
//    self.signInBtn.layer.shadowOffset = CGSizeMake(0, 3);
//    self.signInBtn.layer.shadowOpacity = 0.6;
//    self.signInBtn.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.signInBtn.frame].CGPath;
    self.addressTextField.delegate = self;
    self.usenameTextField.delegate = self;
    self.pwdTextField.delegate = self;
    self.addressTextField.keyboardType = UIKeyboardTypeASCIICapable;
    self.addressTextField.placeholder = NSLocalizedString(@"serverAddressText",nil);
    self.usenameTextField.placeholder = NSLocalizedString(@"usernameText",nil);
    self.pwdTextField.placeholder = NSLocalizedString(@"passwordText",nil);
    self.pwdTextField.secureTextEntry = YES;
    
    UserManager *user = [UserManager manager];
    self.checkBtn = [[UIButton alloc]initWithFrame:CGRectMake(32, self.signInBtn.frame.origin.y-40, 16, 16)];
    self.checkBtn.layer.borderWidth = 1;
    self.checkBtn.layer.borderColor = [[UIColor grayColor]CGColor];
    self.checkBtn.layer.cornerRadius = 2;
    if(user.isSavePwd){
        self.checkBtn.selected = YES;
        self.checkBtn.layer.borderWidth = 0;
        user.isSavePwd = YES;
    }
    [self.checkBtn addTarget:self action:@selector(checkBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.checkBtn setBackgroundImage:[UIImage imageNamed:@"dc.png"] forState:UIControlStateSelected];
    [self.view addSubview:self.checkBtn];
    
    UIButton *label12 = [[UIButton alloc]initWithFrame:CGRectMake(self.checkBtn.frame.size.width+5+32, self.signInBtn.frame.origin.y-47, 70, 30)];
    [label12 setTitle:DefLocalizedString(@"savePassword") forState:UIControlStateNormal];
    label12.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [label12 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [label12 addTarget:self action:@selector(labelClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:label12];
    
    
    UIButton *label13 = [[UIButton alloc]initWithFrame:CGRectMake(self.checkBtn.frame.size.width+5+132, self.signInBtn.frame.origin.y-47, 70, 30)];
       [label13 setTitle:@"跳转" forState:UIControlStateNormal];
       label13.titleLabel.font = [UIFont systemFontOfSize:15.f];
       [label13 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
       [label13 addTarget:self action:@selector(labelClick2:) forControlEvents:UIControlEventTouchUpInside];
       [self.view addSubview:label13];
    
    if (user.account.length) {
       self.usenameTextField.text = user.account;
    }
    if (user.orderListUrl.length) {
        self.addressTextField.text = user.orderListUrl;
    }
    if (user.password.length && user.isSavePwd) {
        self.pwdTextField.text = user.password;
    }else{
        self.pwdTextField.text = @"";
    }
    
    //添加多选按钮 ip地址保存
    if (user.orderUrlArray.count>1) {
//          self.selectAddress = [[UIButton alloc] initWithFrame:CGRectMake(self.addressTextField.frame.size.width-30,(self.ipAddressView.frame.size.height+20)/2 + 1, 20, 20)];
        self.selectAddress = [[UIButton alloc] initWithFrame:CGRectMake(self.addressTextField.frame.size.width-30,0,self.addressTextField.frame.size.height,self.addressTextField.frame.size.height)];
        //    self.selectAddress.layer.borderWidth = 1;
        //    self.selectAddress.layer.borderColor = [[UIColor grayColor]CGColor];
        //    self.selectAddress.layer.cornerRadius = 2;
            [self.selectAddress addTarget:self action:@selector(showMoreIPAddress:) forControlEvents:UIControlEventTouchUpInside];
//            [self.selectAddress setBackgroundImage:[UIImage imageNamed:@"ipdizhi"] forState:UIControlStateNormal];
            [self.selectAddress setImage:[UIImage imageNamed:@"ipdizhi"] forState:UIControlStateNormal];
//            [self.selectAddress setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            [self.addressTextField addSubview:self.selectAddress];
    }
   
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
//    [self.pwdTextField addTarget:self action:@selector(keyboardWillChangeFrame:) forControlEvents:UIControlEventEditingDidBegin];
    //输入结束
    [self.pwdTextField addTarget:self action:@selector(textFieldEditEnd) forControlEvents:UIControlEventEditingDidEnd];

    
    //检查版本升级 迭代更新
    [[BGCheckAppVersionMgr sharedInstance] isUpdataApp:kAppleId andCompelete:^(NSString * _Nonnull respObjc) {
        
    }];
    [self setTheme];
}

-(void)showMoreIPAddress:(UIButton *)showMoreBtn{
    UserManager *user = [UserManager manager];
    // 使用方法 2，以 UIWindow 的形式显示到界面上，这种无需默认隐藏，也无需 add 到某个 UIView 上
    __weak __typeof(self)weakSelf = self;
       self.popupByWindow = [[QMUIPopupMenuView alloc] init];
       self.popupByWindow.automaticallyHidesWhenUserTap = YES;// 点击空白地方消失浮层
       self.popupByWindow.maskViewBackgroundColor = UIColorMaskWhite;// 使用方法 2 并且打开了 automaticallyHidesWhenUserTap 的情况下，可以修改背景遮罩的颜色
       self.popupByWindow.shouldShowItemSeparator = YES;
       self.popupByWindow.preferLayoutDirection = QMUIPopupContainerViewLayoutDirectionBelow;
       self.popupByWindow.itemConfigurationHandler = ^(QMUIPopupMenuView *aMenuView, QMUIPopupMenuButtonItem *aItem, NSInteger section, NSInteger index) {
           // 利用 itemConfigurationHandler 批量设置所有 item 的样式
//           aItem.button.highlightedBackgroundColor = [UIColor.qd_tintColor colorWithAlphaComponent:.2];
       };
    

//    NSMutableSet *orderUrlMutArr = [user.orderUrlArray mutableCopy];
//    [orderUrlMutArr addObject:orderListUrl];
    NSMutableArray *orderMutArr = [NSMutableArray new];
    if(user.orderUrlArray.count>1){
//         NSDictionary *orderObject = @{@"ipAddress":orderListUrl,@"account":weakSelf.usenameTextField.text,@"pwd":weakSelf.pwdTextField.text,@"isSavePwd":isSave};
        for (NSDictionary *orderObject in user.orderUrlArray) {
            NSString *showIpAddress = [NSString changgeNonulWithString:orderObject[@"ipAddress"]];
            QMUIPopupMenuButtonItem *item = [QMUIPopupMenuButtonItem itemWithImage:[UIImageMake(@"icon_tabbar_component") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] title:showIpAddress handler:^(QMUIPopupMenuButtonItem *aItem) {
                weakSelf.addressTextField.text = aItem.title;
                weakSelf.usenameTextField.text = [NSString changgeNonulWithString:orderObject[@"account"]];
                NSString *issave = [NSString changgeNonulWithString:orderObject[@"isSavePwd"]];
                if ([issave isEqualToString:@"YES"]) {
                    weakSelf.pwdTextField.text = [NSString changgeNonulWithString:orderObject[@"pwd"]];
                }else{
                    weakSelf.pwdTextField.text = @"";
                }
                [aItem.menuView hideWithAnimated:YES];
            }];
            [orderMutArr addObject:item];
        }
    }
    self.popupByWindow.items = [orderMutArr copy];
    
       self.popupByWindow.didHideBlock = ^(BOOL hidesByUserTap) {
//           [weakSelf.button2 setTitle:@"显示菜单浮层" forState:UIControlStateNormal];
       };
       self.popupByWindow.sourceView = self.selectAddress;// 相对于 button2 布局
    
    [self.popupByWindow showWithAnimated:YES];
}

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

-(void)labelClick2:(UIButton *)label{
    BGLogFirstViewController *firstVC = [[BGLogFirstViewController alloc] init];
    [UIApplication sharedApplication].keyWindow.rootViewController = firstVC;
//    [self pushViewController:firstVC animation:YES];
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

//配置主题
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

- (IBAction)signInClickEvent:(UIButton *)sender {
    __weak __typeof(self)weakSelf = self;
    if (!self.addressTextField.text.length) {
        [MBProgressHUD showError:DefLocalizedString(@"Domain name cannot be empty")];
        return;
    }
    if (!self.usenameTextField.text.length) {
        [MBProgressHUD showError:DefLocalizedString(@"User name cannot be empty")];
        return;
    }
    if (!self.pwdTextField.text.length) {
        [MBProgressHUD showError:DefLocalizedString(@"Password cannot be empty")];
        return;
    }
    NSString *regex = @"((https?)://)?[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![pred evaluateWithObject:self.addressTextField.text]) {
        [MBProgressHUD showError:DefLocalizedString(@"Domain name filling out is not standard")];
        return;
    }
    if ([self.addressTextField.text containsString:@"："] || [self.addressTextField.text containsString:@" "] || [self.addressTextField.text containsString:@"。"]) {
           NSString *newStr = self.addressTextField.text;
           newStr = [newStr stringByReplacingOccurrencesOfString:@"：" withString:@":"];
           newStr = [newStr stringByReplacingOccurrencesOfString:@"。" withString:@"."];
           newStr = [newStr stringByReplacingOccurrencesOfString:@" " withString:@""];
           self.addressTextField.text = newStr;
    }
    NSString *orderListUrl;
    if (![self.addressTextField.text hasPrefix:@"http"]) {
        orderListUrl = [NSString stringWithFormat:@"http://%@",self.addressTextField.text];
    }else{
        orderListUrl = self.addressTextField.text;
    }
    NSString *lastString = [orderListUrl substringFromIndex:orderListUrl.length-1];
   if([lastString isEqualToString:@"/"] || [lastString isEqualToString:@"、"] ){
       orderListUrl = [orderListUrl substringToIndex:[orderListUrl length]-1];
   }
   
    [DefNSUD setObject:orderListUrl forKey:kBaseUrlString];
    DefNSUDSynchronize
    
    UserManager *user = [UserManager manager];
    user.account = self.usenameTextField.text;
    if (user.isSavePwd) {
        user.password = self.pwdTextField.text;
    }else{
        user.password = @"";
    }
   
    user.orderListUrl = orderListUrl;
    NSString *uniqueProjectip = orderListUrl;
    if (uniqueProjectip) {
        if([uniqueProjectip containsString:@"https:"]){
            uniqueProjectip = [uniqueProjectip stringByReplacingOccurrencesOfString:@"https://" withString:@""];
        }else if ([uniqueProjectip containsString:@"http:"]){
            uniqueProjectip = [uniqueProjectip stringByReplacingOccurrencesOfString:@"http://" withString:@""];
        }
        if ([uniqueProjectip containsString:@":"]) {
            NSRange range = [uniqueProjectip rangeOfString:@":" options:NSBackwardsSearch];
            uniqueProjectip = [uniqueProjectip substringToIndex:range.location];
        }
    }
    
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

//- (void)setDefaultRealmForUser:(NSString *)username {
//    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
//    // 设置新的架构版本。这个版本号必须高于之前所用的版本号（如果您之前从未设置过架构版本，那么这个版本号设置为 0）
//    config.schemaVersion = 2;
//
//    // 使用默认的目录，但是请将文件名替换为用户名
//    config.fileURL = [[[config.fileURL URLByDeletingLastPathComponent]
//                            URLByAppendingPathComponent:username]
//                            URLByAppendingPathExtension:@"realm"];
//
//    // 设置闭包，这个闭包将会在打开低于上面所设置版本号的 Realm 数据库的时候被自动调用
//    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
//        // 目前我们还未进行数据迁移，因此 oldSchemaVersion == 0
//        if (oldSchemaVersion < 1) {
//            // 什么都不要做！Realm 会自行检测新增和需要移除的属性，然后自动更新硬盘上的数据库架构
//        }
//    };
//
//    // 将该配置设置为默认 Realm 配置
//    [RLMRealmConfiguration setDefaultConfiguration:config];
//    // 现在我们已经告诉了 Realm 如何处理架构的变化，打开文件之后将会自动执行迁移
//    [RLMRealm defaultRealm];
//}


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

//-(void)getWebAPIVersion{
//    BGWeakSelf;
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    NSString *baseURL = [BASE_URL stringByAppendingString:BGUPdateAddress];
//    [NetService bg_httpGetWithTokenWithPath:baseURL params:nil success:^(id respObjc) {
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//        UserManager *user = [UserManager manager];
//
//        [weakSelf makeRootMenu];
//        [weakSelf createTabBarController];
//    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//        if (errorMsg) {
//            [MBProgressHUD showError:errorMsg toView:self.view withAfterDelay:2.0f];
//        }else{
//            [MBProgressHUD showError:@"请求失败" toView:self.view withAfterDelay:2.0f];
//        }
//    }];
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == self.pwdTextField){
        [textField resignFirstResponder];
        [self signInClickEvent:self.signInBtn];
    }else{
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

-(void)textFieldEditEnd{
    [self.view endEditing:YES];
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


- (void)createTabBarController {
    QDTabBarViewController *tabBarViewController = [[QDTabBarViewController alloc] init];
    [UIApplication sharedApplication].keyWindow.rootViewController = tabBarViewController;
}

- (IBAction)autoText:(UIButton *)sender {
//    self.pwdTextField.text = @"Acrel123654";
//    self.usenameTextField.text = @"admin";
//    self.addressTextField.text = @"http://116.236.149.162:8090";
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self creatView];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(30, SCREEN_HEIGHT-40, 100, 30);
    [button addTarget:self action:@selector(autoText:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}

//#pragma mark - 获取IP地址
////获取设备当前网络IP地址（是获取IPv4 还是 IPv6）
//- (NSString *)getIPAddress:(BOOL)preferIPv4
//{
//    //从字典中按顺序查询 查询到不为空即停止（顺序为4G(3G)、Wi-Fi、局域网）
//    NSArray *searchArray = preferIPv4 ?
//    @[ /*IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6,*/ IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_WIFI2 @"/" IP_ADDR_IPv4, IOS_WIFI1 @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv4] :
//    @[ /*IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4,*/ IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_WIFI2 @"/" IP_ADDR_IPv6, IOS_WIFI1 @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv6] ;
//
//    NSDictionary *addresses = [self getIPAddresses];
//    NSLog(@"addresses: %@", addresses);
//
//    __block NSString *address;
//    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
//        {
//            address = addresses[key];
//            if(address) *stop = YES;
//        } ];
//    return address ? address : @"0.0.0.0";
//}
//
////获取所有相关IP信息
//- (NSDictionary *)getIPAddresses
//{
//    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
//
//    // retrieve the current interfaces - returns 0 on success
//    struct ifaddrs *interfaces;
//    if(!getifaddrs(&interfaces)) {
//        // Loop through linked list of interfaces
//        struct ifaddrs *interface;
//        for(interface=interfaces; interface; interface=interface->ifa_next) {
//            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
//                continue; // deeply nested code harder to read
//            }
//            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
//            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
//            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
//                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
//                NSString *type;
//                if(addr->sin_family == AF_INET) {
//                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
//                        type = IP_ADDR_IPv4;
//                    }
//                } else {
//                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
//                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
//                        type = IP_ADDR_IPv6;
//                    }
//                }
//                if(type) {
//                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
//                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
//                }
//            }
//        }
//        // Free memory
//        freeifaddrs(interfaces);
//    }
//    return [addresses count] ? addresses : nil;
//}



@end
