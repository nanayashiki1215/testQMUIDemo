//
//  BGUIWebViewController.h
//  变电所运维
//
//  Created by Acrel on 2019/5/21.
//

#import <UIKit/UIKit.h>
#import "JXCategoryListCollectionContainerView.h"

NS_ASSUME_NONNULL_BEGIN

//定义枚举类型
typedef enum {
    showWebTypeAssets= 0,
    showWebTypeDevice,
    showWebTypeAlarm,
    showWebTypeAlarmWithTab,
    showWebFromMsgNotif //从消息通知页面跳入
} showWebType;

@interface BGUIWebViewController : UIViewController<JXCategoryListCollectionContentViewDelegate,UIScrollViewDelegate>

@property (nonatomic,strong) NSString *localUrlString;
@property (nonatomic,strong) NSString *onlineUrlString;
@property (nonatomic,assign) BOOL isUseOnline;
@property (nonatomic,assign) BOOL isAllowXZoom;//允许缩放
@property (nonatomic,assign) BOOL isTabbarHidden;
@property (nonatomic,copy) NSString *titleName;
@property (nonatomic,copy) NSString *urlParams;
@property (nonatomic,assign) NSInteger showWebType; //展示类型
@property (nonatomic,copy) NSString *menuId;//待查询的菜单ID
//从报警页面跳入
@property (nonatomic,copy) NSString *isFromAlarm;
//从文件页面跳入
@property (nonatomic,copy) NSString *isFromFile;
@property(nonatomic,strong)NSData *Filelocaldata;//传入文件
@property(nonatomic,strong)NSString *downloadFileName;
@property(nonatomic,strong)NSString *fileLocalUrlPath;//本地文件路径

@end

NS_ASSUME_NONNULL_END
