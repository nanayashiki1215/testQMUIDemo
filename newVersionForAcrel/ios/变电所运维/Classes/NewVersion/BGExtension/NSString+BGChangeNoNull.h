//
//  NSString+BGChangeNoNull.h
//  BusinessGo
//
//  Created by per on 16/11/3.
//  Copyright © 2016年 com.Ideal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (BGChangeNoNull)
/**
 修改后台返回字符串，使其为字符（NSString）类型
 
 @param str 后台返回字段
 @return 不为空的字符
 */
+(NSString *)changgeNonulWithString:(NSString *)str;

/**
 修改后台返回字符串，使其为字符（NSString）类型，并且将nil和null转换为非nil得空字符@""
 
 @param str 字符
 @return 非nil得空字符@""
 */
+(NSString *)changgeNonulAndNonilWithString:(NSString *)str;

+ (NSString *)bg_changgeNullStringWithString:(NSString *)str;

+(NSString *)changgeNullStringWithString:(NSString *)str;
//网络请求为<null>
+ (NSString *)changeNullStringWithNetworkErrString:(NSString *)str;

+ (NSString *)replaceUnicode:(NSString *)unicodeStr;

/**
 字典转Json字符串
 
 @param infoDict 传入字典
 @return Json字符串用于上传
 */
+ (NSString*)convertToJSONData:(id)infoDict;
//检测网址的正则表达式
+(NSString *)isZhengZe:(NSString *)str;

//判断是否为空
+(BOOL)isNullObject:(id)object;

@end
