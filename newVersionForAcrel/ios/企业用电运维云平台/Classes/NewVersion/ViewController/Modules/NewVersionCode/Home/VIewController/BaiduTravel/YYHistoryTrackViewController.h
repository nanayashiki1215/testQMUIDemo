//
//  YYHistoryTrackViewController.h
//  YYObjCDemo
//
//  Created by Daniel Bey on 2017年06月16日.
//  Copyright © 2017 百度鹰眼. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYHistoryTrackViewController : UIViewController <BMKMapViewDelegate>
@property(nonatomic,strong)NSString *bgEntityName;//传递需要查询的轨迹id
@property(nonatomic,strong)NSString *startTime;//
@property(nonatomic,strong)NSString *endTime;//

@end
