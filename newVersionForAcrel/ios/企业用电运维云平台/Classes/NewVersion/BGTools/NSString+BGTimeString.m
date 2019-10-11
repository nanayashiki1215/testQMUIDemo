//
//  NSString+BGTimeString.m
//  BusinessUCSDK
//
//  Created by Beryl on 2018/7/16.
//  Copyright © 2018年 com.Ideal. All rights reserved.
//

#import "NSString+BGTimeString.h"

@implementation NSString (BGTimeString)
/*
 * 需要传入的时间格式 2017-06-14 14:18:54
 
 */
+ (NSString *)transFromChatShowTime:(NSString *)timeStr{
    //    return timeStr;
    NSDate *nowDate = [NSDate date];
    
    NSDate *sinceDate = [self becomeDateStr:timeStr];
    
    int i  = [nowDate timeIntervalSinceDate:sinceDate];
    
    NSString  *str  = @"";
    if (i < 3600) {
        str = [NSString stringWithFormat:@"今天 %@",[NSString transfromDateToHHmm:timeStr]];
        
    }else if (i>3600 && i<60*60*24){//
        
        if ([self isYesterdayWithDate:sinceDate])
            
        {//24小时内可能是昨天
            
            str = [NSString stringWithFormat:@"昨天 %@",[NSString transfromDateToHHmm:timeStr]];
            
        }else
            
        {//今天
            
            str = [NSString stringWithFormat:@"今天 %@",[NSString transfromDateToHHmm:timeStr]];
            
        }
        
    }else{//
        
        int k = i/(3600*24);
        
        if ([self isYesterdayWithDate:sinceDate])
            
        {//大于24小时也可能是昨天
            
            str = [NSString stringWithFormat:@"昨天 %@",[NSString transfromDateToHHmm:timeStr]];
            
        }else{
            
            //在这里大于1天的我们可以以周几的形式显示
            
            if (k>=1 && k<=7)
                
            {
                
                if (k < [self getNowDateWeek])
                    
                {//本周
                    
                    str  = [NSString stringWithFormat:@"%@ %@",[self weekdayStringFromDate:[self becomeDateStr:timeStr]],[NSString transfromDateToHHmm:timeStr]];
                    
                }else
                {//不是本周
                    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                    [formatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
                    NSString *strDate = [formatter stringFromDate:sinceDate];
                    str = strDate;
                    
                }
                
            }else
                
            {//
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                [formatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
                NSString *strDate = [formatter stringFromDate:sinceDate];
                
                str = strDate;
                
            }
            
        }
        
    }
    
    return str;
}
/*
 * 需要传入的时间格式 2017-06-14 14:18:54
 
 */


// 和当前时间进行比较  输出字符串为（刚刚几个小时前 几天前 ）

+(NSString *)inputTimeStr:(NSString *)timeStr

{
    //    return timeStr;
    NSDate *nowDate = [NSDate date];
    
    NSDate *sinceDate = [self becomeDateStr:timeStr];
    if (sinceDate == nil) {
        return @"";
    }
    
    int i  = [nowDate timeIntervalSinceDate:sinceDate];
    
    
    
    NSString  *str  = @"";
    
    
    
    if (i <= 60)
        
    {//小于60s
        
        str = @"刚刚";
        
    }else if(i>60 && i<=3600)
        
    {//大于60s，小于一小时
        
        str = [NSString stringWithFormat:@"%d分钟前",i/60];
        
    }else if (i>3600 && i<60*60*24)
        
    {//
        
        if ([self isYesterdayWithDate:sinceDate])
            
        {//24小时内可能是昨天
            
            str = [NSString stringWithFormat:@"昨天"];
            
        }else
            
        {//今天
            
            str = [NSString stringWithFormat:@"%d小时前",i/3600];
            
        }
        
    }else
        
    {//
        
        int k = i/(3600*24);
        
        if ([self isYesterdayWithDate:sinceDate])
            
        {//大于24小时也可能是昨天
            
            str = [NSString stringWithFormat:@"昨天"];
            
        }else
            
        {
            
            //在这里大于1天的我们可以以周几的形式显示
            
            if (k>=1 && k<=7)
                
            {
                
                if (k < [self getNowDateWeek])
                    
                {//本周
                    
                    str  = [self weekdayStringFromDate:[self becomeDateStr:timeStr]];
                    
                }else
                {//不是本周
                    
                    str = [NSString stringWithFormat:@"%d天前",i/(3600*24)];;
                    
                }
                
            }else
                
            {//
                
                str = [self transfromDate:sinceDate];
                
            }
            
        }
        
    }
    
    return str;
    
}
//把NSDate转化为yy/m/d 时间字符串
+(NSString *)transfromDate:(NSDate *)date{
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc]init];
    
    [formatter2 setDateFormat:@"yyyy/M/d"];
    NSString *strDate = [formatter2 stringFromDate:date];
    return strDate;
}

//把时间字符串转换成NSDate

+ (NSDate *)becomeDateStr:(NSString *)dateStr

{
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc]init];
    
    [formatter2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date1 = [formatter2 dateFromString:dateStr];
    
    return date1;
    
}

//把时间转换成星期

+ (NSString*)weekdayStringFromDate:(NSDate*)inputDate {
    
    
    
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", nil];
    
    
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    
    
    //    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"zh-Hans"];
    
    
    
    [calendar setTimeZone: timeZone];
    
    
    
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    
    
    
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:inputDate];
    
    
    
    return [weekdays objectAtIndex:theComponents.weekday];
    
}

