//
//  BGHttpService.m
//  IdealCallCenter
//
//  Created by feitian on 15/9/2.
//  Copyright © 2015年 com.Ideal. All rights reserved.
//

#import "BGHttpService.h"
#import "AFNetworking.h"

//#import "HBRequsetManager.h"
#import "NSString+BGChangeNoNull.h"
#import "UIImage+BGPhotoImage.h"
#import "NSString+BGExtension.h"
#import "NSURL+BGExtension.h"
static NSString*  BOUNDARY = @"#####";

@interface BGHttpService ()<NSURLSessionDataDelegate>



@end

@implementation BGHttpService

#pragma mark - 类加载时监测网络的可链接性,可将检测结果标记在单例类中，再使用
+(void)load{
    [super load];
    [self startMonitoringNetWorkReachability];
}

static id _instance;

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
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

- (id)copyWithZone:(NSZone *)zone
{
    return _instance;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        if(!self.tasksMutDic){
            self.tasksMutDic = [NSMutableDictionary dictionary];
        }
    }
    return self;
}

+ (void)startMonitoringNetWorkReachability {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
//    __weak AFNetworkReachabilityManager *weak = manager;
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                DefLog(@"isreach:yes");
                NSLog(@"AFNetworkReachabilityStatusReachableViaWiFi");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                DefLog(@"isreach:no");
                [MBProgressHUD showError:@"当前无网络链接，请检查网络设置"];
//                DefQuickAlert(@"当前无网络链接，请检查网络设置", nil);
//                    NSLog(@"AFNetworkReachabilityStatusNotReachable");
                break;
            default:
                //AFNetworkReachabilityStatusUnknown
                NSLog(@"AFNetworkReachabilityStatusUnknown");
                break;
        }
//            DefLog(@"%d,%d,%d",weak.isReachable,weak.isReachableViaWiFi,weak.isReachableViaWWAN);
    }];
    
    [manager startMonitoring];  //开启网络监视器；
}

#pragma mark - 初始化一个AFHTTPSessionManager
+ (AFHTTPSessionManager *)createHTTPSessionManager{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
     manager.requestSerializer.timeoutInterval = HttpTimeoutInterval;//设置请求超时时
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    manager.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"image/jpeg",@"image/png",@"text/plain",@"text/xml", nil];
    //    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    //    policy.allowInvalidCertificates = YESr;
    //    policy.validatesDomainName = NO;
    //    NSString *certFilePath = [[NSBundle mainBundle] pathForResource:@"client.cer" ofType:nil];
    //    NSData *certData = [NSData dataWithContentsOfFile:certFilePath];
    //    NSSet *certSet = [NSSet setWithObject:certData];
    //    policy.pinnedCertificates = certSet;
    //    manager.securityPolicy = policy;
    //    manager.requestSerializer.stringEncoding = NSUTF16StringEncoding;
    //    manager.baseURL = [NSURL bg_URLWithString:BASE_URL];
    return manager;
}

+ (AFHTTPSessionManager *)createHTTPSessionManagerWithToken{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = HttpTimeoutInterval;//设置请求超时时
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    manager.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded;charset=utf8" forHTTPHeaderField:@"Content-Type"];
    
    [manager.requestSerializer setValue:[UserManager manager].token forHTTPHeaderField:@"Authorization"];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"image/jpeg",@"text/plain",@"text/xml", nil];
    //    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    //    policy.allowInvalidCertificates = YES;
    //    policy.validatesDomainName = NO;
    //    NSString *certFilePath = [[NSBundle mainBundle] pathForResource:@"client.cer" ofType:nil];
    //    NSData *certData = [NSData dataWithContentsOfFile:certFilePath];
    //    NSSet *certSet = [NSSet setWithObject:certData];
    //    policy.pinnedCertificates = certSet;
    //    manager.securityPolicy = policy;
    //    manager.requestSerializer.stringEncoding = NSUTF16StringEncoding;
    //    manager.baseURL = [NSURL bg_URLWithString:BASE_URL];
    return manager;
}


