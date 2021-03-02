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

@interface BGLogFirstViewController ()<QMUITextFieldDelegate,NSURLConnectionDelegate,NSURLConnectionDataDelegate,NSURLSessionDelegate,NSURLSessionTaskDelegate>
@property(nonatomic,strong)QMUITextField * IPTextField;
@property(nonatomic,strong)QMUILabel *IPLabel;//ipAdress
@property(nonatomic,strong)UIView *bgView;
@property(nonatomic,strong)UIView *ipBgView;
@property(nonatomic,strong)UIImageView *imageV;
@property(nonatomic,strong)QMUIButton *saveIpBtn;
@property(nonatomic,strong)UIImageView *imageViewFbg;
@property (nonatomic, strong)UIButton *selectAddress;
@property (nonatomic,strong)UIButton *promptBtn;
@property (nonatomic, strong) QMUIPopupMenuView *popupByWindow;
@property (nonatomic, strong) QMUIPopupMenuView *popupPrompt;
@property (nonatomic, assign) BOOL isSelected;

@end

@implementation BGLogFirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createView];
    self.title = DefLocalizedString(@"IPAddress");
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
       
   //增加监听，当键退出时收出消息
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.isPush) {
        self.navigationController.navigationBarHidden = NO;
    }else{
        self.navigationController.navigationBarHidden = YES;
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
        if (isPad) {
            make.height.mas_offset(@667);
        }else{
            make.height.mas_offset(SCREEN_WIDTH);
        }
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
              [self.ipBgView addSubview:self.selectAddress];
              [self.selectAddress mas_makeConstraints:^(MASConstraintMaker *make) {
                  make.centerY.equalTo(self.imageV);
                  make.right.equalTo(self.IPTextField.mas_right).offset(0);
                  make.height.mas_offset(20);
                  make.width.mas_offset(20);
              }];
              //    self.selectAddress.layer.borderWidth = 1;
              //    self.selectAddress.layer.borderColor = [[UIColor grayColor]CGColor];
              //    self.selectAddress.layer.cornerRadius = 2;
                  
      //            [self.selectAddress setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    }else{
        [self.ipBgView addSubview:self.promptBtn];
        [self.promptBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.imageV);
            make.right.equalTo(self.IPTextField.mas_right).offset(0);
            make.height.mas_offset(20);
            make.width.mas_offset(20);
        }];
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

#pragma mark - 点击保存事件
-(void)pushLoginViewC{
    if (!self.IPTextField.text) {
        [MBProgressHUD showError:DefLocalizedString(@"Domain name filling out is not standard")];
        return;
    }
    NSString *regex = @"((https?)://)?[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]";
       NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
       if (![pred evaluateWithObject:self.IPTextField.text]) {
           [MBProgressHUD showError:DefLocalizedString(@"Domain name filling out is not standard")];
           return;
       }
       if ([self.IPTextField.text containsString:@"："] || [self.IPTextField.text containsString:@" "] || [self.IPTextField.text containsString:@"。"]) {
              NSString *newStr = self.IPTextField.text;
              newStr = [newStr stringByReplacingOccurrencesOfString:@"：" withString:@":"];
              newStr = [newStr stringByReplacingOccurrencesOfString:@"。" withString:@"."];
              newStr = [newStr stringByReplacingOccurrencesOfString:@" " withString:@""];
              self.IPTextField.text = newStr;
       }
       NSString *orderListUrl;
       if (![self.IPTextField.text hasPrefix:@"http"]) {
           orderListUrl = [NSString stringWithFormat:@"http://%@",self.IPTextField.text];
       }else{
           orderListUrl = self.IPTextField.text;
       }
       NSString *lastString = [orderListUrl substringFromIndex:orderListUrl.length-1];
      if([lastString isEqualToString:@"/"] || [lastString isEqualToString:@"、"] ){
          orderListUrl = [orderListUrl substringToIndex:[orderListUrl length]-1];
      }
   
     UserManager *user = [UserManager manager];
    if(self.IPTextField.text.length>0 && [user.orderListUrl isEqualToString:orderListUrl]){
        user.orderListUrl = orderListUrl;
        //保存域名
        [DefNSUD setObject:orderListUrl forKey:kBaseUrlString];
        DefNSUDSynchronize
    }else if (self.isSelected){
        user.orderListUrl = orderListUrl;
        //保存域名
        [DefNSUD setObject:orderListUrl forKey:kBaseUrlString];
        DefNSUDSynchronize
    }else{
        user.orderListUrl = orderListUrl;
        //保存域名
        [DefNSUD setObject:orderListUrl forKey:kBaseUrlString];
         DefNSUDSynchronize
        user.account = @"";
        user.password = @"";
    }
    
    if (!user.orderListUrl) {
        [MBProgressHUD showError:DefLocalizedString(@"Domain name filling out is not standard")];
        return;
    }
    
    
    //获取登录页配置
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if([orderListUrl containsString:@"https:"]){
        //如果是https域名，访问不通降级http
        [self testUrlHttp:orderListUrl];
    }else if ([orderListUrl containsString:@"http:"]){
        //如果是http域名，访问不通升级https
        [self testUrlHttps:orderListUrl];
    }else{
        [self checkUrlWithhttpORhttps:orderListUrl];
    }
    
    
    //监测域名地址是否可以访问
//    [self urliSAvailable:uniqueProjectip];
//    [NetService bg_getWithTestPath:@"sys/testIPValid" params:@{@"ipAddress":uniqueProjectip} success:^(id respObjc) {
//        DefLog(@"%@",respObjc);
//    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
//        DefLog(@"%@",respObjc);
//    }];
    
}


