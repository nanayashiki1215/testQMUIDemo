//
//  UIColor+BGExtension.h
//  BusinessUCSDK
//
//  Created by feitian on 2018/12/11.
//  Copyright © 2018年 com.Ideal. All rights reserved.
//

#import <UIKit/UIKit.h>

//NS_ASSUME_NONNULL_BEGIN

@interface UIColor (BGExtension)

//设置RGB颜色
+ (UIColor *)bg_red:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue alpha:(CGFloat)alpha;
//将颜色转换成RGB
+ (NSArray *)bg_convertColorToRGB:(UIColor *)color;
//设置十六进制颜色
+ (UIColor *)bg_colorWithHex:(NSInteger)hex;
+ (UIColor*)bg_colorWithHexString:(NSString *)hexString;
+ (CAGradientLayer *)setGradualChangingColor:(UIView *)view fromColor:(NSString *)fromHexColorStr toColor:(NSString *)toHexColorStr;

@end

//NS_ASSUME_NONNULL_END
