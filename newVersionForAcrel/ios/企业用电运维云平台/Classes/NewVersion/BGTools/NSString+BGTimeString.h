//
//  NSString+BGTimeString.h
//  BusinessUCSDK
//
//  Created by Beryl on 2018/7/16.
//  Copyright © 2018年 com.Ideal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (BGTimeString)
//聊天室里面显示的时间格式
+ (NSString *)transFromChatShowTime:(NSString *)timeStr;
+(NSString *)inputTimeStr:(NSString *)timeStr;

//把NSDate转化为HH:mm 时间字符串
+ (NSString *)transfromDateToHHmm:(NSString *)dataStr;

//把时间转化为yyyy-MM-dd HH:mm 时间字符串
+ (NSString *)transfromDateExclusiveSecond:(NSString *)dataStr;
//判断是否为今天
+ (BOOL)isTodydayWithDate:(NSString *)dataStr;
+ (NSString*)weekdayStringFromDate:(NSDate*)inputDate;

//判断逾期
+(NSString *)getYUQIState:(NSString *)timeStr;
//MM月dd日
+ (NSString *)getDateFormatWithChinese:(NSString *)dateStr;
+ (NSString *)getMMSSFromSS:(NSString *)totalTime;
@end
