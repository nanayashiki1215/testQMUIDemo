//
//  BGFileUtils.m
//  BusinessUCSDK
//
//  Created by feitian on 2019/1/30.
//  Copyright © 2019 com.Ideal. All rights reserved.
//

#import "BGFileUtils.h"

@implementation BGFileUtils

+(NSString *)displayFileSize:(NSInteger )size{
    NSString *fizesize = nil;
    if(size > 1024000){
        fizesize = [NSString stringWithFormat:@"%.1f MB",(CGFloat)size/1024/1024];
    }else{
        fizesize = [NSString stringWithFormat:@"%.1f KB",(CGFloat)size/1024];
    }
    return fizesize;
}

//缩略图
+(NSString *)fileThumbnailImageByFileName:(NSString *)fileName{
    NSString *fileType = [[fileName componentsSeparatedByString:@"."] lastObject];
    return [BGFileUtils fileThumbnailImageByFileType:fileType];
}

//缩略图
+(NSString *)fileThumbnailImageByFileType:(NSString *)fileType{
    if (fileType == nil) {
        return @"soft_12";
    }
    if ([fileType isEqualToString:@"txt"]) {
        return @"soft_12";
    }else if ([fileType isEqualToString:@"pdf"]){
        return @"soft_14";
    }else if ([fileType isEqualToString:@"html"]){
        return @"soft_12";
    }else if ([fileType isEqualToString:@"docx"]){
        return @"soft_06";
    }else if ([fileType isEqualToString:@"doc"]){
        return @"soft_06";
    }else if ([fileType isEqualToString:@"ppt"]){
        return @"soft_10";
    }else if ([fileType isEqualToString:@"pptx"]){
        return @"soft_10";
    }else if ([fileType isEqualToString:@"xls"]){
        return @"soft_08";
    }else if ([fileType isEqualToString:@"xlsx"]){
        return @"soft_08";
    }else if ([fileType isEqualToString:@"mp3"] || [fileType isEqualToString:@"wav"] || [fileType isEqualToString:@"ape"] || [fileType isEqualToString:@"aac"]){
        return @"soft_16";
    }else if ([fileType isEqualToString:@"mp4"] || [fileType isEqualToString:@"wmv"] || [fileType isEqualToString:@"avi"] || [fileType isEqualToString:@"mpeg"] || [fileType isEqualToString:@"rmvb"] ||[fileType isEqualToString:@"rm"]||[fileType isEqualToString:@"MOV"]){
        return @"soft_18";
    }else if ([fileType isEqualToString:@"png"] || [fileType isEqualToString:@"jpg"] ||[fileType isEqualToString:@"jpeg"] ||[fileType isEqualToString:@"bmp"]){
        return @"soft_03";
    }else if([fileType isEqualToString:@"ipa"] || [fileType isEqualToString:@"apk"]){
        return @"soft_07";
    }else{
        return @"soft_12";
    }
}
@end
