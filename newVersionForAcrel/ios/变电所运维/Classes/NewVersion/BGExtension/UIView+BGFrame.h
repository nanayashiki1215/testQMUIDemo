//
//  UIView+Frame.h
//  IdealCallCenter
//
//  Created by feitian on 15/8/28.
//  Copyright © 2015年 com.Ideal. All rights reserved.
//
/**
 *  本类提供uiview与frame相关的简便操作，直接获取和设置frame
 *
 */
#import <UIKit/UIKit.h>

@interface UIView (BGFrame)

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat bottom;


@end
