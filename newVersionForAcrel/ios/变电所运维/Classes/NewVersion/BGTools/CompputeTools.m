//
//  CompputeTools.m
//  SPDBCCC
//
//  Created by WuQiaoqiao on 14/10/24.
//  Copyright (c) 2014年 Qiaoqiao.Wu. All rights reserved.
//

#import "CompputeTools.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
@implementation CompputeTools
static BaseViewController *currectController;
//延时执行
+(void)waitWithTime:(NSTimeInterval )time withWorkBlock:(void(^)(void))work{
    
    double delayInSeconds = time;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(),work);
    
}
//验证身份证
+ (BOOL) validateIdentityCard: (NSString *)identityCard
{
    BOOL flag;
    if (identityCard.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:identityCard];
}
//验证邮箱
+(BOOL)validateEmail:(NSString *)email
{
    NSString *emailRegex= @"[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
    
    return [emailTest evaluateWithObject:email];
}
//ip地址
+ (NSString *)deviceIPAdress {
    NSString *address = @"an error occurred when obtaining ip address";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    
    if (success == 0) { // 0 表示获取成功
        
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    return address;
}
//按什么分割字符串
+(NSArray *)separatedString:(NSString *)orginString by:(NSString *)sepString{
    NSArray *array = [orginString componentsSeparatedByString:sepString];
    return array;
}

//从目录搜索扩展名为XX的文件
+(NSMutableArray *)searchFileName:(NSString *)fileUrl fmorString:(NSString *)fmorString
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *direnum;
    direnum = [fileManager enumeratorAtPath: fileUrl];
    
    NSMutableArray *filesArr = [[NSMutableArray alloc] init];
    NSString *filename;
    while (filename = [direnum nextObject]) {
        if([[filename pathExtension] hasSuffix:fmorString]){
            [filesArr addObject:filename];
        }
    }
    return filesArr;
}

//不可变转可变数据类型，适用不可变数组，字典，字符串
+ (id)transformToMuable:(id)objc {
    if ([objc isKindOfClass:[NSArray class]]) {
        NSMutableArray *mutarr = [NSMutableArray array];
        for (id obj in objc) {
            [mutarr addObject:[self transformToMuable:obj]];
        }
        return mutarr;
    }else if([objc isKindOfClass:[NSDictionary class]]){
        NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
        NSArray *keys = [objc allKeys];
        for (NSString *key in keys) {
            [mutDic setObject:[self transformToMuable:[objc objectForKey:key]] forKey:key];
        }
        return mutDic;
    }else if([objc isKindOfClass:[NSString class]]){
        NSMutableString *str = [NSMutableString stringWithString:objc];
        return str;
    }else{
        return objc;
    }
    return nil;
}

//#warning 不确定的映射关系！！！
+(NSDictionary *)skillQueueToChinese{
    return @{@"677":@"投诉技能组",
             @"661":@"咨询技能组",
             @"669":@"语音技能组",
             @"675":@"其他技能组"
             };
    
}

+(NSDictionary *)skillQueueTypeToChinese{
    return @{@"677":@"投诉",
             @"661":@"咨询",
             @"669":@"语音",
             @"675":@"其他"
             };
}

+(NSDictionary *)statusToChinese{
    return @{@"0":@"未登录",
             @"1":@"下班",
             @"2":@"上班",
             @"3":@"示闲",
             @"4":@"示忙"
             };
}

//获取文件用
+(NSDictionary *)fileTypeImage{
    return @{@"0":@"",
             @"1":@"",
             @"2":@"",
             @"3":@"",
             @"4":@"",
             @"5":@""};
}

// 把大于size的图片压缩，
+ (UIImage *)compressImage:(UIImage *)img toSize:(CGSize)size {
    if (img.size.width <= size.width || img.size.height <= size.height) {
        return img;
    }
    
    UIGraphicsBeginImageContext(size);
    CGRect rect = {{0,0}, size};
    [img drawInRect:rect];
    UIImage *compressedImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return compressedImg;
}

/**
 *将图片缩放到指定的CGSize大小
 * UIImage image 原始的图片
 * CGSize size 要缩放到的大小
 */
