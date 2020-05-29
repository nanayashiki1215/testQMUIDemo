//
//  SKControllerTools.m
//  IdealCallCenter
//
//  Created by nanayashiki on 15/8/31.
//  Copyright (c) 2015年 nanayashiki. All rights reserved.
//

#import "SKControllerTools.h"
#import <sys/utsname.h>//要导入头文件

#define IOS7 [[UIDevice currentDevice]systemVersion].floatValue>=7.0
@implementation SKControllerTools
+(UILabel*)createLabelWithFrame:(CGRect)frame Font:(int)font Text:(NSString*)text
{
    
    UILabel*label=[[UILabel alloc]initWithFrame:frame];
    //限制行数
    label.numberOfLines=0;
    //对齐方式
    label.textAlignment=NSTextAlignmentLeft;
    label.backgroundColor=[UIColor clearColor];
    label.font=[UIFont systemFontOfSize:font];
    //单词折行
    label.lineBreakMode=NSLineBreakByWordWrapping;
    //默认字体颜色是白色
    label.textColor=[UIColor whiteColor];
    //自适应（行数~字体大小按照设置大小进行设置）
    label.adjustsFontSizeToFitWidth=YES;
    label.text=text;
    return label;
}
+(UIButton*)createButtonWithFrame:(CGRect)frame normalBGImageName:(NSString*)normalBGImageName selectBGImageName:(NSString*)selectBGImageName Target:(id)target Action:(SEL)action Title:(NSString*)title
{
    UIButton*button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=frame;
    [button setTitle:title forState:UIControlStateNormal];
    //设置背景图片，可以使文字与图片共存
    [button setBackgroundImage:[UIImage imageNamed:normalBGImageName] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:selectBGImageName] forState:UIControlStateSelected];
    //图片与文字如果需要同时存在，就需要图片足够小 详见人人项目按钮设置
    // [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

+(UIButton*)createButtonWithFrame:(CGRect)frame normalImageName:(NSString*)normalImageName selectImageName:(NSString*)selectImageName Target:(id)target Action:(SEL)action Title:(NSString*)title
{
    UIButton*button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:normalImageName] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:selectImageName] forState:UIControlStateSelected];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+(UIImageView*)createImageViewWithFrame:(CGRect)frame ImageName:(NSString*)imageName
{
    UIImageView*imageView=[[UIImageView alloc]initWithFrame:frame];
    imageView.image=[UIImage imageNamed:imageName];
    imageView.userInteractionEnabled=YES;
    return imageView ;
}
+(UIView*)createViewWithFrame:(CGRect)frame
{
    UIView*view=[[UIView alloc]initWithFrame:frame];
    
    return view ;
    
}
+(UITextField*)createTextFieldWithFrame:(CGRect)frame placeholder:(NSString*)placeholder passWord:(BOOL)YESorNO leftImageView:(UIImageView*)imageView rightImageView:(UIImageView*)rightImageView Font:(float)font
{
    UITextField*textField=[[UITextField alloc]initWithFrame:frame];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    //灰色提示框
    textField.placeholder=placeholder;
    //文字对齐方式
    textField.textAlignment=NSTextAlignmentLeft;
    textField.secureTextEntry=YESorNO;
    //边框
    //textField.borderStyle=UITextBorderStyleLine;
    //键盘类型
    textField.keyboardType=UIKeyboardTypeEmailAddress;
    //关闭首字母大写
    textField.autocapitalizationType=NO;
    //清除按钮
    textField.clearButtonMode=YES;
    //左图片
    textField.leftView=imageView;
    textField.leftViewMode=UITextFieldViewModeAlways;
    //右图片
    textField.rightView=rightImageView;
    //编辑状态下一直存在
    textField.rightViewMode=UITextFieldViewModeWhileEditing;
    //自定义键盘
    //textField.inputView
    //字体
    textField.font=[UIFont systemFontOfSize:font];
    //字体颜色
    textField.textColor=[UIColor whiteColor];
    return textField ;
    
}

