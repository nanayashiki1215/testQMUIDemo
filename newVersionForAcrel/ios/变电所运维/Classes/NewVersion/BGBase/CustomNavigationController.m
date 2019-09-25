//
//  CustomNavigationController.m
//  IdealCallCenter
//
//  Created by feitian on 15/9/7.
//  Copyright © 2015年 com.Ideal. All rights reserved.
//

#import "CustomNavigationController.h"
#import "SKControllerTools.h"

@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

+ (void)initialize{
    
    // 设置整个项目所有item的主题样式
    UIBarButtonItem *item = [UIBarButtonItem appearance];
    
    // 设置普通状态
    // key：NS****AttributeName
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
//    textAttrs[NSForegroundColorAttributeName] = [UIColor grayColor];
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:17.f];
    
    [item setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    
    //    // 设置不可用状态
    //    NSMutableDictionary *disableTextAttrs = [NSMutableDictionary dictionary];
    //    disableTextAttrs[NSForegroundColorAttributeName] = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.7];
    //    disableTextAttrs[NSFontAttributeName] = textAttrs[NSFontAttributeName];
    //    [item setTitleTextAttributes:disableTextAttrs forState:UIControlStateDisabled];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationBar.layer.masksToBounds = NO;
//    self.navigationBar.layer.shadowOffset = CGSizeMake(0, 3);
//    self.navigationBar.layer.shadowOpacity = 0.6;
//    self.navigationBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.navigationBar.bounds].CGPath;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    if (self.viewControllers.count > 0) { // 这时push进来的控制器viewController，不是第一个子控制器（不是根控制器）
        /* 自动显示和隐藏tabbar */
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

//- (void)back {
//    [self popViewControllerAnimated:YES];
//}
//
//- (void)more {
//
//}
//0:leftBarButtonItems,1:rightBarButtonItems



@end
