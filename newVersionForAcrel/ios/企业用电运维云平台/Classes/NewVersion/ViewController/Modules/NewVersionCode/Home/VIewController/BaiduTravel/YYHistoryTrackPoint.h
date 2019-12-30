//
//  YYHistoryTrackPoint.h
//  YYObjCDemo
//
//  Created by Daniel Bey on 2017年06月16日.
//  Copyright © 2017 百度鹰眼. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYHistoryTrackPoint : NSObject
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) NSUInteger loctime;
@property (nonatomic, assign) NSUInteger direction;
@end