-(void)checkUrlWithhttpORhttps:(NSString *)unqiue{
    BGWeakSelf;
    UserManager *user = [UserManager manager];
    [NetService bg_getIPAddressWithPath:@"main/getAppIndexSets" params:@{@"ip":unqiue} success:^(id respObjc) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        DefLog(@"respObj");
        NSDictionary *dataDic = respObjc[@"data"];
        if (dataDic) {
           NSString *appIndexsset = [NSString changgeNonulWithString:dataDic[@"appIndexSets"]];
           NSString *imageUrl = [NSString changgeNonulWithString:dataDic[@"imgURL"]];
           if(appIndexsset){
               user.appIndexSet = appIndexsset;
           }
           if (imageUrl) {
               [DefNSUD setObject:imageUrl forKey:@"APPLoginImageUrl"];
                DefNSUDSynchronize
           }
           NSString *indexEncryot = [NSString changgeNonulWithString:dataDic[@"indexencryptAll"]];
            if (indexEncryot) {
                user.indexencryptAll = indexEncryot;
            }
        }
        if (weakSelf.isPush) {
             [weakSelf.navigationController popViewControllerAnimated:YES];
        } else {
            if (weakSelf.IPTextField.text && weakSelf.IPTextField.text.length>0) {
                BGLogSecondViewController *secVC = [[BGLogSecondViewController alloc] init];
                QMUINavigationController *navi = [[QMUINavigationController alloc] initWithRootViewController:secVC];
                [UIApplication sharedApplication].keyWindow.rootViewController = navi;
            } else {
                [MBProgressHUD showError:DefLocalizedString(@"Domain name filling out is not standard")];
            }
        }
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
        if(respObjc){
            NSDictionary *dic = respObjc[@"data"];
            if (dic) {
                user.indexencryptAll = [NSString changgeNonulWithString:dic[@"indexencryptAll"]];
            }
        }
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        if (weakSelf.isPush) {
             [weakSelf.navigationController popViewControllerAnimated:YES];
        } else {
            if (weakSelf.IPTextField.text && weakSelf.IPTextField.text.length>0) {
                BGLogSecondViewController *secVC = [[BGLogSecondViewController alloc] init];
                QMUINavigationController *navi = [[QMUINavigationController alloc] initWithRootViewController:secVC];
                [UIApplication sharedApplication].keyWindow.rootViewController = navi;
            } else {
                [MBProgressHUD showError:DefLocalizedString(@"Domain name filling out is not standard")];
            }
        }
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

-(void)showPopupPbtn:(UIButton *)showMoreBtn{
  
    // 使用方法 2，以 UIWindow 的形式显示到界面上，这种无需默认隐藏，也无需 add 到某个 UIView 上
       __weak __typeof(self)weakSelf = self;
       self.popupByWindow = [[QMUIPopupMenuView alloc] init];
       self.popupByWindow.automaticallyHidesWhenUserTap = YES;// 点击空白地方消失浮层
       self.popupByWindow.maskViewBackgroundColor = UIColorMaskWhite;// 使用方法 2 并且打开了 automaticallyHidesWhenUserTap 的情况下，可以修改背景遮罩的颜色
       self.popupByWindow.shouldShowItemSeparator = YES;
       self.popupByWindow.preferLayoutDirection = QMUIPopupContainerViewLayoutDirectionAbove;
       self.popupByWindow.itemConfigurationHandler = ^(QMUIPopupMenuView *aMenuView, QMUIPopupMenuButtonItem *aItem, NSInteger section, NSInteger index) {
           // 利用 itemConfigurationHandler 批量设置所有 item 的样式
//           aItem.button.highlightedBackgroundColor = [UIColor.qd_tintColor colorWithAlphaComponent:.2];
       };
//    NSMutableArray *orderMutArr = [NSMutableArray new];
   
    QMUIPopupMenuButtonItem *item = [QMUIPopupMenuButtonItem itemWithImage:nil title:@"域名示例：www.xxxxx.cn" handler:^(QMUIPopupMenuButtonItem *aItem) {
        [aItem.menuView hideWithAnimated:YES];
    }];
    QMUIPopupMenuButtonItem *item2 = [QMUIPopupMenuButtonItem itemWithImage:nil title:@"IP示例：116.216.149.164:8080" handler:^(QMUIPopupMenuButtonItem *aItem) {
        [aItem.menuView hideWithAnimated:YES];
    }];
    self.popupByWindow.items = @[item,item2];
    
       self.popupByWindow.didHideBlock = ^(BOOL hidesByUserTap) {
//           [weakSelf.button2 setTitle:@"显示菜单浮层" forState:UIControlStateNormal];
       };
       self.popupByWindow.sourceView = self.promptBtn;// 相对于 button2 布局
    
    [self.popupByWindow showWithAnimated:YES];
}

//判断此路径是否能够请求成功,直接进行HTTP请求
- (void)urliSAvailable:(NSString *)urlStr{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"HEAD"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            DefLog(@"不可用");
        }else{
            DefLog(@"可用");
        }
    }];
    [task resume];
}



