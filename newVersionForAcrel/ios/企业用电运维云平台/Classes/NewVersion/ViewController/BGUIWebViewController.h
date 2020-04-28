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
    showWebTypeDevice,//设备档案、两个记录、文档管理
    showWebTypeDeviceForYY,//待办事项 开启关闭鹰眼
    showWebTypeAlarm,//报警页面
    showWebTypeAlarmWithTab,//报警tab页面
    showWebFromMsgNotif, //从消息通知页面跳入
    showWebTypePolicy,//隐私政策 显示navbar 可通用
    showWebTypeReport,//用户报告
    showWebTypeZYSusView,//轨迹 小圆点
    showWebTypeVersion,//版本介绍
    showWebTypeWithPush,//推送跳转 含轨迹球
    showWebTypeWithPushNoYY,//推送跳转 不含轨迹球
} showWebType;

@interface BGUIWebViewController : UIViewController<JXCategoryListCollectionContentViewDelegate,UIScrollViewDelegate,BTKTraceDelegate>

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
//url拼接参数
@property(nonatomic,strong)NSString *pathParamStr;//拼接url参数

@end

NS_ASSUME_NONNULL_END
