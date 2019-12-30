//
//  YYMultiColorPolyline.h
//  YYObjCDemo
//
//  Created by Daniel Bey on 2017年06月22日.
//  Copyright © 2017 百度鹰眼. All rights reserved.
//



@interface YYMultiColorPolyline : BMKPolyline

/**
 本条线段的颜色
 */
@property (nonatomic, strong) UIColor *color;

- (instancetype)initWithCoordinates:(CLLocationCoordinate2D *)coords color:(UIColor *)color;

@end