+ (AFHTTPSessionManager *)createHTTPSessionUploadManagerWithToken{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = HttpTimeoutInterval;//设置请求超时时
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded;charset=utf8" forHTTPHeaderField:@"Content-Type"];
    
    [manager.requestSerializer setValue:[UserManager manager].token forHTTPHeaderField:@"Authorization"];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"image/jpeg",@"image/png",@"text/plain",@"text/xml", nil];
    //    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    //    policy.allowInvalidCertificates = YES;
    //    policy.validatesDomainName = NO;
    //    NSString *certFilePath = [[NSBundle mainBundle] pathForResource:@"client.cer" ofType:nil];
    //    NSData *certData = [NSData dataWithContentsOfFile:certFilePath];
    //    NSSet *certSet = [NSSet setWithObject:certData];
    //    policy.pinnedCertificates = certSet;
    //    manager.securityPolicy = policy;
    //    manager.requestSerializer.stringEncoding = NSUTF16StringEncoding;
    //    manager.baseURL = [NSURL bg_URLWithString:BASE_URL];
    return manager;
}
#pragma mark - 初始化一个AFSecurityPolicy
+ (AFSecurityPolicy *)customSecurityPolicy {
    //先导入证书，找到证书的路径
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"client" ofType:@"cer"];
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    
    //AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    
    //allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    //如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = NO;
    NSSet *set = [[NSSet alloc] initWithObjects:certData, nil];
    securityPolicy.pinnedCertificates = set;
    
    return securityPolicy;
}

