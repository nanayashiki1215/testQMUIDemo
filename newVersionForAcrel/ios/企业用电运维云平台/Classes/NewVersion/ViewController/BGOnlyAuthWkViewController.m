//
//  BGOnlyAuthWkViewController.m
//  变电所运维
//
//  Created by Acrel on 2019/5/21.
//

#import "BGOnlyAuthWkViewController.h"
#import <WebKit/WebKit.h>
#import "WSDatePickerView.h"
#import <BMKLocationKit/BMKLocationComponent.h>
#import <UIKit/UIWindowScene.h>
#import <CoreLocation/CLLocationManager.h>
#import "BGFileDownModel.h"
#import <QuickLook/QuickLook.h>
#import "QLPreviewController+autoTitle.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "UIImagePickerController+custom.h"
#import "ZYSuspensionView.h"
#import "YYServiceViewController.h"
#import "YYHistoryTrackViewController.h"
#import "YYServiceManager.h"
#import "YYServiceParam.h"
#import <CoreLocation/CoreLocation.h>
#import "BGQMVideoListTableVC.h"
#import "BGQMNavigationController.h"
#import "JZLocationConverter.h"

@import MapKit;//ios7 使用苹果自带的框架使用@import导入则不用在Build Phases 导入框架了
@import CoreLocation;

//轨迹持续上传
@interface BGOnlyAuthWkViewController ()<WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate,BMKLocationManagerDelegate,QLPreviewControllerDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ZYSuspensionViewDelegate>

@property (strong,nonatomic) WKWebView *webView;
//网页加载进度视图
@property (nonatomic, strong) UIProgressView * progressView;

@property (nonatomic, strong) BMKLocationManager *locationManager; //定位对象
    
@property (nonatomic, strong) UIView *viewStatusColorBlend;//背景层

@property (nonatomic) BOOL pageStillLoading;//线程等待

@property (nonatomic, strong) UIView *statusBar;

@property (strong, nonatomic)QLPreviewController *previewController;
@property (copy, nonatomic)NSURL *fileURL; //文件路径

@property (strong,nonatomic) NSString * picDataInfo;

@property (nonatomic,assign) BOOL editeOrNot;

@property (nonatomic,strong) UIImage *image;

@property (nonatomic,strong) NSString *indexStr;

@property (nonatomic, weak) ZYSuspensionView *susView;

@end

@implementation BGOnlyAuthWkViewController

//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//
//        swizzling_exchangeMethod([self class], @selector(presentViewController:animated:completion:), @selector(myPresentViewController:animated:completion:));
//    });
//}
//- (void)myPresentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
//    //设置满屏，不需要小卡片
//    if(@available(iOS 13.0, *)) {
//        viewControllerToPresent.modalPresentationStyle = UIModalPresentationFullScreen;
//    }
//    [self myPresentViewController:viewControllerToPresent animated:flag completion:completion];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self.webView.scrollView setShowsVerticalScrollIndicator:NO];
    [self.webView.scrollView setShowsHorizontalScrollIndicator:NO];
//    if (@available(iOS 11.0, *)) {
//        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//    }
    self.previewController = [[QLPreviewController alloc]  init];
//    [self.previewController.navigationBar setTintColor:COLOR_NAVBAR];
    self.previewController.dataSource  = self;
    
    //注册runtime图片加载器替换系统
    [UIImagePickerController hookDelegate];
    self.webView.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
    //添加监测网页加载进度的观察者
    [self.webView addObserver:self
                   forKeyPath:NSStringFromSelector(@selector(estimatedProgress))
                      options:0
                      context:nil];
    [self.webView addObserver:self
                   forKeyPath:@"title"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    if (self.titleName.length>0) {
       
            [self loadLocalWithParamHtml];
        
    }else{
        if (!self.isUseOnline) {
         
                [self loadLocalHtml];
            
        }else{
           
                [self loadOnlineHtml];
            
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   
//        self.navigationController.navigationBarHidden = YES;
//        self.automaticallyAdjustsScrollViewInsets = NO;
//        [self setStatusBarBackgroundColor:COLOR_WEBNAVBAR];
    
    if (self.titleName.length>0) {
        self.navigationItem.title = self.titleName;
    }
   
}

//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    // 禁用返回手势
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//    }
//}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (@available(iOS 13.0, *)) {
        self.viewStatusColorBlend.backgroundColor = [UIColor clearColor];
        [self.viewStatusColorBlend removeFromSuperview];
    }else{
        [self setStatusBarBackgroundColor:[UIColor clearColor]];
    }
    
    self.navigationController.navigationBarHidden = NO;
    // 开启返回手势
//   if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//       self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//   }
}


//设置状态栏颜色
- (void)setStatusBarBackgroundColor:(UIColor *)color {
    
    if (UNDERiOS12) {
        UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
            statusBar.backgroundColor = color;
        }
    }else{
        if (@available(iOS 13.0, *)) {
//            UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].keyWindow.windowScene.statusBarManager;
//            id _statusBar = nil;
//            if ([statusBarManager respondsToSelector:@selector(createLocalStatusBar)]) {
//                UIView *_localStatusBar = [statusBarManager performSelector:@selector(createLocalStatusBar)];
//                if ([_localStatusBar respondsToSelector:@selector(statusBar)]) {
//                    _statusBar = [_localStatusBar performSelector:@selector(statusBar)];
////                    self.view.backgroundColor = color;
//                    UIView * statusBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
//                    statusBarView.backgroundColor = [UIColor orangeColor];
//                    [_statusBar addSubview:statusBarView];
//                }
                UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
//                self.viewStatusColorBlend = [[UIView alloc] initWithFrame:keyWindow.windowScene.statusBarManager.statusBarFrame];
                self.viewStatusColorBlend.backgroundColor = color;
                [keyWindow addSubview:self.viewStatusColorBlend];
//            }
        }
    }
    
}

-(UIView *)viewStatusColorBlend{
    if (!_viewStatusColorBlend) {
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        if (@available(iOS 13.0, *)) {
            _viewStatusColorBlend = [[UIView alloc] initWithFrame:keyWindow.windowScene.statusBarManager.statusBarFrame];
        }
    }
    return _viewStatusColorBlend;
}

-(void)loadLocalHtml{
    if (self.localUrlString) {
//        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"Dis-test/demo"];
//        NSURL *pathURL = [NSURL fileURLWithPath:filePath];
        NSURL *pathURL = [NSURL fileURLWithPath:self.localUrlString];
        [self.webView loadRequest:[NSURLRequest requestWithURL:pathURL]];
    }
}

