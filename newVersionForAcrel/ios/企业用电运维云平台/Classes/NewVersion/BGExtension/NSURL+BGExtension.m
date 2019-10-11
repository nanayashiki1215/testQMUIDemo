//
//  NSURL+BGExtension.m
//  BusinessUCSDK
//
//  Created by feitian on 2018/6/1.
//  Copyright © 2018年 com.Ideal. All rights reserved.
//

#import "NSURL+BGExtension.h"
#import "NSString+BGExtension.h"

@implementation NSURL (BGExtension)

+(instancetype)bg_URLWithString:(NSString *)string{
    NSString *urlString = [string bg_stringByReplacingChineseCharacter];
    return [self URLWithString:urlString];
}

@end
