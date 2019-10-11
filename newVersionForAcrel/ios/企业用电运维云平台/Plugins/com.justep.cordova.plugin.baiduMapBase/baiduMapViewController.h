//
//  baiduMapViewController.h
//  baiduMap
//
//  Created by LiangQiangkun on 16/5/20.
//
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BMKLocationKit/BMKLocationComponent.h>
#import "NSObject+ObjectMap.h"
@interface baiduMapViewController : UIViewController<BMKMapViewDelegate,BMKLocationManagerDelegate>
@property(nonatomic,strong)NSDictionary *mapSettings;
+(baiduMapViewController *)sharedVC;
@end
