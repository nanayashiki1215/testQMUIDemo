//
//  YYServiceParam.h
//  YYObjCDemo
//
//  Created by Daniel Bey on 2017年06月16日.
//  Copyright © 2017 百度鹰眼. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface YYServiceParam : NSObject

@property (nonatomic, assign) NSUInteger gatherInterval;
@property (nonatomic, assign) NSUInteger packInterval;
@property (nonatomic, copy) NSString *entityName;
@property (nonatomic, assign) CLActivityType activityType;
@property (nonatomic, assign) CLLocationAccuracy desiredAccuracy;
@property (nonatomic, assign) CLLocationDistance distanceFilter;
@property (nonatomic, assign) BOOL keepAlive;


//获取单例
+(instancetype)serviceParamManager;


@end
