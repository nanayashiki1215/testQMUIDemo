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
@property(nonatomic,copy)NSString *privateUnreadNumStr;/**< 推送未读数 */
@property(nonatomic,copy)NSString *emasAppKey;/**< 推送AppKey */
@property(nonatomic,copy)NSString *emasAppSecret;/**< 推送AppSecret */


//获取单例
+(instancetype)manager;

@end
