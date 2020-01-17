//
//  YYServiceViewController.h
//  YYObjCDemo
//
//  Created by Daniel Bey on 2017年06月16日.
//  Copyright © 2017 百度鹰眼. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BMKLocationKit/BMKLocationComponent.h>

@interface YYServiceViewController : UIViewController <BMKMapViewDelegate, BTKTraceDelegate, BTKTrackDelegate, CLLocationManagerDelegate,BMKLocationManagerDelegate>

@end
