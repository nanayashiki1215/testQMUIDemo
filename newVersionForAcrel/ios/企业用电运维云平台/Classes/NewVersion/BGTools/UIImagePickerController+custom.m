//
//  NSObject+custom.m
//  OpenPhotos
//
//  Created by Allen Gao on 2019/1/21.
//  Copyright © 2019 Allen Gao. All rights reserved.
//

#import "UIImagePickerController+custom.h"
#import <objc/runtime.h>

@implementation UIImagePickerController (custom)

static BOOL isDelegateMethodHooked = false;

+ (void)hookDelegate {
    SEL swizzledSEL = @selector(swizzled_imagePickerController:didFinishPickingMediaWithInfo:);
    SEL originSEL = @selector(imagePickerController:didFinishPickingMediaWithInfo:);
    
    if (swizzledSEL && originSEL) {
        Class class = NSClassFromString(@"WKFileUploadPanel");
        hook_delegateMethod(class, originSEL, [UIImagePickerController class], swizzledSEL, swizzledSEL);
    }
}

+ (void)unHookDelegate {
    SEL swizzledSEL = @selector(swizzled_imagePickerController:didFinishPickingMediaWithInfo:);
    SEL originSEL = @selector(imagePickerController:didFinishPickingMediaWithInfo:);
    Class class = NSClassFromString(@"WKFileUploadPanel");
    unHook_delegateMethod(class,swizzledSEL,originSEL);
}

/**
 替换代理方法的实现
 */
static void hook_delegateMethod(Class originalClass, SEL originalSel, Class replacedClass, SEL replacedSel, SEL noneSel)  {
    //原实例方法
    Method originalMethod = class_getInstanceMethod(originalClass, originalSel);
    //替换的实例方法
    Method replacedMethod = class_getInstanceMethod(replacedClass, replacedSel);
    
    if (!originalMethod) {// 如果没有实现 delegate 方法，则手动动态添加
        Method noneMethod = class_getInstanceMethod(replacedClass, noneSel);
        class_addMethod(originalClass, originalSel, method_getImplementation(noneMethod), method_getTypeEncoding(noneMethod));
        return;
    }
    
    // 向实现 delegate 的类中添加新的方法
    class_addMethod(originalClass, replacedSel, method_getImplementation(replacedMethod), method_getTypeEncoding(replacedMethod));
    
    // 重新拿到添加被添加的 method, 因为替换的方法已经添加到原类中了, 应该交换原类中的两个方法
    Method newMethod = class_getInstanceMethod(originalClass, replacedSel);
    if(!isDelegateMethodHooked && originalMethod && newMethod) {
        method_exchangeImplementations(originalMethod, newMethod);// 实现交换
        isDelegateMethodHooked = YES;
    }
}

/**
 恢复代理方法的实现
 */
static void unHook_delegateMethod(Class originalClass, SEL originalSel, SEL replacedSel){
    if(isDelegateMethodHooked) {
        Method originalMethod = class_getInstanceMethod(originalClass, originalSel);
        Method replacedMethod = class_getInstanceMethod(originalClass, replacedSel);
        if (originalMethod && replacedMethod){
            // 重新拿到添加被添加的 method,这里是关键(注意这里 originalClass, 不 replacedClass), 因为替换的方法已经添加到原类中了, 应该交换原类中的两个方法
            Method newMethod = class_getInstanceMethod(originalClass, replacedSel);
            method_exchangeImplementations(originalMethod, newMethod);// 实现交换
            isDelegateMethodHooked = NO;
        }
    }
}

/**
 替换的代理实现

 @param picker picker
 @param info info
 */
