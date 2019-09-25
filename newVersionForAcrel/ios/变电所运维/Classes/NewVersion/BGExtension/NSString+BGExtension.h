//
//  NSString+Extension.h
//  IdealCallCenter
//
//  Created by feitian on 15/9/7.
//  Copyright © 2015年 com.Ideal. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSString (BGExtension)
@property (readonly) NSString *md5StringForFile;
@property (readonly) NSString *sha1String;
@property (readonly) NSString *sha256String;
@property (readonly) NSString *sha512String;

- (NSString *)hmacSHA1StringWithKey:(NSString *)key;
- (NSString *)hmacSHA256StringWithKey:(NSString *)key;
- (NSString *)hmacSHA512StringWithKey:(NSString *)key;

// 清空字符串中的空白字符
- (NSString *)trimString;

// 判断字符串是否为空
- (BOOL)notEmptyOrNull;

// 写入系统偏好
- (void)saveToNSDefaultsWithKey:(NSString *)key;

// 删除符号：()-空格
- (NSString*)trimSymbol;

// 判断手机号码是否正确
- (BOOL)isPhoneNum;

// 判断是否是邮箱
- (BOOL)isEmail;

// 判断是否是纯数字
- (BOOL)isPureNum;

// 判断输入的内容是否为字母
- (BOOL)isLetter;

// 判断长度是否处于num1和num2之间
- (BOOL)isLengthBetween:(int)num1 and:(int)num2;

// 是否包含某个字符串
//- (BOOL)containsString:(NSString *)str;

//转换为md5
- (NSString *) md5String;
//json对象转字符串
+(NSString *)stringFromJsonObject:(id)objc;
//字符串转json对象
-(id)jsonObjectFromString;

//替换字符串中的中文字符，用于网络链接的转换
-(NSString *)bg_stringByReplacingChineseCharacter;

//字符串包含表情
+ (BOOL)stringContainsEmoji:(NSString *)string;

//判断中英混合的的字符串长度
- (int)convertToInt;

- (NSString *)transformToPinyin:(NSString *)aString;

- (NSString *) pinyinFirstLetter:(NSString*)sourceString;

@end
