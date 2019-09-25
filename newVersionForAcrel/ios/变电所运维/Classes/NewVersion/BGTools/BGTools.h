//
//  BGTools.h
//  ZSKSalesAide
//
//  Created by feitian on 2017/11/22.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BGTools : NSObject

+(NSMutableDictionary *)bg_deviceMessage;

//获取当前屏幕显示的viewcontroller
+ (UIViewController *)bg_getCurrentTopVC;

//获取底层viewcontroller
+ (UIViewController *)bg_getRootViewController;

//垂直push跳转
+ (void)bg_wantToPushWithVerticalWay:(UIViewController *)vc;

+ (NSTimeInterval)AudioDurationFromFilePath:(NSString *)filePath ;

@end
