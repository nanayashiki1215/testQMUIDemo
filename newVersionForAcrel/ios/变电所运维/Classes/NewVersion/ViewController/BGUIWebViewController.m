//
//  BGUIWebViewController.m
//  变电所运维
//
//  Created by Acrel on 2019/5/21.
//

#import "BGUIWebViewController.h"
#import <WebKit/WebKit.h>
#import "WSDatePickerView.h"
#import <BMKLocationKit/BMKLocationComponent.h>


// WKWebView 内存不释放的问题解决
@interface WeakWebViewScriptMessageDelegate : NSObject<WKScriptMessageHandler>

//WKScriptMessageHandler 这个协议类专门用来处理JavaScript调用原生OC的方法
@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;

@end
@implementation WeakWebViewScriptMessageDelegate

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate {
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

#pragma mark - WKScriptMessageHandler
//遵循WKScriptMessageHandler协议，必须实现如下方法，然后把方法向外传递
//通过接收JS传出消息的name进行捕捉的回调方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([self.scriptDelegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
        [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}

@end

@interface BGUIWebViewController ()<WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate,BMKLocationManagerDelegate>

@property (strong,nonatomic) WKWebView *webView;
//网页加载进度视图
@property (nonatomic, strong) UIProgressView * progressView;

@property (nonatomic, strong) BMKLocationManager *locationManager; //定位对象

@end

@implementation BGUIWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.webView.navigationDelegate = self;
//    self.webView.scrollView.delegate = self;
    [self.webView.scrollView setShowsVerticalScrollIndicator:NO];
    [self.webView.scrollView setShowsHorizontalScrollIndicator:NO];
//    if (@available(iOS 11.0, *)) {
//        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//    }
    [self.view addSubview:self.webView];
//    [self.view addSubview:self.progressView];
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
    if(self.showWebType == showWebTypeDevice){
        self.navigationController.navigationBarHidden = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
        [self setStatusBarBackgroundColor:COLOR_WEBNAVBAR];
    }
    if (self.titleName.length>0) {
        self.navigationItem.title = self.titleName;
    }
    
    if(self.showWebType == showWebTypeAlarm){
//      报警类型重新加载
        if (!self.isUseOnline) {
            [self loadLocalHtml];
        }else{
            [self loadOnlineHtml];
        }
    }
   
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self setStatusBarBackgroundColor:[UIColor clearColor]];
}


//设置状态栏颜色
- (void)setStatusBarBackgroundColor:(UIColor *)color {
    
    if (UNDERiOS11) {
        UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
            statusBar.backgroundColor = color;
        }
    }
    
}

-(void)loadLocalHtml{
    if (self.localUrlString) {
//        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"Dis-test/demo"];
//        NSURL *pathURL = [NSURL fileURLWithPath:filePath];
        NSURL *pathURL = [NSURL fileURLWithPath:self.localUrlString];
        [self.webView loadRequest:[NSURLRequest requestWithURL:pathURL]];
    }
//    NSURL *url = [[NSBundle mainBundle] URLForResource:@"/sfa/html/index.html" withExtension:nil];
//    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

-(void)loadOnlineHtml{
    if (self.onlineUrlString) {
        NSURL * url = [NSURL URLWithString:self.onlineUrlString];
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
        
        NSLog(@"网页加载进度 = %f",_webView.estimatedProgress);
//        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        self.progressView.progress = _webView.estimatedProgress;
        if (_webView.estimatedProgress >= 1.0f) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                self.progressView.progress = 0;
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
        NSLog(@"改变HTML的背景色");
    }];
    
    //改变字体大小 调用原生JS方法
    NSString *jsFont = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'", arc4random()%99 + 100];
    [_webView evaluateJavaScript:jsFont completionHandler:nil];
    
    NSString * path =  [[NSBundle mainBundle] pathForResource:@"girl" ofType:@"png"];
    NSString *jsPicture = [NSString stringWithFormat:@"changePicture('%@','%@')", @"pictureId",path];
    [_webView evaluateJavaScript:jsPicture completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        NSLog(@"切换本地头像");
    }];
    
}

#pragma mark -- Getter

