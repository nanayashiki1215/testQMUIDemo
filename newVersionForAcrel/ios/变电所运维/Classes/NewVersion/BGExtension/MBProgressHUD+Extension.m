//
//  MBProgressHUD+Extension.m
//  IdealCallCenter
//
//  Created by feitian on 15/9/7.
//  Copyright © 2015年 com.Ideal. All rights reserved.
//

#import "MBProgressHUD+Extension.h"

@implementation MBProgressHUD (Extension)

+(void)showProgressingHUDForView:(UIView *)view andMessage:(NSString *)message andUserInteractionEnabled:(BOOL)enabled{
    // show waiting
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    if (!hud) {
        hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    }else{
        [hud showAnimated:YES];
    }
    hud.label.text = message;
    if (YES == enabled) {
        hud.userInteractionEnabled = YES;
    }else{
        hud.userInteractionEnabled = NO;
    }
    
}

+(void)dismissProgressingHUDForView:(UIView *)view {
    [MBProgressHUD hideHUDForView:view animated:YES];
}

+(void)showProgressingHUDForView:(UIView *)view andMessage:(NSString *)message andAfterDelay:(NSTimeInterval)delay andUserInteractionEnabled:(BOOL)enabled{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    if (!hud) {
        hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    }else{
        [hud showAnimated:YES];
    }
    hud.label.text = message;
    if (YES == enabled) {
        hud.userInteractionEnabled = YES;
    }else{
        hud.userInteractionEnabled = NO;
    }
    [hud hideAnimated:YES afterDelay:delay];
}

@end
