//
//  UIView+ChangeCorner.m
//  ExpressTransport
//
//  Created by per on 16/8/10.
//  Copyright © 2016年 per. All rights reserved.
//

#import "UIView+BGChangeCorner.h"

@implementation UIView (BGChangeCorner)
-(void)changeCornerWithCornerRect:(UIRectCorner)cornerRect andRadio:(CGSize)radio {
    CGRect rect = self.bounds;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:cornerRect cornerRadii:radio];
    CAShapeLayer *masklayer = [[CAShapeLayer alloc]init];//创建shapelayer
    masklayer.frame = self.bounds;
    masklayer.path = path.CGPath;//设置路径
    self.layer.mask = masklayer;
}

+(BOOL)isCurrentViewControllerVisible:(UIViewController *)viewController
{
    return (viewController.isViewLoaded && viewController.view.window);
}
@end