//本地h5带参数
-(void)loadLocalHtmlWithParam{
    if (self.localUrlString) {
        NSURL *pathURL = [NSURL fileURLWithPath:self.localUrlString];
        [self.webView loadRequest:[NSURLRequest requestWithURL:pathURL]];
        NSString * urlString2 = [[NSString stringWithFormat:@"?jumpId=%@",self.pathParamStr] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString2 relativeToURL:pathURL]]];
    }
}

-(void)loadOnlineHtml{
    if (self.onlineUrlString) {
        NSURL * url = [NSURL URLWithString:self.onlineUrlString];
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
}

-(void)loadOnlineHtmlWithParam{
    if (self.onlineUrlString) {
        NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?jumpId=%@",self.onlineUrlString,self.pathParamStr]];
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
}

-(void)loadLocalWithParamHtml{
    if (self.localUrlString) {
        NSURL *pathURL = [NSURL fileURLWithPath:self.localUrlString];
//        NSString * pathString = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"app/html"];
        NSString * urlString2 = [self.urlParams stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString2 relativeToURL:pathURL]]];
    }
}

//kvo 监听进度 必须实现此方法
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                      context:(void *)context{

    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))]
        && object == _webView) {

        DefLog(@"网页加载进度 = %f",_webView.estimatedProgress);
//        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.progressView.progress = _webView.estimatedProgress;
        if (_webView.estimatedProgress >= 1.0f) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressView.progress = 0;
//                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }
    }else if([keyPath isEqualToString:@"title"]
             && object == _webView){
        self.navigationItem.title = _webView.title;
    }else{
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

#pragma mark -- Event Handle

- (void)goBackAction:(id)sender{
    [_webView goBack];
}

- (void)localHtmlClicked{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"JStoOC.html" ofType:nil];
    NSString *htmlString = [[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [_webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
}

- (void)refreshAction:(id)sender{
    [_webView reload];
}

- (void)ocToJs{
    
    //OC调用JS
    
    //changeColor()是JS方法名，completionHandler是异步回调block
    NSString *jsString = [NSString stringWithFormat:@"changeColor('%@')", @"Js参数"];
    [_webView evaluateJavaScript:jsString completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        DefLog(@"改变HTML的背景色");
    }];
    
    //改变字体大小 调用原生JS方法
    NSString *jsFont = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'", arc4random()%99 + 100];
    [_webView evaluateJavaScript:jsFont completionHandler:nil];
    
    NSString * path =  [[NSBundle mainBundle] pathForResource:@"girl" ofType:@"png"];
    NSString *jsPicture = [NSString stringWithFormat:@"changePicture('%@','%@')", @"pictureId",path];
    [_webView evaluateJavaScript:jsPicture completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        DefLog(@"切换本地头像");
    }];
}

#pragma mark -- Getter

- (UIProgressView *)progressView
{
    if (!_progressView){
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0,1, self.view.frame.size.width, 0.1)];
        _progressView.tintColor = COLOR_NAVBAR;
        _progressView.trackTintColor = [UIColor clearColor];
    }
    return _progressView;
}

- (WKWebView *)webView{
    
    if(_webView == nil){
        
        //创建网页配置对象
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        
        // 创建设置对象
        WKPreferences *preference = [[WKPreferences alloc]init];
        //最小字体大小 当将javaScriptEnabled属性设置为NO时，可以看到明显的效果
        preference.minimumFontSize = 0;
        //设置是否支持javaScript 默认是支持的
        preference.javaScriptEnabled = YES;
        // 在iOS上默认为NO，表示是否允许不经过用户交互由javaScript自动打开窗口
        preference.javaScriptCanOpenWindowsAutomatically = YES;
        config.preferences = preference;
        
        // 是使用h5的视频播放器在线播放, 还是使用原生播放器全屏播放
        config.allowsInlineMediaPlayback = YES;
        //设置视频是否需要用户手动播放  设置为NO则会允许自动播放
        config.requiresUserActionForMediaPlayback = YES;
        //设置是否允许画中画技术 在特定设备上有效
        config.allowsPictureInPictureMediaPlayback = YES;
        //设置请求的User-Agent信息中应用程序名称 iOS9后可用
        config.applicationNameForUserAgent = @"ChinaDailyForiPad";
        
        //以下代码适配文本大小
//        NSString *jSString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
        //用于进行JavaScript注入
//        WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
//        [config.userContentController addUserScript:wkUScript];
        
        //自适应网页内容
        NSString *jScript;
        if(self.isAllowXZoom){
            jScript = @"var meta = document.createElement('meta'); \
            meta.name = 'viewport'; \
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=10.0, user-scalable=yes'; \
            var head = document.getElementsByTagName('head')[0];\
            head.appendChild(meta);";
        }else if ([self.isFromFile isEqualToString:@"openFile"]){
            //自适应网页内容
           jScript = @"var meta = document.createElement('meta'); \
           meta.name = 'viewport'; \
           meta.content = 'text/html,width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'; \
           meta.charset = 'utf-8'; \
           var head = document.getElementsByTagName('head')[0];\
           head.appendChild(meta);";
        }else{
            jScript = @"var meta = document.createElement('meta'); \
            meta.name = 'viewport'; \
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'; \
            var head = document.getElementsByTagName('head')[0];\
            head.appendChild(meta);";
        }
        WKUserScript *wkUScript = [[NSClassFromString(@"WKUserScript") alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
        [config.userContentController addUserScript:wkUScript];
        
        UserManager *user = [UserManager manager];
//        NSString *jsStartString = [NSString stringWithFormat: @"localStorage.setItem(\"BaseUrl\",'%@'); localStorage.setItem(\"fsubID\",'%@'); localStorage.setItem(\"Token\",'%@');",BASE_URL,user.fsubID,user.token];
//        NSString *versionStr = [NSString stringWithFormat:@"/%@",user.versionNo];
        NSString *baseUrl = [BASE_URL stringByAppendingString:user.versionNo];
        NSString *ipAddress = GetBaseURL;
        NSString *jsStartString;
        NSString *languageType = @"zh";
        NSString *isOpenTrack = @"1";
        if(user.selectlanageArr.count>0){
            NSString *languageId;
            for (NSDictionary *dic in user.selectlanageArr) {
               if ([dic[@"click"] integerValue] == 1) {
                   languageId = dic[@"id"];
               }
            }
            if ([languageId integerValue] == 1) {
                languageType = @"zh";
            } else {
                languageType = @"en";
            }
        }
        
        if (user.isOpenTjBaidu) {
            isOpenTrack = @"1";
        }else{
            isOpenTrack = @"0";
        }
//       window.webkit.messageHandlers.getLocation.postMessage("");
//       loc = localStorage.getItem("locationStrJS");
        if ([self.isPushEnergy isEqualToString:@"1"]) {
            if (user.energyAccountNum && user.energyDns && user.energyPassword && self.energyToken) {
                       //能耗头energyToken
//               jsStartString = [NSString stringWithFormat:@"var obj = {'token': '%@','baseurl':'%@','fsubID':'%@','ipAddress':'%@','fmenuId':'%@','userID':'%@','languageType':'%@','isOpenTrack':'%@'}; obj = JSON.stringify(obj); localStorage.setItem('energyToken',obj);",self.energyToken,user.energyDns,user.fsubID,ipAddress,self.menuId,user.bguserId,languageType,isOpenTrack];
                jsStartString = [NSString stringWithFormat:@"var obj = {'token': '%@','baseurl':'%@','fsubID':'%@','ipAddress':'%@','fmenuId':'%@','userID':'%@','languageType':'%@','isOpenTrack':'%@','energyToken':'%@','energyBaseurl':'%@'}; obj = JSON.stringify(obj); localStorage.setItem('accessToken',obj);",user.token,baseUrl,user.fsubID,ipAddress,self.menuId,user.bguserId,languageType,isOpenTrack,self.energyToken,user.energyDns];
            }else{
                [MBProgressHUD showError:@"获取能耗Token异常"];
            }
        }else if (self.menuId.length>0) {
           jsStartString = [NSString stringWithFormat:@"var obj = {'token': '%@','baseurl':'%@','fsubID':'%@','ipAddress':'%@','fmenuId':'%@','userID':'%@','languageType':'%@','isOpenTrack':'%@'}; obj = JSON.stringify(obj); localStorage.setItem('accessToken',obj);",user.token,baseUrl,user.fsubID,ipAddress,self.menuId,user.bguserId,languageType,isOpenTrack];
        }else{
           jsStartString = [NSString stringWithFormat:@"var obj = {'token': '%@','baseurl':'%@','fsubID':'%@','ipAddress':'%@','userID':'%@','languageType':'%@','isOpenTrack':'%@'}; obj = JSON.stringify(obj); localStorage.setItem('accessToken',obj);",user.token,baseUrl,user.fsubID,ipAddress,user.bguserId,languageType,isOpenTrack];
        }
        //用于进行JavaScript注入
       
       
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-BGSafeAreaTopHeight-BGSafeAreaBottomHeight) configuration:config];
    
        // UI代理
        _webView.UIDelegate = self;
        // 导航代理
        _webView.navigationDelegate = self;
        // 是否允许手势左滑返回上一级, 类似导航控制的左滑返回
        _webView.allowsBackForwardNavigationGestures = YES;
        //可返回的页面列表, 存储已打开过的网页
        WKBackForwardList * backForwardList = [_webView backForwardList];
        
        //        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.chinadaily.com.cn"]];
        //        [request addValue:[self readCurrentCookieWithDomain:@"http://www.chinadaily.com.cn"] forHTTPHeaderField:@"Cookie"];
     

        
    }
    return _webView;
}


