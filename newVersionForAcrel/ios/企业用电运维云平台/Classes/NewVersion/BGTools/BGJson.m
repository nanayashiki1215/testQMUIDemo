//
//  BGJson.m
//  ZSKSalesAide
//
//  Created by feitian on 2017/11/27.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "BGJson.h"

@implementation BGJson

+(NSString *)bg_jsonStringFromJsonObject:(id)jsonObj{
    if (jsonObj == nil) {
        return nil;
    }
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObj options:0 error:&err];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+(id)bg_jsonObjectFromJsonString:(NSString *)jsonStr{
    if (jsonStr == nil) {
        return nil;
    }
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    return [BGJson bg_jsonObjectFromJsonData:jsonData];
}

+(id)bg_jsonObjectFromJsonData:(NSData *)jsonData{
    if (jsonData == nil) {
        return nil;
    }
    NSError *err;
    id objc = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return objc;
}

@end
