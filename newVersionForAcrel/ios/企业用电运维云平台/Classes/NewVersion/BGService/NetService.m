//
//  NetService.m
//  IdealCallCenter
//
//  Created by feitian on 15/9/2.
//  Copyright © 2015年 com.Ideal. All rights reserved.
//

#import "NetService.h"
#import "BGLogSecondViewController.h"
#import "BGLogFirstViewController.h"
#import "CustomNavigationController.h"
#import "YYServiceManager.h"
#import <CloudPushSDK/CloudPushSDK.h>
#import <CoreLocation/CoreLocation.h>
#import <BMKLocationKit/BMKLocationComponent.h>
#import "SKControllerTools.h"

@interface NetService ()<BMKLocationManagerDelegate>
@property (nonatomic, strong) BMKLocationManager *locationManager; //定位对象

@end

@implementation NetService

static NetService *_instance;

#pragma mark - post接口

+ (instancetype)shareInstance
{
    if (!_instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[NetService alloc] init];
        });
    }
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (void)bg_postWithPath:(NSString *)path params:(NSDictionary *)params success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail{
    NSMutableDictionary * mutParams = [NSMutableDictionary dictionaryWithDictionary:params];
//    BGUserInfo *user = [BGUserInfo gettingLoginSuccessLastLogin];
//    NSString *tenantId = user.tenantId;
//    if ([tenantId notEmptyOrNull]) {
//        [mutParams setNotNullObject:tenantId ForKey:ktenantId];
//    }
    NSString *urlString = [BASE_URL stringByAppendingString:path];
    [NetService bg_httpPostWithPath:urlString params:mutParams success:^(id responseObject) {
        NSString *respCode = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespCode]];
        if ([respCode isEqualToString:k0000]) {
            if (Success) {
                Success(responseObject);
            }
        }else if ([respCode isEqualToString:@"5000"]){
            [self pushUpErrorMsg:responseObject];
            return ;
        }else{
//            NSString *respMsg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespMsg]];
            NSString *respMsg = [NSString stringWithFormat:@"%@",[NetService failCodeDic][respCode]];
            if (!respMsg || [respMsg isEqualToString:@"(null)"] || [respMsg isEqualToString:@"null"]) {
                respMsg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespMsg]];
                if (!respMsg) {
                    respMsg = @"未知错误";
                }
            }
            if (Fail) {
                if (respMsg) {
                    [MBProgressHUD showError:respMsg];
                }
                Fail(responseObject,respCode,respMsg);
            }
        }
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
        if (errorMsg) {
            [MBProgressHUD showError:errorMsg];
        }else{
            [MBProgressHUD showError:@"请求失败,请检查网络链接或域名地址"];
        }
        if (Fail) {
            Fail(nil,nil,nil);
        }
    }];
}

+ (void)bg_postWithTokenWithPath:(NSString *)path params:(NSDictionary *)params success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail{
    NSMutableDictionary * mutParams = [NSMutableDictionary dictionaryWithDictionary:params];
    //    BGUserInfo *user = [BGUserInfo gettingLoginSuccessLastLogin];
    //    NSString *tenantId = user.tenantId;
    //    if ([tenantId notEmptyOrNull]) {
    //        [mutParams setNotNullObject:tenantId ForKey:ktenantId];
    //    }
    UserManager *user = [UserManager manager];
    if (!user.versionNo) {
        return;
    }
    NSString *baseURL = [BASE_URL stringByAppendingString:user.versionNo];
    NSString *urlString = [baseURL stringByAppendingString:path];
    BGWeakSelf;
    [NetService bg_httpPostWithTokenWithPath:urlString params:mutParams success:^(id responseObject) {
        NSString *respCode = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespCode]];
                if ([respCode isEqualToString:k0000]) {
                    if (Success) {
                        Success(responseObject);
                    }
                }else if ([respCode isEqualToString:@"5000"]){
                    [weakSelf pushUpErrorMsg:responseObject];
                    return ;
                }else if([respCode isEqualToString:@"700"]){
                    NSString *token = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"token"]];
                    if(token.length>0){
                        [UserManager manager].token = token;
                        
                    }
                    return ;
                }else{
                    //            NSString *respMsg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespMsg]];
                    NSString *respMsg = [NSString stringWithFormat:@"%@",[NetService failCodeDic][respCode]];
                    if (!respMsg || [respMsg isEqualToString:@"(null)"] || [respMsg isEqualToString:@"null"]) {
                        respMsg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespMsg]];
                        if (!respMsg) {
                            respMsg = @"未知错误";
                        }
                    }
                    if (Fail) {
                        if (respMsg) {
                           [MBProgressHUD showError:respMsg];
                        }
                        Fail(responseObject,respCode,respMsg);
                    }
                }
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
        if (errorMsg) {
            [MBProgressHUD showError:errorMsg];
        }else{
            [MBProgressHUD showError:@"请求失败,请检查网络链接或域名地址"];
        }
        if (Fail) {
            Fail(nil,nil,nil);
        }
    }];
}
#pragma mark - 纯净版GET接口，不允许出现提示框,判断返回码，拼接URL地址等业务逻辑！！！
// get方法
+ (void)bg_getWithPath:(NSString *)path params:(NSDictionary *)params success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail {
    NSMutableDictionary * mutParams = [NSMutableDictionary dictionaryWithDictionary:params];
//    BGUserInfo *user = [BGUserInfo gettingLoginSuccessLastLogin];
//    NSString *tenantId = user.tenantId;
//    if ([tenantId notEmptyOrNull]) {
//        [mutParams setNotNullObject:tenantId ForKey:ktenantId];
//    }
    __weak __typeof(self)weakSelf = self;
    NSString *urlString = [BASE_URL stringByAppendingString:path];
    [NetService bg_httpGetWithPath:urlString params:mutParams success:^(id responseObject) {
        NSString *respCode = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespCode]];
        NSString *respMsg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespMsg]];
        //        k0000 成功
     
        if ([respMsg isEqualToString:@"Unauthorized"] || [respCode isEqualToString:@"600"]) {
            
            [weakSelf loginOut:respCode];
            return ;
        }else if([respCode isEqualToString:@"700"]){
            NSString *token = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"token"]];
            if(token.length>0){
                [UserManager manager].token = token;
            }
            return ;
        }else if ([respCode isEqualToString:@"5000"]){
            [self pushUpErrorMsg:responseObject];
            return ;
        }
        if ([respCode isEqualToString:k0000]) {
            if (Success) {
                Success(responseObject);
            }
        }else if ([respCode isEqualToString:@"410"]){
            if (Fail) {
                if (respMsg) {
                   [MBProgressHUD showError:respMsg];
                }
                Fail(responseObject,respCode,respMsg);
            }
        }
        else{
//            NSString *respMsg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespMsg]];
            respMsg = [NSString stringWithFormat:@"%@",[NetService failCodeDic][respCode]];
            if (!respMsg || [respMsg isEqualToString:@"(null)"] || [respMsg isEqualToString:@"null"]) {
                respMsg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespMsg]];
                if (!respMsg) {
                    respMsg = @"未知错误";
                }
            }
            if (Fail) {
                if (respMsg) {
                   [MBProgressHUD showError:respMsg];
                }
                Fail(responseObject,respCode,respMsg);
            }
        }
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
        if (errorMsg) {
            [MBProgressHUD showError:errorMsg];
        }else{
            [MBProgressHUD showError:@"请求失败,请检查网络链接或域名地址"];
        }
        if (Fail) {
            Fail(nil,nil,nil);
        }
    }];
}

