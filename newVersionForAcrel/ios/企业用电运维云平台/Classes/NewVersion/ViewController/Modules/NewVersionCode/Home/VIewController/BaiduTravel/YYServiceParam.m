//
//  YYServiceParam.m
//  YYObjCDemo
//
//  Created by Daniel Bey on 2017年06月16日.
//  Copyright © 2017 百度鹰眼. All rights reserved.
//

#import "YYServiceParam.h"

@implementation YYServiceParam

static YYServiceParam* serviceBasicInfo;

//获取单例
+(instancetype)serviceParamManager{
    static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            serviceBasicInfo = [[YYServiceParam alloc]init];
            // 配置默认值
            UserManager *tjuser = [UserManager manager];
            if (tjuser.yytjBaiduDic) {
                NSDictionary *baiduDic = tjuser.yytjBaiduDic;
                //设置采集周期 30秒
                NSString *tjGetherInterval =[NSString changgeNonulWithString:baiduDic[@"tjGetherInterval"]];
               serviceBasicInfo.gatherInterval = [tjGetherInterval integerValue];
                //设置上传周期 50秒
                NSString *tjPackInterval =[NSString changgeNonulWithString:baiduDic[@"tjPackInterval"]];
              serviceBasicInfo.packInterval = [tjPackInterval integerValue];
                // @[@"步行、骑行、跑步", @"驾车", @"火车、飞机", @"其他类型"]; 驾车
                NSString *tjActivityType =[NSString changgeNonulWithString:baiduDic[@"tjActivityType"]];
                if([tjActivityType integerValue] == 1){
                    serviceBasicInfo.activityType = CLActivityTypeAutomotiveNavigation;
                }else if([tjActivityType integerValue] == 2){
                    serviceBasicInfo.activityType = CLActivityTypeOtherNavigation;
                }else if([tjActivityType integerValue] == 3){
                    serviceBasicInfo.activityType = CLActivityTypeAutomotiveNavigation;
                }else{
                    serviceBasicInfo.activityType = CLActivityTypeFitness;
                }
                // @[@"最高精度（插电才有效）", @"米级", @"十米级别", @"百米级别", @"公里级别", @"最低精度"]; 最高精度
                 NSString *tjDesiredAccuracy =[NSString changgeNonulWithString:baiduDic[@"tjDesiredAccuracy"]];
                if([tjDesiredAccuracy integerValue] == 0){
                    serviceBasicInfo.desiredAccuracy = kCLLocationAccuracyBest;
                }else if ([tjDesiredAccuracy integerValue] == 1){
                    serviceBasicInfo.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
                }else if ([tjDesiredAccuracy integerValue] == 2){
                    serviceBasicInfo.desiredAccuracy = kCLLocationAccuracyHundredMeters;
                }else if ([tjDesiredAccuracy integerValue] == 3){
                    serviceBasicInfo.desiredAccuracy = kCLLocationAccuracyKilometer;
                }else if ([tjDesiredAccuracy integerValue] == 4){
                    serviceBasicInfo.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
                }else{
                    serviceBasicInfo.desiredAccuracy = kCLLocationAccuracyBest;
                }
                //设置触发定位的距离阈值@[@1, @10, @100, @500];
               serviceBasicInfo.distanceFilter = kCLDistanceFilterNone;
               //开启保活
               serviceBasicInfo.keepAlive = YES;
              
            }else{
                //设置采集周期 30秒
                serviceBasicInfo.gatherInterval = 30;
                //设置上传周期 50秒
                serviceBasicInfo.packInterval = 120;
                // @[@"步行、骑行、跑步", @"驾车", @"火车、飞机", @"其他类型"]; 驾车
                serviceBasicInfo.activityType = CLActivityTypeAutomotiveNavigation;
                // @[@"最高精度（插电才有效）", @"米级", @"十米级别", @"百米级别", @"公里级别", @"最低精度"]; 最高精度
                serviceBasicInfo.desiredAccuracy = kCLLocationAccuracyBest;
                //设置触发定位的距离阈值@[@1, @10, @100, @500];
                serviceBasicInfo.distanceFilter = kCLDistanceFilterNone;
                //开启保活
                serviceBasicInfo.keepAlive = YES;
                //设置唯一id 利用ip地址+userid的方式
    //            NSString *entityName = [NSString stringWithFormat:@"%@_%@",GetBaseURL,[UserManager manager].bguserId];
    //            if (entityName != nil && entityName.length != 0) {
    //                serviceBasicInfo.entityName = entityName;
    //            }
            }
             //设置唯一id 利用ip地址+userid的方式
            //            GetBaseURL
            NSString *baseUrl = GetBaseURL;
            NSString *strUrl2 = @"";
            NSString *strUrl = [baseUrl stringByReplacingOccurrencesOfString:@"." withString:@"-"];
            if ([strUrl containsString:@":"]) {
                strUrl2 = [strUrl stringByReplacingOccurrencesOfString:@":" withString:@"_"];
            }else{
                strUrl2 = strUrl;
            }
            if([strUrl2 containsString:@"http"]){
                baseUrl = [strUrl2 stringByReplacingOccurrencesOfString:@"/" withString:@""];
            }else{
                baseUrl = strUrl2;
            }
           NSString *entityName = [NSString stringWithFormat:@"%@-%@",baseUrl,[UserManager manager].bguserId];
           if (entityName != nil && entityName.length != 0) {
               serviceBasicInfo.entityName = entityName;
           }
        });
    return serviceBasicInfo;
}

@end
