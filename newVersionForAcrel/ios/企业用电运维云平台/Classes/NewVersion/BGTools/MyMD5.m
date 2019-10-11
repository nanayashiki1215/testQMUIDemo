//
//  MyMD5.m
//  GoodLectures
//
//  Created by yangshangqing on 11-10-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "MyMD5.h"
#import "CommonCrypto/CommonDigest.h"
//#import ""

@implementation MyMD5

#define ENCODE_KEY @"!*'();:@&=+$,/?%#[]"
#define Md5Key @"13171090"

+(NSString *) md5: (NSString *) inPutText 
{
    if (inPutText == nil) {
        return nil;
    }
    const char *cStr = [inPutText UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr,(int)strlen(cStr), result);
    
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] uppercaseString];
}

+(NSString *)jointStr:(NSString *)str parameterDic:(NSDictionary *)parameter
{
    NSString *serviceUrlStr = [@"" stringByAppendingFormat:@"%@",str] ;
    
    NSString *jsonStr = [MyMD5 cStrWithDic:parameter];
    
    //NSString *dataParameterStr = [self encodeURL:jsonStr];
    
    NSString *macStr = [MyMD5 md5:[NSString stringWithFormat:@"%@%@",jsonStr,Md5Key]];
    
    NSString *CloudServiceUrlStr = [serviceUrlStr stringByAppendingFormat:@"%@",macStr];
    
    return CloudServiceUrlStr;
}

//dictionary 转 json
+(NSString *)cStrWithDic:(NSDictionary *)dictionary
{
    NSData *json = [NSJSONSerialization dataWithJSONObject:dictionary
                                                   options:0
                                                     error:nil];
    
    NSString *string = [[NSString alloc] initWithData:json
                                             encoding:NSUTF8StringEncoding];
    
    return string;
}


//encodeing
+(NSString *)encodeURL:(NSString *)dString{
    
    NSString *escapeUrlString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)dString, NULL, (CFStringRef)ENCODE_KEY, kCFStringEncodingUTF8 ));
    
    escapeUrlString = [escapeUrlString stringByAddingPercentEscapesUsingEncoding:kCFStringEncodingUTF8];
    
    return escapeUrlString;
}

@end