// get update专用方法
+ (void)bg_getWithUpdatePath:(NSString *)path params:(NSDictionary *)params success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail {
    NSMutableDictionary * mutParams = [NSMutableDictionary dictionaryWithDictionary:params];
//    BGUserInfo *user = [BGUserInfo gettingLoginSuccessLastLogin];
//    NSString *tenantId = user.tenantId;
//    if ([tenantId notEmptyOrNull]) {
//        [mutParams setNotNullObject:tenantId ForKey:ktenantId];
//    }
    
    //最新更新接口
    NSString *urlString = [[@"http://www.acrelcloud.cn" stringByAppendingString:BaseFileURLString] stringByAppendingString:path];
    [NetService bg_httpGetWithPath:urlString params:mutParams success:^(id responseObject) {
//        NSString *respCode = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespCode]];
//        NSString *respMsg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespMsg]];
        //        k0000 成功
        //        401 token过期
//        if ([respMsg isEqualToString:@"Unauthorized"]) {
//            //
//            [self loginOut];
//        }
//        if ([respCode isEqualToString:k0000]) {

            if (Success) {
                if (!responseObject || responseObject == nil) {
                    return ;
                }
                Success(responseObject);
            }
//        }else{
////            NSString *respMsg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespMsg]];
//            respMsg = [NSString stringWithFormat:@"%@",[NetService failCodeDic][respCode]];
//            if (!respMsg || [respMsg isEqualToString:@"(null)"] || [respMsg isEqualToString:@"null"]) {
//                respMsg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespMsg]];
//                if (!respMsg) {
//                    respMsg = @"未知错误";
//                }
//            }
//            if (Fail) {
//                Fail(responseObject,respCode,respMsg);
//            }
//        }
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
//        if (errorMsg) {
//            [MBProgressHUD showError:errorMsg];
//        }else{
//            [MBProgressHUD showError:@"请求失败,请检查网络链接或域名地址"];
//        }
        if (Fail) {
            Fail(nil,nil,nil);
        }
    }];
}

 //测试联调接口
+ (void)bg_getWithTestPath:(NSString *)path params:(NSDictionary *)params success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail {
    NSMutableDictionary * mutParams = [NSMutableDictionary dictionaryWithDictionary:params];
//    BGUserInfo *user = [BGUserInfo gettingLoginSuccessLastLogin];
//    NSString *tenantId = user.tenantId;
//    if ([tenantId notEmptyOrNull]) {
//        [mutParams setNotNullObject:tenantId ForKey:ktenantId];
//    }
    //测试联调接口
//    NSString *urlString = [[DominAddress stringByAppendingString:BaseFileURLString] stringByAppendingString:path];
    NSString *urlString = [[DominAddress stringByAppendingString:BaseFileURLString] stringByAppendingString:path];
    [NetService bg_httpGetWithPath:urlString params:mutParams success:^(id responseObject) {
            if (Success) {
                if (!responseObject || responseObject == nil) {
                    return ;
                }
                Success(responseObject);
            }
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
        if (errorMsg) {
//            [MBProgressHUD showError:errorMsg];
        }else{
//            [MBProgressHUD showError:@"请求失败,请检查网络链接或域名地址"];
        }
        if (Fail) {
            Fail(respObjc,errorCode,nil);
        }
    }];
}

// 带头get方法
+ (void)bg_getWithTokenWithPath:(NSString *)path params:(NSDictionary *)params success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail {
    NSMutableDictionary * mutParams = [NSMutableDictionary dictionaryWithDictionary:params];
    //    BGUserInfo *user = [BGUserInfo gettingLoginSuccessLastLogin];
    //    NSString *tenantId = user.tenantId;
    //    if ([tenantId notEmptyOrNull]) {
    //        [mutParams setNotNullObject:tenantId ForKey:ktenantId];
    //    }
    UserManager *user = [UserManager manager];
    if (!user.versionNo) {
        return;
    }
    __weak __typeof(self)weakSelf = self;
    NSString *baseURL = [BASE_URL stringByAppendingString:user.versionNo];
    NSString *urlString = [baseURL stringByAppendingString:path];
    [NetService bg_httpGetWithTokenWithPath:urlString params:mutParams success:^(id responseObject) {
        NSString *respCode = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespCode]];
        NSString *respMsg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespMsg]];
//
        if ([respMsg isEqualToString:@"Unauthorized"] || [respCode isEqualToString:@"600"]) {
            
            [weakSelf loginOut:respCode];
            return ;
        }else if([respCode isEqualToString:@"700"]){
            NSString *token = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"token"]];
            if(token.length>0){
                [UserManager manager].token = token;
            }
            return ;
        }else if ([respCode isEqualToString:@"5000"]){
            Fail(nil,@"5000",@"5000");
            [self pushUpErrorMsg:responseObject];
            return ;
        }
        if ([respCode isEqualToString:k0000]) {
            if (Success) {
                Success(responseObject);
            }
        }else{
            respMsg = [NSString stringWithFormat:@"%@",[NetService failCodeDic][respCode]];
            if (!respMsg || [respMsg isEqualToString:@"(null)"] || [respMsg isEqualToString:@"null"]) {
                respMsg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespMsg]];
                if (!respMsg) {
                    respMsg = @"未知错误";
                }
            }
            if (Fail) {
                if (respMsg) {
                    [MBProgressHUD showError:respMsg];
                }
                Fail(responseObject,respCode,respMsg);
            }
        }
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
        if (Fail) {
            Fail(nil,nil,nil);
        }
        if (errorMsg) {
            [MBProgressHUD showError:errorMsg];
        }else{
            [MBProgressHUD showError:@"请求失败,请检查网络链接或域名地址"];
        }
    }];
}

