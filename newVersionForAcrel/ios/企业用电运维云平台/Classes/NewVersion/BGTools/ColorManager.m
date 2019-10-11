//
//  ColorManager.m
//  最基础的主题切换
//
//  Created by mibo02 on 17/1/14.
//  Copyright © 2017年 mibo02. All rights reserved.
//

#import "ColorManager.h"

@implementation ColorManager
+(id)shareInstance
{
    static ColorManager *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[ColorManager alloc] init];
    });
    return obj;
}


- (id)init{
    if (self = [super init]) {
        
    }
    return self;
}

//设置主题色
- (void)setThemeColor:(UIColor *)color
{
    //将颜色存入本地，当下次进入时保持该种状态
    NSString *colorStr = [self toStrByUIColor:color];
    [UserDefaults setObject:colorStr forKey:@"ThemeColor"];
}
//获取主题色
- (UIColor *)getThemeColor
{
    if ([UserDefaults objectForKey:@"ThemeColor"]) {
        UIColor *color = [self toUIColorByStr:[UserDefaults objectForKey:@"ThemeColor"]];
        return color;
    }
    return DefColorFromRGB(74, 125, 112, 1.0);//默认颜色
}
//设置字体
- (void)setThemeFont:(CGFloat)fontSize
{
    [UserDefaults setFloat:fontSize forKey:@"ThemeFont"];
}
//获取字体
- (CGFloat)getThemeFont
{
    if ([UserDefaults objectForKey:@"ThemeFont"]) {
        CGFloat size = [[UserDefaults objectForKey:@"ThemeFont"] floatValue];
        return size;
    }
    return 18;
}
// 颜色 字符串转16进制
-(UIColor*)toUIColorByStr:(NSString*)colorStr{
    
    NSString *cString = [[colorStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return [UIColor blackColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

// 颜色 转字符串（16进制）
-(NSString*)toStrByUIColor:(UIColor*)color{
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    int rgb = (int) (r * 255.0f)<<16 | (int) (g * 255.0f)<<8 | (int) (b * 255.0f)<<0;
    return [NSString stringWithFormat:@"%06x", rgb];
}

@end