+(UIImage*)bg_image:(UIImage *)image scaleToSize:(CGSize)size{
    
    // 得到图片上下文，指定绘制范围
    UIGraphicsBeginImageContext(size);
    
    // 将图片按照指定大小绘制
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    // 从当前图片上下文中导出图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 当前图片上下文出栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}

/**
 *从图片中按指定的位置大小截取图片的一部分
 * UIImage image 原始的图片
 * CGRect rect 要截取的区域
 */
+(UIImage *)bg_imageFromImage:(UIImage *)image inRect:(CGRect)rect{
    
    //将UIImage转换成CGImageRef
    CGImageRef sourceImageRef = [image CGImage];
    
    //按照给定的矩形区域进行剪裁
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    
    //将CGImageRef转换成UIImage
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    //返回剪裁后的图片
    return newImage;
}

/**
 *根据给定的size的宽高比自动缩放原图片、自动判断截取位置,进行图片截取
 * UIImage image 原始的图片
 * CGSize size 截取图片的size
 */
+(UIImage *)bg_clipImage:(UIImage *)image toRect:(CGSize)size{
    if (image.size.width>=size.width && image.size.height>=size.height) {
        // 调用剪切方法
        // 这里是以中心位置剪切，也可以通过改变rect的x、y值调整剪切位置
        return [self bg_imageFromImage:image inRect:CGRectMake((image.size.width-size.width)/2, (image.size.height-size.height)/2, size.width, size.height)];
    }else{
        //被切图片宽比例比高比例小 或者相等，以图片宽进行放大
        if (image.size.width*size.height <= image.size.height*size.width) {
            //以被剪裁图片的宽度为基准，得到剪切范围的大小
            CGFloat width  = size.width;
            CGFloat height = image.size.height * size.width / image.size.width;
            UIImage *compressImage = [CompputeTools bg_image:image scaleToSize:CGSizeMake(width, height)];
            // 调用剪切方法
            // 这里是以中心位置剪切，也可以通过改变rect的x、y值调整剪切位置
            return [self bg_imageFromImage:compressImage inRect:CGRectMake((compressImage.size.width-size.width)/2, (compressImage.size.height-size.height)/2, size.width, size.height)];
        }else{ //被切图片宽比例比高比例大，以图片高进行剪裁
            // 以被剪切图片的高度为基准，得到剪切范围的大小
            CGFloat height = size.height;
            CGFloat width  = image.size.width * size.height / image.size.height;
            UIImage *compressImage = [CompputeTools bg_image:image scaleToSize:CGSizeMake(width, height)];
            // 调用剪切方法
            // 这里是以中心位置剪切，也可以通过改变rect的x、y值调整剪切位置
            return [self bg_imageFromImage:compressImage inRect:CGRectMake((compressImage.size.width-size.width)/2, (compressImage.size.height-size.height)/2, size.width, size.height)];
        }
    }
    return nil;
}

/**
 *根据给定的size的宽高比自动判断截取位置,进行图片截取,截取后缩放图片到预定尺寸。
 * UIImage image 原始的图片
 * CGSize size 截取图片的size
 */
+(UIImage *)bg_clipImageFromCenter:(UIImage *)image toRect:(CGSize)size{
    //被切图片宽比例比高比例小 或者相等，以图片宽进行放大
    if (image.size.width*size.height <= image.size.height*size.width) {
        //以被剪裁图片的宽度为基准，得到剪切范围的大小
        CGFloat width  = image.size.width;
        CGFloat height = image.size.width * size.height / size.width;
        
        // 调用剪切方法
        // 这里是以中心位置剪切，也可以通过改变rect的x、y值调整剪切位置
        UIImage*clipImage = [self bg_imageFromImage:image inRect:CGRectMake(0, (image.size.height -height)/2, width, height)];
        return [CompputeTools bg_image:clipImage scaleToSize:size];
    }else{ //被切图片宽比例比高比例大，以图片高进行剪裁
        
        // 以被剪切图片的高度为基准，得到剪切范围的大小
        CGFloat width  = image.size.height * size.width / size.height;
        CGFloat height = image.size.height;
        
        // 调用剪切方法
        // 这里是以中心位置剪切，也可以通过改变rect的x、y值调整剪切位置
        UIImage*clipImage =  [self bg_imageFromImage:image inRect:CGRectMake((image.size.width -width)/2, 0, width, height)];
        return [CompputeTools bg_image:clipImage scaleToSize:size];
    }
    return nil;
}

+(NSString *)imageNameWithChannelCode:(NSString *)channelCode{
//    NSString *imageName;
//    if ([channelCode isEqualToString:ChannelCode_WeiXin]) {
//        imageName = @"weixin";
//    }else if ([channelCode isEqualToString:ChannelCode_WeiBo]) {
//        imageName = @"icon_sina";
//    }else if ([channelCode isEqualToString:ChannelCode_OcxVoice]) {
//        imageName = @"icon_webcall";
//    }else if ([channelCode isEqualToString:ChannelCode_OnlineVideo]) {
//        imageName = @"video_icon";
//    }else if ([channelCode isEqualToString:ChannelCode_Email]) {
//        imageName = @"icon_mail";
//    }else if ([channelCode isEqualToString:ChannelCode_KeFu]) {
//        imageName = @"icon_tx3";
//    }else if([channelCode isEqualToString:ChannelCode_QQ]){
//        imageName = @"icon_qq";
//    }else if([channelCode isEqualToString:ChannelCode_QiTa]){
//        imageName = @"icon_default";
//    }else if([channelCode isEqualToString:ChannelCode_YiXin]){
//        imageName = @"channel_yixin";
//    }else{
//        imageName = @"icon_default";
//    }
//    return imageName;
}

+(BOOL)isDefinedMsgType:(NSString *)msgType{
    BOOL isDefined = NO;
//    NSArray *definedMsgType = @[DefMsgType_text,DefMsgType_image,DefMsgType_email,DefMsgType_location,DefMsgType_ocxVoice,DefMsgType_onlineVideo,DefMsgType_voice,DefMsgType_shortvideo];
//    for (NSString *definedType in definedMsgType) {
//        if ([definedType isEqualToString:msgType]) {
//            isDefined = YES;
//        }
//    }
    return isDefined;
}

+(BOOL)isDefinedChannelCode:(NSString *)channelCode{
//    BOOL isDefined = NO;
//    NSArray *definedChannelCode = DefChannelCodeArray;
//    for (NSString *definedCode in definedChannelCode) {
//        if ([definedCode isEqualToString:channelCode]) {
//            isDefined = YES;
//            break;
//        }
//    }
//    return isDefined;
}

+(BaseViewController *)getCurrectController{
    return currectController;
}

+(void)setCurrectController:(BaseViewController *) controller{
    currectController =controller;
}

+ (NSString *)secondsFormatted:(NSInteger)totalSeconds{
    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds / 60) % 60;
    NSInteger hours = totalSeconds / 3600;
    if(hours){
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",hours, minutes, seconds];
    }
    return [NSString stringWithFormat:@"%02ld:%02ld", minutes, seconds];
}