#pragma mark - 纯净版Post接口，不允许出现提示框,判断返回码，拼接URL地址等业务逻辑！！！
+ (void)bg_httpPostWithPath:(NSString *)path params:(NSDictionary *)params success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail{
    NSString *realURL = path;
    NSString *upPath = [realURL lowercaseString];
    if (!([upPath hasPrefix:@"http://"] || [upPath hasPrefix:@"https://"])) {
        DefLog(@"请检查请求URL：%@",path);
        Fail(nil,nil,nil);
        return;
    }
    
    AFHTTPSessionManager *manager = [BGHttpService createHTTPSessionManager];
    //HTTPS SSL的验证，在此处调用上面的代码，给这个证书验证；
//    [manager setSecurityPolicy:[BGHttpService customSecurityPolicy]];
    [manager POST:realURL parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DefLog(@"\n\n***************  Start  ***************\nPOST:\nURL:%@\nParams:%@\nResponse:%@\n***************   End   ***************\n\n.",realURL,params,responseObject);
        if (Success) {
            if (Success) {
                Success(responseObject);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DefLog(@"\n\n***************  Start  ***************\nPOST:\nURL:%@\nParams:%@\nError:%@\n***************   End   *************** \n\n.",realURL,params,error);
        if (Fail) {
            Fail(nil,nil,nil);
        }
    }];
}

//带token头的post请求
+ (void)bg_httpPostWithTokenWithPath:(NSString *)path params:(NSDictionary *)params success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail{
    NSString *realURL = path;
    NSString *upPath = [realURL lowercaseString];
    if (!([upPath hasPrefix:@"http://"] || [upPath hasPrefix:@"https://"])) {
        DefLog(@"请检查请求URL：%@",path);
         Fail(nil,nil,nil);
        return;
    }
    
    AFHTTPSessionManager *manager = [BGHttpService createHTTPSessionManagerWithToken];
    //HTTPS SSL的验证，在此处调用上面的代码，给这个证书验证；
//        [manager setSecurityPolicy:[BGHttpService customSecurityPolicy]];
    [manager POST:realURL parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DefLog(@"\n\n***************  Start  ***************\nPOST:\nURL:%@\nParams:%@\nResponse:%@\n***************   End   ***************\n\n.",realURL,params,responseObject);
        if (Success) {
            if (Success) {
                Success(responseObject);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DefLog(@"\n\n***************  Start  ***************\nPOST:\nURL:%@\nParams:%@\nError:%@\n***************   End   *************** \n\n.",realURL,params,error);
        if (Fail) {
            Fail(nil,nil,nil);
        }
    }];
}
#pragma mark - 纯净版GET接口，不允许出现提示框,判断返回码，拼接URL地址等业务逻辑！！！
// get方法
+ (void)bg_httpGetWithPath:(NSString *)path params:(NSDictionary *)params success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail {
    NSString *upPath = [path lowercaseString];
    if (!([upPath hasPrefix:@"http://"] || [upPath hasPrefix:@"https://"])) {
        DefLog(@"请检查请求URL：%@",path);
         Fail(nil,nil,nil);
        return;
    }
    NSString *realURL = path;
    AFHTTPSessionManager *manager = [BGHttpService createHTTPSessionManager];
    //HTTPS SSL的验证，在此处调用上面的代码，给这个证书验证；
//    [manager setSecurityPolicy:[BGHttpService customSecurityPolicy]];
    [manager GET:realURL parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DefLog(@"\n\n***************  Start  ***************\nGET:\nURL:%@\nParams:%@\nResponse:%@\n***************   End   ***************\n\n.",realURL,params,responseObject);
        if (Success) {
            Success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DefLog(@"\n\n***************  Start  ***************\nGET:\nURL:%@\nParams:%@\nError:%@\n***************   End   ***************\n\n.",realURL,params,error);
        if (Fail) {
            Fail(nil,nil,nil);
        }
    }];
}

// 带头get方法
+ (void)bg_httpGetWithTokenWithPath:(NSString *)path params:(NSDictionary *)params success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail {
    NSString *upPath = [path lowercaseString];
    if (!([upPath hasPrefix:@"http://"] || [upPath hasPrefix:@"https://"])) {
        DefLog(@"请检查请求URL：%@",path);
         Fail(nil,nil,nil);
        return;
    }
    NSString *realURL = path;
    AFHTTPSessionManager *manager = [BGHttpService createHTTPSessionManagerWithToken];
    //HTTPS SSL的验证，在此处调用上面的代码，给这个证书验证；
//        [manager setSecurityPolicy:[BGHttpService customSecurityPolicy]];
    [manager GET:realURL parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DefLog(@"\n\n***************  Start  ***************\nGET:\nURL:%@\nParams:%@\nResponse:%@\n***************   End   ***************\n\n.",realURL,params,responseObject);
        
        if (Success) {
            Success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DefLog(@"\n\n***************  Start  ***************\nGET:\nURL:%@\nParams:%@\nError:%@\n***************   End   ***************\n\n.",realURL,params,error);
        if (Fail) {
            Fail(nil,nil,nil);
        }
    }];
}
#pragma mark - 纯净版PUT接口，不允许出现提示框,判断返回码，拼接URL地址等业务逻辑！！！
+ (void)bg_httpPutWithPath:(NSString *)path params:(NSDictionary *)params success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail{
    NSString *upPath = [path lowercaseString];
    if (!([upPath hasPrefix:@"http://"] || [upPath hasPrefix:@"https://"])) {
        DefLog(@"请检查请求URL：%@",path);
         Fail(nil,nil,nil);
        return;
    }
    NSString *realURL = path;
    AFHTTPSessionManager *manager = [BGHttpService createHTTPSessionManager];
    //HTTPS SSL的验证，在此处调用上面的代码，给这个证书验证；
//    [manager setSecurityPolicy:[BGHttpService customSecurityPolicy]];
    [manager PUT:realURL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DefLog(@"\n\n***************  Start  ***************\nPUT:\nURL:%@\nParams:%@\nResponse:%@\n***************   End   ***************\n\n.",realURL,params,responseObject);
        if (Success) {
            Success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DefLog(@"\n\n***************  Start  ***************\nPUT:\nURL:%@\nParams:%@\nError:%@\n***************   End   ***************\n\n.",realURL,params,error);
        if (Fail) {
            Fail(nil,nil,nil);
        }
    }];
}

#pragma mark - 纯净版download接口，不允许出现提示框,判断返回码，拼接URL地址等业务逻辑！！！
//下载文件,监测下载进度
+(void)bg_httpDownloadFileFromUrlPath:(NSString *)fileUrlPath andSaveTo:(NSString *)localFullFilePath progress:(BGNetServiceProgressBlock)progress success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail{
    NSString *upPath = [fileUrlPath lowercaseString];
    if (fileUrlPath == nil) {
        DefLog(@"请检查请求URL：%@",fileUrlPath);
        return;
    }
    //需要处理汉字url
    NSString *encodeUrlStr = fileUrlPath;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL bg_URLWithString:encodeUrlStr]];
    AFHTTPSessionManager *manager = [BGHttpService createHTTPSessionManager];
    NSURLSessionDownloadTask *downTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //         progress(nil,nil,1.0 * downloadProgress.completedUnitCount/downloadProgress.totalUnitCount,1.0 * downloadProgress.totalUnitCount,1.0 * downloadProgress.completedUnitCount);
        //      progress(session,downloadTask,bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:localFullFilePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        [[BGHttpService manager].tasksMutDic removeObjectForKey:encodeUrlStr];
        DefLog(@"\n\n***************  Start  ***************\nDownload:\nURL:%@\nSaveTo:%@\nError:%@\n***************   End   ***************\n\n.",fileUrlPath,filePath.absoluteString,error);
        if (nil == error && Success) {
            Success(filePath);
        }else if (Fail){
            [[NSFileManager defaultManager] removeItemAtPath:localFullFilePath error:nil];
            Fail(nil,[NSString stringWithFormat:@"%ld",error.code],error.domain);
        }
    }];
    [manager setDownloadTaskDidWriteDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        DefLog(@"%p %f/completed=%lld/total=%lld",downloadTask,(double)totalBytesWritten/(double)totalBytesExpectedToWrite, totalBytesWritten , totalBytesExpectedToWrite);
        if (progress) {
            progress(session,downloadTask,bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
        }
    }];
    [downTask resume];
    if (encodeUrlStr && manager) {
        [[BGHttpService manager].tasksMutDic setObject:manager forKey:encodeUrlStr];
    }
}