//解决第一次进入的cookie丢失问题
//- (NSString *)readCurrentCookieWithDomain:(NSString *)domainStr{
//    NSHTTPCookieStorage*cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    NSMutableString * cookieString = [[NSMutableString alloc]init];
//    for (NSHTTPCookie*cookie in [cookieJar cookies]) {
//        [cookieString appendFormat:@"%@=%@;",cookie.name,cookie.value];
//    }
//
//    //删除最后一个“;”
//    if ([cookieString hasSuffix:@";"]) {
//        [cookieString deleteCharactersInRange:NSMakeRange(cookieString.length - 1, 1)];
//    }
//
//    return cookieString;
//}

//解决 页面内跳转（a标签等）还是取不到cookie的问题
//- (void)getCookie{
//
//    //取出cookie
//    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    //js函数
//    NSString *JSFuncString =
//    @"function setCookie(name,value,expires)\
//    {\
//    var oDate=new Date();\
//    oDate.setDate(oDate.getDate()+expires);\
//    document.cookie=name+'='+value+';expires='+oDate+';path=/'\
//    }\
//    function getCookie(name)\
//    {\
//    var arr = document.cookie.match(new RegExp('(^| )'+name+'=([^;]*)(;|$)'));\
//    if(arr != null) return unescape(arr[2]); return null;\
//    }\
//    function delCookie(name)\
//    {\
//    var exp = new Date();\
//    exp.setTime(exp.getTime() - 1);\
//    var cval=getCookie(name);\
//    if(cval!=null) document.cookie= name + '='+cval+';expires='+exp.toGMTString();\
//    }";
//
//    //拼凑js字符串
//    NSMutableString *JSCookieString = JSFuncString.mutableCopy;
//    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
//        NSString *excuteJSString = [NSString stringWithFormat:@"setCookie('%@', '%@', 1);", cookie.name, cookie.value];
//        [JSCookieString appendString:excuteJSString];
//    }
//    //执行js
//    [_webView evaluateJavaScript:JSCookieString completionHandler:nil];
//
//}

#pragma mark - H5互调方法

//被自定义的WKScriptMessageHandler在回调方法里通过代理回调回来，绕了一圈就是为了解决内存不释放的问题
//通过接收JS传出消息的name进行捕捉的回调方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    DefLog(@"name:%@\\\\n body:%@\\\\n frameInfo:%@\\\\n",message.name,message.body,message.frameInfo);
   
}

#pragma mark - 轨迹记录功能

