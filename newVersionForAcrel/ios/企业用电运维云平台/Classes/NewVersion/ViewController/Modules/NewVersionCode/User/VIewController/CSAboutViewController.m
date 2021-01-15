//
//  CSAboutViewController.m
//  CloudService
//
//  Created by nanayashiki on 15/12/1.
//  Copyright © 2015年 com.Ideal. All rights reserved.
//

#import "CSAboutViewController.h"
#import "BGCheckAppVersionMgr.h"
#import "UIColor+BGExtension.h"
#import "BGUIWebViewController.h"
//#import "BGTools.h"

@interface CSAboutViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoToTop;
@property (weak, nonatomic) IBOutlet UILabel *nameLB;
@property (weak, nonatomic) IBOutlet UILabel *currentVersonLB;
@property (weak, nonatomic) IBOutlet UIButton *versonUpdateBTN;
@property (weak, nonatomic) IBOutlet UIImageView *iconIV;
@property (weak, nonatomic) IBOutlet UIButton *FunctionIntroBtn;//功能介绍
@property (weak, nonatomic) IBOutlet UIButton *upgradeRecordBtn;//升级记录
//@property (weak, nonatomic) IBOutlet UILabel *detailtext;
//@property (weak, nonatomic) IBOutlet UILabel *banquanBottom;

@end

@implementation CSAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //版本信息页面
    self.title = DefLocalizedString(@"VersionInfo");
    [self getAboutNetData];
    // Do any additional setup after loading the view from its nib.
//    [self.versonUpdateBTN setBackgroundColor:COLOR_NAVIGATION];
//    UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressView:)];
//    //长按等待时间
//    longPressGest.minimumPressDuration = 0.1f;
//    //长按时候,手指头可以移动的距离
//    longPressGest.allowableMovement = 30;
//    self.erweimaIV.userInteractionEnabled = YES;
//    [self.erweimaIV addGestureRecognizer:longPressGest];
    [self checkVersonFromLocal];
//    [self checkVersonFromServer];
    //设置iPhone X导航栏88状况
    self.logoToTop.constant = BGSafeAreaTopHeight + 16 + 100;
//    [self.versonUpdateBTN.layer addSublayer:[UIColor setGradualChangingColor:self.versonUpdateBTN fromColor:COLOR_LightLWithChangeIn16 toColor:COLOR_DeepLWithChangeIn16]];
    
    //设置边框的粗细
//    [self.versonUpdateBTN.layer setBorderColor:COLOR_NAVBAR.CGColor];
//    [self.versonUpdateBTN.layer setBorderWidth:1.0];
//    [self.FunctionIntroBtn.layer setBorderColor:COLOR_NAVBAR.CGColor];
//    [self.FunctionIntroBtn.layer setBorderWidth:1.0];
//    [self.upgradeRecordBtn.layer setBorderColor:COLOR_NAVBAR.CGColor];
//    [self.upgradeRecordBtn.layer setBorderWidth:1.0];
    
    CALayer *deleteBtnBorder = [CALayer layer];
    float height = self.versonUpdateBTN.frame.size.height;
//    float width = self.versonUpdateBTN.frame.size.width;
    deleteBtnBorder.frame = CGRectMake(0, height-1, SCREEN_WIDTH, 1);
    deleteBtnBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.versonUpdateBTN.layer addSublayer:deleteBtnBorder];
    self.versonUpdateBTN.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    CALayer *deleteBtnBorder2 = [CALayer layer];
    deleteBtnBorder2.frame = CGRectMake(0, height-1, SCREEN_WIDTH, 1);
    deleteBtnBorder2.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.FunctionIntroBtn.layer addSublayer:deleteBtnBorder2];
    self.FunctionIntroBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    CALayer *deleteBtnBorder3 = [CALayer layer];
    deleteBtnBorder3.frame = CGRectMake(0, height-1, SCREEN_WIDTH, 1);
    deleteBtnBorder3.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.upgradeRecordBtn.layer addSublayer:deleteBtnBorder3];
    self.upgradeRecordBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
//    dibudaohanglan
    
    //右上角版本功能介绍 列表
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"select"] style:UIBarButtonItemStylePlain target:self action:@selector(clickRightBtn)];
    
}

