//
//  BGQMElectViewController.m
//  变电所运维
//
//  Created by Acrel on 2019/6/3.
//  
//

#import "BGQMElectViewController.h"

static const CGFloat kAnimationDuration = 0.9;

//static const CGFloat kSubLayerWidth = 8;
//static const CGFloat kSubLayerHeiht = 26;
//static const CGFloat kSubLayerSpace = 4;
//static const NSInteger kSubLayerCount = 3;

static const CGFloat kCircleContainerSize = 80;
static const NSInteger kCircleCount = 12;
static const CGFloat kCircleSize = 12;

@interface BGQMElectViewController ()
@property(nonatomic, strong) QMUIGridView *gridView;
@property(nonatomic, strong) QMUIGridView *showDataGridView;
@property(nonatomic, strong) UIScrollView *showScrollerView;

@property(nonatomic, strong) CALayer *line2;
@end

@implementation BGQMElectViewController{
    CAReplicatorLayer *_containerLayer2;
}

- (void)didInitialize {
    [super didInitialize];
    self.showScrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.showScrollerView.contentSize = CGSizeMake(SCREEN_WIDTH, 900);
    if (@available(iOS 11, *)) {
        self.showScrollerView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.view addSubview:self.showScrollerView];
    // init 时做的事情请写在这里
}

- (void)initSubviews {
    [super initSubviews];
    [UIView animateWithDuration:2 animations:^{
        // 要执行动画的代码
         [self beginAnimation];
    } completion:^(BOOL finished) {
        // 动画执行完成后的回调
    }];
    // 对 subviews 的初始化写在这里
    // 对 subviews 的初始化写在这里
    self.showDataGridView = [[QMUIGridView alloc] init];
    self.showDataGridView.columnCount = 2;
    self.showDataGridView.rowHeight = 60;
    self.showDataGridView.separatorWidth = PixelOne;
    self.showDataGridView.separatorColor = UIColorSeparator;
    self.showDataGridView.separatorDashed = NO;
    [self.showScrollerView addSubview:self.showDataGridView];
    
    // 将要布局的 item 以 addSubview: 的方式添加进去即可自动布局
    NSArray<UIColor *> *themeColors2 = @[UIColorTheme1, UIColorTheme2, UIColorTheme3, UIColorTheme4, UIColorTheme5, UIColorTheme6];
    for (NSInteger i = 0; i < themeColors2.count; i++) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [themeColors2[i] colorWithAlphaComponent:.7];
        UILabel *label = [[UILabel alloc] init];
        label.text = [NSString stringWithFormat:@"图表数据:%@",themeColors2[i]];
        [view addSubview:label];
        [self.showDataGridView addSubview:view];
    }
    
    self.gridView = [[QMUIGridView alloc] init];
    self.gridView.columnCount = 4;
    self.gridView.rowHeight = 60;
    self.gridView.separatorWidth = PixelOne;
    self.gridView.separatorColor = UIColorSeparator;
    self.gridView.separatorDashed = NO;
    [self.showScrollerView addSubview:self.gridView];
    
    // 将要布局的 item 以 addSubview: 的方式添加进去即可自动布局
    NSArray<UIColor *> *themeColors = @[UIColorTheme1, UIColorTheme2, UIColorTheme3, UIColorTheme4, UIColorTheme5, UIColorTheme6, UIColorTheme7, UIColorTheme8];
    for (NSInteger i = 0; i < themeColors.count; i++) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [themeColors[i] colorWithAlphaComponent:.7];
        [self.gridView addSubview:view];
    }
    
    _containerLayer2 = [CAReplicatorLayer layer];
    _containerLayer2.masksToBounds = YES;
    _containerLayer2.instanceCount = kCircleCount;
    _containerLayer2.instanceDelay = kAnimationDuration / _containerLayer2.instanceCount;
    _containerLayer2.instanceTransform = CATransform3DMakeRotation(AngleWithDegrees(360 / _containerLayer2.instanceCount), 0, 0, 1);
    [self.showScrollerView.layer addSublayer:_containerLayer2];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [QMUITips showLoading:@"加载中..." inView:self.showScrollerView hideAfterDelay:2];
    // 对 self.showScrollerView 的操作写在这里
}

- (void)strokeAPic{
  
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   
    [self strokeAPic];
//    [UIView animateWithDuration:5.0f delay:0.1f options:UIViewAnimationOptionLayoutSubviews animations:^{
//         [self beginAnimation];
//    } completion:^(BOOL finished) {
////        [_containerLayer2 removeAllAnimations];
//        [self.showScrollerView.layer removeAllAnimations];
//    }];
    
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
    UIEdgeInsets padding = UIEdgeInsetsMake(24 +200 + self.qmui_navigationBarMaxYInViewCoordinator, 12 + self.view.qmui_safeAreaInsets.left, 24 + self.view.qmui_safeAreaInsets.bottom, 12 + self.view.qmui_safeAreaInsets.right);
    CGFloat contentWidth = CGRectGetWidth(self.view.bounds) - UIEdgeInsetsGetHorizontalValue(padding);
    self.showDataGridView.frame = CGRectMake(padding.left, padding.top, contentWidth, QMUIViewSelfSizingHeight);
    
    
    UIEdgeInsets padding2 = UIEdgeInsetsMake(24 +400 + self.qmui_navigationBarMaxYInViewCoordinator, 12 + self.view.qmui_safeAreaInsets.left, 24 + self.view.qmui_safeAreaInsets.bottom, 12 + self.view.qmui_safeAreaInsets.right);
    CGFloat contentWidth2 = CGRectGetWidth(self.view.bounds) - UIEdgeInsetsGetHorizontalValue(padding2);
    self.gridView.frame = CGRectMake(padding2.left, padding2.top, contentWidth2, QMUIViewSelfSizingHeight);
    
    _containerLayer2.frame = CGRectMake(CGFloatGetCenter(CGRectGetWidth(self.view.bounds), kCircleContainerSize), self.view.frame.size.height/2-kCircleContainerSize, kCircleContainerSize, kCircleContainerSize);
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    self.title = NSLocalizedString(@"Electric",nil);
}

- (void)beginAnimation {
    CALayer *subLayer2 = [CALayer layer];
    subLayer2.backgroundColor = UIColorBlue.CGColor;
    subLayer2.frame = CGRectMake((kCircleContainerSize - kCircleSize) / 2, 0, kCircleSize, kCircleSize);
    subLayer2.cornerRadius = kCircleSize / 2;
    subLayer2.transform = CATransform3DMakeScale(0, 0, 0);
    [_containerLayer2 addSublayer:subLayer2];
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation2.fromValue = @(1);
    animation2.toValue = @(0.1);
    animation2.repeatCount = HUGE;
    animation2.removedOnCompletion = NO;
    animation2.duration = kAnimationDuration;
    [subLayer2 addAnimation:animation2 forKey:nil];
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

- (void)listDidDisappear {
    DefLog(@"%@", NSStringFromSelector(_cmd));
}
@end

