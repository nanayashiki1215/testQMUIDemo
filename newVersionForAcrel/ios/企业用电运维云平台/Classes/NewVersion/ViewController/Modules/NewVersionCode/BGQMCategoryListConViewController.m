//
//  BGQMCategoryListConViewController.m
//  变电所运维
//
//  Created by Acrel on 2019/6/4.
//  
//

#import "BGQMCategoryListConViewController.h"
#import "JXCategoryView.h"
#import "JXCategoryListCollectionContainerView.h"
#import "BGQMElectViewController.h"
#import "BGUIWebViewController.h"
#import "BGQMVideoListTableVC.h"

@interface BGQMCategoryListConViewController ()< JXCategoryListCollectionContainerViewDataSource>
@property (nonatomic, strong) JXCategoryTitleView *categoryView;
@property (nonatomic, strong) JXCategoryListCollectionContainerView *listContainerView;
@property (nonatomic, strong) NSArray <NSString *> *titles;

@end

@implementation BGQMCategoryListConViewController

- (void)didInitialize {
    [super didInitialize];
    // init 时做的事情请写在这里
}

- (void)initSubviews {
    [super initSubviews];
    // 对 subviews 的初始化写在这里
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 对 self.view 的操作写在这里
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.titles = [self getRandomTitles];
    self.categoryView = [[JXCategoryTitleView alloc] init];
    //因为JXCategoryListCollectionContainerView触发列表加载是在willDisplayCell代理方法里面。如果categoryView跨item点击（比如当前index=0，点击了index=10），并且过渡有动画就会依次触发中间cell的willDisplayCell方法，进而加载列表（即触发index:1~9的列表加载）。这显然违背懒加载，所以如果你选择使用JXCategoryListCollectionContainerView，那么最好就是将contentScrollViewClickTransitionAnimationEnabled设置为NO。
    self.categoryView.contentScrollViewClickTransitionAnimationEnabled = NO;
    self.categoryView.titles = self.titles;
    self.categoryView.titleColor = [UIColor blackColor];
    self.categoryView.titleSelectedColor = COLOR_NAVBAR;
    self.categoryView.titleColorGradientEnabled = YES;
//    self.categoryView.titleLabelZoomScrollGradientEnabled = NO;
    
    JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
    lineView.indicatorColor = COLOR_NAVBAR;
    lineView.indicatorLineViewHeight = 1.f;
    self.categoryView.indicators = @[lineView];
    
    self.listContainerView = [[JXCategoryListCollectionContainerView alloc] init];
    self.listContainerView.dataSource = self;
    if (self.clickIndex) {
        self.categoryView.defaultSelectedIndex = self.clickIndex;
        self.listContainerView.defaultSelectedIndex = self.clickIndex;
    }else{
        self.categoryView.defaultSelectedIndex = 0;
        self.listContainerView.defaultSelectedIndex = 0;
    }
    [self.view addSubview:self.categoryView];
    [self.view addSubview:self.listContainerView];
    
    self.categoryView.contentScrollView = self.listContainerView.collectionView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.categoryView.frame = CGRectMake(0,BGSafeAreaTopHeight, SCREEN_WIDTH, BGTopBarHeight);
    self.listContainerView.frame = CGRectMake(0, BGTopBarHeight+BGSafeAreaTopHeight, self.view.bounds.size.width, self.view.bounds.size.height - BGTopBarHeight - BGSafeAreaTopHeight-BGSafeAreaBottomHeight);
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    UserManager *user = [UserManager manager];
    self.title = user.fsubName;
}

#pragma mark - JXCategoryListCollectionContainerViewDataSource