+ (void)bg_getWithTokenWithPathAndNoTips:(NSString *)path params:(NSDictionary *)params success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail{
    NSMutableDictionary * mutParams = [NSMutableDictionary dictionaryWithDictionary:params];
     UserManager *user = [UserManager manager];
        if (!user.versionNo) {
            return;
        }
        __weak __typeof(self)weakSelf = self;
        NSString *baseURL = [BASE_URL stringByAppendingString:user.versionNo];
        NSString *urlString = [baseURL stringByAppendingString:path];
        [NetService bg_httpGetWithTokenWithPath:urlString params:mutParams success:^(id responseObject) {
            if (!responseObject) {
                return ;
            }
            NSString *respCode = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespCode]];
            NSString *respMsg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespMsg]];
    //        k0000 成功
    //        401 token过期
            if ([respMsg isEqualToString:@"Unauthorized"] || [respCode isEqualToString:@"600"]) {
                [weakSelf loginOut:respCode];
                return ;
            }else if([respCode isEqualToString:@"700"]){
                NSString *token = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"token"]];
                if(token.length>0){
                    [UserManager manager].token = token;
                }
                return ;
            }else if ([respCode isEqualToString:@"5000"]){
                [self pushUpErrorMsg:responseObject];
                return ;
            }
            if ([respCode isEqualToString:k0000]) {
                if (Success) {
                    Success(responseObject);
                }
            }else{
                respMsg = [NSString stringWithFormat:@"%@",[NetService failCodeDic][respCode]];
                if (!respMsg || [respMsg isEqualToString:@"(null)"] || [respMsg isEqualToString:@"null"]) {
                    respMsg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespMsg]];
                    if (!respMsg) {
                        respMsg = @"未知错误";
                    }
                }
                if (Fail) {
                    Fail(responseObject,respCode,respMsg);
                }
            }
        } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
            if (Fail) {
                Fail(nil,nil,nil);
            }
            
        }];
}


// get域名配置方法
+ (void)bg_getIPAddressWithPath:(NSString *)path params:(NSDictionary *)params success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail {
    NSMutableDictionary * mutParams = [NSMutableDictionary dictionaryWithDictionary:params];
//    BGUserInfo *user = [BGUserInfo gettingLoginSuccessLastLogin];
//    NSString *tenantId = user.tenantId;
//    if ([tenantId notEmptyOrNull]) {
//        [mutParams setNotNullObject:tenantId ForKey:ktenantId];
//    }
    __weak __typeof(self)weakSelf = self;
    NSString *urlString = [BASE_URL stringByAppendingString:path];
    [NetService bg_httpGetWithPath:urlString params:mutParams success:^(id responseObject) {
        NSString *respCode = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespCode]];
        NSString *respMsg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespMsg]];
        //        k0000 成功
        if ([respMsg isEqualToString:@"Unauthorized"] || [respCode isEqualToString:@"600"] || [respCode isEqualToString:@"700"] || [respCode isEqualToString:@"5000"]) {
            if (Fail) {
                if (respMsg) {
                    UserManager *user = [UserManager manager];
                     user.appIndexSet = @"";
//                   [MBProgressHUD showError:@"服务器升至最新版本可动态配置登录页"];
                }
                Fail(responseObject,respCode,respMsg);
            }
            return ;
        }
        if ([respCode isEqualToString:k0000]) {
            if (Success) {
                Success(responseObject);
            }
        }else if ([respCode isEqualToString:@"410"]){
            if (Fail) {
                if (respMsg) {
                    UserManager *user = [UserManager manager];
                    user.appIndexSet = @"";
                   [MBProgressHUD showError:respMsg];
                }
                Fail(responseObject,respCode,respMsg);
            }
        }
        else{
//            NSString *respMsg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespMsg]];
            respMsg = [NSString stringWithFormat:@"%@",[NetService failCodeDic][respCode]];
            if (!respMsg || [respMsg isEqualToString:@"(null)"] || [respMsg isEqualToString:@"null"]) {
                respMsg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespMsg]];
                if (!respMsg) {
                    respMsg = @"未知错误";
                }
            }
            if (Fail) {
                if (respMsg) {
                   [MBProgressHUD showError:respMsg];
                }
                Fail(responseObject,respCode,respMsg);
            }
        }
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
        if (errorMsg) {
            [MBProgressHUD showError:errorMsg];
        }else{
            [MBProgressHUD showError:@"请求失败,请检查网络链接或域名地址"];
        }
        if (Fail) {
            Fail(nil,nil,nil);
        }
    }];
}
#pragma mark - 纯净版PUT接口，不允许出现提示框,判断返回码，拼接URL地址等业务逻辑！！！
+ (void)bg_putWithPath:(NSString *)path params:(NSDictionary *)params success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail{
    NSMutableDictionary * mutParams = [NSMutableDictionary dictionaryWithDictionary:params];
//    BGUserInfo *user = [BGUserInfo gettingLoginSuccessLastLogin];
//    NSString *tenantId = user.tenantId;
//    if ([tenantId notEmptyOrNull]) {
//        [mutParams setNotNullObject:tenantId ForKey:ktenantId];
//    }
    [NetService bg_httpPutWithPath:path params:mutParams success:^(id responseObject) {
        NSString *respCode = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespCode]];
        if ([respCode isEqualToString:k0000]) {
            if (Success) {
                Success(responseObject);
            }
        }else if ([respCode isEqualToString:@"5000"]){
            [self pushUpErrorMsg:responseObject];
            return ;
        }else{
            NSString *respMsg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespMsg]];
            if (Fail) {
                if (respMsg) {
                   [MBProgressHUD showError:respMsg];
                }
                Fail(responseObject,respCode,respMsg);
            }
        }
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
        if (errorMsg) {
            [MBProgressHUD showError:errorMsg];
        }else{
            [MBProgressHUD showError:@"请求失败,请检查网络链接或域名地址"];
        }
        if (Fail) {
            Fail(nil,nil,nil);
        }
    }];
}

