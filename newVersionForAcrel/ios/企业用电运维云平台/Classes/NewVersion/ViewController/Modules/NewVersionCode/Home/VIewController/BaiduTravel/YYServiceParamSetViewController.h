//
//  YYServiceParamSetViewController.h
//  YYObjCDemo
//
//  Created by Daniel Bey on 2017年06月16日.
//  Copyright © 2017 百度鹰眼. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYServiceParam.h"


typedef void (^ServiceParamBlock) (YYServiceParam *paramInfo);


typedef NS_ENUM(NSUInteger, YYServiceParamPickerViewTag) {
    YY_SERVICE_PARAM_GATHER_INTEVAL_PICKER = 1,
    YY_SERVICE_PARAM_PACK_INTEVAL_PICKER,
    YY_SERVICE_PARAM_ACTIVITY_TYPE_PICKER,
    YY_SERVICE_PARAM_DESIRED_ACCURACY_PICKER,
    YY_SERVICE_PARAM_DISTANCE_FILTER_PICKER,
};

@interface YYServiceParamSetViewController : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property (nonatomic, copy) ServiceParamBlock block;

@end