+ (UIBarButtonItem *)createBarButtonItemWithTarget:(id)target action:(SEL)action image:(NSString *)image highlightImage:(NSString *)highlightImage{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.imageView.contentMode = UIViewContentModeScaleToFill;
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    // 设置图片
    [btn setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:highlightImage] forState:UIControlStateHighlighted];
    // 设置尺寸
    btn.frame = CGRectMake(0, 0, 44,44);
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    return item;
}

+ (UIBarButtonItem *)createBarButtonTextItemWithTarget:(id)target action:(SEL)action title:(NSString *)title image:(NSString *)image highlightImage:(NSString *)highlightImage{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.imageView.contentMode = UIViewContentModeScaleToFill;
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    // 设置图片
    [btn setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:highlightImage] forState:UIControlStateHighlighted];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateHighlighted];
//    if ([[BGFWGlobal bg_sharedInstance].bgProjectFlag isEqualToString:@"DJ_"]) {
//        [btn setTitleColor:[BGFWGlobal bg_sharedInstance].navigationItemTextColor forState:UIControlStateNormal];
//        [btn setTitleColor:[BGFWGlobal bg_sharedInstance].navigationItemTextColor forState:UIControlStateHighlighted];
//    }else{
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
//    }
   
    [btn.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
    if (title.length>3){
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 6.0, 0.0, 0.0)];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 6.0, 0.0, 0.0)];
        btn.frame = CGRectMake(0, 0, 80,44);
    }else if(title.length>2){
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 3.0, 0.0, 0.0)];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 3.0, 0.0, 0.0)];
        btn.frame = CGRectMake(0, 0, 72,44);
    }else if (title.length>0){
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0.0, -5.0, 0.0, 0.0)];
        btn.frame = CGRectMake(0, 0, 70,44);
    }else{
        btn.frame = CGRectMake(0, 0, 70,44);
    }
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    return item;
}

+ (UIBarButtonItem *)createLeftBackBarButtonItemWithTarget:(id)target action:(SEL)action title:(NSString *)title  showArrows:(BOOL)showArrows{
    
    title = title?title:@"返回";

    if (showArrows == YES) {
        return [self createBarButtonTextItemWithTarget:target action:action title:title image:@"fhjt" highlightImage:@"fhjt"];

    }else{
        return [self createBarButtonTextItemWithTarget:target action:action title:title image:@"" highlightImage:@""];

    }
}


#pragma  mark 适配器方法
+(UITextField*)createTextFieldWithFrame:(CGRect)frame placeholder:(NSString*)placeholder passWord:(BOOL)YESorNO leftImageView:(UIImageView*)imageView rightImageView:(UIImageView*)rightImageView Font:(float)font backgRoundImageName:(NSString*)imageName
{
    UITextField*text= [self createTextFieldWithFrame:frame placeholder:placeholder passWord:YESorNO leftImageView:imageView rightImageView:rightImageView Font:font];
    text.background=[UIImage imageNamed:imageName];
    return  text;
    
}
+(UIScrollView*)makeScrollViewWithFrame:(CGRect)frame andSize:(CGSize)size
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
    
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = size;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    return scrollView ;
}
+(UIPageControl*)makePageControlWithFram:(CGRect)frame
{
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:frame];
    pageControl.numberOfPages = 2;
    pageControl.currentPage = 0;
    return pageControl;
}
+(UISlider*)makeSliderWithFrame:(CGRect)rect AndImage:(UIImage*)image
{
    UISlider *slider = [[UISlider alloc]initWithFrame:rect];
    slider.minimumValue = 0;
    slider.maximumValue = 1;
    [slider setThumbImage:[UIImage imageNamed:@"qiu"] forState:UIControlStateNormal];
    slider.maximumTrackTintColor = [UIColor grayColor];
    slider.minimumTrackTintColor = [UIColor yellowColor];
    slider.continuous = YES;
    slider.enabled = YES;
    return slider ;
}
+(NSString *)stringFromDateWithHourAndMinute:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    
    return destDateString;
}

