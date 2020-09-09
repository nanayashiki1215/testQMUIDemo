//
//  BGChangePasswordVC.h
//  BusinessUCSDK
//
//  Created by Beryl on 2018/6/12.
//  Copyright © 2018年 com.Ideal. All rights reserved.
//

//#import <BusinessUCSDK/BusinessUCSDK.h>
#import <QMUIKit/QMUIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <BMKLocationKit/BMKLocationComponent.h>
#import "SKControllerTools.h"

//定义枚举类型
typedef enum {
    showChangePwdType= 0,
    showChangeSecPwdType
} changePwdType;

@interface BGChangePasswordVC : BaseViewController

@property (nonatomic, strong) BMKLocationManager *locationManager; //定位对象
@property (nonatomic,assign) NSInteger changePwdType; //展示类型

@end
