//
//  UINavigationController+EZOpenSDK.m
//  EZOpenSDKDemo
//
//  Created by DeJohn Dong on 15/11/2.
//  Copyright © 2015年 hikvision. All rights reserved.
//

#import "UINavigationController+EZOpenSDK.h"
#import "UIViewController+EZBackPop.h"

@implementation UINavigationController (EZOpenSDK)

- (BOOL)shouldAutorotate
{
    return [self ez_shouldAutorotate];
}

- (BOOL)ez_shouldAutorotate
{
    UIViewController *topVC = [self.viewControllers lastObject];
    return topVC.isAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

@end
