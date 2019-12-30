//
//  YYHistoryTrackParam.h
//  YYObjCDemo
//
//  Created by Daniel Bey on 2017年06月16日.
//  Copyright © 2017 百度鹰眼. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYHistoryTrackParam : NSObject

@property (nonatomic, copy) NSString *entityName;
@property (nonatomic, assign) NSUInteger startTime;
@property (nonatomic, assign) NSUInteger endTime;
@property (nonatomic, assign) BOOL isProcessed;
@property (nonatomic, strong) BTKQueryTrackProcessOption *processOption;
@property (nonatomic, assign) BTKTrackProcessOptionSupplementMode supplementMode;

@end
