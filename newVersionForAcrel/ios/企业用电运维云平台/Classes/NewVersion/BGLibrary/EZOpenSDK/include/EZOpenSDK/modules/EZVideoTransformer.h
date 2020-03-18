//
//  EZVideoTransformer.h
//  EZOpenSDK
//
//  Created by yuqian on 2019/6/17.
//  Copyright © 2019 Ezviz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    
    EZVideoTransformerTypeMP4,
    
} EZVideoTransformerType;

@interface EZVideoTransformer : NSObject

/**
 本地PS文件转换为MP4文件
 */
+ (void)videoTransFormerPSPath:(NSString *)psPath
                        toPath:(NSString *)targetPath
                          type:(EZVideoTransformerType)type
                       withKey:(NSString *)key
                     succBlock:(void (^)())succBlock
                  processBlock:(void(^)(int rate))processBlock
                     failBlock:(void(^)(int errCode))failBlock;

@end

NS_ASSUME_NONNULL_END