- (id<JXCategoryListCollectionContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    //        NSString *url = [NSString changgeNonulWithString:self.allDataArr[index][@"url"]];
    //        if (url.length) {
    //            BGUIWebViewController *urlWebView = [[BGUIWebViewController alloc] init];
    //            urlWebView.isUseOnline = NO;
    //            urlWebView.onlineUrlString = url;
    //            return urlWebView;
    //        }
//    if (self.clickIndexOfSelectedCell == 5){
        //环境
        NSString *videoStr = [NSString changgeNonulWithString:self.allDataArr[index][@"fCode"]];
        if (videoStr.length>0 && [videoStr isEqualToString:@"videoPlay"]) {
            //视频单独拉出来
            BGQMVideoListTableVC *videoListVC = [[BGQMVideoListTableVC alloc] init];
            videoListVC.ownNaviController = self.navigationController;
            return videoListVC;
        }
//    }
    NSString *url = [NSString changgeNonulWithString:self.allDataArr[index][@"fActionurl"]];
    NSString *iOSUrl = [NSString changgeNonulWithString:self.allDataArr[index][@"fFunctionfield"]];
    if(iOSUrl.length){
            NSArray * strarr = [iOSUrl componentsSeparatedByString:@"."];
            NSString *urlStr= strarr.firstObject;
            BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
            NSString *filePath = [[NSBundle mainBundle] pathForResource:urlStr ofType:@"html" inDirectory:@"assets"];
            nomWebView.isUseOnline = NO;
            nomWebView.localUrlString = filePath;
            return nomWebView;
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
                return urlWebView;
            }
//        NSArray * strarr = [url componentsSeparatedByString:@"."];
//        NSString *urlStr= strarr.firstObject;
//        BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
//        NSString *filePath = [[NSBundle mainBundle] pathForResource:urlStr ofType:@"html" inDirectory:@"assets"];
//        nomWebView.isUseOnline = YES;
//        nomWebView.localUrlString = filePath;
//        return nomWebView;
    }else{
        //其他均用url加载 通用方法
        NSString *url = [NSString changgeNonulWithString:self.allDataArr[index][@"url"]];
        if (url.length) {
            BGUIWebViewController *urlWebView = [[BGUIWebViewController alloc] init];
            urlWebView.isUseOnline = YES;
            urlWebView.onlineUrlString = url;
            return urlWebView;
        }
    }
   
    
