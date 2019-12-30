//
//  ZYSuspensionContainer.h
//  ZYSuspensionViewDemo
//
//  Created by ripper on 2018/9/4.
//  Copyright © 2018年 ripper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZYSuspensionContainer : UIWindow

@property (nonatomic, weak) UIWindow *lastKeyWindow;

@property (nonatomic, assign) BOOL zy_canAffectStatusBarAppearance;
@property (nonatomic, assign) BOOL zy_canBecomeKeyWindow;

@end