#pragma mark - 纯净版download接口，不允许出现提示框,判断返回码，拼接URL地址等业务逻辑！！！
//下载文件,监测下载进度
+(void)bg_downloadFileFromUrlPath:(NSString *)fileUrlPath andSaveTo:(NSString *)localFullFilePath progress:(BGNetServiceProgressBlock)progress success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail{
    [BGHttpService bg_httpDownloadFileFromUrlPath:fileUrlPath andSaveTo:localFullFilePath progress:progress success:Success failure:Fail];
}

-(AFHTTPSessionManager *)bg_sessionManagerWithUrlPath:(NSString *)fileUrl{
    if (fileUrl) {
        return [[NetService manager].tasksMutDic objectForKey:fileUrl];
    }
    return nil;
}

-(NSString*)dj{
    NSString *stateDes = nil;
    AFHTTPSessionManager *manager;
    NSURLSessionDownloadTask *task = manager.downloadTasks.firstObject;
    if (task) {
        switch (task.state) {
            case NSURLSessionTaskStateRunning:
                stateDes = @"已开始";
                break;
            case NSURLSessionTaskStateSuspended:
                stateDes = @"已暂停";
                break;
            case NSURLSessionTaskStateCanceling:
                stateDes = @"已取消";
                break;
            case NSURLSessionTaskStateCompleted:
                stateDes = @"已完成";
                break;
            default:
                break;
        }
    }
    return stateDes;
}

#pragma mark - 纯净版上传数据接口，不允许出现提示框，剪切图片，拼接文件地址等业务逻辑！！！
//上传data 上传图片
+ (void)bg_uploadDataTo:(NSString *)urlStr params:(NSDictionary *)params fileData:(NSData *)uploadData progress:(BGNetServiceProgressBlock)progress success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail{
    NSMutableDictionary * mutParams = [NSMutableDictionary dictionaryWithDictionary:params];
//    BGUserInfo *user = [BGUserInfo gettingLoginSuccessLastLogin];
//    NSString *tenantId = user.tenantId;
//    if ([tenantId notEmptyOrNull]) {
//        [mutParams setNotNullObject:tenantId ForKey:ktenantId];
//    }
    [BGHttpService bg_httpUploadDataTo:urlStr params:mutParams fileData:uploadData progress:progress success:Success failure:Fail];
}

//上传文件
+ (void)bg_uploadFileTo:(NSString *)shortUrlPath params:(NSDictionary *)params file:(NSString *)loaclFileFullPath success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail {
    NSMutableDictionary * mutParams = [NSMutableDictionary dictionaryWithDictionary:params];
//    BGUserInfo *user = [BGUserInfo gettingLoginSuccessLastLogin];
//    NSString *tenantId = user.tenantId;
//    if ([tenantId notEmptyOrNull]) {
//        [mutParams setNotNullObject:tenantId ForKey:ktenantId];
//    }
    [BGHttpService bg_httpUploadFileTo:shortUrlPath params:mutParams file:loaclFileFullPath success:Success failure:Fail];
}

//多图上传
+ (void)bg_uploadMostImageWithURLString:(NSString *)URLString
                             parameters:(NSDictionary *)params
                            uploadDatas:(NSArray *)uploadDatas
                             uploadName:(NSString *)uploadName
                                success:(BGNetServiceSuccessBlock)success
                                failure:(BGNetServiceFailBlock)failure{
    NSMutableDictionary * mutParams = [NSMutableDictionary dictionaryWithDictionary:params];
//    BGUserInfo *user = [BGUserInfo gettingLoginSuccessLastLogin];
//    NSString *tenantId = user.tenantId;
//    if ([tenantId notEmptyOrNull]) {
//        [mutParams setNotNullObject:tenantId ForKey:ktenantId];
//    }
    [BGHttpService bg_httpUploadMostImageWithURLString:URLString parameters:mutParams uploadDatas:uploadDatas uploadName:uploadName success:success failure:failure];
}

#pragma mark - 断点续传方案一
//新建下载
//-(void)bg_downLoadWithURLFromBreakPoint:(NSString *)fileUrlPath
//              progress:(BGNetServiceDownloadProgressBlock)progressBlock
//               success:(BGNetServiceSuccessBlock)successBlock
//                 faile:(BGNetServiceFailBlock)faileBlock
//{
//
////    NSString *fileName = [MyMD5 d5:fileUrlPath];
//    NSString *upPath = [fileUrlPath lowercaseString];
//    if (fileUrlPath == nil) {
//        DefLog(@"请检查请求URL：%@",fileUrlPath);
//        return;
//    }
//    //需要处理汉字url
//    NSString *encodeUrlStr = fileUrlPath;
//    self.successBlock = successBlock;
//    self.failedBlock = faileBlock;
//    self.progressBlock = progressBlock;
//    self.downLoadUrl = encodeUrlStr;
//    [self.task resume];
//}

//- (NSURLSessionDataTask *)task
//{
//    if (!_task) {
//        NSInteger totalLength = [[NSDictionary dictionaryWithContentsOfFile: TotalLengthPlist][ Filename] integerValue];
//
//        if (totalLength &&  DownloadLength == totalLength) {
//            DefLog(@"######文件已经下载过了");
//            return nil;
//        }
//
//        // 创建请求
//        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.downLoadUrl]];
//
//        // 设置请求头
//        // Range : bytes=xxx-xxx，从已经下载的长度开始到文件总长度的最后都要下载
//        NSString *range = [NSString stringWithFormat:@"bytes=%zd-",DownloadLength];
//        [request setValue:range forHTTPHeaderField:@"Range"];
//
//        // 创建一个Data任务
//        _task = [self.session dataTaskWithRequest:request];
//    }
//    return _task;
//}
//
//#pragma mark - <NSURLSessionDataDelegate>
/**
 * 1.接收到响应
 */
//- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
//{
//    // 打开流
//    [self.stream open];
//
//    /*
//     （Content-Length字段返回的是服务器对每次客户端请求要下载文件的大小）
//     比如首次客户端请求下载文件A，大小为1000byte，那么第一次服务器返回的Content-Length = 1000，
//     客户端下载到500byte，突然中断，再次请求的range为 “bytes=500-”，那么此时服务器返回的Content-Length为500
//     所以对于单个文件进行多次下载的情况（断点续传），计算文件的总大小，必须把服务器返回的content-length加上本地存储的已经下载的文件大小
//     */
//    self.totalLength = [response.allHeaderFields[@"Content-Length"] integerValue] +  DownloadLength;
//    //    16069496
//    // 把此次已经下载的文件大小存储在plist文件
//    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile: TotalLengthPlist];
//    if (dict == nil) dict = [NSMutableDictionary dictionary];
//    dict[Filename] = @(self.totalLength);
//    DefLog(@"新下载路径地址:%@",TotalLengthPlist);
//    [dict writeToFile:TotalLengthPlist atomically:YES];
//
//    // 接收这个请求，允许接收服务器的数据
//    completionHandler(NSURLSessionResponseAllow);
//}