-(void)showMoreIPAddress:(UIButton *)showMoreBtn{
    UserManager *user = [UserManager manager];
    // 使用方法 2，以 UIWindow 的形式显示到界面上，这种无需默认隐藏，也无需 add 到某个 UIView 上
    __weak __typeof(self)weakSelf = self;
       self.popupByWindow = [[QMUIPopupMenuView alloc] init];
       self.popupByWindow.automaticallyHidesWhenUserTap = YES;// 点击空白地方消失浮层
       self.popupByWindow.maskViewBackgroundColor = UIColorMaskWhite;// 使用方法 2 并且打开了 automaticallyHidesWhenUserTap 的情况下，可以修改背景遮罩的颜色
       self.popupByWindow.shouldShowItemSeparator = YES;
       self.popupByWindow.preferLayoutDirection = QMUIPopupContainerViewLayoutDirectionAbove;
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
                UserManager *user = [UserManager manager];
                user.account = [NSString changgeNonulWithString:orderObject[@"account"]];
                NSString *issave = [NSString changgeNonulWithString:orderObject[@"isSavePwd"]];
                if ([issave isEqualToString:@"YES"]) {
                    user.password = [NSString changgeNonulWithString:orderObject[@"pwd"]];
                }else{
                    user.password = @"";
                }
                weakSelf.isSelected = YES;
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

#pragma mark - 重定向
//监测并转https
-(void)testUrlHttps:(NSString *)url{
    NSString *uniqueProjectip = url;
    if (uniqueProjectip) {
        if([uniqueProjectip containsString:@"https:"]){
            uniqueProjectip = [uniqueProjectip stringByReplacingOccurrencesOfString:@"https://" withString:@""];
        }else if ([uniqueProjectip containsString:@"http:"]){
            uniqueProjectip = [uniqueProjectip stringByReplacingOccurrencesOfString:@"http://" withString:@""];
        }
//        if ([uniqueProjectip containsString:@":"]) {
//            NSRange range = [uniqueProjectip rangeOfString:@":" options:NSBackwardsSearch];
//            uniqueProjectip = [uniqueProjectip substringToIndex:range.location];
//        }
    }
    
    NSMutableURLRequest *quest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    quest.HTTPMethod = @"GET";
    NSURLConnection *connect = [NSURLConnection connectionWithRequest:quest delegate:self];
    [connect start];

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue currentQueue]];
    
    NSURLSessionDataTask *task = [urlSession dataTaskWithRequest:quest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        //200
        NSLog(@"%ld",urlResponse.statusCode);
        if(urlResponse.statusCode == 200){
                //保存地址
            UserManager *user = [UserManager manager];
            user.orderListUrl = urlResponse.URL.absoluteString;
                //保存域名
            [DefNSUD setObject:urlResponse.URL.absoluteString forKey:kBaseUrlString];
            DefNSUDSynchronize
            
            [self checkUrlWithhttpORhttps:uniqueProjectip];
        }else if(urlResponse.statusCode == 404){
            if ([url containsString:@"http://"]) {
                NSString *httpsUrl = url;
                httpsUrl = [httpsUrl stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
                [self testUrlHttps:httpsUrl];
            }else{
               [self checkUrlWithhttpORhttps:uniqueProjectip];
            }
        }else{
            [self checkUrlWithhttpORhttps:uniqueProjectip];
        }
        NSLog(@"%@",urlResponse.allHeaderFields);
        NSDictionary *dic = urlResponse.allHeaderFields;
        NSLog(@"%@",dic[@"Location"]);
    }];
    [task resume];
}

