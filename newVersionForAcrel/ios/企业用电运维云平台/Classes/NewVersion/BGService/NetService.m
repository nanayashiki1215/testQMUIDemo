//
//  NetService.m
//  IdealCallCenter
//
//  Created by feitian on 15/9/2.
//  Copyright © 2015年 com.Ideal. All rights reserved.
//

#import "NetService.h"
#import "BGLoginViewController.h"
#import "CustomNavigationController.h"

@interface NetService ()

@end

@implementation NetService

#pragma mark - post接口
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
                Fail(responseObject,respCode,respMsg);
            }
        }
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
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
    [NetService bg_httpPostWithTokenWithPath:urlString params:mutParams success:^(id responseObject) {
        NSString *respCode = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespCode]];
                if ([respCode isEqualToString:k0000]) {
                    if (Success) {
                        Success(responseObject);
                    }
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
                        Fail(responseObject,respCode,respMsg);
                    }
                }
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
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
    NSString *urlString = [BASE_URL stringByAppendingString:path];
    [NetService bg_httpGetWithPath:urlString params:mutParams success:^(id responseObject) {
        NSString *respCode = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespCode]];
        NSString *respMsg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespMsg]];
        //        k0000 成功
        //        401 token过期
        if ([respMsg isEqualToString:@"Unauthorized"]) {
            //
            [self loginOut];
        }
        if ([respCode isEqualToString:k0000]) {
            
            if (Success) {
                Success(responseObject);
            }
        }else{
//            NSString *respMsg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespMsg]];
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

// get update专用方法
+ (void)bg_getWithUpdatePath:(NSString *)path params:(NSDictionary *)params success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail {
    NSMutableDictionary * mutParams = [NSMutableDictionary dictionaryWithDictionary:params];
//    BGUserInfo *user = [BGUserInfo gettingLoginSuccessLastLogin];
//    NSString *tenantId = user.tenantId;
//    if ([tenantId notEmptyOrNull]) {
//        [mutParams setNotNullObject:tenantId ForKey:ktenantId];
//    }
    NSString *urlString = [BASE_URL stringByAppendingString:path];
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
        if (Fail) {
            Fail(nil,nil,nil);
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
    NSString *baseURL = [BASE_URL stringByAppendingString:user.versionNo];
    NSString *urlString = [baseURL stringByAppendingString:path];
    [NetService bg_httpGetWithTokenWithPath:urlString params:mutParams success:^(id responseObject) {
        NSString *respCode = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespCode]];
        NSString *respMsg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespMsg]];
//        k0000 成功
//        401 token过期
        if ([respMsg isEqualToString:@"Unauthorized"]) {
            //
            [self loginOut];
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
        }else{
            NSString *respMsg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:krespMsg]];
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
//        NSLog(@"请检查请求URL：%@",fileUrlPath);
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
//            NSLog(@"######文件已经下载过了");
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
//    NSLog(@"新下载路径地址:%@",TotalLengthPlist);
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

+(void)loginOut{
    
    QMUIAlertAction *action = [QMUIAlertAction actionWithTitle:@"确定" style:QMUIAlertActionStyleDestructive handler:^(__kindof QMUIAlertController * _Nonnull aAlertController, QMUIAlertAction * _Nonnull action) {
        
        BGLoginViewController *loginVC = [[BGLoginViewController alloc] initWithNibName:@"BGLoginViewController" bundle:nil];
       UINavigationController *naVC = [[CustomNavigationController alloc] initWithRootViewController:loginVC];
       [UIApplication sharedApplication].keyWindow.rootViewController = naVC;
        //清空NSUserDefaults
        //清空NSUserDefaults 退出登录
        NSUserDefaults *defatluts = [NSUserDefaults standardUserDefaults];
        NSDictionary *dictionary = [defatluts dictionaryRepresentation];
        for(NSString *key in [dictionary allKeys]){
            if ([key isEqualToString:@"orderListUrl"]) {
                continue;
            }else if ([key isEqualToString:kaccount]) {
                continue;
            }else if ([key isEqualToString:kpassword]) {
                continue;
            }else if ([key isEqualToString:@"isSavePwd"]){
                continue;
            }
            else{
                [defatluts removeObjectForKey:key];
                [defatluts synchronize];
            }
        }
       
    }];
    QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:@"Token失效" message:@"您的Token已失效，请您重新登录。" preferredStyle:QMUIAlertControllerStyleAlert];
    [alertController addAction:action];
    
    QMUIVisualEffectView *visualEffectView = [[QMUIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    visualEffectView.foregroundColor = UIColorMakeWithRGBA(255, 255, 255, .7);// 一般用默认值就行，不用主动去改，这里只是为了展示用法
    alertController.mainVisualEffectView = visualEffectView;
    alertController.alertHeaderBackgroundColor = nil;// 当你需要磨砂的时候请自行去掉这几个背景色，不然这些背景色会盖住磨砂
    alertController.alertButtonBackgroundColor = nil;
    [alertController showWithAnimated:YES];
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
             @"0":@"登录失败",
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
             @"315":@"当前变电所没有缺陷"};
}

@end