-(void)generateTrackRecords{
    NSMutableDictionary *mutparam = [NSMutableDictionary new];
    NSString *Projectip = GetBaseURL;
    if([Projectip containsString:@"http:"]){
        Projectip = [Projectip stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    }else if ([Projectip containsString:@"https:"]){
        Projectip = [Projectip stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    }
    [mutparam setObject:Projectip forKey:@"fProjectip"];
     
    UserManager *user = [UserManager manager];
    NSString *startTime = user.startTJtime;
    if (startTime.length) {
         [mutparam setObject:startTime forKey:@"fTrackstarttime"];
    }
    NSString *taskNumber = user.taskID;
    if (taskNumber && taskNumber.length) {
        [mutparam setObject:taskNumber forKey:@"fTasknumber"];
    }
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
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
    //阿里云特殊接口 http://www.acrelcloud.cn
    [NetService bg_getWithTestPath:@"sys/generateTrackRecords" params:mutparam success:^(id respObjc) {
        [UserManager manager].startTJtime = @"";
        [UserManager manager].taskID = @"";
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
        [UserManager manager].startTJtime = @"";
        [UserManager manager].taskID = @"";
    }];
}

#pragma mark - 拍照功能

/**
 *  调用照相机
 */
 
- (void)openCamera:(NSDictionary *)imageDic{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    self.indexStr = imageDic[@"index"];
//    picker.allowsEditing = YES; //可编辑
    //判断是否可以打开照相机
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        //摄像头
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                //出现这个问题，基本就是UI操作放在了非主线程中操作导致。我的问题是webview的回调，有时候会进入子线程处理。所以统一加上dispatch_async(dispatch_get_main_queue...
        dispatch_async(dispatch_get_main_queue(), ^{ //不加这句有时候点击会闪退
            [self presentViewController:picker animated:YES completion:nil];
        });
    }
    else
    {
        DefLog(@"没有摄像头");
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//    UIImage *image = [[UIImage alloc] init];
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if([mediaType isEqualToString:@"public.movie"])
    {
        return;
        //        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        //        DefLog(@"found a video");
        //        //获取视频的thumbnail
        //        MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:videoURL];
        //        image = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
        //        player = nil;
    }else{

//          self.picDataInfo = info[UIImagePickerControllerMediaMetadata][@"{TIFF}"][@"DateTime"];
//          DefLog(@"%@**********", self.picDataInfo);
//          self.editeOrNot = YES;
////                           UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"]; //先把图片转成NSData
//          UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
//          self.image = image;
//        UIImage *waterPoint = [self addText:image text:self.picDataInfo];
//        NSData *data = UIImageJPEGRepresentation(waterPoint, 0.5);
//    //                        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
//        NSData *base64Data = [data base64EncodedDataWithOptions:0];
//        NSString *baseString = [[NSString alloc]initWithData:base64Data encoding:NSUTF8StringEncoding];
//        NSString *dataStr = [data base64Encoding];
//                  DefLog(@"baseString:%@",baseString);
//                  UIImageView *viewImage = [[UIImageView alloc] initWithImage:waterPoint];
//                  viewImage.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
//                  [self.view addSubview:viewImage];
//                 NSString *locationStrJS = [NSString stringWithFormat:@"localStorage.setItem(\"locationStrJS\",'%@');",baseString];
        
//        NSString *documentPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingFormat:@"/Files"];
//        //    documentPath = [documentPath stringByAppendingPathComponent:downloadModel.fileName];//不用加“/”
//        NSFileManager *manager = [NSFileManager defaultManager];
//        [manager createDirectoryAtPath:documentPath withIntermediateDirectories:YES attributes:nil error:nil];
//
//        NSString *fileDateName = [NSString stringWithFormat:@"%.f.jpg",[[NSDate date] timeIntervalSince1970]];
//        documentPath = [documentPath stringByAppendingFormat:@"/%@",fileDateName];
//
//        [UIImageJPEGRepresentation(waterPoint,1) writeToFile:documentPath atomically:YES];
        
//         NSString *imgBaseJS = [NSString stringWithFormat:@"imgBase('%@','%@')",baseString,self.indexStr];
//         [self.webView evaluateJavaScript:imgBaseJS completionHandler:^(id _Nullable item, NSError * _Nullable error) {
//             DefLog(@"item%@",item);
//         }];
                  
              
//              }failureBlock:^(NSError *error) {
//
//          }];
//        __block NSString *createdAssetID =nil;//唯一标识，可以用于图片资源获取
//        NSError *error =nil;
//        [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{
//            createdAssetID = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
//
//        } error:&error];
////
//        [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
//            PHAssetChangeRequest *changeAssetRequest =
//            [PHAssetChangeRequest creationRequestForAssetFromImage:waterPoint];
//            PHAssetCollection *targetCollection =[[PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil] lastObject];
//
//            PHAssetCollectionChangeRequest *changeCollectionRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:targetCollection];
//            PHObjectPlaceholder *assetPlaceholder = [changeAssetRequest placeholderForCreatedAsset];
//            [changeCollectionRequest addAssets:@[assetPlaceholder]];
//
//        } completionHandler:^(BOOL success,NSError * _Nullable error) {
//            DefLog(@"finished adding");
//        }];
        
//        image = info[UIImagePickerControllerOriginalImage];
        
//        [self uploadPickImage:documentPath andImageFileName:fileDateName];
//    NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
//    assets-library://asset/asset.JPG?id=106E99A1-4F6A-45A2-B320-B0AD4A8E8473&ext=JPG
//    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
//    {
//        ALAssetRepresentation *representation = [myasset defaultRepresentation];
//        self.imageFileName = [representation filename];
//        DefLog(@"imageFileName : %@",self.imageFileName);
//    };
//    [self dismissViewControllerAnimated:YES completion:nil];
//    [self uploadPickImage:[imageURL absoluteString]];
//    [self sendImageMessage:image];
        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tableview reloadData];
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }
//    });
    
    
    //获取图片的NSURL 来源于AssetsLibrary.framework  #import <AssetsLibrary/AssetsLibrary.h>
//    NSURL *url = [info objectForKey:UIImagePickerControllerReferenceURL];
//    //ALAssetsLibrary 获取图片和视频
//    ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
//    //根据url获取指定的图片  如果获取到了资源执行resultBlock，否则执行failureBlock
//    //ALAsset实例 代表一个图片或者视频
//    [library assetForURL:url resultBlock:^(ALAsset *asset){
//        //defaultRepresentation 获取资源文件的默认属性
//        //metadata 获取数据的数据，就是在默认属性中的数据，称之为元数据
//        NSDictionary *imageData = [[NSMutableDictionary alloc]initWithDictionary:asset.defaultRepresentation.metadata];
//        //kCGImagePropertyGPSDictionary 关于GPS的字典数据  来源于ImageIO.framework  #import <ImageIO/ImageIO.h>
//
//        NSDictionary *gpsData = [imageData objectForKey:(NSString *)kCGImagePropertyGPSDictionary];
//        //打印纬度
//        DefLog(@"打印纬度:%@",[gpsData objectForKey:@"Altitude"]);
//
//    }failureBlock:^(NSError *error){
//        DefLog(@"error:%@",error);
//    }];
}

- (UIImage *)addText:(UIImage *)img text:(NSString *)mark {
    if (mark.length != 0) {
    } else {
        //将时间戳转换成时间
        NSDate *date = [NSDate date];
        //    限定格式
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@" yyyy-MM-dd  hh:mm:ss"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"china"];//时区名字或地区名字
        [formatter setTimeZone:timeZone];
       mark = [formatter stringFromDate:date];
    }
   
    int w = img.size.width;
    int h = img.size.height;
//    UIGraphicsBeginImageContext(img.size);
    UIGraphicsBeginImageContextWithOptions(img.size, NO, 0);
    [img drawInRect:CGRectMake(0, 0, w, h)];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:50],
//                                NSParagraphStyleAttributeName: paragraphStyle,
                                NSForegroundColorAttributeName : [UIColor redColor]
