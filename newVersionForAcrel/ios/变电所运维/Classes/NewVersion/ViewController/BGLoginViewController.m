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

@interface BGLoginViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *hbgView;//上半部背景
@property (weak, nonatomic) IBOutlet UIButton *signInBtn;//登录按钮
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;//域名
@property (weak, nonatomic) IBOutlet UITextField *usenameTextField;//用户名
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;//密码
@property (weak, nonatomic) IBOutlet UIView *pwdBottomLine;
@property(nonatomic, copy) NSArray<NSObject<QDThemeProtocol> *> *themes;

@property(nonatomic,strong)UIButton *checkBtn;

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
    [label12 setTitle:@"记住密码" forState:UIControlStateNormal];
    label12.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [label12 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [label12 addTarget:self action:@selector(labelClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:label12];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
//    [self.pwdTextField addTarget:self action:@selector(keyboardWillChangeFrame:) forControlEvents:UIControlEventEditingDidBegin];
    //输入结束
    [self.pwdTextField addTarget:self action:@selector(textFieldEditEnd) forControlEvents:UIControlEventEditingDidEnd];

    
    //检查版本升级
    [[BGCheckAppVersionMgr sharedInstance] isUpdataApp:kAppleId andCompelete:^(NSString * _Nonnull respObjc) {
        
    }];
    [self setTheme];
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
    NSString *orderListUrl;
    if (![self.addressTextField.text hasPrefix:@"http"]) {
        orderListUrl = [NSString stringWithFormat:@"http://%@",self.addressTextField.text];
    }else{
        orderListUrl = self.addressTextField.text;
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
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *param = @{@"fLoginname":self.usenameTextField.text,
                            @"fPassword":self.pwdTextField.text,
                            @"deviceType":@"IOS"
                        };
    [NetService bg_postWithPath:BGUserLoginAddress params:param success:^(id respObjc) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UserManager *user = [UserManager manager];
        user.token = respObjc[kdata][@"authorization"];
        
//        NSDictionary *userInfo = respObjc[kdata][@"userInfo"];
//        if (userInfo) {
//            NSString *username = [userInfo bg_StringForKeyNotNull:@"fUsername"];
//            user.bgnickName = username;
//        }
        NSString *userId = [NSString changgeNonulWithString:respObjc
                            [kdata][@"userId"]];
        if (userId) {
            user.bguserId = userId;
        }
        NSString *verStr = [NSString changgeNonulWithString:respObjc[kdata][@"webAPIInfo"][@"fVersion"]];
        if (verStr.length) {
            user.versionNo = verStr;
            user.autoLogin = YES;
            [weakSelf makeRootMenu];
        }else{
            [MBProgressHUD showError:@"登录失败，未获取到版本号"];
        }
        DefLog(@"%@",respObjc);
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (errorMsg) {
            [MBProgressHUD showError:errorMsg toView:self.view withAfterDelay:2.0f];
        }else{
            [MBProgressHUD showError:@"请求失败,请检查域名/服务器地址" toView:self.view withAfterDelay:2.0f];
        }
    }];
//    [NetService bg_postWithPath:@"http://192.168.112.210:8080/web_manage/login.do" params:@{@"":@""}
}

-(void)makeRootMenu{
     BGWeakSelf;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [NetService bg_getWithTokenWithPath:BGGetRootMenu params:nil success:^(id respObjc) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UserManager *user = [UserManager manager];
        user.rootMenuData = respObjc[kdata];
        NSArray *menuArr = user.rootMenuData[@"rootMenu"];
        if (!menuArr.count) {
            [MBProgressHUD showError:@"为确保正常显示，请至少添加一个tab页功能"];
            
        }
        NSString *imageSysBaseUrl = respObjc[kdata][@"iconUrl"];
        [DefNSUD setObject:imageSysBaseUrl forKey:@"systemImageUrlstr"];
        DefNSUDSynchronize
        [weakSelf createTabBarController];
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
    }];
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
    if ([keywindow performSelector:@selector(firstResponder)] == self.pwdTextField) {
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
    self.pwdTextField.text = @"Acrel123654";
    self.usenameTextField.text = @"admin";
    self.addressTextField.text = @"http://116.236.149.162:8090";
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self creatView];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(30, SCREEN_HEIGHT-40, 100, 30);
    [button addTarget:self action:@selector(autoText:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}

@end
