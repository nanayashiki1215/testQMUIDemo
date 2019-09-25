//
//  CompputeTools.h
//  SPDBCCC
//
//  Created by WuQiaoqiao on 14/10/24.
//  Copyright (c) 2014年 Qiaoqiao.Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "BaseViewController.h"

@interface CompputeTools : NSObject

/**
 GCD:传入需要等待的时间,后台等待,主线程执行
 */
+(void)waitWithTime:(NSTimeInterval )time
      withWorkBlock:(void(^)(void))work;
+(BOOL)validateEmail:(NSString *)email;
+ (NSString *)deviceIPAdress;
+(NSArray *)separatedString:(NSString *)orginString by:(NSString *)sepString;
+(NSMutableArray *)searchFileName:(NSString *)fileUrl fmorString:(NSString *)fmorString;
//不可变转可变数据类型，适用不可变数组，字典，字符串
+ (id)transformToMuable:(id)objc;
//#warning 不确定的映射关系！！！
+(NSDictionary *)skillQueueToChinese;
+(NSDictionary *)skillQueueTypeToChinese;
+(NSDictionary *)statusToChinese;

// 把大于size的图片压缩，
+ (UIImage *)compressImage:(UIImage *)img toSize:(CGSize)size;
//截图
+(UIImage *)screenShotFromView:(UIView *)fromView;

+(NSString *)imageNameWithChannelCode:(NSString *)channelCode;

+(BOOL)isDefinedMsgType:(NSString *)msgType;
+(BOOL)isDefinedChannelCode:(NSString *)channelCode;

+(BaseViewController *)getCurrectController;

+(void)setCurrectController:(BaseViewController *) controller;

+ (NSString *)secondsFormatted:(NSInteger)totalSeconds;

+ (NSString *)secondsFormattedToHMS:(NSInteger)totalSeconds;

+(UIImage*)bg_image:(UIImage *)image scaleToSize:(CGSize)size;
+(UIImage *)bg_imageFromImage:(UIImage *)image inRect:(CGRect)rect;
+(UIImage *)bg_clipImageFromCenter:(UIImage *)image toRect:(CGSize)size;

@end