- (UIProgressView *)progressView
{
    if (!_progressView){
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0,1, self.view.frame.size.width, 2)];
        _progressView.tintColor = [UIColor blueColor];
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
        
        //自定义的WKScriptMessageHandler 是为了解决内存不释放的问题
        WeakWebViewScriptMessageDelegate *weakScriptMessageDelegate = [[WeakWebViewScriptMessageDelegate alloc] initWithDelegate:self];
        //这个类主要用来做native与JavaScript的交互管理
        WKUserContentController * wkUController = [[WKUserContentController alloc] init];
        //注册一个name为jsToOcNoPrams的js方法 设置处理接收JS方法的对象
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate  name:@"goBackiOS"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate  name:@"jsToOcWithPrams"];
        //调用时间控件
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate  name:@"getiOSTime"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"needHiddenTabbar"];
//        pushNewWebView
//        getLocation
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"pushNewWebView"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"getLocation"];
        config.userContentController = wkUController;
        
        //以下代码适配文本大小
//        NSString *jSString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
        //用于进行JavaScript注入
//        WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
//        [config.userContentController addUserScript:wkUScript];
        
        //自适应网页内容
        NSString *jScript;
        if(self.isAllowXZoom){
//            jScript = @"var meta = document.createElement('meta'); \
//            meta.name = 'viewport'; \
//            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=10.0, user-scalable=yes'; \
//            var head = document.getElementsByTagName('head')[0];\
//            head.appendChild(meta);";
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
        if (self.menuId.length>0) {
           jsStartString = [NSString stringWithFormat:@"var obj = {'token': '%@','baseurl':'%@','fsubID':'%@','ipAddress':'%@','fmenuId':'%@','userID':'%@'}; obj = JSON.stringify(obj); localStorage.setItem('accessToken',obj);",user.token,baseUrl,user.fsubID,ipAddress,self.menuId,user.bguserId];
        }else{
           jsStartString = [NSString stringWithFormat:@"var obj = {'token': '%@','baseurl':'%@','fsubID':'%@','ipAddress':'%@','userID':'%@'}; obj = JSON.stringify(obj); localStorage.setItem('accessToken',obj);",user.token,baseUrl,user.fsubID,ipAddress,user.bguserId];
        }
//        NSString *jsStartString = [NSString stringWithFormat:@"var baserUrl = %@; var token %@",baseUrl,user.token];
        
        //用于进行JavaScript注入
        WKUserScript *wkUScript2 = [[WKUserScript alloc] initWithSource:jsStartString injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];

        [config.userContentController addScriptMessageHandler:weakScriptMessageDelegate name:@"iOS"];
        [config.userContentController addUserScript:wkUScript2];
        
        if(self.showWebType == showWebTypeDevice){
            
//            _webView.backgroundColor = [UIColor clearColor];
            if (iOS11) {
//                _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
                _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) configuration:config];
            } else if (iOS9){
                _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT) configuration:config];
            }else{
                _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) configuration:config];
            }
//                self.edgesForExtendedLayout = UIRectEdgeNone;
//            }
            _webView.scrollView.bounces = false;
        }else if(self.showWebType == showWebTypeAlarmWithTab || self.showWebType == showWebTypeAlarm){
            _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-BGSafeAreaTopHeight) configuration:config];
        }else{
            
            _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-BGSafeAreaTopHeight-BGTopBarHeight-BGSafeAreaBottomHeight) configuration:config];
    }
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
        //        [_webView loadRequest:request];
//        NSString *path;
//        if (self.localUrlString) {
//            path = [[NSBundle mainBundle] pathForResource:self.localUrlString ofType:nil];
//        }
//        NSString *htmlString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//        [_webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
        
    }
    return _webView;
}


//解决第一次进入的cookie丢失问题
- (NSString *)readCurrentCookieWithDomain:(NSString *)domainStr{
    NSHTTPCookieStorage*cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSMutableString * cookieString = [[NSMutableString alloc]init];
    for (NSHTTPCookie*cookie in [cookieJar cookies]) {
        [cookieString appendFormat:@"%@=%@;",cookie.name,cookie.value];
    }
    
    //删除最后一个“;”
    if ([cookieString hasSuffix:@";"]) {
        [cookieString deleteCharactersInRange:NSMakeRange(cookieString.length - 1, 1)];
    }
    
    return cookieString;
}

