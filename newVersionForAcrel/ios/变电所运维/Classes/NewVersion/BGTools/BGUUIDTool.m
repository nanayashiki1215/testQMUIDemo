//
//  BGUUIDTool.m
//  BusinessUCSDK
//
//  Created by feitian on 2018/9/5.
//  Copyright © 2018年 com.Ideal. All rights reserved.
//

#import "BGUUIDTool.h"

#define BGDeviceUUIDKeyName @"BGDeviceUUIDKeyName"

@implementation BGUUIDTool

+(NSString *)bg_deviceUUID{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *deviceUUID = [userDefaults stringForKey:BGDeviceUUIDKeyName];
    if (deviceUUID && [deviceUUID isKindOfClass:[NSString class]] && deviceUUID.length > 0) {
        return deviceUUID;
    }else{
        deviceUUID = [BGUUIDTool bg_tempUUID];
        [userDefaults setObject:deviceUUID forKey:BGDeviceUUIDKeyName];
        [userDefaults synchronize];
    }
    return deviceUUID;
}

+(NSString *)bg_tempUUID{
    NSString *uuid =[[NSUUID UUID] UUIDString];
    return uuid;
}

@end
