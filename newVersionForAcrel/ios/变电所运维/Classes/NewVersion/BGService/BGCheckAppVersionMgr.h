//
//  BGCheckAppVersionMgr.h
//  变电所运维
//
//  Created by Acrel on 2019/5/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^BGCheckAppVersionBlock)(NSString *respObjc);
@interface BGCheckAppVersionMgr : NSObject

@property (copy) BGCheckAppVersionBlock  checkBlock;
+ (BGCheckAppVersionMgr *)sharedInstance;
- (void)isUpdataApp:(NSString *)appId andCompelete:(BGCheckAppVersionBlock)checkSuccess;

@end

NS_ASSUME_NONNULL_END
