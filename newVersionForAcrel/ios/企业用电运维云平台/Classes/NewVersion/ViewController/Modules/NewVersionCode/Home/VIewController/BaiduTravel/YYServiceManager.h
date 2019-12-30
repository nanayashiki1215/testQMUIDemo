//
//  YYServiceManager.h
//  YYObjCDemo
//
//  Created by Daniel Bey on 2017年06月21日.
//  Copyright © 2017 百度鹰眼. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ServiceOperationType) {
    YY_SERVICE_OPERATION_TYPE_START_SERVICE,
    YY_SERVICE_OPERATION_TYPE_STOP_SERVICE,
    YY_SERVICE_OPERATION_TYPE_START_GATHER,
    YY_SERVICE_OPERATION_TYPE_STOP_GATHER,
};


@interface YYServiceManager : NSObject <BTKTraceDelegate>

+(YYServiceManager *)defaultManager;

/**
 标志是否已经开启轨迹服务
 */
@property (nonatomic, assign) BOOL isServiceStarted;

/**
 标志是否已经开始采集
 */
@property (nonatomic, assign) BOOL isGatherStarted;


/**
 开启轨迹服务

 @param startServiceOption 开启服务的选项
 */
-(void)startServiceWithOption:(BTKStartServiceOption *)startServiceOption;

/**
 停止轨迹服务
 */
-(void)stopService;

/**
 开始采集
 */
-(void)startGather;

/**
 停止采集
 */
-(void)stopGather;

@end