//解决 页面内跳转（a标签等）还是取不到cookie的问题
- (void)getCookie{
    
    //取出cookie
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    //js函数
    NSString *JSFuncString =
    @"function setCookie(name,value,expires)\
    {\
    var oDate=new Date();\
    oDate.setDate(oDate.getDate()+expires);\
    document.cookie=name+'='+value+';expires='+oDate+';path=/'\
    }\
    function getCookie(name)\
    {\
    var arr = document.cookie.match(new RegExp('(^| )'+name+'=([^;]*)(;|$)'));\
    if(arr != null) return unescape(arr[2]); return null;\
    }\
    function delCookie(name)\
    {\
    var exp = new Date();\
    exp.setTime(exp.getTime() - 1);\
    var cval=getCookie(name);\
    if(cval!=null) document.cookie= name + '='+cval+';expires='+exp.toGMTString();\
    }";
    
    //拼凑js字符串
    NSMutableString *JSCookieString = JSFuncString.mutableCopy;
    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
        NSString *excuteJSString = [NSString stringWithFormat:@"setCookie('%@', '%@', 1);", cookie.name, cookie.value];
        [JSCookieString appendString:excuteJSString];
    }
    //执行js
    [_webView evaluateJavaScript:JSCookieString completionHandler:nil];
    
}


//被自定义的WKScriptMessageHandler在回调方法里通过代理回调回来，绕了一圈就是为了解决内存不释放的问题
//通过接收JS传出消息的name进行捕捉的回调方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    NSLog(@"name:%@\\\\n body:%@\\\\n frameInfo:%@\\\\n",message.name,message.body,message.frameInfo);
    //用message.body获得JS传出的参数体
//    NSDictionary *parameter = message.body;
    //JS调用OC
//     UIView *view = [[UIView alloc] initWithFrame:CGRectMake(40, 0, SCREEN_WIDTH-40, 100)];
    if ([message.name isEqualToString:@"getiOSTime"]) {
        //获取原生时间控件
        __weak __typeof(self)weakSelf = self;
        WSDatePickerView *datepicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDay CompleteBlock:^(NSDate *selectDate) {
            NSString *showString = [selectDate stringWithFormat:@"yyyy-MM-dd HH:mm"];
            NSString *dateString = [selectDate stringWithFormat:@"yyyyMMdd"];
            NSLog(@"选择的日期：%@",dateString);
            
//            DefLog(@"timeStr:%@",timerStr);
            NSString *timeStrJS = [NSString stringWithFormat:@"alertAction('%@')",showString];
            [weakSelf.webView evaluateJavaScript:timeStrJS completionHandler:^(id _Nullable item, NSError * _Nullable error) {
                NSLog(@"alert");
            }];
        }];
        datepicker.dateLabelColor = COLOR_NAVBAR;//年-月-日-时-分 颜色
        datepicker.datePickerColor = [UIColor blackColor];//滚轮日期颜色
        datepicker.doneButtonColor = COLOR_NAVBAR;//确定按钮的颜色
        [datepicker show];
    }else if([message.name isEqualToString:@"goBackiOS"]){
        //返回到原生页面
        [self.navigationController popViewControllerAnimated:YES];
        [self setStatusBarBackgroundColor:[UIColor clearColor]];
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//        view.backgroundColor = COLOR_NAVBAR;
//        //获取当前UIWindow 并添加一个视图
//
//        UIApplication *ap = [UIApplication sharedApplication];
//        [ap.keyWindow addSubview:view];

//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"js调用到了oc" message:@"不带参数" preferredStyle:UIAlertControllerStyleAlert];
//        [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        }])];
//        [self presentViewController:alertController animated:YES completion:nil];

    }
    else if([message.name isEqualToString:@"jsToOcWithPrams"]){
        //配置小红点
//        view.hidden = YES;
//        [view removeFromSuperview];
        NSDictionary *msgDic = message.body;
        NSString *str = msgDic[@"unreadCountSum"];
        NSInteger count = [str integerValue];
        if (count>0) {
            [[BGQMToolHelper bg_sharedInstance] bg_setTabbarBadge:YES withItemsNumber:1 withShowText:str];
        }else{
            [[BGQMToolHelper bg_sharedInstance] bg_setTabbarBadge:NO withItemsNumber:1 withShowText:@""];
        }
        DefLog(@"%@",message);
    }else if ([message.name isEqualToString:@"needHiddenTabbar"]){
        BOOL isHidden = [message.body isEqualToString:@"YES"]?YES:NO;
        [self hideTabbar:isHidden];
    }else if ([message.name isEqualToString:@"pushNewWebView"]){
        DefLog(@"%@",message.body);
        NSString *titleName = message.body[@"title"];
        NSString *url = message.body[@"url"];
        BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"alarmsDetail" ofType:@"html" inDirectory:@"aDevices"];
        nomWebView.isUseOnline = NO;
        nomWebView.localUrlString = filePath;
        nomWebView.urlParams = url;
        nomWebView.showWebType = showWebTypeAlarmWithTab;
        nomWebView.titleName = titleName;
        [self.navigationController pushViewController:nomWebView animated:YES];
    }else if ([message.name isEqualToString:@"getLocation"]){
//    self.locationManager = [[BMKLocationManager alloc] init];
//       locationManager.delegate = self;
//       locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
//       locationManager.distanceFilter = kCLDistanceFilterNone;
//       locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//       locationManager.activityType = CLActivityTypeAutomotiveNavigation;
//       locationManager.pausesLocationUpdatesAutomatically = NO;
//       locationManager.allowsBackgroundLocationUpdates = YES;
//       locationManager.locationTimeout = 10;
//       locationManager.reGeocodeTimeout = 10;

        [self getLoation];
    }
}

