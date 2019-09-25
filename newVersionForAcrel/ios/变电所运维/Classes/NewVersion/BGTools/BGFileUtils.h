//
//  BGFileUtils.h
//  BusinessUCSDK
//
//  Created by feitian on 2019/1/30.
//  Copyright © 2019 com.Ideal. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BGFileUtils : NSObject

+(NSString *)displayFileSize:(NSInteger )size;

//缩略图
+(NSString *)fileThumbnailImageByFileName:(NSString *)fileName;

//缩略图
+(NSString *)fileThumbnailImageByFileType:(NSString *)fileType;

@end

NS_ASSUME_NONNULL_END
