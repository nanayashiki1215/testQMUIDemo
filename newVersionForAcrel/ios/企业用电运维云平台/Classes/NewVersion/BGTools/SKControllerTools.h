//
//  SKControllerTools.h
//  IdealCallCenter
//
//  Created by nanayashiki on 15/8/31.
//  Copyright (c) 2015年 nanayashiki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKControllerTools : NSObject
//#pragma mark --判断设备型号
//+(NSString *)platformString;
#pragma mark --创建Label
+(UILabel*)createLabelWithFrame:(CGRect)frame Font:(int)font Text:(NSString*)text;
#pragma mark --创建View
+(UIView*)createViewWithFrame:(CGRect)frame;
#pragma mark --创建imageView
+(UIImageView*)createImageViewWithFrame:(CGRect)frame ImageName:(NSString*)imageName;
#pragma mark --创建button
+(UIButton*)createButtonWithFrame:(CGRect)frame normalBGImageName:(NSString*)normalBGImageName selectBGImageName:(NSString*)selectBGImageName Target:(id)target Action:(SEL)action Title:(NSString*)title;
+(UIButton*)createButtonWithFrame:(CGRect)frame normalImageName:(NSString*)normalImageName selectImageName:(NSString*)selectImageName Target:(id)target Action:(SEL)action Title:(NSString*)title;
#pragma mark --创建UITextField
+(UITextField*)createTextFieldWithFrame:(CGRect)frame placeholder:(NSString*)placeholder passWord:(BOOL)YESorNO leftImageView:(UIImageView*)imageView rightImageView:(UIImageView*)rightImageView Font:(float)font;
//创建BarButtonItem



+ (UIBarButtonItem *)createBarButtonItemWithTarget:(id)target action:(SEL)action image:(NSString *)image highlightImage:(NSString *)highlightImage;
+ (UIBarButtonItem *)createBarButtonTextItemWithTarget:(id)target action:(SEL)action title:(NSString *)title image:(NSString *)image highlightImage:(NSString *)highlightImage;




+ (UIBarButtonItem *)createLeftBackBarButtonItemWithTarget:(id)target action:(SEL)action title:(NSString *)title showArrows:(BOOL)needArrows;
//适配器的方法  扩展性方法
//现有方法，已经在工程里面存在，如果修改工程内所有方法，工作量巨大，就需要使用适配器的方法
+(UITextField*)createTextFieldWithFrame:(CGRect)frame placeholder:(NSString*)placeholder passWord:(BOOL)YESorNO leftImageView:(UIImageView*)imageView rightImageView:(UIImageView*)rightImageView Font:(float)font backgRoundImageName:(NSString*)imageName;
#pragma mark 创建UIScrollView
+(UIScrollView*)makeScrollViewWithFrame:(CGRect)frame andSize:(CGSize)size;
#pragma mark 创建UIPageControl
+(UIPageControl*)makePageControlWithFram:(CGRect)frame;
#pragma mark 创建UISlider
+(UISlider*)makeSliderWithFrame:(CGRect)rect AndImage:(UIImage*)image;
#pragma mark 创建时间转换字符串
+(NSString *)stringFromDateWithHourAndMinute:(NSDate *)date;
#pragma mark --判断导航的高度64or44
+(float)isIOS7;

#pragma mark 内涵图需要的方法
+ (NSString *)stringDateWithTimeInterval:(NSString *)timeInterval;

+ (CGFloat)textHeightWithString:(NSString *)text width:(CGFloat)width fontSize:(NSInteger)fontSize;

+ (NSString *)addOneByIntegerString:(NSString *)integerString;


@end
