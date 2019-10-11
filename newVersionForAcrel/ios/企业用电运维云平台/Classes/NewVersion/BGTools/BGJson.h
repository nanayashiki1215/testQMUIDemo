//
//  BGJson.h
//  ZSKSalesAide
//
//  Created by feitian on 2017/11/27.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BGJson : NSObject

+(NSString *)bg_jsonStringFromJsonObject:(id)jsonObj;
+(id)bg_jsonObjectFromJsonString:(NSString *)jsonStr;
+(id)bg_jsonObjectFromJsonData:(NSData *)jsonData;

@end
