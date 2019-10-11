//
//  NSString+Rect.h
//  IdealCallCenter
//
//  Created by feitian on 15/8/28.
//  Copyright © 2015年 com.Ideal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@interface NSString (Rect)

/**
 *计算字符串显示时占用的size
 *  @param font     字体大小
 *  @param maxWidth 一行宽度
 *
 *  @return 字符串的size
 */
- (CGSize)sizeWithFont:(UIFont *)font maxWidth:(CGFloat)maxWidth;

/**
 * 计算字符串显示时占用的size，不限制宽度，一行显示
 */
- (CGSize)sizeWithFont:(UIFont *)font;

@end
