#import <Foundation/Foundation.h>

@interface DateUtils : NSObject

+ (NSString*)weekdayStringFromDate:(NSDate*)inputDate ;

+ (int)calculateDay:(NSString *) st withEnd:(NSString *) ed;

+ (NSDate *)parse:(NSString *) str withPattern:(NSString *) pattern;

+ (NSString *)format:(NSDate *) date withPattern:(NSString *) pattern;

+ (NSDate *)bg_parseLocalTimeStr:(NSString *) str withPattern:(NSString *) pattern;

+ (NSString *)bg_formatLocalTimeDate:(NSDate *) date withPattern:(NSString *) pattern;

+ (NSString *)bg_stringformatLocalDate:(NSDate *) date withPattern:(NSString *) pattern;

+ (NSDate *)localDate:(NSDate *)date;

+ (NSDate *)stringToDate:(NSString *)strdate;

+(NSArray *)dateCount:(NSInteger) count withBillDay:(NSString *)billDay;

+(NSString *)currectDay;

+(NSString *)formatMonth:(long) month;

+(NSString *)formatDay:(long)day;

+(NSString *)currectDayWithOut;

+(NSString *)dateFormat:(NSString *)dateString;

+(NSString *)dateFormatSigle:(NSString *)dateString;

+(NSString *)dateFormatString:(NSString *)dateString;

+(NSString *)getCurrentMonth;

+(NSString *)getCurrentYear;

+(NSString *)getCurrentDay;

+(NSDate *)localDateFromCN:(NSDate *)date;
//转
+(NSString *)formatTimeFromSecond:(NSString *)dataString forState:(NSString *)formatData;
//根据两个时间戳，计算时间差
+ (NSString*)compareTwoTime:(long)time1 time2:(long)time2;
@end 
