//
//  BGDistributeMessage.h
//  企业用电运维云平台
//
//  Created by Acrel on 2019/11/28.
//

#import <Foundation/Foundation.h>
#import "LZLPushMessage.h"

NS_ASSUME_NONNULL_BEGIN

//消息推送管理类
@interface BGDistributeMessage : NSObject

+(void)distributeMessage:(LZLPushMessage *)message;

@end

NS_ASSUME_NONNULL_END