//    if (self.clickIndexOfSelectedCell == 0) {
//        //事件
//        if (index ==0) {
//            BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
//            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"function" ofType:@"html" inDirectory:@"assets"];
//            nomWebView.isUseOnline = NO;
//            nomWebView.localUrlString = filePath;
//            return nomWebView;
//        }else if (index == 1){
//            BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
//            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"functionDisplace" ofType:@"html" inDirectory:@"assets"];
//            nomWebView.isUseOnline = NO;
//            nomWebView.localUrlString = filePath;
//            return nomWebView;
//        }else if (index == 2){
//            BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
//            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"meterOffline" ofType:@"html" inDirectory:@"assets"];
//            nomWebView.isUseOnline = NO;
//            nomWebView.localUrlString = filePath;
//            return nomWebView;
//        }else if (index == 3){
//            BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
//            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"gatewayOffline" ofType:@"html" inDirectory:@"assets"];
//            nomWebView.isUseOnline = NO;
//            nomWebView.localUrlString = filePath;
//            return nomWebView;
//        }else{
//            NSString *url = [NSString changgeNonulWithString:self.allDataArr[index][@"url"]];
//            if (url.length) {
//                BGUIWebViewController *urlWebView = [[BGUIWebViewController alloc] init];
//                urlWebView.isUseOnline = YES;
//                urlWebView.onlineUrlString = url;
//                return urlWebView;
//            }
//        }
//    }else if (self.clickIndexOfSelectedCell == 1){
//        //电力
//        if (index ==0) {
//            //配电图
//            BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
//            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"DistributDiagram" ofType:@"html" inDirectory:@"assets"];
//            nomWebView.isUseOnline = NO;
//            nomWebView.localUrlString = filePath;
//            nomWebView.isAllowXZoom = YES;
//            return nomWebView;
//        }else if (index == 1){
//            BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
//            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"max" ofType:@"html" inDirectory:@"assets"];
//            nomWebView.isUseOnline = NO;
//            nomWebView.localUrlString = filePath;
//            return nomWebView;
//        }else if (index == 2){
//            BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
//            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ElectricData" ofType:@"html" inDirectory:@"assets"];
//            nomWebView.isUseOnline = NO;
//            nomWebView.localUrlString = filePath;
//            return nomWebView;
//        }else if (index == 3){
//            BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
//            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"powerFactor" ofType:@"html" inDirectory:@"assets"];
//            nomWebView.isUseOnline = NO;
//            nomWebView.localUrlString = filePath;
//            return nomWebView;
//        }else{
//            NSString *url = [NSString changgeNonulWithString:self.allDataArr[index][@"url"]];
//            if (url.length) {
//                BGUIWebViewController *urlWebView = [[BGUIWebViewController alloc] init];
//                urlWebView.isUseOnline = YES;
//                urlWebView.onlineUrlString = url;
//                return urlWebView;
//            }
//        }
//    }else if (self.clickIndexOfSelectedCell == 2){
//        //电量
//        if (index == 0) {
//            //电量统计
//            BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
//            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ElectricSum" ofType:@"html" inDirectory:@"assets"];
//            nomWebView.isUseOnline = NO;
//            nomWebView.localUrlString = filePath;
//            return nomWebView;
//        }else if (index == 1){
//            //分时电量
//            BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
//            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"dosage" ofType:@"html" inDirectory:@"assets"];
//            nomWebView.isUseOnline = NO;
//            nomWebView.localUrlString = filePath;
//            return nomWebView;
//        }else if(index == 2){
//            //集抄
//            BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
//            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"collect" ofType:@"html" inDirectory:@"assets"];
//            nomWebView.isUseOnline = NO;
//            nomWebView.localUrlString = filePath;
//            return nomWebView;
//        }
//    }else if (self.clickIndexOfSelectedCell == 3){
//        //电能质量
//        if (index == 0) {
//            BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
//            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"HarmonicData" ofType:@"html" inDirectory:@"assets"];
//            nomWebView.isUseOnline = NO;
//            nomWebView.localUrlString = filePath;
//            return nomWebView;
//        }else if (index == 1){
//            BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
//            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Unbalance" ofType:@"html" inDirectory:@"assets"];
//            nomWebView.isUseOnline = NO;
//            nomWebView.localUrlString = filePath;
//            return nomWebView;
//        }
//    }else if (self.clickIndexOfSelectedCell == 4){
//        //电气安全
//        if (index == 0) {
//            BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
//            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"cableTemperature" ofType:@"html" inDirectory:@"assets"];
//            nomWebView.isUseOnline = NO;
//            nomWebView.localUrlString = filePath;
//            return nomWebView;
//        }else if (index == 1){
//            BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
//            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"LeakageMonitor" ofType:@"html" inDirectory:@"assets"];
//            nomWebView.isUseOnline = NO;
//            nomWebView.localUrlString = filePath;
//            return nomWebView;
//        }
//    }else if (self.clickIndexOfSelectedCell == 5){
//        //环境
//        if (index == 0) {
//            BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
//            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"TempHumidityData" ofType:@"html" inDirectory:@"assets"];
//            nomWebView.isUseOnline = NO;
//            nomWebView.localUrlString = filePath;
//            return nomWebView;
//        }else if (index == 1){
//            BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
//            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"TempWater" ofType:@"html" inDirectory:@"assets"];
//            nomWebView.isUseOnline = NO;
//            nomWebView.localUrlString = filePath;
//            return nomWebView;
//        }else if (index == 2){
//            BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
//            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"TempSmog" ofType:@"html" inDirectory:@"assets"];
//            nomWebView.isUseOnline = NO;
//            nomWebView.localUrlString = filePath;
//            return nomWebView;
//        }else if (index == 3){
//            BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
//            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"TempDoor" ofType:@"html" inDirectory:@"assets"];
//            nomWebView.isUseOnline = NO;
//            nomWebView.localUrlString = filePath;
//            return nomWebView;
//        }
//        else if (index == 4) {
//            //视频单独拉出来
//            BGQMVideoListTableVC *videoListVC = [[BGQMVideoListTableVC alloc] init];
//            videoListVC.ownNaviController = self.navigationController;
//            return videoListVC;
//        }
//    }else if (self.clickIndexOfSelectedCell == 6){
//        //变压器
//
//    }else if (self.clickIndexOfSelectedCell == 7){
//        //报表
//        if (index == 0) {
//            BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
//            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ElectricExtremumReport" ofType:@"html" inDirectory:@"assets"];
//            nomWebView.isUseOnline = NO;
//            nomWebView.localUrlString = filePath;
//            return nomWebView;
//        }else if (index == 1){
//            BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
//            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"EnergyYOY" ofType:@"html" inDirectory:@"assets"];
//            nomWebView.isUseOnline = NO;
//            nomWebView.localUrlString = filePath;
//            return nomWebView;
//        }else if (index == 2){
//            BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
//            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"EnergyMOM" ofType:@"html" inDirectory:@"assets"];
//            nomWebView.isUseOnline = NO;
//            nomWebView.localUrlString = filePath;
//            return nomWebView;
//        }
//    }else{
//        //其他均用url加载 通用方法
//        NSString *url = [NSString changgeNonulWithString:self.allDataArr[index][@"url"]];
//        if (url.length) {
//            BGUIWebViewController *urlWebView = [[BGUIWebViewController alloc] init];
//            urlWebView.isUseOnline = YES;
//            urlWebView.onlineUrlString = url;
//            return urlWebView;
//        }
//    }
//    return nil;

   
}

- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return self.titles.count;
}

- (NSArray <NSString *> *)getRandomTitles {
    if (self.titleArr) {
        NSMutableArray *resultArray = [NSMutableArray arrayWithArray:self.titleArr];
        return resultArray;
    }
//    NSMutableArray *titles = @[@"概况", @"电量分析", @"成本统计", @"安全用电", @"漏电监测", @"分类6", @"分类7", @"分类8", @"分类9", @"分类10", @"更多"].mutableCopy;
//    NSInteger randomMaxCount = arc4random()%6 + 5;
//    NSMutableArray *resultArray = [NSMutableArray array];
//    for (int i = 0; i < randomMaxCount; i++) {
//        NSInteger randomIndex = arc4random()%titles.count;
//        [resultArray addObject:titles[randomIndex]];
//        [titles removeObjectAtIndex:randomIndex];
    
//    }
//    NSMutableArray *resultArray = [NSMutableArray arrayWithArray:titles];
    return nil;
}

/**
 重载数据源：比如从服务器获取新的数据、否则用户对分类进行了排序等
 */
- (void)reloadData {
    self.titles = [self getRandomTitles];
    
    //重载之后默认回到0，你也可以指定一个index
    if (self.clickIndex) {
        self.categoryView.defaultSelectedIndex = self.clickIndex;
        self.listContainerView.defaultSelectedIndex = self.clickIndex;
    }else{
        self.categoryView.defaultSelectedIndex = 0;
        self.listContainerView.defaultSelectedIndex = 0;
    }
    
    self.categoryView.titles = self.titles;
    [self.categoryView reloadData];
    
    
    [self.listContainerView reloadData];
}

//传递didClickSelectedItemAt事件给listContainerView，必须调用！！！
//- (void)categoryView:(JXCategoryBaseView *)categoryView didClickSelectedItemAtIndex:(NSInteger)index {
//    [self.listContainerView didClickSelectedItemAtIndex:index];
//}
//
////传递scrolling事件给listContainerView，必须调用！！！
//- (void)categoryView:(JXCategoryBaseView *)categoryView scrollingFromLeftIndex:(NSInteger)leftIndex toRightIndex:(NSInteger)rightIndex ratio:(CGFloat)ratio {
//    [self.listContainerView scrollingFromLeftIndex:leftIndex toRightIndex:rightIndex ratio:ratio selectedIndex:categoryView.selectedIndex];
//}

@end
