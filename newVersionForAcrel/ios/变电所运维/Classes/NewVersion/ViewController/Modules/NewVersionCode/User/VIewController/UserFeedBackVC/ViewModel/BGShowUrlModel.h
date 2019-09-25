//
//  BGShowUrlModel.h
//  变电所运维
//
//  Created by Acrel on 2019/8/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BGShowUrlModel : NSObject
@property  NSString *msgId;//发布消息内容,显示朋友圈时使用
@property  NSString *iconString;
@property  NSString *urlString;
@property  NSString *textContent;
@property  BOOL reloadInfo;//设置成YES将会刷新标题和icon

@end

NS_ASSUME_NONNULL_END
