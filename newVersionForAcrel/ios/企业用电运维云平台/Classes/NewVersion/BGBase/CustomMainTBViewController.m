//
//  CustomMainTBViewController.m
//  变电所运维
//
//  Created by Acrel on 2019/5/16.
//

#import "CustomMainTBViewController.h"
#import "CustomNavigationController.h"

#import "BGHomeViewController.h"
//#import "BGUIWebViewController.h"
#import "UIImage+BGExtension.h"


@interface CustomMainTBViewController()

// 保存之前选中的按钮
@property (nonatomic, retain) UIButton *preSelBtn;
@end

@implementation CustomMainTBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createViewControllers];
}

// 创建分栏控制器管理的视图控制器数据
- (void)createViewControllers
{
    BGHomeViewController *homeVC = [[BGHomeViewController alloc] initWithNibName:@"BGHomeViewController" bundle:nil];
//    UINavigationController *nav1 =[[UINavigationController alloc] initWithRootViewController:firstVC1];
    [self addChildViewController:homeVC title:DefLocalizedString(@"Home") image:@"home2" selectedImage:@"index"];
  
}

/**
 *  添加一个子控制器
 *
 *  @param childVc       子控制器
 *  @param title         标题
 *  @param image         图片
 *  @param selectedImage 选中的图片
 */
- (void)addChildViewController:(UIViewController *)childVc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage
{
//    UIEdgeInsets insets = UIEdgeInsetsMake(6, 5, -6, -5);
    //87 175 225
    UIColor *selectColor = DefColorFromRGB(87,175,225,1);
//    UIColor *selectColor = [UIColor blueColor];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:selectColor} forState:UIControlStateSelected];
    
    // 设置子控制器的文字
    if([title isEqualToString:@"主页"] || [title isEqualToString:@"Home"]){
        childVc.navigationItem.title = DefLocalizedString(@"LoginText");
    }else{
        childVc.navigationItem.title = title; // 同时设置tabbar和navigationBar的文字
    }
    
    childVc.tabBarItem.title = title;
    
//    UIImage *image1 = [self setImage:[UIImage imageNamed:image] toColor:DefColorFromRGB(235, 235, 222, 1)];
    UIImage *image1 = [UIImage imageNamed:image];
    UIImage *image2 = [UIImage imageNamed:selectedImage];
    // 设置子控制器的图片
    childVc.tabBarItem.image = [image1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childVc.tabBarItem.selectedImage = [image2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    //    if (IS_IPHONE_X || SCREEN_HEIGHT == 480) {
    //        childVc.tabBarItem.imageInsets = UIEdgeInsetsMake(2, 0, -2, 0);
    //    }else if (SCREEN_HEIGHT == 736){
    //        childVc.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    //
    //    }else{
    //        childVc.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    //    }
    
    /*******/
    if ( SCREEN_HEIGHT == 480) {
        childVc.tabBarItem.imageInsets = UIEdgeInsetsMake(2, 0, -2, 0);
    }else if (SCREEN_HEIGHT == 568||SCREEN_HEIGHT == 667){
        [childVc.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0,-4)];
        childVc.tabBarItem.imageInsets = UIEdgeInsetsMake(2, 0, -2, 0);
    }else if (SCREEN_HEIGHT == 736){
        [childVc.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0,-5)];
        childVc.tabBarItem.imageInsets = UIEdgeInsetsMake(2, 0, -2, 0);
    }else{
        //iphone x 往上
        childVc.tabBarItem.imageInsets = UIEdgeInsetsMake(2, 0, -2, 0);
    }
    
    
    // 先给外面传进来的小控制器 包装 一个导航控制器
    CustomNavigationController *nav = [[CustomNavigationController alloc] initWithRootViewController:childVc];
    [self configureAppStyleWithSetBarTintColor:[UIColor whiteColor] AndSetStatusBarStyle:nil AndSetTitleFont:nil AndSetTitleColor:nil];
    // 添加为子控制器
    [self addChildViewController:nav];
}