//                                NSTextEffectAttributeName: NSTextEffectLetterpressStyle
                                };
    [mark drawInRect:CGRectMake(w-500, h - 440, 500, 100) withAttributes:attribute];
    
    //添加水印文字
    UIImage *aImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return aImage;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSString *imgUpCancelJS = [NSString stringWithFormat:@"imgUpCancel('%@')",self.indexStr];
    [self.webView evaluateJavaScript:imgUpCancelJS completionHandler:^(id _Nullable item, NSError * _Nullable error) {
        DefLog(@"item%@",item);
    }];
     
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self popViewControllerAnimation:YES];
}

#pragma mark - 跳转视频

-(void)didClickpushVideoVC:(NSDictionary *)pushdic{
    
    BGQMVideoListTableVC *videoVC = [[BGQMVideoListTableVC alloc] init];
    videoVC.pushTitleName = [pushdic objectForKeyNotNull:@"Subname"];
    videoVC.pushSubid = [pushdic objectForKeyNotNull:@"Subid"];

    QMUINavigationController *naVC = [[QMUINavigationController alloc] initWithRootViewController:videoVC];
    videoVC.ownNaviController = naVC;
    [self presentViewController:naVC animated:YES completion:nil];
//    [self.navigationController pushViewController:videoVC animated:YES];
}
    
#pragma mark - 文件下载打开

-(void)didClickDownloadButton:(NSDictionary *)downDic{
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    NSString *url = [downDic bg_StringForKeyNotNull:@"fFilepath"];
    NSString *filecode = [downDic bg_StringForKeyNotNull:@"fFilecode"];
    NSString *fileName1 = [downDic bg_StringForKeyNotNull:@"fFilename"];
//    NSString *url = @"fileSystem/filesManagement";
//    NSString *filecode =  @"71babdb74bff47c1ac8ce00307ac1fb6.docx";
//    NSString *fileName1 = @"测试文档";
    //        6ac19ed59a474ce6bc08b8419d922607.txt
    //        2e2eb1ceb8b74750a707f02964bf4e91.pdf
    DefLog(@"我点击了第%ld行",(long)button.tag);
    BGFileDownModel *downloadModel = [[BGFileDownModel alloc] init];
    downloadModel.fileName = filecode;
    downloadModel.nickName = fileName1;
    downloadModel.fileType = @"1";
    downloadModel.fileUrlString = [GetBaseURL stringByAppendingString:[NSString stringWithFormat:@"/%@/%@",url,filecode]];
    
    NSString *fileName = [downloadModel.fileName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //    urlString = [urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [downloadModel.fileUrlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    //拼接本地地址
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    documentPath = [documentPath stringByAppendingFormat:@"/Files"];
//    documentPath = [documentPath stringByAppendingPathComponent:downloadModel.fileName];//不用加“/”
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager createDirectoryAtPath:documentPath withIntermediateDirectories:YES attributes:nil error:nil];
//    documentPath = [documentPath stringByAppendingFormat:@"/%@",downloadModel.fileName];
    documentPath = [documentPath stringByAppendingFormat:@"/%@",fileName];

//    NSString *fileType = [[documentPath componentsSeparatedByString:@"."] lastObject];
    BOOL exist = [manager fileExistsAtPath:documentPath];
    DefLog(@"%@",documentPath);
    if (exist) {
        DefLog(@"找到本地缓存的文件");
        BGFileDownModel *isDownloadedmodel = [BGFileDownModel searchFileNameInRealm:downloadModel.fileName];
        NSString *documentPathLocal = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        documentPathLocal = [documentPathLocal stringByAppendingFormat:@"/Files/%@",isDownloadedmodel.fileName];
         //文档，其他 支持格式 txt/pdf/html/doc/docx/xls/xlsx/ppt/pptx
//        NSFileManager* fm = [NSFileManager defaultManager];
//        NSData* data = [[NSData alloc] init];
//        data = [fm contentsAtPath:documentPathLocal];
//        NSData *data = [NSData dataWithContentsOfURL:documentPathLocal];
//        DefLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

        self.fileURL = [NSURL fileURLWithPath:documentPathLocal];
        self.previewController.qlpTitle = downloadModel.nickName;
        [self.navigationController pushViewController:self.previewController animated:YES];
//        [self presentViewController:self.previewController animated:YES completion:nil];
        //刷新界面,如果不刷新的话，不重新走一遍代理方法，返回的url还是上一次的url
        [self.previewController refreshCurrentPreviewItem];
    }else{
    //网络请求下载文件
    __weak __typeof(self)weakSelf = self;
    [NetService bg_downloadFileFromUrlPath:urlString andSaveTo:documentPath progress:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
         DefLog(@"%p %f/completed=%lld/total=%lld",downloadTask,(double)totalBytesWritten/(double)totalBytesExpectedToWrite, totalBytesWritten , totalBytesExpectedToWrite);
        //        dispatch_async(dispatch_get_main_queue(), ^{
        //            downloadCell.fileDownBtn.hidden = YES;
        //            downloadCell.downLoadingLabel.hidden = NO;
        //            [downloadCell.fileDownBtn setNeedsDisplay];
        //            [downloadCell.downLoadingLabel setNeedsDisplay];
        //        });
    } success:^(id respObjc) {
         DefLog(@"succeed:%@",respObjc);
        if (respObjc) {
            NSString *localString = [(NSURL *)respObjc absoluteString];
            [realm beginWriteTransaction];
            downloadModel.fileLocalString = localString;
            downloadModel.isOwnDownloaded = NO;
            downloadModel.nickName = fileName1;
            [realm addObject:downloadModel];
            [realm commitWriteTransaction];
            
            BGFileDownModel *isDownloadedmodel = [BGFileDownModel searchFileNameInRealm:downloadModel.fileName];
                   NSString *documentPathLocal = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            documentPathLocal = [documentPathLocal stringByAppendingFormat:@"/Files/%@",isDownloadedmodel.fileName];
             //        BGOnlyAuthWkViewController *webVC = [[BGOnlyAuthWkViewController alloc] init];
            //        webVC.titleName = isDownloadedmodel.nickName;
            //        webVC.downloadFileName = isDownloadedmodel.fileName;
            //        webVC.isFromFile = @"openFile";
            //        webVC.Filelocaldata = data;
            //        webVC.fileLocalUrlPath = documentPathLocal;
            //        [self.navigationController pushViewController:webVC animated:YES];
            weakSelf.fileURL = [NSURL fileURLWithPath:documentPathLocal];
            weakSelf.previewController.qlpTitle = fileName1;
            [weakSelf.navigationController pushViewController:weakSelf.previewController animated:YES];
            //        [self presentViewController:self.previewController animated:YES completion:nil];
                    //刷新界面,如果不刷新的话，不重新走一遍代理方法，返回的url还是上一次的url
            [weakSelf.previewController refreshCurrentPreviewItem];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                downloadCell.downLoadingLabel.text = @"下载完成";
//                downloadCell.downLoadingLabel.hidden = YES;
//                downloadCell.fileDownBtn.hidden = YES;
//                [downloadCell.fileDownBtn setNeedsDisplay];
//                [downloadCell.downLoadingLabel setNeedsDisplay];
//                [weakSelf.tableview reloadData];
//            });
        }
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
         DefLog(@"error");
    }];
    }
}