- (void)swizzled_imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    NSString *imageURLKey = @"UIImagePickerControllerImageURL";
    NSString *imageKey = @"UIImagePickerControllerOriginalImage";
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:info];
    
    //UIImagePickerControllerReferenceURL设为空是关键一步。
    //相机是不会有asset URL,即referenceURL会为空，所以这里不需要传asset URL，直接传图片对象即可。
    //让WKFileUploadPanel以为从相册来的图片也是从相机来的
    [dict setValue:nil forKey:@"UIImagePickerControllerReferenceURL"];
    UIImage *originImage = [dict valueForKey:imageKey];;
    NSString *picTime = info[UIImagePickerControllerMediaMetadata][@"{TIFF}"][@"DateTime"];
    UIImage *targetImage = [UIImagePickerController compressImage:originImage andAddTime:picTime];
    
    
    NSString *imageFilePath = [UIImagePickerController imageFilePath];
    [UIImagePickerController saveToSandBox:targetImage filePath:imageFilePath];
    NSURL *targetImageURL = [NSURL fileURLWithPath:imageFilePath];
    [dict setObject:targetImage forKey:imageKey];
    [dict setObject:targetImageURL forKey:imageURLKey];
    
    //方法的实现已经通过Method swizling交换了，所以这里调用的是原始实现
    [self swizzled_imagePickerController:picker didFinishPickingMediaWithInfo:dict];
}

+ (void)saveToSandBox:(UIImage *)image filePath:(NSString *)path {
    NSData *data = UIImagePNGRepresentation(image);
    [data writeToFile:path atomically:YES];
}

+ (NSString *)imageFilePath {
    NSArray *documentDirectories =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                        NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    dateFormater.dateFormat = @"yyyyMMddHHmmss";
    NSString *dateString = [dateFormater stringFromDate:date];
    NSString *fileName = [dateString stringByAppendingString:@".png"];
    return [documentDirectory stringByAppendingPathComponent:fileName];
}

/**
 压缩图片
 
 @param image 原始图片
 @return 加工完成的图片
 */
+ (UIImage *)compressImage:(UIImage *)image andAddTime:(NSString *)showTime{
//    NSData *data = UIImageJPEGRepresentation(image, 0.01);
    UIImage *resultImage = [self imageCompressWithSimple:image];
    UIImage *waterPoint = [self addText:resultImage text:showTime];
    return waterPoint;
}

+ (UIImage*)imageCompressWithSimple:(UIImage*)image{
    CGSize size = image.size;
    CGFloat scale = 1.0;
    //TODO:KScreenWidth屏幕宽
    
    CGFloat KScreenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat KScreenHeight = [UIScreen mainScreen].bounds.size.height;
    
    if (size.width > KScreenWidth || size.height > KScreenHeight) {
        if (size.width > size.height) {
            scale = KScreenWidth / size.width;
        }else {
            scale = KScreenHeight / size.height;
        }
    }
    CGFloat width = size.width;
    CGFloat height = size.height;
    CGFloat scaledWidth = width * scale;
    CGFloat scaledHeight = height * scale;
    CGSize secSize =CGSizeMake(scaledWidth, scaledHeight);
    //TODO:设置新图片的宽高
    UIGraphicsBeginImageContext(secSize); // this will crop
    [image drawInRect:CGRectMake(0,0,scaledWidth,scaledHeight)];
    UIImage* newImage= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)addText:(UIImage *)img text:(NSString *)mark {
    if (mark.length != 0) {
        NSArray * ar = [mark componentsSeparatedByString:@" "];
        NSString *yearStr = ar.firstObject;
        NSString *timeStr = ar.lastObject;
        yearStr = [[yearStr stringByReplacingOccurrencesOfString:@":" withString:@"-"] stringByAppendingString:@" "];
        mark = [yearStr stringByAppendingString:timeStr];
    } else {
        //将时间戳转换成时间
        NSDate *date = [NSDate date];
        //    限定格式
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd  hh:mm:ss"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"china"];//时区名字或地区名字
        [formatter setTimeZone:timeZone];
        mark = [formatter stringFromDate:date];
    }
   
    int w = img.size.width;
    int h = img.size.height;
//    UIGraphicsBeginImageContext(img.size);
    UIGraphicsBeginImageContextWithOptions(img.size, NO, 0);
    [img drawInRect:CGRectMake(0, 0, w, h)];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:30],
//                                NSParagraphStyleAttributeName: paragraphStyle,
                                NSForegroundColorAttributeName : [UIColor redColor]
//                                NSTextEffectAttributeName: NSTextEffectLetterpressStyle
                                };
    [mark drawInRect:CGRectMake(10, h - 50, w-10, 50) withAttributes:attribute];
    
    //添加水印文字
    UIImage *aImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return aImage;
}
@end
