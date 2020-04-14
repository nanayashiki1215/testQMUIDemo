//
//  BGHttpService.h
//  IdealCallCenter
//
//  Created by feitian on 15/9/2.
//  Copyright © 2015年 com.Ideal. All rights reserved.
//
/*
 网络请求使用https，验证服务器证书，需在／configure／Certificates／目录下放入服务器的证书。
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define HttpTimeoutInterval 15

typedef void(^BGNetServiceSuccessBlock)(id respObjc);
typedef void(^BGNetServiceFailBlock)(id respObjc,NSString * errorCode,NSString *errorMsg);
typedef void (^BGNetServiceProgressBlock)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);
typedef void (^BGNetServiceDownloadProgressBlock)(NSURLSession *session, NSURLSessionDataTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);
typedef void (^DonwLoadSuccessBlock)(NSURL *fileUrlPath ,NSURLResponse *  response );
typedef void (^DownLoadfailBlock)(NSError*  error ,NSInteger statusCode);
typedef void (^DowningProgress)(CGFloat  progress);

@interface BGHttpService : NSObject

@property (copy) BGNetServiceSuccessBlock  successBlock;
@property (copy) BGNetServiceFailBlock     failedBlock;
@property (copy) BGNetServiceDownloadProgressBlock    progressBlock;
@property (nonatomic, strong) NSMutableDictionary *tasksMutDic;

//2018.8.10断点续传
/** 下载任务 */
@property (nonatomic, strong) NSURLSessionDataTask *task;
/** 写文件的流对象 */
@property (nonatomic, strong) NSOutputStream *stream;
/** 文件的总大小 */
@property (nonatomic, assign) NSInteger totalLength;
@property(nonatomic,strong)NSString *downLoadUrl;
/**  下载历史记录 */
@property (nonatomic,strong) NSMutableDictionary *downLoadHistoryDictionary;
@property (nonatomic,strong) NSString  *fileHistoryPath;

/**
 下载manager单例
 */
+ (instancetype)manager;

/**
 *  监测网络的可链接性
 */
+ (void)startMonitoringNetWorkReachability;

#pragma mark - 纯净版Post接口，不允许出现提示框,判断返回码，拼接URL地址等业务逻辑！！！
/**
 *   post方法
 *
 *  @param path    请求网址字符串
 *  @param params  参数请求体
 *  @param Success 成功回调
 *  @param Fail    失败回调
 */
+ (void)bg_httpPostWithPath:(NSString *)path params:(NSDictionary *)params success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail;
//带token头的post请求
+ (void)bg_httpPostWithTokenWithPath:(NSString *)path params:(NSDictionary *)params success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail;
#pragma mark - 纯净版GET接口，不允许出现提示框,判断返回码，拼接URL地址等业务逻辑！！！

+ (void)bg_httpGetWithPath:(NSString *)path params:(NSDictionary *)params success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail;
// 带token头的get方法
+ (void)bg_httpGetWithTokenWithPath:(NSString *)path params:(NSDictionary *)params success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail;

#pragma mark - 纯净版PUT接口，不允许出现提示框,判断返回码，拼接URL地址等业务逻辑！！！
/**
 *   put方法
 *
 *  @param path    请求网址字符串
 *  @param params  参数请求体
 *  @param Success 成功回调
 *  @param Fail    失败回调
 */
+ (void)bg_httpPutWithPath:(NSString *)path params:(NSDictionary *)params success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail;

#pragma mark - 纯净版download接口，不允许出现提示框,判断返回码，拼接URL地址等业务逻辑！！！
/**
 *  下载文件并保存到指定的目录，监测下载进度
 *
 *  @param fileUrlPath  文件网址
 *  @param localFullFilePath 文件保存路径
 *  @param progress  监听下载进度的回调。
 *  @param Success 成功回调
 *  @param Fail    失败回调
 */
+(void)bg_httpDownloadFileFromUrlPath:(NSString *)fileUrlPath andSaveTo:(NSString *)localFullFilePath progress:(BGNetServiceProgressBlock)progress success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail;
//-(AFHTTPSessionManager *)bg_sessionManagerWithUrlPath:(NSString *)fileUrl;

#pragma mark - 纯净版上传文件接口，不允许出现提示框，剪切图片，拼接文件地址等业务逻辑！！！
+ (void)bg_httpUploadDataTo:(NSString *)urlStr params:(NSDictionary *)params fileData:(NSData *)uploadData progress:(BGNetServiceProgressBlock)progress success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail;
+ (void)bg_httpUploadFileTo:(NSString *)shortUrlPath params:(NSDictionary *)params file:(NSString *)loaclFileFullPath success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail;
#pragma mark - 多图上传
+ (void)bg_httpUploadMostImageWithURLString:(NSString *)URLString
                             parameters:(NSDictionary *)params
                            uploadDatas:(NSArray *)uploadDatas
                             uploadName:(NSString *)uploadName
                                success:(BGNetServiceSuccessBlock)success
                                failure:(BGNetServiceFailBlock)failure;


//#pragma mark - 请求体
//+(void)postBossDemoWithUrl:(NSString*)url
//
//                     param:(NSString*)param
//
//                   success:(void(^)(NSDictionary *dict))success
//
//                      fail:(void (^)(NSError *error))fail;


#pragma mark - 下载文件断点续传方法
-(void)bg_downLoadWithURLFromBreakPoint:(NSString *)fileUrlPath
                               progress:(BGNetServiceProgressBlock)progressBlock
                                success:(BGNetServiceSuccessBlock)successBlock
                                  faile:(BGNetServiceFailBlock)faileBlock;
/**
 文件下载
 @param urlHost 下载地址
 @param progress 下载进度
 @param localUrl 本地存储路径
 @param success 下载成功
 @param failure 下载失败
 @return downLoadTask
 */
- (NSURLSessionDownloadTask  *)bg_DownLoadFileWithUrlFromBreakPoint:(NSString*)urlHost
                                                           progress:(DowningProgress)progress
                                                       fileLocalUrl:(NSURL *)localUrl
                                                            success:(DonwLoadSuccessBlock)success
                                                            failure:(DownLoadfailBlock)failure;





/** 停止所有的下载任务*/
- (void)stopAllDownLoadTasks;


//+ (AFHTTPSessionManager *)createHTTPSessionManager;
//+ (AFSecurityPolicy *)customSecurityPolicy ;

@end