//-(void)showDifferentFile{
//    if (!self.Filelocaldata) {
//        return;
//    }
//
////    NSURL *pathUrl = [NSURL URLWithString:self.fileLocalUrlPath];
////    //加载
////    NSURLRequest *request = [NSURLRequest requestWithURL:pathUrl];
////    [self.webView loadRequest:request];
//
//    NSString *fileType = [[self.downloadFileName componentsSeparatedByString:@"."] lastObject];
//    if ([fileType isEqualToString:@"txt"]) {
////        [self.webView loadData:self.Filelocaldata MIMEType:@"text/plain" textEncodingName:@"UTF-8" baseURL:nil];
//        [self.webView loadData:self.Filelocaldata MIMEType:@"text/plain"  characterEncodingName:@"UTF-8" baseURL:nil];
//    }else if ([fileType isEqualToString:@"pdf"]){
////        [self.webView loadData:self.Filelocaldata MIMEType:@"application/pdf" textEncodingName:@"UTF-8" baseURL:nil];
//        [self.webView loadData:self.Filelocaldata MIMEType:@"application/pdf"  characterEncodingName:@"UTF-8" baseURL:nil];
//    }else if ([fileType isEqualToString:@"html"]){
//        [self.webView loadData:self.Filelocaldata MIMEType:@"text/html" characterEncodingName:@"UTF-8" baseURL:nil];
//    }else if ([fileType isEqualToString:@"docx"]){
//        [self.webView loadData:self.Filelocaldata MIMEType:@"application/vnd.openxmlformats-officedocument.wordprocessingml.document" characterEncodingName:@"GB2312" baseURL:nil];
//    }else if ([fileType isEqualToString:@"doc"]){
//        [self.webView loadData:self.Filelocaldata MIMEType:@"application/msword" characterEncodingName:@"UTF-8" baseURL:nil];
//    }else if ([fileType isEqualToString:@"ppt"]){
//        [self.webView loadData:self.Filelocaldata  MIMEType:@"application/vnd.ms-powerpoint" characterEncodingName:@"UTF-8" baseURL:nil];
//    }else if ([fileType isEqualToString:@"pptx"]){
//        [self.webView loadData:self.Filelocaldata MIMEType:@"application/vnd.openxmlformats-officedocument.presentationml.presentation" characterEncodingName:@"UTF-8" baseURL:nil];
//    }else if ([fileType isEqualToString:@"xls"]){
//        [self.webView loadData:self.Filelocaldata MIMEType:@"application/vnd.ms-excel    application/x-excel" characterEncodingName:@"UTF-8" baseURL:nil];
//    }else if ([fileType isEqualToString:@"xlsx"]){
//        [self.webView loadData:self.Filelocaldata MIMEType:@"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" characterEncodingName:@"UTF-8" baseURL:nil];
//    }
//
//}

#pragma mark - 获取地址

-(void)getLoation{
    __weak __typeof(self)weakSelf = self;
//    self.pageStillLoading = YES;
    [self.locationManager requestLocationWithReGeocode:YES withNetworkState:YES completionBlock:^(BMKLocation * _Nullable location, BMKLocationNetworkState state, NSError * _Nullable error) {
             //获取经纬度和该定位点对应的位置信息
        DefLog(@"%@ %d",location,state);
        if(location){
            NSString *addressStr = [NSString stringWithFormat:@"%@%@%@%@%@%@",location.rgcData.country,location.rgcData.province,location.rgcData.city,location.rgcData.district,location.rgcData.street,location.rgcData.streetNumber];
            NSString *locationStr = [NSString stringWithFormat:@"%f;%f;%@",location.location.coordinate.latitude,location.location.coordinate.longitude,addressStr];
            NSString *locationStrJS = @"";

            UserManager *user = [UserManager manager];
            if ([user.versionNo isEqualToString:ISVersionNo]) {
                locationStrJS = [NSString stringWithFormat:@"getLocAndCheckIn('%@');",locationStr];
            }else{
                locationStrJS = [NSString stringWithFormat:@"localStorage.setItem(\"locationStrJS\",'%@');",locationStr];
            }
           
           [weakSelf.webView evaluateJavaScript:locationStrJS completionHandler:^(id _Nullable item, NSError * _Nullable error) {
               DefLog(@"item:%@ andlocationStrJs:%@",item,locationStrJS);
               
               weakSelf.pageStillLoading = NO;
           }];
        }else{
            //定位不能用
            NSString *locationStr = @"";
            NSString *locationStrJS = @"";
            UserManager *user = [UserManager manager];
            if ([user.versionNo isEqualToString:ISVersionNo]) {
                locationStrJS = [NSString stringWithFormat:@"getLocAndCheckIn('%@');",locationStr];
            }else{
                locationStrJS = [NSString stringWithFormat:@"localStorage.setItem(\"locationStrJS\",'%@');",locationStr];
            }
//            NSString *locationStrJS = [NSString stringWithFormat:@"getLocAndCheckIn('%@');",locationStr];
//           NSString *locationStrJS = [NSString stringWithFormat:@"localStorage.setItem(\"locationStrJS\",'%@');",locationStr];
           [self.webView evaluateJavaScript:locationStrJS completionHandler:^(id _Nullable item, NSError * _Nullable error) {
               DefLog(@"item%@",item);
               weakSelf.pageStillLoading = NO;
           }];
        }
        
    }];
    
    while (self.pageStillLoading) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    //开启定位服务
}

#pragma mark - Lazy loading
- (BMKLocationManager *)locationManager {
    if (!_locationManager) {
        //初始化BMKLocationManager类的实例
        _locationManager = [[BMKLocationManager alloc] init];
        //设置定位管理类实例的代理
        _locationManager.delegate = self;
        //设定定位坐标系类型，默认为 BMKLocationCoordinateTypeGCJ02
        _locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
        //设定定位精度，默认为 kCLLocationAccuracyBest
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        //设定定位类型，默认为 CLActivityTypeAutomotiveNavigation
        _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        //指定定位是否会被系统自动暂停，默认为NO
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        /**
         是否允许后台定位，默认为NO。只在iOS 9.0及之后起作用。
         设置为YES的时候必须保证 Background Modes 中的 Location updates 处于选中状态，否则会抛出异常。
         由于iOS系统限制，需要在定位未开始之前或定位停止之后，修改该属性的值才会有效果。
         */
        _locationManager.allowsBackgroundLocationUpdates = YES;
        /**
         指定单次定位超时时间,默认为10s，最小值是2s。注意单次定位请求前设置。
         注意: 单次定位超时时间从确定了定位权限(非kCLAuthorizationStatusNotDetermined状态)
         后开始计算。
         */
        _locationManager.locationTimeout = 10;
    }
    return _locationManager;
}

- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didFailWithError:(NSError * _Nullable)error {
    DefLog(@"定位失败");
    self.pageStillLoading = NO;
}


- (void)hideTabbar:(BOOL)hide {
    
    // 内嵌页面 不操作tabbar
    if (![self.parentViewController isKindOfClass:[UINavigationController class]]) {
        return;
    }
    
    // 二级页面 不操作tabbar
    if (![self isEqual:self.navigationController.viewControllers[0]]) {
        return;
    }
    
    self.isTabbarHidden = hide; // isTabbarHidden 用来保存当前tabbar的隐藏状态
    self.tabBarController.tabBar.hidden = hide;
    self.hidesBottomBarWhenPushed = hide; // 设置这个主要是用于tab间切换，切换回来的时候，保持当前页面tabbar状态不变
    
    // 调整view的大小
    UIView *tab = self.tabBarController.view;
    if (hide) {
        self.view.frame = tab.bounds;
//        self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self.webView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
//        self.hideTabbarBefore = true;
    } else {
        self.view.frame = CGRectMake(tab.bounds.origin.x, tab.bounds.origin.y, tab.bounds.size.width, tab.bounds.size.height - self.tabBarController.tabBar.frame.size.height);
    }
}

#pragma mark -- 判断网络链接

-(void)networkReachability{
     AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    //    __weak AFNetworkReachabilityManager *weak = manager;
    __weak __typeof(self)weakSelf = self;
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSString *locStrJs = @"";
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                DefLog(@"AFNetworkReachabilityStatusReachableViaWiFi");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                DefLog(@"AFNetworkReachabilityStatusNotReachable");
                locStrJs = @"当前无网络链接，请检查网络设置";
               [weakSelf.webView evaluateJavaScript:[NSString stringWithFormat:@"showToast('%@')", locStrJs] completionHandler:^(id _Nullable item, NSError * _Nullable error) {

               }];
               break;
            default:
                //AFNetworkReachabilityStatusUnknown
                DefLog(@"AFNetworkReachabilityStatusUnknown");
                break;
        }
    DefLog(@"%d,%d,%d",weak.isReachable,weak.isReachableViaWiFi,weak.isReachableViaWWAN);
    }];
        
    [manager startMonitoring];  //开启网络监视器；
}

#pragma mark -- WKNavigationDelegate
/*
 WKNavigationDelegate主要处理一些跳转、加载处理操作，WKUIDelegate主要处理JS脚本，确认框，警告框等
 */
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}


// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    // 如果是被取消，这里根据自身实际业务需求进行编辑
    if (error.code == NSURLErrorCancelled) {
        return;
    }
    [self.progressView setProgress:0.0f animated:NO];
//    [MBProgressHUD hideHUDForView:self.view animated:YES];xx
    [MBProgressHUD showError:[NSString stringWithFormat:@"页面加载失败,错误码：%ld",(long)error.code]];
    
    if([self.isFromAlarm isEqualToString:@"1"]){
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"showErrorFromAlarm" ofType:@"html" inDirectory:@"aDevices"];
                  NSURL *pathURL = [NSURL fileURLWithPath:filePath];
        [self.webView loadRequest:[NSURLRequest requestWithURL:pathURL]];
    }else{
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"showError" ofType:@"html" inDirectory:@"aDevices"];
           NSURL *pathURL = [NSURL fileURLWithPath:filePath];
        [self.webView loadRequest:[NSURLRequest requestWithURL:pathURL]];
    }
}

// 当内容到达主框架时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
   
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    DefLog(@"跳转了");
//    [self getCookie];

}

//提交发生错误时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.progressView setProgress:0.0f animated:NO];
    [MBProgressHUD showError:[NSString stringWithFormat:@"提交发生错误,错误信息%@",error.localizedDescription]];
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

// 接收到服务器跳转请求即服务重定向时之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    
}

// 根据WebView对于即将跳转的HTTP请求头信息和相关信息来决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSString * urlStr = navigationAction.request.URL.absoluteString;
    DefLog(@"发送跳转请求：%@",urlStr);
    //自己定义的协议头
    //about:blank
    NSString *htmlHeadString = @"github://";
    if([urlStr hasPrefix:htmlHeadString]){
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"通过截取URL调用OC" message:@"你想前往我的Github主页?" preferredStyle:UIAlertControllerStyleAlert];
//        [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//
//        }])];
//        [alertController addAction:([UIAlertAction actionWithTitle:@"打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            NSURL * url = [NSURL URLWithString:[urlStr stringByReplacingOccurrencesOfString:@"github://callName_?" withString:@""]];
//            [[UIApplication sharedApplication] openURL:url];
//
//        }])];
//        [self presentViewController:alertController animated:YES completion:nil];
//
//        decisionHandler(WKNavigationActionPolicyCancel);
//
    }else if ([urlStr isEqualToString:@"about:blank"]){
       decisionHandler(WKNavigationActionPolicyAllow);
//        [_webView goBack];
//        if(UIDEVICE_SYSTEMVERSION < 9.0f){
//            decisionHandler(WKNavigationActionPolicyAllow);
//        }else{
//            //返回+2的枚举值
//            decisionHandler(WKNavigationActionPolicyAllow + 2);
//        }
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

// 根据客户端受到的服务器响应头以及response相关信息来决定是否可以跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSString * urlStr = navigationResponse.response.URL.absoluteString;
    DefLog(@"当前跳转地址：%@",urlStr);
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationResponsePolicyCancel);
}

//需要响应身份验证时调用 同样在block中需要传入用户身份凭证
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    
    //用户身份信息
//    NSURLCredential * newCred = [[NSURLCredential alloc] initWithUser:@"user123" password:@"123" persistence:NSURLCredentialPersistenceNone];
//    //为 challenge 的发送方提供 credential
//    [challenge.sender useCredential:newCred forAuthenticationChallenge:challenge];
//    completionHandler(NSURLSessionAuthChallengeUseCredential,newCred);
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([challenge previousFailureCount] == 0) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        } else {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    } else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }

}

//进程被终止时调用
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
    
}

