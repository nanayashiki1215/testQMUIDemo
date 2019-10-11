//
//  ColorManager.h
//  最基础的主题切换
//
//  Created by mibo02 on 17/1/14.
//  Copyright © 2017年 mibo02. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define UserDefaults [NSUserDefaults standardUserDefaults]
#define kTheme @"kThemeName"
#define kThemeColorChangeNotification @"kThemeColorChangeNotification"
#define kThemeFontChangeNotifocation @"kThemeFontChangeNotifocation"

@interface ColorManager : NSObject

+(id)shareInstance;
//设置主题色
- (void)setThemeColor:(UIColor *)color;
//获取主题色
- (UIColor *)getThemeColor;
//设置字体
- (void)setThemeFont:(CGFloat)fontSize;
//获取字体
- (CGFloat)getThemeFont;




@end