#pragma -mark 判断导航的高度
+(float)isIOS7{
    
    float height;
    if (IOS7) {
        height=64.0;
    }else{
        height=44;
    }
    
    return height;
}
//+(NSString *)platformString{
//    // Gets a string with the device model
//    size_t size;
//    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
//    char *machine = malloc(size);
//    sysctlbyname("hw.machine", machine, &size, NULL, 0);
//    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
//    free(machine);
//    NSDictionary* d = nil;
//    if (d == nil)
//    {
//        d = @{
//              @"iPhone1,1": @"iPhone 2G",
//              @"iPhone1,2": @"iPhone 3G",
//              @"iPhone2,1": @"iPhone 3GS",
//              @"iPhone3,1": @"iPhone 4",
//              @"iPhone3,2": @"iPhone 4",
//              @"iPhone3,3": @"iPhone 4 (CDMA)",
//              @"iPhone4,1": @"iPhone 4S",
//              @"iPhone5,1": @"iPhone 5",
//              @"iPhone5,2": @"iPhone 5 (GSM+CDMA)",
//
//              @"iPod1,1": @"iPod Touch (1 Gen)",
//              @"iPod2,1": @"iPod Touch (2 Gen)",
//              @"iPod3,1": @"iPod Touch (3 Gen)",
//              @"iPod4,1": @"iPod Touch (4 Gen)",
//              @"iPod5,1": @"iPod Touch (5 Gen)",
//
//              @"iPad1,1": @"iPad",
//              @"iPad1,2": @"iPad 3G",
//              @"iPad2,1": @"iPad 2 (WiFi)",
//              @"iPad2,2": @"iPad 2",
//              @"iPad2,3": @"iPad 2 (CDMA)",
//              @"iPad2,4": @"iPad 2",
//              @"iPad2,5": @"iPad Mini (WiFi)",
//              @"iPad2,6": @"iPad Mini",
//              @"iPad2,7": @"iPad Mini (GSM+CDMA)",
//              @"iPad3,1": @"iPad 3 (WiFi)",
//              @"iPad3,2": @"iPad 3 (GSM+CDMA)",
//              @"iPad3,3": @"iPad 3",
//              @"iPad3,4": @"iPad 4 (WiFi)",
//              @"iPad3,5": @"iPad 4",
//              @"iPad3,6": @"iPad 4 (GSM+CDMA)",
//
//              @"i386": @"Simulator",
//              @"x86_64": @"Simulator"
//              };
//    }
//    NSString* ret = [d objectForKey: platform];
//
//    if (ret == nil)
//    {
//        return platform;
//    }
//    return ret;
//}

