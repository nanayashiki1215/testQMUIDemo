//
//  BGUIWebViewController.h
//  变电所运维
//
//  Created by Acrel on 2019/5/21.
//

#import <UIKit/UIKit.h>
#import "JXCategoryListCollectionContainerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface BGUIDeviceWebViewController : UIViewController<JXCategoryListCollectionContentViewDelegate,UIScrollViewDelegate>

@property (nonatomic,strong) NSString *localUrlString;
@property (nonatomic,strong) NSString *onlineUrlString;
@property (nonatomic,assign) BOOL isUseOnline;
@property (nonatomic,assign) BOOL isAllowXZoom;//允许缩放
@end

NS_ASSUME_NONNULL_END