#pragma mark -- WKUIDelegate

/**
 *  web界面中有弹出警告框时调用
 *
 *  @param webView           实现该代理的webview
 *  @param message           警告框中的内容
 *  @param completionHandler 警告框消失调用
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 确认框
//JavaScript调用confirm方法后回调的方法 confirm是js中的确定框，需要在block中把用户选择的情况传递进去
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 输入框
//JavaScript调用prompt方法后回调的方法 prompt是js中的输入框 需要在block中把用户输入的信息传入
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 页面是弹出窗口 _blank 处理
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{

    //移除观察者
    [_webView removeObserver:self
                  forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    [_webView removeObserver:self
                  forKeyPath:NSStringFromSelector(@selector(title))];
    
    [UIImagePickerController unHookDelegate];
    //移除注册的js方法
    
     [self.susView removeFromScreen];
}


#pragma mark - JXCategoryListCollectionContentViewDelegate

- (UIView *)listView {
    return self.view;
}

- (void)listDidAppear {
    DefLog(@"%@", NSStringFromSelector(_cmd));
    //因为`JXCategoryListCollectionContainerView`内部通过`UICollectionView`的cell加载列表。当切换tab的时候，之前的列表所在的cell就被回收到缓存池，就会从视图层级树里面被剔除掉，即没有显示出来且不在视图层级里面。这个时候MJRefreshHeader所持有的UIActivityIndicatorView就会被设置hidden。所以需要在列表显示的时候，且isRefreshing==YES的时候，再让UIActivityIndicatorView重新开启动画。
    //    if (self.showScrollerView.mj_header.isRefreshing) {
    //        UIActivityIndicatorView *activity = [self.showScrollerView.mj_header valueForKey:@"loadingView"];
    //        [activity startAnimating];
    //    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    if(!self.isAllowXZoom){
        return nil;
    }else{
//        [self.webView.scrollView setZoomScale:0.8 animated:NO];
        return self.webView.scrollView.subviews.firstObject;
    }
}

- (void)listDidDisappear {
    DefLog(@"%@", NSStringFromSelector(_cmd));
    
}

#pragma mark - QLPreviewControllerDataSource
-(id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
//    NSURL *url = [NSURL fileURLWithPath:self.savePath];
//       FotileFileItem *item = [[FotileFileItem alloc] init];
//
//       item.previewItemURL = url; //url
//       item.name = self.navTitle; //title

    return self.fileURL;
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController{
    return 1;
}


#pragma mark - ZYSuspensionViewDelegate 悬浮球代理 轨迹
- (void)suspensionViewClick:(ZYSuspensionView *)suspensionView
{
    DefLog(@"click %@",suspensionView.titleLabel.text);
    UIViewController *subVC = [[YYServiceViewController alloc] init];
    subVC.title = DefLocalizedString(@"pathtracking");
    [self.susView removeFromScreen];
    [self.navigationController pushViewController:subVC animated:NO];

}

#pragma mark - 导航第三方地图
-(void)pushAddressMapSelectWithLatitude:(NSString *)fLatitude andLongitude:(NSString *)fLongitude andLocName:(NSString *)locName{
    NSString *urlScheme = @"MapJump://";
    NSString *appName = @"MapJump";
    CLLocationCoordinate2D coordinate;
    if (fLatitude && fLongitude) {
        coordinate  = CLLocationCoordinate2DMake([fLatitude doubleValue], [fLongitude doubleValue]);
    }else{
        [MBProgressHUD showError:@"变电所位置为空"];
    }
    NSString *addressName = @"终点";
    if(locName){
        addressName = locName;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择地图" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    //这个判断其实是不需要的
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"http://maps.apple.com/"]]) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"苹果地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            CLLocationCoordinate2D desCoordinate = coordinate;
            
            MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:desCoordinate addressDictionary:nil]];
            toLocation.name = addressName;//可传入目标地点名称
            [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                           launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
        }];
        
        [alert addAction:action];
    }
    
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        
            CLLocationCoordinate2D desCoordinate = [JZLocationConverter gcj02ToBd09:coordinate];//火星坐标转化为百度坐标
        
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"百度地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            //我的位置代表起点位置为当前位置，也可以输入其他位置作为起点位置，如天安门
            NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=name:%@|latlng:%f,%f&mode=driving&src=JumpMapDemo",addressName,desCoordinate.latitude, desCoordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            DefLog(@"%@",urlString);
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            
        }];
        
        [alert addAction:action];
    }
    
    
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        //coordinate = CLLocationCoordinate2DMake(40.057023, 116.307852);
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"高德地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            CLLocationCoordinate2D desCoordinate = coordinate;
            
            NSString *urlString = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=applicationName&sid=BGVIS1&sname=%@&did=BGVIS2&dlat=%f&dlon=%f&dev=0&m=0&t=0",@"我的位置",desCoordinate.latitude, desCoordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//@"我的位置"可替换为@"终点名称"
            
            DefLog(@"%@",urlString);
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            
        }];
        
        [alert addAction:action];
    }
    
    
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"谷歌地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            CLLocationCoordinate2D desCoordinate = coordinate;
            
            NSString *urlString = [[NSString stringWithFormat:@"comgooglemaps://?x-source=%@&x-success=%@&saddr=&daddr=%f,%f&directionsmode=driving",appName,urlScheme,desCoordinate.latitude, desCoordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            DefLog(@"%@",urlString);
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            
        }];
        
        [alert addAction:action];
    }
    
    
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]])    {
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"腾讯地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            CLLocationCoordinate2D desCoordinate = coordinate;
            
            NSString *urlString = [[NSString stringWithFormat:@"qqmap://map/routeplan?type=drive&from=我的位置&to=%@&tocoord=%f,%f&policy=1&referer=%@", addressName, desCoordinate.latitude, desCoordinate.longitude, appName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            DefLog(@"%@",urlString);
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            
        }];
        
        [alert addAction:action];
    }
    
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    
//    [[self getCurrentVC] presentViewController:alert animated:YES completion:^{
//
//    }];
    [self presentViewController:alert animated:YES completion:nil];
}

//左滑页面
//- (void)willMoveToParentViewController:(UIViewController*)parent
//{
//    [super willMoveToParentViewController:parent];
//
//    DefLog(@"%s,%@",__FUNCTION__,parent);
//
//}
//
//- (void)didMoveToParentViewController:(UIViewController*)parent
//{
//    [super didMoveToParentViewController:parent];
//
//    DefLog(@"%s,%@",__FUNCTION__,parent);
//    if(self.isFromAlarm){
//           [self hideTabbar:NO];
//       }
//    if(!parent){
//        DefLog(@"离开页面");
//
//    }
//}



@end
