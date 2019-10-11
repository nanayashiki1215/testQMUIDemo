//
//  CALayer+BGExtension.h
//  BusinessUCSDK
//
//  Created by feitian on 2019/1/23.
//  Copyright © 2019 com.Ideal. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface CALayer (BGExtension)

- (void)setBorderColorFromUIColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