/**
 * 2.接收到服务器返回的数据（这个方法可能会被调用N次）
 */
//- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
//{
//    // 写入数据
//    [self.stream write:data.bytes maxLength:data.length];
//
//    float progress = 1.0 *  DownloadLength / self.totalLength;
//    if (self.progressBlock) {
//        self.progressBlock(session, self.task, DownloadLength, self.totalLength, progress);
////        self.progressBlock(progress);
//    }
//    // 下载进度
//}

/**
 * 3.请求完毕（成功\失败）
 */
//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
//{
//    if (error) {
//        if (self.failedBlock) {
//            self.failedBlock(error, @"0001", @"下载失败");
//        }
//        self.stream = nil;
//        self.task = nil;
//
//    }else{
//        if (self.successBlock) {
//            NSString *documentPath = [BGChatUtils getBGFilePath];
//            NSString *onlineFullPath = [documentPath stringByAppendingPathComponent:self.downLoadUrl.md5String];
//            self.successBlock(onlineFullPath);
//        }
//        // 关闭流
//        [self.stream close];
//        self.stream = nil;
//        // 清除任务
//        self.task = nil;
//    }
//}

//- (NSOutputStream *)stream
//{
//    if (!_stream) {
////        NSString *localImageName =  [BGFileDownModel fileThumbnailImageByFileName:filemodel.fileName];
////        NSString *fileName = [MyMD5 md5:filemodel.fileUrl];
////        NSString *fileType = [[filemodel.fileUrl componentsSeparatedByString:@"."] lastObject];
////        fileName = [@"" stringByAppendingFormat:@"%@.%@",fileName,fileType];
////
//        NSString *documentPath = [BGChatUtils getBGFilePath];
//        NSString *onlineFullPath = [documentPath stringByAppendingPathComponent:self.downLoadUrl.md5String];
//        _stream = [NSOutputStream outputStreamToFileAtPath:onlineFullPath append:YES];
////                _stream = [NSOutputStream outputStreamToFileAtPath:FileStorePath append:YES];
//    }
//    return _stream;
//}

//-(void)stopTask{
//    [self.task suspend];
//
//}

#pragma mark - 断点续传方案二

+(void)loginOut:(NSString *)respCode{
    if ([respCode isEqualToString:@"600"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"软件授权已过期" message:@"您使用的软件授权已过期，请咨询软件服务商，并在网页端进行配置。" preferredStyle:UIAlertControllerStyleAlert];
         UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
             //确认处理
             __weak __typeof(self)weakSelf = self;
             if ([[self findCurrentViewController] isKindOfClass:[BGLogSecondViewController class]] || [[self findCurrentViewController] isKindOfClass:[BGLogFirstViewController class]]) {
                 return ;
             }
             [weakSelf getLocationWithLoginVersionNo:[UserManager manager].versionNo andToken:[UserManager manager].token];
             [weakSelf removeAlias:nil];
              NSUserDefaults *defatluts = [NSUserDefaults standardUserDefaults];
             NSDictionary *dictionary = [defatluts dictionaryRepresentation];
             for (NSString *key in [dictionary allKeys]){
                 if ([key isEqualToString:@"orderListUrl"]) {
                     continue;
                 }else if ([key isEqualToString:kaccount]) {
                     continue;
                 }else if ([key isEqualToString:kpassword]) {
                     continue;
                 }else if ([key isEqualToString:@"isSavePwd"]){
                     continue;
                 }else if ([key isEqualToString:@"orderUrlArray"]){
                     continue;
                 }else if ([key isEqualToString:@"selectlanageArr"]){
                     continue;
                 }else if ([key isEqualToString:@"myLanguage"]){
                     continue;
                 }else if ([key isEqualToString:@"isOpenBoxInApp"] || [key isEqualToString:@"isAlwaysUploadPosition"]){
                     continue;
                 }else if ([key isEqualToString:@"APPLoginImageUrl"] || [key isEqualToString:@"appIndexSet"] || [key isEqualToString:kBaseUrlString]){
                     continue;
                 }
                 else{
                     [defatluts removeObjectForKey:key];
                     [defatluts synchronize];
                 }
             }
             // 停止采集轨迹
            if ([YYServiceManager defaultManager].isGatherStarted) {
                [YYServiceManager defaultManager].isGatherStarted = NO;
               
                [[YYServiceManager defaultManager] stopGather];
                //传给后台
                [self generateTrackRecords];
            }
             BGLogSecondViewController *loginVC = [[BGLogSecondViewController alloc] init];
             UINavigationController *naVC = [[CustomNavigationController alloc] initWithRootViewController:loginVC];
             [UIApplication sharedApplication].keyWindow.rootViewController = naVC;
         }];
         
         [alert addAction:action2];
         [[self findCurrentViewController] presentViewController:alert animated:YES completion:nil];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Token失效" message:@"您的Token已失效，请您重新登录。" preferredStyle:UIAlertControllerStyleAlert];
         UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
             //确认处理
             __weak __typeof(self)weakSelf = self;
             [weakSelf getLocationWithLoginVersionNo:[UserManager manager].versionNo andToken:[UserManager manager].token];
             [weakSelf removeAlias:nil];
             NSUserDefaults *defatluts = [NSUserDefaults standardUserDefaults];
             NSDictionary *dictionary = [defatluts dictionaryRepresentation];
             for (NSString *key in [dictionary allKeys]){
                 if ([key isEqualToString:@"orderListUrl"]) {
                     continue;
                 }else if ([key isEqualToString:kaccount]) {
                     continue;
                 }else if ([key isEqualToString:kpassword]) {
                     continue;
                 }else if ([key isEqualToString:@"isSavePwd"]){
                     continue;
                 }else if ([key isEqualToString:@"orderUrlArray"]){
                     continue;
                 }else if ([key isEqualToString:@"selectlanageArr"]){
                     continue;
                 }else if ([key isEqualToString:@"myLanguage"]){
                     continue;
                 }else if ([key isEqualToString:@"isOpenBoxInApp"] || [key isEqualToString:@"isAlwaysUploadPosition"]){
                     continue;
                 }else if ([key isEqualToString:@"APPLoginImageUrl"] || [key isEqualToString:@"appIndexSet"] || [key isEqualToString:kBaseUrlString]){
                     continue;
                 }else{
                     [defatluts removeObjectForKey:key];
                     [defatluts synchronize];
                 }
             }
             // 停止采集轨迹
                        if ([YYServiceManager defaultManager].isGatherStarted) {
                            [YYServiceManager defaultManager].isGatherStarted = NO;
                           
                            [[YYServiceManager defaultManager] stopGather];
                            //传给后台
                            [self generateTrackRecords];
                        }
             BGLogSecondViewController *loginVC = [[BGLogSecondViewController alloc] init];
             UINavigationController *naVC = [[CustomNavigationController alloc] initWithRootViewController:loginVC];
             [UIApplication sharedApplication].keyWindow.rootViewController = naVC;
         }];
         
         [alert addAction:action2];
         [[self findCurrentViewController] presentViewController:alert animated:YES completion:nil];
    }
   
    
