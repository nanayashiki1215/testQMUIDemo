//
//  UILabel+Extension.m
//  CloudService
//
//  Created by feitian on 16/1/27.
//  Copyright © 2016年 com.Ideal. All rights reserved.
//

#import "UILabel+BGExtension.h"
#import <objc/runtime.h>

@implementation UILabel (BGExtension)

-(void)setLocalizedText:(NSString *)text{
    [self setLocalizedText:NSLocalizedString(text, nil)];
}

+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        Method originalMethod = class_getInstanceMethod(class, @selector(setText:));
        Method swizzledMethod = class_getInstanceMethod(class, @selector(setLocalizedText:));
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

@end