-(void)clickRightBtn{
//     NSString *url = [NSString changgeNonulWithString:self.allDataArr[index][@"fActionurl"]];
//     NSString *iOSUrl = [NSString changgeNonulWithString:self.allDataArr[index][@"fFunctionfield"]];
    NSString *url = [NSString changgeNonulWithString:@""];
    NSString *iOSUrl = [NSString changgeNonulWithString:@"versionIntroduce"];
    if(iOSUrl.length){
                NSArray * strarr = [iOSUrl componentsSeparatedByString:@"."];
                NSString *urlStr= strarr.firstObject;
                BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
                NSString *filePath = [[NSBundle mainBundle] pathForResource:urlStr ofType:@"html" inDirectory:@"aDevices"];
                nomWebView.isUseOnline = NO;
                nomWebView.localUrlString = filePath;
                nomWebView.showWebType = showWebTypeDevice;
//                nomWebView.titleName = DefLocalizedString(@"versionIntroduce");
                [self.navigationController pushViewController:nomWebView animated:YES];
    }else if(url.length){
            //其他均用url加载 通用方法
    //        fFunctionfield
    //        NSString *url = [NSString changgeNonulWithString:self.allDataArr[index][@"fActionurl"]];
            BGUIWebViewController *urlWebView = [[BGUIWebViewController alloc] init];
            urlWebView.isUseOnline = YES;
            UserManager *user = [UserManager manager];
            //list
            if (user.singleSubFullData) {
                NSString *versionURL = [user.singleSubFullData objectForKeyNotNull:@"versionURL"];
                NSString *urlstring = [NSString stringWithFormat:@"/%@/",versionURL];
                NSString *str = [GetBaseURL stringByAppendingString:urlstring];
                NSString *urlStr = [str stringByAppendingString:url];
                urlWebView.onlineUrlString = urlStr;
                urlWebView.showWebType = showWebTypeDevice;
                [self.navigationController pushViewController:urlWebView animated:YES];
            }
        }else{
            //其他均用url加载 通用方法
            NSString *url = [NSString changgeNonulWithString:@""];
            if (url.length) {
                BGUIWebViewController *urlWebView = [[BGUIWebViewController alloc] init];
                urlWebView.isUseOnline = YES;
                urlWebView.onlineUrlString = url;
                urlWebView.showWebType = showWebTypeDevice;
                [self.navigationController pushViewController:urlWebView animated:YES];
            }
        }
}

-(void)getAboutNetData{
    if (self.aboutMenuID.length>0) {
//        BGWeakSelf;
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
        [NetService bg_getWithTokenWithPath:getbgSubinfoVoByPid params:@{@"pid":self.aboutMenuID,@"english":language} success:^(id respObjc) {
            NSDictionary *dic = respObjc[@"data"];
            NSArray *arr = dic[@"menuList"];
            if (arr.count>0) {
                UserManager *user = [UserManager manager];
                user.versionArr = arr;
                [self checkVersonFromLocal];
            }else{
                UserManager *user = [UserManager manager];
                user.versionArr = @[];
            }
            
        } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
            
        }];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)initNavigationBarButtonItems {
    [super initNavigationBarButtonItems];
    
}

//-(void)backButtonAction:(UIButton *)backBtn{
//    [self popViewControllerAnimation:YES];
//}

//升级记录
- (IBAction)updateRecord:(UIButton *)sender {
    [self clickRightBtn];
}