//    QMUIAlertAction *action = [QMUIAlertAction actionWithTitle:@"确定" style:QMUIAlertActionStyleDestructive handler:^(__kindof QMUIAlertController * _Nonnull aAlertController, QMUIAlertAction * _Nonnull action) {
//
//       NSUserDefaults *defatluts = [NSUserDefaults standardUserDefaults];
//        NSDictionary *dictionary = [defatluts dictionaryRepresentation];
//        for(NSString *key in [dictionary allKeys]){
//            if ([key isEqualToString:@"orderListUrl"]) {
//                continue;
//            }else if ([key isEqualToString:kaccount]) {
//                continue;
//            }else if ([key isEqualToString:kpassword]) {
//                continue;
//            }else if ([key isEqualToString:@"isSavePwd"]){
//                continue;
//            }
//            else{
//                [defatluts removeObjectForKey:key];
//                [defatluts synchronize];
//            }
//        }
//        BGLogSecondViewController *loginVC = [[BGLogSecondViewController alloc] initWithNibName:@"BGLogSecondViewController" bundle:nil];
//        UINavigationController *naVC = [[CustomNavigationController alloc] initWithRootViewController:loginVC];
//        [UIApplication sharedApplication].keyWindow.rootViewController = naVC;
//
//    }];
//    QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:@"Token失效" message:@"您的Token已失效，请您重新登录。" preferredStyle:QMUIAlertControllerStyleAlert];
//    [alertController addAction:action];
//
//    QMUIVisualEffectView *visualEffectView = [[QMUIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
//    visualEffectView.foregroundColor = UIColorMakeWithRGBA(255, 255, 255, .7);// 一般用默认值就行，不用主动去改，这里只是为了展示用法
//    alertController.alertHeaderBackgroundColor = nil;// 当你需要磨砂的时候请自行去掉这几个背景色，不然这些背景色会盖住磨砂
//    alertController.alertButtonBackgroundColor = nil;
//    [alertController showWithAnimated:YES];
}

+(void)removeAlias:(NSString *)alias{
    [CloudPushSDK removeAlias:alias withCallback:^(CloudPushCallbackResult *res) {
           if (res.success) {
               DefLog(@"别名移除成功,别名：%@",alias);
           } else {
               DefLog(@"别名移除失败，错误: %@", res.error);
           }
    }];
}

+ (UIViewController *)findCurrentViewController
{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    UIViewController *topViewController = [window rootViewController];
    
    while (true) {
        
        if (topViewController.presentedViewController) {
            
            topViewController = topViewController.presentedViewController;

        } else if ([topViewController isKindOfClass:[UINavigationController class]] && [(UINavigationController*)topViewController topViewController]) {
            
            topViewController = [(UINavigationController *)topViewController topViewController];
            
        } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            
            UITabBarController *tab = (UITabBarController *)topViewController;
            topViewController = tab.selectedViewController;
            
        } else {
            break;
        }
    }
    return topViewController;
}

+ (UIViewController *)findRootCurrentViewController
{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    UIViewController *topViewController = [window rootViewController];
    
    while (true) {
        
        if (topViewController.presentedViewController) {
            
            topViewController = topViewController;

        } else if ([topViewController isKindOfClass:[UINavigationController class]] && [(UINavigationController*)topViewController topViewController]) {
            
            topViewController = [(UINavigationController *)topViewController topViewController];
            
        } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            
            UITabBarController *tab = (UITabBarController *)topViewController;
            topViewController = tab.selectedViewController;
            
        } else {
            break;
        }
    }
    return topViewController;
}

