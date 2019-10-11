//
//  BGQMFeedBackViewController.h
//  变电所运维
//
//  Created by Acrel on 2019/8/1.
//

#import <QMUIKit/QMUIKit.h>
#import "BGShowUrlModel.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, SendMegType) {
    SendMegTypeDefult,
    SendMegTypeText,
    SendMegTypeImage,
    SendMegTypeTextAndImag,
    SendMegTypeUrl,
    SendMegTypeTextAndUrl,
};
@interface BGQMFeedBackViewController : QMUICommonTableViewController
@property(nonatomic, assign)SendMegType sendMsgType;
@property(nonatomic, strong)BGShowUrlModel *showUrlModel;
@property(nonatomic, copy)void(^sendCompletionBlock)(id objc);

-(void)setSendCompletionBlock:(void (^)(id))sendCompletionBlock;
@end

NS_ASSUME_NONNULL_END
