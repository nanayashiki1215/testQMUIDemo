//
//  UIButton+SQPExtension.h
//  OC_APP网红
//
//  Created by China-SQP on 16/6/21.
//  Copyright © 2016年 China-SQP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (SQPExtension)

+ (UIButton*) createButtonWithFrame: (CGRect) frame Target:(id)target Selector:(SEL)selector Image:(NSString *)image ImagePressed:(NSString *)imagePressed;

+ (UIButton *) createButtonWithFrame:(CGRect)frame Title:(NSString *)title Target:(id)target Selector:(SEL)selector;
@end
