//
//  UserManager.h
//  CloudService
//
//  Created by feitian on 15/11/18.
//  Copyright © 2015年 com.Ideal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BGQMSubstationModel.h"

@interface UserManager : NSObject{
    NSString *_account;//登录工号
    NSString *_password;//密码
    NSArray *_FunURLArray;
    BOOL _isSavePwd;
    BOOL _autoLogin;
    NSString *_imageUrl;
    NSArray *_subList;
    NSDictionary *_singleSubFullData;
    NSDictionary *_rootMenuData;
    NSString *_fsubID;
    NSString *_fsubName;
    NSString *_token;
    NSString *_versionNo;
    NSString *_bgnickName;
    NSString *_bgtelphone;
    NSString *_bgaddress;
    NSString *_bguserId;
    NSString *_homefMenuid;
    NSArray *_selectlanageArr;
    NSArray *_versionArr;
    NSString *_orderListUrl;
    NSString *_privateUnreadNumStr;
    NSDictionary *_homeALLFullData;
    NSString *_emasAppKey;
    NSString *_emasAppSecret;
    NSString *_alarmUnreadNumStr;
    NSArray *_orderUrlArray;
    NSDictionary *_yytjBaiduDic;
    BOOL _isOpenTjBaidu;
    BOOL _isContinueShowTJ;
    NSString *_startTJtime;
    NSString *_taskID;
    NSDictionary *_loginData;
    NSString *_userIdForAlias;
    NSString *_energyDns;
    NSString *_energyAccountNum;
    NSString *_energyPassword;
    NSString *_versionURLForEnergy;
    BOOL _isOpenBoxInApp;
    BOOL _isAlwaysUploadPosition;
    BOOL _isShowNewVersion;
    NSString *_appIndexSet;
    NSArray *_platformList;
}

@property(nonatomic,copy)NSString *account;/**< 用户名 */
@property(nonatomic,copy)NSString *password;/**< 密码 */
@property(nonatomic,copy)NSString *orderListUrl;/**< 域名地址 */

@property(nonatomic,copy)NSString *lastVersion;
@property(nonatomic,assign)BOOL isSavePwd;
@property(nonatomic,assign)BOOL autoLogin;
@property(nonatomic,strong)NSArray *FunURLArray;/**< 获取权限数组 */
@property(nonatomic,copy)NSString *tenantCode;

//刷新主页数据
@property(nonatomic,strong)NSArray *usuallyWordUserinfo;
@property(nonatomic,strong)NSArray *linkList;//个人链接
@property(nonatomic,strong)NSArray *functionsPrefixArray;/**< 用于辨别是否有数据，显示小红点 数组 */

@property(nonatomic,strong)NSArray *privateChatListArray;//私聊的会话列表

//20190611
@property (nonatomic,strong) NSDictionary *rootMenuData;//全量菜单数据
@property (nonatomic,strong) NSArray *subList;//变电站列表
//0190614
@property (nonatomic,strong) NSDictionary *singleSubFullData;//单个变电站全量数据
@property (nonatomic,copy) NSString *fsubID;//变电所id
@property (nonatomic,copy) NSString *fsubName;//变电所id
@property (nonatomic,copy) NSString *token;
@property (nonatomic,copy) NSString *versionNo;
//个人信息
@property(nonatomic,copy)NSString *imageUrl;//头像
@property(nonatomic,copy)NSString *bgnickName;//昵称
@property(nonatomic,copy)NSString *bgtelphone;//手机
@property(nonatomic,copy)NSString *bgaddress;//地址
@property(nonatomic,copy)NSString *bguserId;//用户id 登录时获取
@property(nonatomic,copy)NSString *homefMenuid;//首页Menuid
@property(nonatomic,copy)NSArray *selectlanageArr;//切换语言Arr
@property(nonatomic,copy)NSArray *versionArr;//版本描述与版权所有

//20191028
@property (nonatomic,strong) NSDictionary *homeALLFullData;//首页配置全量数据

//20191118
@property(nonatomic,copy)NSString *privateUnreadNumStr;/**< 任务 工作推送未读数 */
@property(nonatomic,copy)NSString *alarmUnreadNumStr;/**< 报警推送未读数 */
@property(nonatomic,copy)NSString *emasAppKey;/**< 推送AppKey */
@property(nonatomic,copy)NSString *emasAppSecret;/**< 推送AppSecret */

//用于存档ip地址记录
@property(nonatomic,copy)NSArray *orderUrlArray;

//用于存取百度鹰眼轨迹配置
@property(nonatomic,copy)NSDictionary *yytjBaiduDic;
@property(nonatomic,assign)BOOL isOpenTjBaidu;//是否开启百度鹰眼功能
@property(nonatomic,assign)BOOL isContinueShowTJ;//是否持续显示悬浮球
@property(nonatomic,copy)NSString *startTJtime;/**< 轨迹开始时间 */
@property(nonatomic,copy)NSString *taskID;/**< 与轨迹捆绑的任务ID */
@property(nonatomic,strong)NSDictionary *loginData;//登录全量数据
//阿里云
@property(nonatomic,strong)NSString *userIdForAlias;//用于注册推送的别名alias
//能耗
@property(nonatomic,strong)NSString *energyDns;//能耗管理地址
@property(nonatomic,strong)NSString *energyAccountNum;//登录名
@property(nonatomic,strong)NSString *energyPassword;//密码
@property(nonatomic,strong)NSString *versionURLForEnergy;//能耗管理拼接地址
//展示应用内收到消息
@property(nonatomic,assign)BOOL isOpenBoxInApp;//是否展示
//是否持续定位
@property(nonatomic,assign)BOOL isAlwaysUploadPosition;
//展示最新版本更新内容
@property(nonatomic,assign)BOOL isShowNewVersion;
//首页展示管理
@property(nonatomic,strong) NSString *appIndexSet;
//平台报表 12/29
@property (nonatomic,strong) NSArray *platformList;

//获取单例
+(instancetype)manager;

@end
