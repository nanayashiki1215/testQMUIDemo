//
//  UIImage+BGExtension.h
//  BusinessUCSDK
//
//  Created by feitian on 2018/3/1.
//  Copyright © 2018年 com.Ideal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (BGExtension)

+ (nullable UIImage *)imageNamed:(NSString *)name;

- (UIImage *)setImage:(UIImage *)image toColor:(UIColor *)color;

@end
