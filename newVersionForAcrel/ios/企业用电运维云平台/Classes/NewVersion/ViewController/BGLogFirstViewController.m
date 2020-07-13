//
//  BGLogFirstViewController.m
//  企业用电运维云平台
//
//  Created by Acrel on 2020/7/2.
//

#import "BGLogFirstViewController.h"
#import "Masonry.h"
#import "BGLogSecondViewController.h"
#import "UIColor+BGExtension.h"
#import "UIColor+BGExtension.h"

@interface BGLogFirstViewController ()<QMUITextFieldDelegate>
@property(nonatomic,strong)QMUITextField * IPTextField;
@property(nonatomic,strong)QMUILabel *IPLabel;//ipAdress
@property(nonatomic,strong)UIView *bgView;
@property(nonatomic,strong)UIView *ipBgView;
@property(nonatomic,strong)UIImageView *imageV;
@property(nonatomic,strong)QMUIButton *saveIpBtn;
@property(nonatomic,strong)UIImageView *imageViewFbg;
@property (nonatomic, strong)UIButton *selectAddress;
@property (nonatomic, strong) QMUIPopupMenuView *popupByWindow;

@end

@implementation BGLogFirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createView];
    self.title = DefLocalizedString(@"IPAddress");
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.isPush) {
        self.navigationController.navigationBarHidden = NO;
    }
//    UserManager *user = [UserManager manager];
  //添加多选按钮 ip地址保存
      
}

-(void)createView{
   self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
//   [self.bgView.layer addSublayer:[UIColor setGradualChangingColor:self.bgView fromColor:COLOR_LightLWithChangeIn16 toColor:COLOR_DeepLWithChangeIn16]];
//   UIImageView *imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login-p"]];
//   imageV.frame = CGRectMake((SCREEN_WIDTH-imageV.frame.size.width)/2, 80, imageV.frame.size.width, imageV.frame.size.height);
//   UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageV.frame.size.height+95, SCREEN_WIDTH, 50)];
//
//
//   label.text = NSLocalizedString(@"LoginText",nil);
//   label.textAlignment = NSTextAlignmentCenter;
//   [label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:23]];
//   label.textColor = [UIColor whiteColor];
//   [self.bgView addSubview:imageV];
//   [self.bgView addSubview:label];
    [self.bgView addSubview:self.imageViewFbg];
    [self.view addSubview:self.bgView];
//   [self.view bringSubviewToFront:self.settingBtn];
//   [self.view bringSubviewToFront:self.loginBgView];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = COLOR_TEXT;
    [self.view addSubview:self.ipBgView];
    [self.ipBgView addSubview:self.imageV];
    [self.ipBgView addSubview:lineView];
    [self.ipBgView addSubview:self.IPTextField];
    self.IPTextField.delegate = self;
    [self.view addSubview:self.saveIpBtn];
    
    [self.imageViewFbg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@0);
        make.right.mas_equalTo(@0);
//        if (self.isPush) {
//            make.top.mas_offset(NavigationContentTop);
//        }else{
             make.top.mas_equalTo(@0);
//        }
        make.height.mas_offset(SCREEN_WIDTH);
    }];
    
    [self.ipBgView mas_makeConstraints:^(MASConstraintMaker *make) {
             make.left.mas_equalTo(@10);
             make.right.mas_equalTo(@-10);
//             make.top.mas_equalTo(@200);
//             make.centerY.equalTo(self.view);
             make.top.equalTo(self.imageViewFbg.mas_bottom).offset(30);
             make.height.mas_offset(180);
     //        make.bottom.equalTo(self.view).with.offset(0);
     }];
         
     [self.imageV mas_makeConstraints:^(MASConstraintMaker *make) {
 //        make.left.mas_equalTo(@15);
         make.left.equalTo(self.ipBgView.mas_left).offset(15);
         make.top.mas_equalTo(@30);
         make.width.mas_offset(20);
         make.height.mas_offset(20);
     }];
     
     [self.IPTextField mas_makeConstraints:^(MASConstraintMaker *make) {
         make.centerY.equalTo(self.imageV);
         make.left.equalTo(self.imageV.mas_right).offset(3);
         make.right.equalTo(self.ipBgView.mas_right).offset(-15);
         make.height.mas_offset(50);
     }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imageV.mas_left).offset(0);
        make.top.equalTo(self.IPTextField.mas_bottom).offset(0);
        make.right.equalTo(self.IPTextField.mas_right).offset(0);
        make.height.mas_offset(1);
    }];
    
    [self.saveIpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.ipBgView);
        make.top.equalTo(lineView.mas_bottom).offset(50);
        make.left.equalTo(self.ipBgView.mas_left).offset(30);
        make.right.equalTo(self.ipBgView.mas_right).offset(-30);
        make.height.mas_offset(52);
    }];
    [self.saveIpBtn.layer addSublayer:[UIColor setGradualChangingColor:self.saveIpBtn fromColor:COLOR_LightLWithChangeIn16 toColor:COLOR_DeepLWithChangeIn16]];
    UserManager *user = [UserManager manager];
    if (user.orderUrlArray.count>1) {
      //          self.selectAddress = [[UIButton alloc] initWithFrame:CGRectMake(self.addressTextField.frame.size.width-30,(self.ipAddressView.frame.size.height+20)/2 + 1, 20, 20)];
    //          self.selectAddress = [[UIButton alloc] initWithFrame:CGRectMake(self.IPTextField.frame.size.width-30,0,self.IPTextField.frame.size.height,self.IPTextField.frame.size.height)];
              
              [self.selectAddress mas_makeConstraints:^(MASConstraintMaker *make) {
                  make.centerY.equalTo(self.imageV);
                  make.right.equalTo(self.IPTextField.mas_right).offset(-25);
                  make.height.mas_offset(20);
                  make.width.mas_offset(20);
              }];
              //    self.selectAddress.layer.borderWidth = 1;
              //    self.selectAddress.layer.borderColor = [[UIColor grayColor]CGColor];
              //    self.selectAddress.layer.cornerRadius = 2;
                  
      //            [self.selectAddress setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
              [self.ipBgView addSubview:self.selectAddress];
          }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [self pushLoginViewC];
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

