//
//  BaseViewController.m
//  IdealCallCenter
//
//  Created by feitian on 15/9/2.
//  Copyright © 2015年 com.Ideal. All rights reserved.
//

#import "BaseViewController.h"
#define IS_IOS_VERSION_11 (([[[UIDevice currentDevice]systemVersion]floatValue] >= 11.0)? (YES):(NO))


@interface BaseViewController ()
@property(nonatomic,strong)NSString *backString;
@property (nonatomic, assign) BOOL isNeedUpdate;

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isNeedUpdate = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
//    self.view.backgroundColor = COLOR_BACKGROUND;
    
    //隐藏返回按钮上的标题
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(NSIntegerMin, 2) forBarMetrics:UIBarMetricsDefault];
    
    [self buildBut];
    [self initNavigationBarButtonItems];
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleTap];
    //这个可以加到任何控件上,比如你只想响应WebView，我正好填满整个屏幕
    singleTap.cancelsTouchesInView = NO;
    // Do any additional setup after loading the view.
    
}

-(void)setBaseAssistBlock:(void (^)(BaseViewController *, id))baseAssistBlock{
    if (baseAssistBlock) {
        _baseAssistBlock = [baseAssistBlock copy];
    }
}

-(void)buildBut
{
    CGRect backframe = CGRectMake(0,0,44,32);
    self.backButton= [[UIButton alloc] initWithFrame:backframe];
    [self.backButton setTitle:@"" forState:UIControlStateNormal];
    self.backButton.titleLabel.font=[UIFont systemFontOfSize:17];
    self.backButton.titleLabel.textColor = [UIColor blackColor];
    [self.backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [self.backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.showsTouchWhenHighlighted = YES;
    
    CGRect homeframe = CGRectMake(0,0,44,32);
    self.homeButton= [[UIButton alloc] initWithFrame:homeframe];
    [self.homeButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.homeButton setTitle:@"" forState:UIControlStateNormal];
    self.homeButton.titleLabel.textColor = [UIColor blackColor];
    [self.homeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.homeButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    self.homeButton.titleLabel.font=[UIFont systemFontOfSize:17];
    [self.homeButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.homeButton.showsTouchWhenHighlighted = YES;
    UIBarButtonItem* rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.homeButton];
    _homeButton.hidden = YES;
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.isNeedUpdate=YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [CompputeTools setCurrectController:self];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //    self.navigationItem.title = self.backString;
    self.isNeedUpdate = YES;
    if (self.isNeedUpdate) {
        [self.view setNeedsLayout];
    }
}
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self updateNavLayout];
}

- (void)updateNavLayout{
    if (!IS_IOS_VERSION_11||!self.isNeedUpdate) {
        return;
    }
    self.isNeedUpdate=NO;
    UINavigationItem * item=self.navigationItem;
    NSArray * array=item.rightBarButtonItems.count?item.rightBarButtonItems:item.leftBarButtonItems;
    if (array&&array.count != 0){
        UIBarButtonItem * buttonItem = array[0];
        UIView * view = [[[buttonItem.customView superview] superview] superview];
        NSArray * arrayConstraint = view.constraints;
        for (NSLayoutConstraint * constant in arrayConstraint) {
            if (constant.constant == 16) {
                constant.constant = 10;
            }else if (constant.constant == -16){
                constant.constant = -10;
            }
//            NSLog(@"%f",constant.constant);
        }
    }
}

/*
 默认返回样式
 <返回
 */
- (void)initNavigationBarButtonItems {
    [self initNavigationBarButtonItemsWithTitle:@"返回"];
}
/*
 返回样式 只修改backTitle
 <backTitle
 */
-(void)initNavigationBarButtonItemsWithTitle:(NSString *)backTitle{
    NSString *imageName = @"fhjt";
    NSString *highlightImageName = @"fhjt";
    
    [self initNavigationBarButtonItemsWithTitle:backTitle image:imageName highlightImage:highlightImageName];

}

/*
 返回样式 自定义
 */
-(void)initNavigationBarButtonItemsWithTitle:(NSString *)backTitle image:(NSString *)image highlightImage:(NSString *)highlightImage{

//    image = image?image:@"fhjt";
//    highlightImage = highlightImage?highlightImage:@"fhjt";

    
    //    if (self.navigationController.viewControllers.count>2) {
    //        self.navigationItem.leftBarButtonItem = [SKControllerTools createBarButtonTextItemWithTarget:self action:@selector(backButtonAction:) title:@"返回" image:@"fhjt" highlightImage:@"fhjt"];
    //    }else if (self.navigationController.viewControllers.count>1){
    //        NSString *backStr = self.navigationController.viewControllers.firstObject.navigationItem.title;
    //        self.navigationItem.leftBarButtonItem = [SKControllerTools createBarButtonTextItemWithTarget:self action:@selector(backButtonAction:) title:backStr image:@"fhjt" highlightImage:@"fhjt"];
    //    }
//    if (self.navigationController.viewControllers.count>1) {
//        self.navigationItem.leftBarButtonItem = [SKControllerTools createBarButtonTextItemWithTarget:self action:@selector(backButtonAction:) title:backTitle image:image highlightImage:highlightImage];
//    }
    
}


- (void)backButtonAction:(UIButton *)backBtn {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self popViewControllerAnimation:YES];
    }
}

