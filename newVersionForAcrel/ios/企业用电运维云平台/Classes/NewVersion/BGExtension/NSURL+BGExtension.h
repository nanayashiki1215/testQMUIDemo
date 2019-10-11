//
//  NSURL+BGExtension.h
//  BusinessUCSDK
//
//  Created by feitian on 2018/6/1.
//  Copyright © 2018年 com.Ideal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (BGExtension)

//编码URL中的汉字
+(instancetype)bg_URLWithString:(NSString *)string;

@end