//监测并转http
-(void)testUrlHttp:(NSString *)url{
    NSString *uniqueProjectip = url;
    if (uniqueProjectip) {
        if([uniqueProjectip containsString:@"https:"]){
            uniqueProjectip = [uniqueProjectip stringByReplacingOccurrencesOfString:@"https://" withString:@""];
        }else if ([uniqueProjectip containsString:@"http:"]){
            //二次调用会用到
            uniqueProjectip = [uniqueProjectip stringByReplacingOccurrencesOfString:@"http://" withString:@""];
        }
//        if ([uniqueProjectip containsString:@":"]) {
//            NSRange range = [uniqueProjectip rangeOfString:@":" options:NSBackwardsSearch];
//            uniqueProjectip = [uniqueProjectip substringToIndex:range.location];
//        }
    }
    
    NSMutableURLRequest *quest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    quest.HTTPMethod = @"GET";
    NSURLConnection *connect = [NSURLConnection connectionWithRequest:quest delegate:self];
    [connect start];

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue currentQueue]];
    
    NSURLSessionDataTask *task = [urlSession dataTaskWithRequest:quest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        //200
        NSLog(@"%ld",urlResponse.statusCode);
        if(urlResponse.statusCode == 200){
                //保存地址
            UserManager *user = [UserManager manager];
            user.orderListUrl = urlResponse.URL.absoluteString;
                //保存域名
            [DefNSUD setObject:urlResponse.URL.absoluteString forKey:kBaseUrlString];
            DefNSUDSynchronize
            [self checkUrlWithhttpORhttps:uniqueProjectip];
        }else if(urlResponse.statusCode == 404){
            if ([url containsString:@"https://"]) {
                NSString *httpsUrl = url;
                httpsUrl = [httpsUrl stringByReplacingOccurrencesOfString:@"https://" withString:@"http://"];
                [self testUrlHttp:httpsUrl];
            }else{
               [self checkUrlWithhttpORhttps:uniqueProjectip];
            }
        }else{
            [self checkUrlWithhttpORhttps:uniqueProjectip];
        }
        NSLog(@"%@",urlResponse.allHeaderFields);
        NSDictionary *dic = urlResponse.allHeaderFields;
        NSLog(@"%@",dic[@"Location"]);
    }];
    [task resume];
}