+ (NSString *)getCurrentDeviceModel{
   struct utsname systemInfo;
   uname(&systemInfo);
   NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
   
if ([deviceModel isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
if ([deviceModel isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
if ([deviceModel isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
if ([deviceModel isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
if ([deviceModel isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
if ([deviceModel isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
if ([deviceModel isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
if ([deviceModel isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
if ([deviceModel isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
if ([deviceModel isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
if ([deviceModel isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
if ([deviceModel isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
if ([deviceModel isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
if ([deviceModel isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
if ([deviceModel isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
// 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
if ([deviceModel isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
if ([deviceModel isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
if ([deviceModel isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
if ([deviceModel isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
if ([deviceModel isEqualToString:@"iPhone10,1"])   return @"iPhone_8";
if ([deviceModel isEqualToString:@"iPhone10,4"])   return @"iPhone_8";
if ([deviceModel isEqualToString:@"iPhone10,2"])   return @"iPhone_8_Plus";
if ([deviceModel isEqualToString:@"iPhone10,5"])   return @"iPhone_8_Plus";
if ([deviceModel isEqualToString:@"iPhone10,3"])   return @"iPhone X";
if ([deviceModel isEqualToString:@"iPhone10,6"])   return @"iPhone X";
if ([deviceModel isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
if ([deviceModel isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
if ([deviceModel isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
if ([deviceModel isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";
if ([deviceModel isEqualToString:@"iPhone12,1"])   return @"iPhone 11";
if ([deviceModel isEqualToString:@"iPhone12,3"])   return @"iPhone 11 Pro";
if ([deviceModel isEqualToString:@"iPhone12,5"])   return @"iPhone 11 Pro Max";
if ([deviceModel isEqualToString:@"iPhone12,8"])   return @"iPhone SE2";
if ([deviceModel isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
if ([deviceModel isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
if ([deviceModel isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
if ([deviceModel isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
if ([deviceModel isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
if ([deviceModel isEqualToString:@"iPad1,1"])      return @"iPad";
if ([deviceModel isEqualToString:@"iPad1,2"])      return @"iPad 3G";
if ([deviceModel isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
if ([deviceModel isEqualToString:@"iPad2,2"])      return @"iPad 2";
if ([deviceModel isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
if ([deviceModel isEqualToString:@"iPad2,4"])      return @"iPad 2";
if ([deviceModel isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
if ([deviceModel isEqualToString:@"iPad2,6"])      return @"iPad Mini";
if ([deviceModel isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
if ([deviceModel isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
if ([deviceModel isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
if ([deviceModel isEqualToString:@"iPad3,3"])      return @"iPad 3";
if ([deviceModel isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
if ([deviceModel isEqualToString:@"iPad3,5"])      return @"iPad 4";
if ([deviceModel isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
if ([deviceModel isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
if ([deviceModel isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
if ([deviceModel isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
if ([deviceModel isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
if ([deviceModel isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
if ([deviceModel isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
if ([deviceModel isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
if ([deviceModel isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
if ([deviceModel isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
if ([deviceModel isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
if ([deviceModel isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
if ([deviceModel isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
if ([deviceModel isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
if ([deviceModel isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
if ([deviceModel isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
if ([deviceModel isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";

if ([deviceModel isEqualToString:@"AppleTV2,1"])      return @"Apple TV 2";
if ([deviceModel isEqualToString:@"AppleTV3,1"])      return @"Apple TV 3";
if ([deviceModel isEqualToString:@"AppleTV3,2"])      return @"Apple TV 3";
if ([deviceModel isEqualToString:@"AppleTV5,3"])      return @"Apple TV 4";

if ([deviceModel isEqualToString:@"i386"])         return @"Simulator";
if ([deviceModel isEqualToString:@"x86_64"])       return @"Simulator";
    return deviceModel;
}

#pragma mark 内涵图需要的方法
+ (NSString *)stringDateWithTimeInterval:(NSString *)timeInterval
{
    NSTimeInterval seconds = [timeInterval integerValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyyMMddHHmmss";
    return [format stringFromDate:date];
}

+ (CGFloat)textHeightWithString:(NSString *)text width:(CGFloat)width fontSize:(NSInteger)fontSize
{
    NSDictionary *dict = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    // 根据第一个参数的文本内容，使用280*float最大值的大小，使用系统14号字，返回一个真实的frame size : (280*xxx)!!
    CGRect frame = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    return frame.size.height + 5;
}

// 返回一个整数字符串加1后的新字符串
+ (NSString *)addOneByIntegerString:(NSString *)integerString
{
    NSInteger integer = [integerString integerValue];
    return [NSString stringWithFormat:@"%ld",integer+1];
}

#pragma mark 返回排序数据
- (NSArray *)getArrayFromPlistFile:(NSString *)fileName {
    //从bundle中获取文件
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    
    NSArray *dataArray = [NSArray arrayWithContentsOfFile:filePath];
    
    return [dataArray copy];
    
}

@end