- (void)moreButtonAction:(UIButton *)moreBtn {
    
}

#pragma mark push & pop

- (void)pushViewController:(UIViewController*)viewController animation:(BOOL)animation{



    // 修改tabBra的frame

//    CGRect frame = self.tabBarController.tabBar.frame;
//
//    frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height;
//
//    self.tabBarController.tabBar.frame = frame;
    [self.navigationController pushViewController:viewController animated:animation];
}

- (void)popViewControllerAnimation:(BOOL)animation{
    
    [self.navigationController popViewControllerAnimated:animation];
}

- (void)popToRootViewControllerAnimation:(BOOL)animation{
    
    [self.navigationController popToRootViewControllerAnimated:animation];
}

- (void)popToViewControllerClass:(Class)viewControllerClass animated:(BOOL)animation {
    NSArray *temArray = self.navigationController.viewControllers;
    for(UIViewController *temVC in temArray){
        if ([temVC isKindOfClass:[viewControllerClass class]]){
            [self.navigationController popToViewController:temVC animated:animation];
        }
    }
}

- (void)bg_popViewControllerClass:(Class)viewControllerClass animated:(BOOL)animation {
    //    NSArray *temArray = self.navigationController.viewControllers;
    //    UIViewController *vc = nil;
    //    for(UIViewController *temVC in temArray){
    //        if ([temVC isKindOfClass:[viewControllerClass class]]){
    //            vc = temVC;
    //            break;
    //        }
    //    }
    //    if (vc) {
    //        NSUInteger index = [temArray indexOfObject:vc];
    //        if (index <= 0) {
    //            [self.navigationController popToRootViewControllerAnimated:animation];
    //        }else{
    //            UIViewController *popVc = [temArray objectAtIndex:(index-1)];
    //            [self.navigationController popToViewController:popVc animated:animation];
    //        }
    //    }
    
    NSArray *array = self.navigationController.viewControllers;
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (UIViewController * controller in array) { //遍历
        if ([controller isKindOfClass:viewControllerClass]) {
            break;
        }else{
            [mutableArray addObject:controller];
        }
    }
    if (self.navigationController.viewControllers.count != mutableArray.count) {
        self.navigationController.viewControllers = mutableArray;
    }
}

- (void)popToViewControllerWithBackNumber:(NSUInteger)backNumber animated:(BOOL)animation {
    NSArray *temArray = self.navigationController.viewControllers;
    NSInteger i = temArray.count-1-backNumber;
    if (i>=0 && i<temArray.count){
        UIViewController *temVC = temArray[i];
        [self.navigationController popToViewController:temVC animated:animation];
    }
    
}

- (void)popNouseViewControllerWithClassName:(NSString*)className{
    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    for (UIViewController * controller in self.navigationController.viewControllers) { //遍历
        if ([controller isKindOfClass:NSClassFromString(className)]) {
            [tempArr removeObject:controller];
            
        }
    }
    if (self.navigationController.viewControllers.count != tempArr.count) {
        self.navigationController.viewControllers = tempArr;
    }
}

- (void)popNouseViewController:(UIViewController*)vc{
    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    for (UIViewController * controller in self.navigationController.viewControllers) { //遍历
        if (controller == self) {
            [tempArr removeObject:controller];
        }
    }
    if (self.navigationController.viewControllers.count != tempArr.count) {
        self.navigationController.viewControllers = tempArr;
    }
}

-(void)removeAllVCOnlyFirstVC{
    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    id lastVc = [tempArr lastObject];
    for (NSInteger i = 0; i<tempArr.count; i++) {
        id vc = tempArr[i];
        if (i==0||[vc isEqual:lastVc]) {
        }else{
            [tempArr removeObjectAtIndex:i];
        }
    }
    //    [tempArr addObject:vc];
    if (self.navigationController.viewControllers.count != tempArr.count) {
        self.navigationController.viewControllers = tempArr;
    }
    
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender

{
 
}

//添加页面通知，空方法，由子类实现
-(void)bg_addNotification{
    //添加页面通知，空方法，由子类实现
}

//删除页面通知，空方法，由子类实现
-(void)bg_removeNotification{
    
}

//配置导航栏相关设置项，空方法，由子类实现
- (void)bg_setNavigationBar{
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSString *className = NSStringFromClass([self class]);
    DefLog(@"\n          VC 成功dealloc:    %@\n",className);
}

@end