-(void)getLoation{
    __weak __typeof(self)weakSelf = self;
    [self.locationManager requestLocationWithReGeocode:YES withNetworkState:YES completionBlock:^(BMKLocation * _Nullable location, BMKLocationNetworkState state, NSError * _Nullable error) {
             //获取经纬度和该定位点对应的位置信息
        DefLog(@"%@ %d",location,state);
        
        NSString *addressStr = [NSString stringWithFormat:@"%@%@%@%@%@%@",location.rgcData.country,location.rgcData.province,location.rgcData.city,location.rgcData.district,location.rgcData.street,location.rgcData.streetNumber];
        NSString *locationStr = [NSString stringWithFormat:@"%f;%f;%@",location.location.coordinate.latitude,location.location.coordinate.longitude,addressStr];
        NSString *locationStrJS = [NSString stringWithFormat:@"passOnLocation('%@')",locationStr];
       [weakSelf.webView evaluateJavaScript:locationStrJS completionHandler:^(id _Nullable item, NSError * _Nullable error) {
           NSLog(@"item%@",item);
       }];
    }];
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
        _locationManager.allowsBackgroundLocationUpdates = NO;
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
//        self.hideTabbarBefore = true;
    } else {
        self.view.frame = CGRectMake(tab.bounds.origin.x, tab.bounds.origin.y, tab.bounds.size.width, tab.bounds.size.height - self.tabBarController.tabBar.frame.size.height);
    }
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
    [self.progressView setProgress:0.0f animated:NO];
//    [MBProgressHUD hideHUDForView:self.view animated:YES];xx
    [MBProgressHUD showError:[NSString stringWithFormat:@"页面加载失败,错误码：%ld",(long)error.code]];
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    [self getCookie];

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
    NSLog(@"发送跳转请求：%@",urlStr);
    //自己定义的协议头
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
    }else{
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

// 根据客户端受到的服务器响应头以及response相关信息来决定是否可以跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSString * urlStr = navigationResponse.response.URL.absoluteString;
    NSLog(@"当前跳转地址：%@",urlStr);
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationResponsePolicyCancel);
}

//需要响应身份验证时调用 同样在block中需要传入用户身份凭证
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    
    //用户身份信息
    NSURLCredential * newCred = [[NSURLCredential alloc] initWithUser:@"user123" password:@"123" persistence:NSURLCredentialPersistenceNone];
    //为 challenge 的发送方提供 credential
    [challenge.sender useCredential:newCred forAuthenticationChallenge:challenge];
    completionHandler(NSURLSessionAuthChallengeUseCredential,newCred);
    
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
    [alertController addAction:([UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 确认框
//JavaScript调用confirm方法后回调的方法 confirm是js中的确定框，需要在block中把用户选择的情况传递进去
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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

- (void)dealloc{

    [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"goBackiOS"];
    [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"jsToOcWithPrams"];
    [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"getiOSTime"];
     [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"needHiddenTabbar"];
//    pushNewWebView
     [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"pushNewWebView"];
//    getLocation
     [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"getLocation"];
//    getiOSTime
    //移除观察者
    [_webView removeObserver:self
                  forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    [_webView removeObserver:self
                  forKeyPath:NSStringFromSelector(@selector(title))];
    //移除注册的js方法
//    self.webView.UIDelegate = nil;
//    self.webView.navigationDelegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - JXCategoryListCollectionContentViewDelegate

- (UIView *)listView {
    return self.view;
}

- (void)listDidAppear {
    NSLog(@"%@", NSStringFromSelector(_cmd));
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
    NSLog(@"%@", NSStringFromSelector(_cmd));
}



@end
