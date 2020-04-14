//
//  BGNetworkDefine.h
//  变电所运维
//
//  Created by Acrel on 2019/6/5.
//

#ifndef BGNetworkDefine_h
#define BGNetworkDefine_h

///开发环境／生产环境
#if 0
//生产环境
//#define JPushAppKey @"e0274c3719b620b1dd586d32"
//#define JPushChannel @"ADH"
//#define JPushIsProduction YES
#define UseMoxtra YES
#define UseAgora NO

#elif 1
//开发环境
#define BASE_URL [GetBaseURL stringByAppendingString:BaseFileURLString]
#define GetBaseURL [NSString stringWithFormat:@"%@",[BGNetworkDefine getBaseUslString]]
#define DefaultBaseUrlString @"http://116.236.149.165:8090"
#define BaseFileURLString @"/SubstationWEBV2/"
#define UseMoxtra YES
#define UseAgora NO
//发版最新版本
#define ISVersionNo @"v5"
//轨迹记录测试地址
#define DominAddress @"http://116.236.149.165:8090"

#endif

//登录接口 post 请求
//#define BGUserLoginAddress NSLocalizedString(@"/SubstationWEBV2/user/login", @"")
#define BGUserLoginAddress @"user/login"

#define BGUPdateAddress @"sys/getWebAPIVersion"

//
#define BGGetRootMenu @"/getRootMenu"

//变电所列表 get 请求
#define getSubstationListByUser @"/getSubstationListByUser?pageNo=1&pageSize=999"

//变电所详情Ui接口
//#define getSubinfoVo @"/getSubinfoVo"
#define getSubinfoVo @"/getSubinfoVoNew"

//主页树形子节点接口
#define getbgSubinfoVoByPid @"/getSubinfoVoByPid"

//视频列表地址
#define getVideoInfoList @"/getVideoInfoList"

//获取头像图片地址
#define APPImageIconADS @"/fileSystem/app/icon/"
#define GetAPPImageBaseURL [NSString stringWithFormat:@"/%@/",[BGNetworkDefine getAppImageUrlstr]]
#define getImageIconADS [GetBaseURL stringByAppendingString:GetAPPImageBaseURL]

//获取系统配置的图片
#define SystemImageIconADS @"/fileSystem/app/icon/"
#define GetSystemImageBaseURL [NSString stringWithFormat:@"/%@/",[BGNetworkDefine getSystemImageUrlstr]]
#define getSystemIconADS [GetBaseURL stringByAppendingString:GetSystemImageBaseURL]

//获取设备管理的图片


#endif /* BGNetworkDefine_h */

@interface BGNetworkDefine : NSObject

+(NSString *)getBaseUslString;
+(NSString *)getAppImageUrlstr;
+(NSString *)getSystemImageUrlstr;


@end
