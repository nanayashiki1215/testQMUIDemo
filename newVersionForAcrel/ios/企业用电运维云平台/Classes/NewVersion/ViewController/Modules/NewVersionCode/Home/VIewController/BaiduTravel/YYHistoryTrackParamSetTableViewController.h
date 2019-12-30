//
//  YYHistoryTrackParamSetTableViewController.h
//  YYObjCDemo
//
//  Created by Daniel Bey on 2017年06月16日.
//  Copyright © 2017 百度鹰眼. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYHistoryTrackParam.h"

typedef void (^HistoryTrackParamBlock) (YYHistoryTrackParam *paramInfo);

typedef NS_ENUM(NSUInteger, YYHistoryTrackParamPickerViewTag) {
    YY_HISTORY_TRACK_PARAM_RADIUS_THRESHOLD_PICKER = 1,
    YY_HISTORY_TRACK_PARAM_TRANSPORT_MODE_PICKER,
    YY_HISTORY_TRACK_PARAM_SUPPLEMENT_MODE_PICKER,
};


@interface YYHistoryTrackParamSetTableViewController : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property (nonatomic, copy) HistoryTrackParamBlock completionHandler;

@end