#pragma mark - code码映射
+(NSDictionary *)failCodeDic{
    return @{@"200":@"请求成功，插入成功，",
             @"201":@"主外键异常",
             @"401":@"需要客户端进行身份验证，需要客户端登录",
             @"105":@"新增项不允许出现在包含设备设备详情或者巡检项详情的项下",
             @"101":@"请删除子项",
             @"500":@"服务异常",
             @"1000":@"数据库pagecustom 表数据异常",
             @"10001":@"信息填写有误",
             @"300":@"appKey重复",
             @"301":@"文件上传失败",
             @"302":@"请添加图片",
             @"303":@"删除失败，没有此图片",
             @"107":@"新增项业务类型需要与父级业务类型一致",
             @"108":@"没有此菜单",
             @"109":@"此菜单未初始化排序值",
             @"120":@"没有可改变的菜单",
             @"125":@"更新视频信息错误",
             @"126":@"删除视频信息错误",
             @"127":@"文件找不到",
             @"128":@"error:启用的版本出错",
             @"129":@"error:没有此id的版本",
             @"130":@"更新失败",
             @"140":@"删除安卓版本信息失败",
             @"141":@"插入安卓版本信息失败",
             @"142":@"数据库api版本数据出现错误",
             @"143":@"不支持此设备",
             @"144":@"请检查用户名和用户密码，登录失败",
             @"0":@"用户名错误或没有此账号",
             @"1":@"获取用户错误，请重新登录",
             @"145":@"反馈提交失败，请重新提交",
             @"146":@"更新用户信息失败",
             @"147":@"没有权限，请去配置权限",
             @"304":@"请输入fSubid",
             @"305":@"变电所已存在",
             @"306":@"该变电所的编号或名称已存在",
             @"307":@"数据初始化失败",
             @"308":@"删除失败",
             @"309":@"增加失败",
             @"310":@"不是任务管理员",
             @"144":@"请检查用户名和用户密码，登录失败",
             @"311":@"不在此任务人员清单中",
             @"312":@"请先签到",
             @"313":@"此账号没有权限签名",
             @"314":@"重复签到",
             @"316":@"当前没有设备",
             @"317":@"当前变电所没有设备",
             @"315":@"当前变电所没有缺陷",
             @"316":@"当前没有设备",
             @"317":@"当前变电所没有设备",
             @"318":@"当前任务已经有巡检单",
             @"319":@"负责人不能是执行人",
             @"320":@"当前角色及其下级角色下存在用户",
             @"321":@"当前用户组及其下级用户组下存在用户",
             @"322":@"当前组织机构及其下级组织机构下存在变电所",
             @"323":@"当前组织机构及其下级组织机构下存在角色",
             @"324":@"当前组织机构及其下级组织机构下存在用户组",
             @"325":@"当前区域及其下级区域下存在变电所",
             @"326":@"H5文件上传失败",
             @"700":@"刷新token",
             @"327":@"插入失败，该公司名称已存在",
             @"328":@"插入失败，请重试（公司编号重复）",
             @"329":@"请先添加文档",
             @"330":@"日期格式化失败",
             @"331":@"文件名已经存在",
             @"332":@"文件大小不能超过10M",
             @"333":@"数据库记录删除失败",
             @"334":@"文件不存在",
             @"335":@"该用户被禁用，请通知管理员开启使用权限",
             @"336":@"不能禁用当前登录用户",
             @"205":@"该设备存在记录",
             @"338":@"用户名已存在",
             @"339":@"萤石云appKey不正确",
             @"340":@"萤石云appSecret不正确",
             @"341":@"网络配置错误",
             @"342":@"自定义名称重复",
             @"343":@"自定义报表计算项名称已存在",
             @"344":@"该变电所下网关名称已经存在",
             @"345":@"插入失败，网关代码重复",
             @"346":@"萤石云appKey不能为空",
             @"347":@"萤石云appSecret不能为空",
             @"600":@"您使用的软件授权已过期",
             @"348":@"当前用户没有变电所权限",
             @"349":@"此变电所下已经有该仪表名称",
             @"350":@"该变电所已经有该仪表code码",
             @"351":@"该变电所已经有该仪表名称",
             @"352":@"该回路编号已经存在",
             @"353":@"该变压器编号已存在",
             @"354":@"admin角色名称不能修改",
             @"355":@"admin角色不能删除",
             @"356":@"admin用户登录名不能修改",
             @"357":@"admin用户不能删除",
             @"358":@"删除失败， 请登录有管理员权限的账号",
             @"359":@"用户登录名已存在",
             @"360":@"首页当前配置已为默认配置",
             @"361":@"未配置萤石云appkey与secret信息",
             @"362":@"该文档类别已存在",
             @"363":@"当前用户未配角色",
             @"364":@"非admin角色，操作权限不足",
             @"365":@"该变电所没有组织机构",
             @"366":@"变电所数量达到上限",
             @"367":@"仪表数量达到上限",
             @"368":@"没有此变电所",
             @"369":@"没有查询到该变电所的组织机构信息",
             @"370":@"admin用户不能被禁用",
             @"371":@"不能修改admin用户的组织机构或角色",
             @"372":@"用户没有所选的全部变电所",
             @"373":@"该模板及其下级模板已有变电所在使用",
             @"374":@"该变电所编号超出范围，不能使用自动生成",
             @"375":@"系统中存在编号为10109999变电所，无法自动生成，请联系管理员",
             @"376":@"该变电所下，该网关下的仪表编号已存在",
             @"5000":@"error",
             @"377":@"该变电所id可用",
             @"378":@"该变电所id不可用",
             @"379":@"该条数据主键已存在",
             @"380":@"设备重名",
             @"381":@"该变电所没有设备分组",
             @"382":@"该变电所当前设备分组下已存在同名设备，建议修改",
             @"383":@"队列服务器连接超时，请检查队列服务器配置是否正确",
             @"384":@"队列创建失败，请检查使用的队列服务器账户是都具有足够的操作权限",
             @"385":@"业务队列不存在，请检查对应业务字段是否正确",
             @"386":@"版本号已存在",
             @"387":@"参数不存在",
             @"388":@"激活码已过期，无法更新",
             @"389":@"当前报警分类下，已存在报警类型，不可删除该报警分类",
             @"390":@"无效订阅",
             @"391":@"报警类型模板无法删除",
             @"392":@"托管已到期，请联系管理员",
             @"393":@"参数值不符合规范",
             @"394":@"必要参数缺失",
             @"395":@"工作通知不可更改分类",
             @"396":@"该用户所属的组织机构已过期，请到组织机构管理中更新使用时间",
             @"397":@"第三方的applicationKey不能为空",
             @"398":@"未填写正确的第三方数据",
             @"399":@"第三方域名不能为空",
             @"400":@"第三方账号不能为空",
             @"403":@"文件重名",
             @"402":@"重命名失败",
             @"405":@"旧密码错误",
             @"406":@"新密码不能与旧密码相同",
             @"407":@"新密码不能为空",

    };
}

//上传5000
+(void)pushUpErrorMsg:(NSDictionary *)responseObject{
//    NSString *baseURL = [BASE_URL stringByAppendingString:@"main/uploadExceptionLog"];
    NSString *baseURL = @"http://www.acrelcloud.cn/SubstationWEBV2/main/uploadExceptionLog";
    NSString *url = BASE_URL;
    NSArray *arr = responseObject[@"data"][@"stackTrace"];
    if (arr.count>0) {
        NSDictionary *param = @{@"ip":url,@"exceptionMessage":arr};
        [NetService bg_httpPostWithPath:baseURL params:param success:^(id responseObject) {
            DefLog(@"%@",responseObject);
        }failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
            DefLog(@"%@",respObjc);
        }];
    }
}

