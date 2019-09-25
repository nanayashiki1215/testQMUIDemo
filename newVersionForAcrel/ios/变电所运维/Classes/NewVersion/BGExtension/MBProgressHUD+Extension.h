//
//  MBProgressHUD+Extension.h
//  IdealCallCenter
//
//  Created by feitian on 15/9/7.
//  Copyright © 2015年 com.Ideal. All rights reserved.
//

#import "MBProgressHUD.h"

#define HUDDELAYTIME 0.8

@interface MBProgressHUD (Extension)

+(void)showProgressingHUDForView:(UIView *)view andMessage:(NSString *)message andUserInteractionEnabled:(BOOL)enabled ;

+(void)dismissProgressingHUDForView:(UIView *)view ;

+(void)showProgressingHUDForView:(UIView *)view andMessage:(NSString *)message andAfterDelay:(NSTimeInterval)delay andUserInteractionEnabled:(BOOL)enabled;

@end