-(AFHTTPSessionManager *)bg_sessionManagerWithUrlPath:(NSString *)fileUrl{
    if (fileUrl) {
        return [[BGHttpService manager].tasksMutDic objectForKey:fileUrl];
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
//上传data
+ (void)bg_httpUploadDataTo:(NSString *)urlStr params:(NSDictionary *)params fileData:(NSData *)uploadData progress:(BGNetServiceProgressBlock)progress success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail{
    //首先判断网络连接
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    if(! reachabilityManager.isReachable){
        Fail(nil,nil,nil);
        return ;
    }
    NSString *upPath = [urlStr lowercaseString];
    if (!([upPath hasPrefix:@"http://"] || [upPath hasPrefix:@"https://"])) {
        DefLog(@"请检查请求URL：%@",urlStr);
        Fail(nil,nil,nil);
        return;
    }
    NSString *realURL = urlStr;
    
    AFHTTPSessionManager *manager = [BGHttpService createHTTPSessionUploadManagerWithToken];
    [manager POST:realURL parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        /* url      :  本地文件路径
         * name     :  与服务端约定的参数
         * fileName :  自己随便命名的
         * mimeType :  文件格式类型 [mp3 : application/octer-stream application/octet-stream] [mp4 : video/mp4]
         */
        [formData appendPartWithFileData:uploadData name:@"file" fileName:@"userIcon.png" mimeType:@"image/png;boundary=boundary"];
//        [formData appendPartWithFileData:uploadData name:@"file" fileName:@"icon" mimeType:@"multipart/form-data;boundary=boundary"];
//        [formData throttleBandwidthWithPacketSize:1024*80 delay:1.0];
        //        [formData appendPartWithFileData:uploadFileData name:@"file" fileName:params[kfileName] mimeType:@"application/octet-stream"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        DefLog(@"%f/completed=%lld/total=%lld",(double)uploadProgress.completedUnitCount/(double)uploadProgress.totalUnitCount, uploadProgress.completedUnitCount , uploadProgress.totalUnitCount);
        if (progress) {
            progress(nil,nil,uploadProgress.completedUnitCount,uploadProgress.totalUnitCount,(uploadProgress.totalUnitCount-uploadProgress.completedUnitCount));
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DefLog(@"\n\n***************  Start  ***************\nUpload:\nURL:%@\nParams:%@\nResponse:%@\n***************   End   ***************\n\n.",realURL,params,responseObject);
        if (Success) {
            Success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DefLog(@"\n\n***************  Start  ***************\nUpload:\nURL:%@\nParams:%@\nError:%@\n***************   End   ***************\n\n.",realURL,params,error);
        if (Fail) {
            Fail(nil,nil,nil);
        }
    }];
}

//上传文件
+ (void)bg_httpUploadFileTo:(NSString *)shortUrlPath params:(NSDictionary *)params file:(NSString *)loaclFileFullPath success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail {
    //判断文件是否存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:loaclFileFullPath]) {
        if (Fail) {
            Fail(nil,nil,nil);
        }
    }
    NSData *data = [[NSData alloc] initWithContentsOfFile:loaclFileFullPath];
    [BGHttpService bg_httpUploadDataTo:shortUrlPath params:params fileData:data progress:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        
    } success:^(id  _Nullable objc) {
        DefLog(@"\n\n***************  Start  ***************\nUpload:\nURL:%@\nParams:%@\nResponse:%@\n***************   End   ***************\n\n.",shortUrlPath,params,objc);
        if (Success) {
            Success(objc);
        }
    } failure:^(id respObjc, NSString * _Nullable errorCode, NSString * _Nullable errorMsg) {
        DefLog(@"\n\n***************  Start  ***************\nUpload:\nURL:%@\nParams:%@\nError:%@\n***************   End   ***************\n\n.",shortUrlPath,params,errorMsg);
        if (Fail) {
            Fail(nil,errorCode,errorMsg);
        }
    }];
}

//多图上传
+ (void)bg_httpUploadMostImageWithURLString:(NSString *)URLString
                             parameters:(NSDictionary *)params
                            uploadDatas:(NSArray *)uploadDatas
                             uploadName:(NSString *)uploadName
                                success:(BGNetServiceSuccessBlock)success
                                failure:(BGNetServiceFailBlock)failure{
    AFHTTPSessionManager *manager = [BGHttpService createHTTPSessionManager];
    [manager POST:URLString parameters:params constructingBodyWithBlock:^(id< AFMultipartFormData >  _Nonnull formData) {
        for (int i=0; i< uploadDatas.count; i++) {
            
            [formData appendPartWithFileData:uploadDatas[i] name:@"files" fileName:params[@"fileName"] mimeType:@"multipart/form-data;boundary=boundary"];
        }
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DefLog(@"\n\n***************  Start  ***************\nUpload:\nURL:%@\nParams:%@\nResponse:%@\n***************   End   ***************\n\n.",URLString,params,responseObject);
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DefLog(@"\n\n***************  Start  ***************\nUpload:\nURL:%@\nParams:%@\nError:%@\n***************   End   ***************\n\n.",URLString,params,error);
        if (failure) {
            failure(nil,nil,nil);
        }
    }];
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
//+(void)postBossDemoWithUrl:(NSString*)url
//
//                     param:(NSString*)param
//
//                   success:(void(^)(NSDictionary *dict))success
//
//                      fail:(void (^)(NSError *error))fail
//
//{
//
//
//
//        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//
//        manager.securityPolicy = [AFSecurityPolicypolicyWithPinningMode:AFSSLPinningModeNone];//不设置会报-1016或者会有编码问题
//
//        manager.requestSerializer = [AFHTTPRequestSerializer serializer]; //不设置会报-1016或者会有编码问题
//
//        manager.responseSerializer = [AFHTTPResponseSerializer serializer]; //不设置会报 error 3840
//
//        [manager.responseSerializer setAcceptableContentTypes:[NSSetsetWithObjects:@"application/json",@"text/json", @"text/javascript",@"text/html",@"text/plain",nil]];
//
//        NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer]  requestWithMethod:@"POST" URLString:url parameters:nilerror:nil];
//
//        [request addValue:@"application/json"forHTTPHeaderField:@"Content-Type"];
//
//        NSData *body  =[paramdata UsingEncoding:NSUTF8StringEncoding];
//
//        [request setHTTPBody:body];
//
//
//
//        //发起请求
//
//        [[manager dataTaskWithRequest:requestcompletionHandler:^(NSURLResponse *_Nonnull response, id _Nullable responseObject,NSError * _Nullable error)
//
//                {
//
//                        NSDictionary * dic = [NSJSONSerializationJSONObjectWithData:responseObjectoptions:NSJSONReadingMutableContainerserror:nil];
//
//                        success(dic);
//
//
//
//                    }]
//         resume
//         ];
//
//}

@end