+ (NSString *)secondsFormattedToHMS:(NSInteger)totalSeconds{
    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds / 60) % 60;
    NSInteger hours = totalSeconds / 3600;
    if(hours){
        return [NSString stringWithFormat:@"%ld小时%ld分%ld秒",hours, minutes, seconds];
    }
    if(minutes){
        return [NSString stringWithFormat:@"%ld分%ld秒", minutes, seconds];
    }
    return [NSString stringWithFormat:@"%ld秒", seconds];
}

+(UIImage *)screenShotFromView:(UIView *)fromView{
    //    UIGraphicsBeginImageContext(fromView.bounds.size);
    //    CGContextRef context = UIGraphicsGetCurrentContext();
    //    [fromView.layer renderInContext:context];
    //    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    //    UIGraphicsEndImageContext();
    //    return theImage;
    
    //    CGImageRef UIGetScreenImage();
    //    CGImageRef img = UIGetScreenImage();
    //    UIImage *scImage = [UIImage imageWithCGImage:img];
    //    UIImageWriteToSavedPhotosAlbum(scImage, nil, nil, nil);
    //    return scImage;
    CGFloat h = fromView.bounds.size.height;
    CGRect r = CGRectMake(0, 0, fromView.bounds.size.width, h);
    UIImage *img;
    UIGraphicsBeginImageContextWithOptions(fromView.bounds.size, YES, 0.0);
    [fromView drawViewHierarchyInRect:r afterScreenUpdates:NO];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
    
    return img;
}

@end