+(void)generateTrackRecords{
    NSMutableDictionary *mutparam = [NSMutableDictionary new];
    NSString *Projectip = GetBaseURL;
    if([Projectip containsString:@"http:"]){
        Projectip = [Projectip stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    }else if ([Projectip containsString:@"https:"]){
        Projectip = [Projectip stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    }
    [mutparam setObject:Projectip forKey:@"fProjectip"];
     
    UserManager *user = [UserManager manager];
    NSString *startTime = user.startTJtime;
    if (startTime.length) {
         [mutparam setObject:startTime forKey:@"fTrackstarttime"];
    }
    NSString *taskNumber = user.taskID;
    if (taskNumber && taskNumber.length) {
        [mutparam setObject:taskNumber forKey:@"fTasknumber"];
    }
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *endTime = [formatter stringFromDate:date];
    [mutparam setObject:endTime forKey:@"fTrackendtime"];
    //设置采集周期 30秒
    NSDictionary *baiduDic = user.yytjBaiduDic;
    NSString *tjGetherInterval =[NSString changgeNonulWithString:baiduDic[@"tjGetherInterval"]];
    NSString *tjPackInterval =[NSString changgeNonulWithString:baiduDic[@"tjPackInterval"]];
    if (tjGetherInterval && tjPackInterval) {
        [mutparam setObject:tjGetherInterval forKey:@"tjGetherInterval"];
        [mutparam setObject:tjPackInterval forKey:@"tjPackInterval"];
    } else {
        tjGetherInterval = @"5";
        tjPackInterval = @"30";
    }
    NSDictionary *param = user.loginData;
    NSString *projectname = [NSString changgeNonulWithString:param[@"fProjectname"]];
    NSString *userid = [NSString changgeNonulWithString:param[@"userId"]];
    NSString *username = [NSString changgeNonulWithString:param[@"username"]];
    //组织机构编号
    NSString *coaccountno = [NSString changgeNonulWithString:param[@"fCoaccountNo"]];
    //组织机构名
    NSString *coname = [NSString changgeNonulWithString:param[@"fConame"]];
    if (projectname) {
        [mutparam setObject:projectname forKey:@"fProjectname"];
    }
    if (userid) {
        [mutparam setObject:userid forKey:@"fUserid"];
    }
    if (username) {
        [mutparam setObject:username forKey:@"fUsername"];
    }
    if (coaccountno) {
        [mutparam setObject:coaccountno forKey:@"fCoaccountno"];
    }
    if (coname) {
        [mutparam setObject:coname forKey:@"fConame"];
    }
    //阿里云特殊接口 http://www.acrelcloud.cn
    [NetService bg_getWithTestPath:@"sys/generateTrackRecords" params:mutparam success:^(id respObjc) {
        [UserManager manager].startTJtime = @"";
        
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
        [UserManager manager].startTJtime = @"";
       
    }];
    
}

#pragma mark - 上传定位
+(void)getLocationWithLoginVersionNo:(NSString *)versionNo andToken:(NSString *)token{
    if ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)) {
    //            [self performSelectorOnMainThread:@selector(getLoation) withObject:nil waitUntilDone:YES];
                //定位功能可用
        [self getLoationWithversionNo:versionNo andToken:token];

    }else{
        NSString *sktoolsStr = [SKControllerTools getCurrentDeviceModel];
        NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
        NSString *userIP = [NSString stringWithFormat:@"%@,%@",sktoolsStr,phoneVersion];
        NSDictionary *param = @{@"deviceType":@"IOS",@"userIp":userIP,@"userAddress":@""};
        [self uploadLogininMsg:param andVersionNo:versionNo andToken:token];
    }
}

+(void)getLoationWithversionNo:(NSString *)versionNo andToken:(NSString *)token{
//    __weak __typeof(self)weakSelf = self;
    [[NetService shareInstance].locationManager requestLocationWithReGeocode:YES withNetworkState:YES completionBlock:^(BMKLocation * _Nullable location, BMKLocationNetworkState state, NSError * _Nullable error) {
             //获取经纬度和该定位点对应的位置信息
        DefLog(@"%@ %d",location,state);
        NSString *sktoolsStr = [SKControllerTools getCurrentDeviceModel];
        NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
        NSString *userIP = [NSString stringWithFormat:@"%@,%@",sktoolsStr,phoneVersion];
        if (!versionNo) {
            return;
        }
        if(location){
            NSString *addressStr = [NSString stringWithFormat:@"%@%@%@%@%@%@",location.rgcData.country,location.rgcData.province,location.rgcData.city,location.rgcData.district,location.rgcData.street,location.rgcData.streetNumber];
            if(location.rgcData.country){
                NSDictionary *param = @{@"deviceType":@"IOS",@"userIp":userIP,@"userAddress":addressStr};
                [self uploadLogininMsg:param andVersionNo:versionNo andToken:token];
                
            }
        }else{
           NSDictionary *param = @{@"deviceType":@"IOS",@"userIp":userIP,@"userAddress":@""};
           [self uploadLogininMsg:param andVersionNo:versionNo andToken:token];
        }
        
    }];
}

+(void)uploadLogininMsg:(NSDictionary *)param andVersionNo:(NSString *)versionNo andToken:(NSString *)token{
    [BGHttpService bg_httpPostWithTokenWithLogout:@"/logout" withVersionNo:versionNo andToken:token params:param success:^(id respObjc) {
         DefLog(@"%@",respObjc);
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
        
    }];
}

- (BMKLocationManager *)locationManager {
    if (!_locationManager) {
        //初始化BMKLocationManager类的实例
        _locationManager = [[BMKLocationManager alloc] init];
        //设置定位管理类实例的代理
        _locationManager.delegate = self;
        //设定定位坐标系类型，默认为 BMKLocationCoordinateTypeGCJ02
        _locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
        //设定定位精度，默认为 kCLLocationAccuracyBest
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        //设定定位类型，默认为 CLActivityTypeAutomotiveNavigation
        _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        //指定定位是否会被系统自动暂停，默认为NO
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        /**
         是否允许后台定位，默认为NO。只在iOS 9.0及之后起作用。
         设置为YES的时候必须保证 Background Modes 中的 Location updates 处于选中状态，否则会抛出异常。
         由于iOS系统限制，需要在定位未开始之前或定位停止之后，修改该属性的值才会有效果。
         */
        _locationManager.allowsBackgroundLocationUpdates = YES;
        /**
         指定单次定位超时时间,默认为10s，最小值是2s。注意单次定位请求前设置。
         注意: 单次定位超时时间从确定了定位权限(非kCLAuthorizationStatusNotDetermined状态)
         后开始计算。
         */
        _locationManager.locationTimeout = 10;
    }
    return _locationManager;
}

- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didFailWithError:(NSError * _Nullable)error {
    DefLog(@"定位失败");
}
@end