//把时间转化为HH:mm 时间字符串
+ (NSString *)transfromDateToHHmm:(NSString *)dataStr{
    NSDate *nowData = [self becomeDateStr:dataStr];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *strDate = [formatter stringFromDate:nowData];
    return strDate;
}

//把时间转化为yyyy-MM-dd HH:mm:ss 时间字符串
+ (NSString *)transfromDateExclusiveSecond:(NSString *)dataStr{
    NSDate *nowData = [self becomeDateStr:dataStr];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [formatter stringFromDate:nowData];
    return strDate;
}


//判断是否为今天

+ (BOOL)isTodydayWithDate:(NSString *)dataStr {
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [format dateFromString:dataStr];
    
    BOOL isToday = [[NSCalendar currentCalendar] isDateInToday:date];
    return isToday;
}

//判断是否为昨天

+ (BOOL)isYesterdayWithDate:(NSDate *)newDate

{
    
    BOOL isYesterday = YES;
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    
    //
    
    NSDate *yearsterDay =  [[NSDate alloc] initWithTimeIntervalSinceNow:-secondsPerDay];
    
    /** 前天判断
     
     //    NSDate *qianToday =  [[NSDate alloc] initWithTimeIntervalSinceNow:-2*secondsPerDay];
     
     //    NSDateComponents* comp3 = [calendar components:unitFlags fromDate:qianToday];
     
     //    if (comp1.year == comp3.year && comp1.month == comp3.month && comp1.day == comp3.day)
     
     //    {
     
     //        dateContent = @"前天";
     
     //    }
     
     **/
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    
    //    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:newDate];
    
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:yearsterDay];
    
    
    
    if ( comp1.year == comp2.year && comp1.month == comp2.month && comp1.day == comp2.day)
        
    {
        
        isYesterday = YES;
        
    }else
        
    {
        
        isYesterday = NO;
        
    }
    
    return isYesterday;
    
}

//判断今天是本周的第几天

+ (int)getNowDateWeek

{
    
    NSDate *nowDate = [NSDate date];
    
    NSString *nowWeekStr = [self weekdayStringFromDate:nowDate];
    
    int  factWeekDay = 0;
    
    
    
    if ([nowWeekStr isEqualToString:@"周日"])
        
    {
        
        factWeekDay = 7;
        
    }else if ([nowWeekStr isEqualToString:@"周一"])
        
    {
        
        factWeekDay = 1;
        
    }else if ([nowWeekStr isEqualToString:@"周二"])
        
    {
        
        factWeekDay = 2;
        
    }else if ([nowWeekStr isEqualToString:@"周三"])
        
    {
        
        factWeekDay = 3;
        
    }else if ([nowWeekStr isEqualToString:@"周四"])
        
    {
        
        factWeekDay = 4;
        
    }else if ([nowWeekStr isEqualToString:@"周五"])
        
    {
        
        factWeekDay = 5;
        
    }else if ([nowWeekStr isEqualToString:@"周六"])
        
    {
        
        factWeekDay = 6;
        
    }
    
    return  factWeekDay;
    
}
//判断逾期
+(NSString *)getYUQIState:(NSString *)timeStr{
    
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc]init];
    
    [formatter2 setDateFormat:@"yyyyMMddHHmmss"];
    
    NSDate *sinceDate = [formatter2 dateFromString:timeStr];
    
    
    NSDate *nowDate = [NSDate date];
    
    //利用NSCalendar比较日期的差异
    NSCalendar *calendar = [NSCalendar currentCalendar];
    /**
     * 要比较的时间单位,常用如下,可以同时传：
     *    NSCalendarUnitDay : 天
     *    NSCalendarUnitYear : 年
     *    NSCalendarUnitMonth : 月
     *    NSCalendarUnitHour : 时
     *    NSCalendarUnitMinute : 分
     *    NSCalendarUnitSecond : 秒
     */
    NSCalendarUnit unit = NSCalendarUnitDay;//只比较天数差异
    //比较的结果是NSDateComponents类对象
    NSDateComponents *delta = [calendar components:unit fromDate:nowDate toDate:sinceDate options:0];
    //打印
    if (delta.day>0) {
        //距逾期%ld天
        //        return [NSString  stringWithFormat:@"距逾期%ld天",(long)delta.day];
        return @"";
    }else if (delta.day<0){
        //已逾期
        return [NSString  stringWithFormat:@"逾期%ld天",labs(delta.day)];
        
        //        return @"已逾期";
    }else if (delta.day == 0){
        int i  = [nowDate timeIntervalSinceDate:sinceDate];
        if (i>0) {
            //已逾期
            return @"已逾期";
        }else{
            //            NSLog(@"距逾期不足");
            return  @"距逾期不到1天";
        }
    }
    
    
    return nil;
    
}
+ (NSString *)getDateFormatWithChinese:(NSString *)dateStr{
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc]init];
    [formatter2 setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *date1 = [formatter2 dateFromString:dateStr];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM月dd日 HH:mm"];
    NSString *strDate = [formatter stringFromDate:date1];
    
    return strDate;
}

//传入 秒  得到 xx:xx:xx
+ (NSString *)getMMSSFromSS:(NSString *)totalTime {
    
    NSInteger seconds = [totalTime integerValue];
    
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    
    return format_time;
}

@end
