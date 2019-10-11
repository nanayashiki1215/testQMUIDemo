//
//  BGNomalWebView.m
//  变电所运维
//
//  Created by Acrel on 2019/5/27.
//

#import "BGNomalWebView.h"
#import "WebViewJavascriptBridge.h"
@interface BGNomalWebView ()<UIWebViewDelegate>
@property WebViewJavascriptBridge* bridge;
@end

@implementation BGNomalWebView
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
////    localUrlString = @"www/app/v-beyERj-zh_CN-/app/alarm.w";
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"www/app/v-beyERj-zh_CN-/app/alarm.w" ofType:@"html"];
////     NSString *path = [[NSBundle mainBundle] pathForResource:@"www/app/index" ofType:@"html"];
//    NSURL *url = [NSURL fileURLWithPath:path];
//    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
//    NSData *data = [NSData dataWithContentsOfFile:path];
//
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDir = [paths objectAtIndex:0] ;   //根据自己的具体情况设置，我的html文件在document目录，链接也是在这个目录上开始
//    NSURL *baseUrl = [NSURL fileURLWithPath:documentsDir];
////    [webView loadData:data MIMEType:@"text/html" textEncodingName:@"GBK" baseURL:url];
//    [webView loadData:data MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:baseUrl];
//
////    [webView loadRequest:[NSURLRequest requestWithURL:url]];
//    [self.view addSubview:webView];

    //加载网页
//    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://energy.acrel.cn"]];
//    [self.EMwebview loadRequest:request];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_bridge) { return; }
    UserManager *user = [UserManager manager];
    self.title = user.fsubName;
    
    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:webView];
    
    [WebViewJavascriptBridge enableLogging];
    
    _bridge = [WebViewJavascriptBridge bridgeForWebView:webView];
    [_bridge setWebViewDelegate:self];
    
    [_bridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback called: %@", data);
        responseCallback(@"Response from testObjcCallback");
    }];
    NSString *kToken = [DefNSUD objectForKey:@"Token"];
    //
    NSDictionary *dataDic = @{@"baseUrl":BASE_URL,@"kToken":kToken,@"fSubName":user.fsubName,@"fSubid":user.fsubID};
//    [_bridge callHandler:@"testJavascriptHandler" data:dataDic];
    [_bridge callHandler:@"testJavascriptHandler" data:dataDic responseCallback:^(id response) {
        NSLog(@"testJavascriptHandler responded: %@", response);
    }];
    //[self renderButtons:webView];
    [self loadExamplePage:webView];
}

- (void)callHandler:(id)sender {
    
    UserManager *user = [UserManager manager];
    id data = @{ @"greetingFromObjC": user.fsubID };
    [_bridge callHandler:@"testJavascriptHandler" data:data responseCallback:^(id response) {
        NSLog(@"testJavascriptHandler responded: %@", response);
    }];
}

- (void)loadExamplePage:(UIWebView*)webView {
//    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"function" ofType:@"html"];
//    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
//    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
//    [webView loadHTMLString:appHtml baseURL:baseURL];
//    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:htmlPath]];
//    [webView loadRequest:request];
//    NSURL *url = [[NSBundle mainBundle] URLForResource:@"function.html" withExtension:nil];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"function" ofType:@"html" inDirectory:@"assets"];
    NSURL *pathURL = [NSURL fileURLWithPath:filePath];
    [webView loadRequest:[NSURLRequest requestWithURL:pathURL]];
}

- (void)disableSafetyTimeout {
    [self.bridge disableJavscriptAlertBoxSafetyTimeout];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webViewDidFinishLoad");
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

- (void)listDidDisappear {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}
@end
