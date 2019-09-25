//
//  UIView+ChangeCorner.h
//  ExpressTransport
//
//  Created by per on 16/8/10.
//  Copyright © 2016年 per. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ChangeCorner)
/**
 *  控件的局部圆角，绘制view单一圆角或者多圆角组合
 *
 *  @param cornerRect 四个方向圆角任意组合UIRectCornerTopLeft|UIRectCornerTopRight|UIRectCornerBottomLeft|UIRectCornerBottomRight|UIRectCornerAllCorners
 *  @param radio      圆角大小
 */
-(void)changeCornerWithCornerRect:(UIRectCorner)cornerRect andRadio:(CGSize)radio;


/**
 当前View是否正在显示
 
 @param viewController
 @return
 */
+(BOOL)isCurrentViewControllerVisible:(UIViewController *)viewController;
@end
