//
//  BGWebViewController.m
//  变电所运维
//
//  Created by Acrel on 2019/5/16.
//

#import "BGWebViewController.h"
#import "BGUIWebViewController.h"

@interface BGWebViewController ()<WKUIDelegate>
@property(nonatomic, strong) WKWebView *wkwebview;
@end

@implementation BGWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.homeButton.hidden = NO;
//    self.view.backgroundColor = [UIColor whiteColor];
    
//    NSString *jSString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    NSString *jSString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    //用于进行JavaScript注入
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jSString injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
//    [config.userContentController addScriptMessageHandler:[[WeakWebViewScriptMessageDelegate alloc] initWithDelegate:self] name:@"iOS"];
//    [config.userContentController addUserScript:wkUScript];
    
    self.wkwebview = [[WKWebView alloc] initWithFrame:self.view.bounds];
    
    //    [self.wkwebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.112.212:8080/web_manage/login.jsp"]]];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"function" ofType:@"html" inDirectory:@"assets"];
    NSURL *pathURL = [NSURL fileURLWithPath:filePath];
    [self.wkwebview loadRequest:[NSURLRequest requestWithURL:pathURL]];
    
    self.wkwebview.UIDelegate = self;
    [self.wkwebview addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
   [self.view addSubview:self.wkwebview];
    
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

//WkWebView的 回调
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"title"]) {
        if (object == self.wkwebview) {
            self.title = self.wkwebview.title;
            if (!self.title.length) {
                self.title = @"Web页面";
            }
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}

- (void)moreButtonAction:(UIButton *)moreBtn{
    
}

- (void)dealloc{
    [_wkwebview removeObserver:self forKeyPath:@"title"];
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
