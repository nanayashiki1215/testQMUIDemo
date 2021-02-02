//
//  SecurityUtil.h
//  企业用电运维云平台
//
//  Created by Acrel on 2021/1/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SecurityUtil : NSObject

#pragma mark - AES加密
//将string转成带密码的data
+(NSString*)encryptAESData:(NSString*)string Withkey:(NSString * )key ivkey:(NSString * )ivkey;
//将带密码的data转成string
+(NSString*)decryptAESData:(NSString*)data Withkey:(NSString *)key ivkey:(NSString * )ivkey;

@end

NS_ASSUME_NONNULL_END
