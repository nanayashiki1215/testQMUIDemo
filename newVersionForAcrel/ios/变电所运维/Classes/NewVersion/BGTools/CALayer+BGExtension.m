//
//  CALayer+BGExtension.m
//  BusinessUCSDK
//
//  Created by feitian on 2019/1/23.
//  Copyright © 2019 com.Ideal. All rights reserved.
//

#import "CALayer+BGExtension.h"

@implementation CALayer (BGExtension)

- (void)setBorderColorFromUIColor:(UIColor *)color {
    self.borderColor = color.CGColor;
}

@end