//介绍视频
- (IBAction)introductVideo:(UIButton *)sender {
    //     NSString *url = [NSString changgeNonulWithString:self.allDataArr[index][@"fActionurl"]];
    //     NSString *iOSUrl = [NSString changgeNonulWithString:self.allDataArr[index][@"fFunctionfield"]];
        NSString *url = [NSString changgeNonulWithString:@""];
        NSString *iOSUrl = [NSString changgeNonulWithString:@"versionFunctionIntro"];
        if(iOSUrl.length){
                NSArray * strarr = [iOSUrl componentsSeparatedByString:@"."];
                NSString *urlStr= strarr.firstObject;
                BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
                NSString *filePath = [[NSBundle mainBundle] pathForResource:urlStr ofType:@"html" inDirectory:@"aDevices"];
                nomWebView.isUseOnline = NO;
                nomWebView.localUrlString = filePath;
                nomWebView.showWebType = showWebTypeDevice;
//                nomWebView.titleName = DefLocalizedString(@"versionIntroduce");
                [self.navigationController pushViewController:nomWebView animated:YES];
        }else if(url.length){
                //其他均用url加载 通用方法
        //        fFunctionfield
        //        NSString *url = [NSString changgeNonulWithString:self.allDataArr[index][@"fActionurl"]];
                BGUIWebViewController *urlWebView = [[BGUIWebViewController alloc] init];
                urlWebView.isUseOnline = YES;
                UserManager *user = [UserManager manager];
                //list
                if (user.singleSubFullData) {
                    NSString *versionURL = [user.singleSubFullData objectForKeyNotNull:@"versionURL"];
                    NSString *urlstring = [NSString stringWithFormat:@"/%@/",versionURL];
                    NSString *str = [GetBaseURL stringByAppendingString:urlstring];
                    NSString *urlStr = [str stringByAppendingString:url];
                    urlWebView.onlineUrlString = urlStr;
                    urlWebView.showWebType = showWebTypeDevice;
                    [self.navigationController pushViewController:urlWebView animated:YES];
                }
            }else{
                //其他均用url加载 通用方法
                NSString *url = [NSString changgeNonulWithString:@""];
                if (url.length) {
                    BGUIWebViewController *urlWebView = [[BGUIWebViewController alloc] init];
                    urlWebView.isUseOnline = YES;
                    urlWebView.onlineUrlString = url;
                    urlWebView.showWebType = showWebTypeDevice;
                    [self.navigationController pushViewController:urlWebView animated:YES];
                }
            }
}

-(void)checkVersonFromLocal{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    NSString *name = BGFWGlobalSI.appDisplayName;
    // 当前应用软件版本  比如：1.0.1
    NSString *shortVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    // 当前应用版本号码   int类型
//    NSString *bundleVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    //获得build号:
    NSString *build = [infoDictionary objectForKey:@"CFBundleVersion"];
//    self.nameLB.text = name;
//    self.currentVersonLB.text = [NSString stringWithFormat:@"V%@  Build:%@",shortVersion,build];
    self.currentVersonLB.text = [NSString stringWithFormat:@"V%@",shortVersion];
    UserManager *user = [UserManager manager];
    if (user.versionArr.count>0) {
        for (NSDictionary *dic in user.versionArr) {
            NSString *fCode = dic[@"fCode"];
            if ([fCode isEqualToString:@"appDescribe"] || [fCode isEqualToString:@"appDescribeLower"]) {
                UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 350, SCREEN_WIDTH-40, 100)];
                detailLabel.text = [NSString changgeNonulWithString:dic[@"fExplain"]];
                detailLabel.textAlignment = NSTextAlignmentLeft;
                detailLabel.textColor = [UIColor grayColor];
                detailLabel.numberOfLines = 0;
                [detailLabel setFont:[UIFont systemFontOfSize:15.f]];
                [self.view addSubview:detailLabel];
//                self.detailtext.text = [NSString changgeNonulWithString:dic[@"fExplain"]];
            } else if([fCode isEqualToString:@"Copyright"] || [fCode isEqualToString:@"CopyrightLower"]){
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-60, SCREEN_WIDTH, 25)];
                label.text = [NSString changgeNonulWithString:dic[@"fExplain"]];
                label.textAlignment = NSTextAlignmentCenter;
                label.textColor = [UIColor grayColor];
                label.adjustsFontSizeToFitWidth = YES;
                [label setFont:[UIFont systemFontOfSize:13.f]];
                [self.view addSubview:label];
//                self.banquanBottom.text = [NSString changgeNonulWithString:dic[@"fExplain"]];
            }
        }
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-90, SCREEN_WIDTH, 25)];
    label.text = @"《用户协议和隐私政策》";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blueColor];
    label.adjustsFontSizeToFitWidth = YES;
    [label setFont:[UIFont systemFontOfSize:13.f]];
    label.userInteractionEnabled=YES;
    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelTouchUpInside:)];
    [label addGestureRecognizer:labelTapGestureRecognizer];
    [self.view addSubview:label];
}

