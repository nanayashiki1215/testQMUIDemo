//
//  BGImageUtils.m
//  BusinessUCSDK
//
//  Created by feitian on 2018/4/9.
//  Copyright © 2018年 com.Ideal. All rights reserved.
//

#import "BGImageUtils.h"

@implementation BGImageUtils

#pragma -mark自定义聊天页面图片显示大小
+ (CGSize)bg_chatImageDisplaySizeWithOriginalSize:(CGSize)originalSize{
    CGFloat width = originalSize.width;
    CGFloat height = originalSize.height;
    CGFloat middleNum = 405;
    if (width == 0 || height == 0) {
        return CGSizeMake((middleNum*ImageSizeRate)/3.0, (middleNum*ImageSizeRate)/3.0);
    }
    CGFloat lowNum = 204;
    CGFloat bigNum = 510;
    CGFloat ratio = width / height;
    //根据宽高比来设置外框的 size
    if (ratio < 0.4 ){
        width = lowNum; //这是从微信截图的长度最后需要同一除以 3
        height = bigNum;
    }else if(ratio >= 0.4 && ratio <= 0.5){
        width = lowNum;
        height = lowNum/ratio;
    } else if(ratio > 0.5 && ratio < 1) {
        width = middleNum * ratio;
        height = middleNum;
    } else if(ratio >= 1 && ratio < 1/0.5) { //和前面的宽高转置
        //小图处理 待测试
        if (height * 2 < middleNum * (1/ratio) ) {
            height = height * 2;
            width = width * 2;
        }else{
            height = middleNum * (1/ratio);
            width = middleNum;
        }
    } else if (ratio >= 1/0.5 && ratio < 1/0.4) {
        height = lowNum;
        width = lowNum / (1/ratio);
    } else if (ratio >= 1/0.4) {
        height = lowNum; //这是从微信截图的长度最后需要同一除以 3
        width = bigNum;
    }
    height = (height*ImageSizeRate)/3.0;
    width = (width*ImageSizeRate)/3.0;
    return CGSizeMake(width, height);
}

+ (CGSize)setimageHeightWithImage:(UIImage *)image{
    if (image.size.width > 150) {
        CGSize size = CGSizeMake(150, 0);
        size.height = 150 * image.size.height / image.size.width;
        return size;
    }else if(image.size.width > 60 && image.size.width < 150){
        CGSize size = CGSizeMake(60, (60*image.size.height/image.size.width));
        return size;
    }else{
        return image.size;
    }
    
}

@end
