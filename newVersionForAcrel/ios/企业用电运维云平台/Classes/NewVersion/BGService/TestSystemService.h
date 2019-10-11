//
//  TestSystemService.h
//  veryWallen
//
//  Created by qiuqiu's imac on 14/12/3.
//  Copyright (c) 2014年 qiuqiu's imac. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SystemService) {
    SystemServiceLocation,
    SystemServicePushMessage,
    SystemServicePhoto,
    SystemServiceCamera,
    SystemServiceAdressBook
};

@interface TestSystemService : NSObject
/**
 *  检测是否支持系统服务并提示弹窗
 *
 *  @param service 系统服务
 *
 *  @return 返回是否支持，可以用来作判断
 */
+(BOOL) showLocationAlertWithService:(SystemService)service byShowAlert:(BOOL)show;

@end
