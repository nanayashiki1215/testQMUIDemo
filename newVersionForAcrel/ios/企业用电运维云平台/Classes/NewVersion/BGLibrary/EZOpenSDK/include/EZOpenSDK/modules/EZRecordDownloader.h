//
//  EZRecordDownloader.h
//  EZOpenSDK
//
//  Created by yuqian on 2019/7/2.
//  Copyright © 2019 Ezviz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class EZRecordDownloadTask;

@interface EZRecordDownloader : NSObject

/**
 下载任务列表
 */
@property (nonatomic, copy) NSMutableArray *tasks;

/**
 初始化单例
 
 @return 单例
 */
+ (instancetype) shareInstane;

/**
 添加下载任务，并开始下载，串行任务
 
 @param task 下载任务
 */
- (void) addDownloadTask:(EZRecordDownloadTask *)task;

/**
 停止下载任务，并清除下载列表中的任务。下载结束或失败均要执行，清理资源
 
 @param task 下载任务
 */
- (void) stopDownloadTask:(EZRecordDownloadTask *)task;

@end

NS_ASSUME_NONNULL_END
