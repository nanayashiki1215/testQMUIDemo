//
//  NSString+BGChangeNoNull.m
//  BusinessGo
//
//  Created by per on 16/11/3.
//  Copyright © 2016年 com.Ideal. All rights reserved.
//

#import "NSString+BGChangeNoNull.h"

@implementation NSString (BGChangeNoNull)

+ (NSString *)changgeNonulWithString:(NSString *)str{
    if ([str isKindOfClass:[NSString class]]) {
        return str;
    }else if([str isKindOfClass:[NSNumber class]]){
        return [NSString stringWithFormat:@"%@",str];
    }
    return nil;
}

+ (NSString *)changgeNullStringWithString:(NSString *)str{
    if ([str isKindOfClass:[NSString class]]) {
        if ([str isEqualToString:@"null"]){
            return @"0";
        }
        return str;
    }else if([str isKindOfClass:[NSNumber class]]){
        return [NSString stringWithFormat:@"%@",str];
    }else{
        return @"0";
    }
    return @"0";
}

+ (NSString *)bg_changgeNullStringWithString:(NSString *)str{
    if ([str isKindOfClass:[NSString class]]) {
        if ([str containsString:@"null"]){
            return nil;
        }else{
            
            return str;
        }
    }else if([str isKindOfClass:[NSNumber class]]){
        return [NSString stringWithFormat:@"%@",str];
    }else{
        return nil;
    }
    return nil;
}

+ (NSString *)changeNullStringWithNetworkErrString:(NSString *)str{
    if ([str isKindOfClass:[NSString class]]) {
        if ([str isEqualToString:@"null"]){
            return @"操作失败";
        }
        return str;
    }else if([str isKindOfClass:[NSNumber class]]){
        return [NSString stringWithFormat:@"%@",str];
    }else{
        return @"操作失败";
    }
    return @"操作失败";
}

+(NSString *)changgeNonulAndNonilWithString:(NSString *)str{
    return [self changgeNonulWithString:str]?[self changgeNonulWithString:str]:@"";
}
+ (NSString *)replaceUnicode:(NSString *)unicodeStr

{
    
    
    
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
    
    NSString *tempStr3 = [[@"\""stringByAppendingString:tempStr2]stringByAppendingString:@"\""];
    
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                           
                                                           mutabilityOption:NSPropertyListImmutable
                           
                                                                     format:NULL
                           
                                                           errorDescription:NULL];
    
    //    DefLog(@"%@",returnStr);
    NSString *str = [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
    return str;
    
}

+ (NSString*)convertToJSONData:(id)infoDict{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDict
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    NSString *jsonString = @"";
    
    if (! jsonData)
    {
        DefLog(@"Got an error: %@", error);
    }else
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    
    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return jsonString;
}

+(NSString*)isZhengZe:(NSString*)str
{
    
    NSError *error;
    //http+:[^\\s]* 这是检测网址的正则表达式
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"http+[^:s]*" options:0 error:&error];//筛选
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch = [regex firstMatchInString:str options:0 range:NSMakeRange(0, [str length])];
        
        if (firstMatch) {
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            //从urlString中截取数据
            NSString *result1 = [str substringWithRange:resultRange];
            return result1;
            
        }
    }
    return nil;
}

+ (BOOL)isNullObject:(id)object{
    if (object == nil || [object isEqual:[NSNull class]]) {
        return YES;
    }else if ([object isKindOfClass:[NSNull class]]){
        if ([object isEqualToString:@""]) {
            return YES;
        }else{
            return NO;
        }
    }else if ([object isKindOfClass:[NSNumber class]]){
        if ([object isEqualToNumber:@0]) {
            return YES;
        }else{
            return NO;
        }
    }
    return NO;
}
@end