-(void)pushLoginViewC{
    if (self.isPush) {
         [self.navigationController popViewControllerAnimated:YES];
    } else {
        if (self.IPTextField.text && self.IPTextField.text.length>0) {
            BGLogSecondViewController *secVC = [[BGLogSecondViewController alloc] init];
            QMUINavigationController *navi = [[QMUINavigationController alloc] initWithRootViewController:secVC];
            [UIApplication sharedApplication].keyWindow.rootViewController = navi;
        } else {
            DefQuickAlert(@"域名地址不能为空", nil);
        }
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
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
                weakSelf.IPTextField.text = aItem.title;
//                weakSelf.usenameTextField.text = [NSString changgeNonulWithString:orderObject[@"account"]];
//                NSString *issave = [NSString changgeNonulWithString:orderObject[@"isSavePwd"]];
//                if ([issave isEqualToString:@"YES"]) {
//                    weakSelf.pwdTextField.text = [NSString changgeNonulWithString:orderObject[@"pwd"]];
//                }else{
//                    weakSelf.pwdTextField.text = @"";
//                }
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

#pragma mark - Lazy
-(QMUITextField *)IPTextField{
    if (!_IPTextField) {
        _IPTextField = [[QMUITextField alloc] init];
        _IPTextField.placeholder = DefLocalizedString(@"serverAddressText");
        _IPTextField.placeholderColor = COLOR_TEXT;
        _IPTextField.keyboardType = UIKeyboardTypeASCIICapable;
        _IPTextField.returnKeyType = UIReturnKeyDone;
    }
    return _IPTextField;
}

-(QMUILabel *)IPLabel{
    if (!_IPLabel) {
        _IPLabel = [[QMUILabel alloc] init];
        _IPLabel.text = DefLocalizedString(@"");
    }
    return _IPLabel;
}

-(UIView *)ipBgView{
    if (!_ipBgView) {
        _ipBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _ipBgView.backgroundColor = [UIColor whiteColor];
        [_ipBgView.layer setMasksToBounds:YES];
        [_ipBgView.layer setCornerRadius:10.0];
//        [_ipBgView.layer setBorderWidth:1.0];
    }
    return _ipBgView;
}

-(UIImageView *)imageV{
    if (!_imageV) {
        _imageV =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipaddress2"]];
        
    }
    return _imageV;
}

-(QMUIButton *)saveIpBtn{
    if (!_saveIpBtn) {
        _saveIpBtn = [[QMUIButton alloc] init];
        _saveIpBtn.backgroundColor = COLOR_TEXT;
        [_saveIpBtn setTitle:DefLocalizedString(@"SaveTwo") forState:UIControlStateNormal];
        [_saveIpBtn addTarget:self action:@selector(pushLoginViewC) forControlEvents:UIControlEventTouchUpInside];
        [_saveIpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [_saveIpBtn.layer setMasksToBounds:YES];
        [_saveIpBtn.layer setCornerRadius:25.0];
//        [_saveIpBtn.layer setBorderWidth:1.0];
    }
    return _saveIpBtn;
}

-(UIImageView *)imageViewFbg{
    if (!_imageViewFbg) {
        _imageViewFbg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bgfirstp"]];
    }
    return _imageViewFbg;
}

-(UIButton *)selectAddress{
    if (!_selectAddress) {
        _selectAddress = [[UIButton alloc] init];
        [_selectAddress addTarget:self action:@selector(showMoreIPAddress:) forControlEvents:UIControlEventTouchUpInside];
        //            [self.selectAddress setBackgroundImage:[UIImage imageNamed:@"ipdizhi"] forState:UIControlStateNormal];
        [_selectAddress setImage:[UIImage imageNamed:@"ipdizhi"] forState:UIControlStateNormal];
    }
    return _selectAddress;
}

@end
