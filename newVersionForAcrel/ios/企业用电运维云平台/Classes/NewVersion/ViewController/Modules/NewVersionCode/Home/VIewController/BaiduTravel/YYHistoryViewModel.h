//
//  YYHistoryViewModel.h
//  YYObjCDemo
//
//  Created by Daniel Bey on 2017年06月16日.
//  Copyright © 2017 百度鹰眼. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYHistoryTrackParam.h"

typedef void (^HistoryQueryCompletionHandler) (NSArray *points);

@interface YYHistoryViewModel : NSObject <BTKTrackDelegate>

@property (nonatomic, copy) HistoryQueryCompletionHandler completionHandler;

- (void)queryHistoryWithParam:(YYHistoryTrackParam *)param;

@end
