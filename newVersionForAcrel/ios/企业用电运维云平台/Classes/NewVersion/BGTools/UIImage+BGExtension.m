//
//  UIImage+BGExtension.m
//  BusinessUCSDK
//
//  Created by feitian on 2018/3/1.
//  Copyright © 2018年 com.Ideal. All rights reserved.
//

#import "UIImage+BGExtension.h"

@implementation UIImage (BGExtension)

+ (nullable UIImage *)imageNamed:(NSString *)name{
    NSString *bundlePath  = [[NSBundle mainBundle] pathForResource:@"BusinessUCBundle" ofType: @"bundle"];
    NSBundle *bundle =[NSBundle bundleWithPath: bundlePath];
    UIImage *image = [UIImage bg_imageNamed:name inBundle:bundle];
    if (image == nil) {
        DefLog(@"CUICatalog: Invalid asset name supplied:%@",name);
    }
    return image;
}

+ (nullable UIImage *)bg_imageNamed:(NSString *)name inBundle:(nullable NSBundle *)bundle{
    return [UIImage bg_imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
}

+ (nullable UIImage *)bg_imageNamed:(NSString *)name inBundle:(nullable NSBundle *)bundle compatibleWithTraitCollection:(nullable UITraitCollection *)traitCollection{
    return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:traitCollection];
}


- (UIImage *)setImage:(UIImage *)image toColor:(UIColor *)color{
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    /////没有这部分图片会跳动
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    /////
    CGContextClipToMask(context, rect, image.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage *colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return colorImage;
    
}
@end