//重定向的代理方法
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler{
    //    NSURL *downloadURL = [NSURL URLWithString:model.url];
    //    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    //cancel last download task
    NSLog(@"location code: %ld",response.statusCode);
    NSLog(@"location: %@",response.allHeaderFields);

    completionHandler(request);//这个如果为nil则表示拦截跳转。
}

-(nullable NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(nullable NSURLResponse *)response{

    NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
    
    NSLog(@"%ld",urlResponse.statusCode);
    NSLog(@"%@",urlResponse.allHeaderFields);
    
    NSDictionary *dic = urlResponse.allHeaderFields;
    NSLog(@"%@",dic[@"Location"]);
    
    return request;
}


#pragma mark - 键盘处理
- (void)keyboardWillShow:(NSNotification *)aNotification{
    
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    
    // 设置动画的名字
    [UIView beginAnimations:@"Animation" context:nil];
    // 设置动画的间隔时间
    double duration = [aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView setAnimationDuration:duration];
    // 使用当前正在运行的状态开始下一段动画
    [UIView setAnimationBeginsFromCurrentState: YES];
    // 获取到textfiled 距底部距离
    CGRect rect2 = [self.IPTextField convertRect:self.IPTextField.frame toView:self.view];
//    int textToTop = self.view.frame.size.height - rect2.origin.y - self.pwdTextField.frame.size.height;
    int textToTop = self.view.frame.size.height - rect2.origin.y - self.IPTextField.frame.size.height;
    
    if (textToTop > height) {
        // 如果键盘高度小于textfiled距底部的距离 则不需要任何操作
    }else{
        // 当textToTop 小于 height 时
        // 获取到键盘高度和控件底部距离的差值
        int scrolldistance = height - textToTop;
        // 移动视图y 差值距离
        self.view.frame = CGRectMake(0, -scrolldistance, SCREEN_WIDTH, SCREEN_HEIGHT);
    }
    //设置动画结束
    
    [UIView commitAnimations];
}

//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification{
    // 设置动画的名字
    [UIView beginAnimations:@"Animation" context:nil];
    // 设置动画的间隔时间
    double duration = [aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView setAnimationDuration:duration];
    // 使用当前正在运行的状态开始下一段动画
    [UIView setAnimationBeginsFromCurrentState: YES];
    // 设置视图移动的位移至原来的y值
    self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    //设置动画结束
    [UIView commitAnimations];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Lazy
-(QMUITextField *)IPTextField{
    if (!_IPTextField) {
        _IPTextField = [[QMUITextField alloc] init];
        _IPTextField.placeholder = DefLocalizedString(@"serverAddressText");
        _IPTextField.placeholderColor = COLOR_TEXT;
        _IPTextField.keyboardType = UIKeyboardTypeASCIICapable;
        _IPTextField.returnKeyType = UIReturnKeyDone;
        if ([UserManager manager].orderListUrl) {
            _IPTextField.text = [UserManager manager].orderListUrl;
        }
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

-(UIButton *)promptBtn{
    if (!_promptBtn) {
        _promptBtn = [[UIButton alloc] init];
        [_promptBtn addTarget:self action:@selector(showPopupPbtn:) forControlEvents:UIControlEventTouchUpInside];
               //            [self.selectAddress setBackgroundImage:[UIImage imageNamed:@"ipdizhi"] forState:UIControlStateNormal];
        [_promptBtn setImage:[UIImage imageNamed:@"wenhao-2"] forState:UIControlStateNormal];
    }
    return _promptBtn;
}

@end
