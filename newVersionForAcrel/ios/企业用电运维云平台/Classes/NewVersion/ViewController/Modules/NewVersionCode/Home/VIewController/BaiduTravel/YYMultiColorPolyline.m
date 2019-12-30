//
//  YYMultiColorPolyline.m
//  YYObjCDemo
//
//  Created by Daniel Bey on 2017年06月22日.
//  Copyright © 2017 百度鹰眼. All rights reserved.
//

#import "YYMultiColorPolyline.h"

@implementation YYMultiColorPolyline

-(instancetype)initWithCoordinates:(CLLocationCoordinate2D *)coords color:(UIColor *)color {
    self = [super init];
    if (self) {
        [self setPolylineWithCoordinates:coords count:2];
        _color = color;
    }
    return self;
}

@end