-(void) labelTouchUpInside:(UITapGestureRecognizer *)recognizer{
   
   UILabel *label=(UILabel*)recognizer.view;
   DefLog(@"%@被点击了",label.text);
//if (1) {
               BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
                       NSString *filePath = [[NSBundle mainBundle] pathForResource:@"policy" ofType:@"html" inDirectory:@"aDevices"];
               nomWebView.isUseOnline = NO;
               nomWebView.localUrlString = filePath;
               nomWebView.showWebType = showWebTypePolicy;
               nomWebView.titleName = @"用户协议和隐私政策";
               //        self.tabBarController.hidesBottomBarWhenPushed = YES;
//               [self.navigationController pushViewController:nomWebView animated:YES];
            [self.navigationController pushViewController:nomWebView animated:YES];
//            }else{
//                BGUIWebViewController *urlWebView = [[BGUIWebViewController alloc] init];
//                urlWebView.isUseOnline = YES;
//                if (versionURL.length>0) {
//                    NSString *urlstring = [NSString stringWithFormat:@"/%@/",versionURL];
//                    NSString *str = [GetBaseURL stringByAppendingString:urlstring];
//                    NSString *urlStr = [str stringByAppendingString:fAction];
//                    urlWebView.onlineUrlString = urlStr;
//                    urlWebView.showWebType = showWebTypeDevice;
//                   [[self findCurrentViewController].navigationController pushViewController:urlWebView animated:YES];
//                 }
//            }
   
}

-(void)checkVersonFromServer{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // 当前应用软件版本  比如：1.0.1
//    NSString *shortVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
//    NSDictionary *param = @{kserviceCode:kIOS,
//                            kversion:shortVersion,
//                            };
//    NSString *realURL = [BASE_URL stringByAppendingString:VersionCheck];
//    [BGFWUCService bg_postWithPath:realURL params:param success:^(id respObjc) {
//        NSDictionary *data = [respObjc objectForKeyNotNull:kdata];
//        if (data) {
//            NSString *version = [data objectForKeyNotNull:kversion];
//            if ([shortVersion compare:version] == NSOrderedAscending) {
//                self.versonUpdateBTN.hidden = NO;
//                NSString *title = [NSString stringWithFormat:@"版本更新:(V%@)",version];
//                [self.versonUpdateBTN setTitle:title forState:UIControlStateNormal];
//                [[NSUserDefaults standardUserDefaults] setObject:data forKey:kversion];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//            }else{
//                self.versonUpdateBTN.hidden = YES;
//            }
//        }else{
//            self.versonUpdateBTN.hidden = YES;
//        }
//    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
//        self.versonUpdateBTN.hidden = YES;
//    }];
}

- (IBAction)versonUpdateAction:(UIButton *)sender {
    //检查版本
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/app/id%@",kAppleId]]];
//    [[BGCheckAppVersionMgr sharedInstance] isUpdataApp:kAppleId andCompelete:^(NSString * _Nonnull respObjc) {
//        if (respObjc) {
//            QMUIAlertAction *action2 = [QMUIAlertAction actionWithTitle:DefLocalizedString(@"Sure") style:QMUIAlertActionStyleCancel handler:^(__kindof QMUIAlertController * _Nonnull aAlertController, QMUIAlertAction * _Nonnull action) {
//
//            }];
//            QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:DefLocalizedString(@"VersionUpdate") message:respObjc preferredStyle:QMUIAlertControllerStyleAlert];
//            [alertController addAction:action2];
//
//            QMUIVisualEffectView *visualEffectView = [[QMUIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
//            visualEffectView.foregroundColor = UIColorMakeWithRGBA(255, 255, 255, .7);// 一般用默认值就行，不用主动去改，这里只是为了展示用法
//            alertController.mainVisualEffectView = visualEffectView;
//            alertController.alertHeaderBackgroundColor = nil;// 当你需要磨砂的时候请自行去掉这几个背景色，不然这些背景色会盖住磨砂
//            alertController.alertButtonBackgroundColor = nil;
//            [alertController showWithAnimated:YES];
//        }
//    }];
    
}

#pragma mark 弹出选择框
#pragma mark 把图片保存到相册

//-(void)longPressView:(UILongPressGestureRecognizer *)longPressGest{
//    if (longPressGest.state==UIGestureRecognizerStateBegan) {
//        UIImageView *imageV = (UIImageView *)longPressGest.view;
//        UIImage *currentImage = imageV.image;
//
//        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"图片操作" message:@"是否保存到相册？" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *cacleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//        }];
//        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [self loadImageFinished:currentImage];
//        }];
//
//        [alertVC addAction:cacleAction];
//        [alertVC addAction:sureAction];
//        [self presentViewController:alertVC animated:YES completion:nil];
//    }
//}

//- (void)loadImageFinished:(UIImage *)image{
//    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
//}

#pragma mark 保存完成回调
//- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
//
//}



@end