//配置导航栏、状态栏、导航栏标题颜色、导航栏标题字体
- (void)configureAppStyleWithSetBarTintColor:(UIColor *)naviColor AndSetStatusBarStyle:(UIStatusBarStyle)barStyle AndSetTitleFont:(UIFont *)titleFont AndSetTitleColor:(UIColor *)titleColor{
    //设置导航栏
    [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
    [[UINavigationBar appearance] setBarTintColor:naviColor];
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    //    [[UITabBar appearance] setTranslucent:NO];
    
    //状态栏白色
    if (barStyle) {
        [[UIApplication sharedApplication] setStatusBarStyle:barStyle animated:YES];
    }else{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }
    
    //设置有导航栏时，状态栏的颜色风格
    //设置导航栏返回按钮
    //    [[UINavigationBar appearance] setBackIndicatorImage:[UIImage bg_imageNamedInSDKBundle:nil]];
    //    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage bg_imageNamedInSDKBundle:@""]];
    
    //设置导航栏的字体样式
    //    NSShadow *shadow = [[NSShadow alloc] init];
    //    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    //    shadow.shadowColor = UIColorFromRGB16(0x7F7AB5);//阴影
    //    shadow.shadowOffset = CGSizeMake(1, 1);
    if(titleFont && titleColor){
        NSDictionary *textAttributes =[NSDictionary dictionaryWithObjectsAndKeys:titleColor,NSForegroundColorAttributeName,titleFont,NSFontAttributeName, nil];
        [[UINavigationBar appearance] setTitleTextAttributes:textAttributes];
    }else{
        NSDictionary *textAttributes =[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName,[UIFont fontWithName:@"Helvetica" size:18.0],NSFontAttributeName, nil];
        [[UINavigationBar appearance] setTitleTextAttributes:textAttributes];
    }
    
    //设置tableView为透明色
    [[UITableView appearance]setBackgroundColor:[UIColor clearColor]];
    //设置cell为半透明色
    [[UITableViewCell appearance]setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.7]];
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)Item
{
    tempTabbarItem =Item;
}

//修改tabbar的高度
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //    CGRect frame = self.tabBar.frame;
    //    CGFloat ratio = ([UIScreen mainScreen].bounds.size.height/736);
    //    if (IS_IPHONE_X) {
    //        frame.size.height = 83;
    //    }else if(SCREEN_HEIGHT == 480){
    //        frame.size.height = 49;
    //    }else if(SCREEN_HEIGHT == 568){
    //        frame.size.height = 57;
    //    }else if (SCREEN_HEIGHT == 667){
    //        frame.size.height = 57;
    //    }else if (SCREEN_HEIGHT == 736){
    //        frame.size.height = 73;
    //    }
    //    frame.origin.y = self.view.frame.size.height - frame.size.height;
    //    self.tabBar.frame = frame;
    
    
    /*******/
    
    CGRect frame = self.tabBar.frame;
    //以667屏幕 height = 57为基准
    CGFloat ratio = ([UIScreen mainScreen].bounds.size.height/667);
    if(SCREEN_HEIGHT == 480){
        frame.size.height = 49;
    }else if(SCREEN_HEIGHT == 568){
        frame.size.height = 57;
    }else if (SCREEN_HEIGHT == 667){
        frame.size.height = 57;
    }else if (SCREEN_HEIGHT == 736){
        frame.size.height = 57*ratio;
    }else{
        //iphone x 往上
        frame.size.height = 83;
    }
    frame.origin.y = self.view.frame.size.height - frame.size.height;
    self.tabBar.frame = frame;
    
    
}

//颜色通用方法
//改变颜色 描边
- (UIImage *)setImage:(UIImage *)image toColor:(UIColor *)color{
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    /////没有这部分图片会跳动
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    /////
    CGContextClipToMask(context, rect, image.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage *colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return colorImage;
    
}

//缩小图片
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
