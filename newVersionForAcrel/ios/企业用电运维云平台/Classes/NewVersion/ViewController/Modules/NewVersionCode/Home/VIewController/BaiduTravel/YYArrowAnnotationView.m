//
//  YYArrowAnnotationView.m
//  YYObjCDemo
//
//  Created by Daniel Bey on 2017年06月20日.
//  Copyright © 2017 百度鹰眼. All rights reserved.
//

#import "YYArrowAnnotationView.h"

@implementation YYArrowAnnotationView

-(id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.bounds = CGRectMake(0, 0, 22, 22);
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
        _imageView.image = [UIImage imageNamed:@"sportarrow"];
        [self addSubview:_imageView];
    }
    return self;
}

@end
