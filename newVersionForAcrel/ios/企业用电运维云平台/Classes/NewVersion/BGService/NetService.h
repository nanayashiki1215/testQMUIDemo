//
//  NetService.h
//  IdealCallCenter
//
//  Created by feitian on 15/9/2.
//  Copyright © 2015年 com.Ideal. All rights reserved.
//

/*
 网络请求使用https，验证服务器证书，需在／configure／Certificates／目录下放入服务器的证书。
 */

#import "BGHttpService.h"
#import "AFNetworking.h"

@interface NetService : BGHttpService

#pragma mark - 纯净版Post接口，不允许出现提示框,判断返回码，拼接URL地址等业务逻辑！！！
/**
 *   post方法
 *
 *  @param path    请求网址字符串
 *  @param params  参数
 *  @param Success 成功回调
 *  @param Fail    失败回调
 */
+ (void)bg_postWithPath:(NSString *)path params:(NSDictionary *)params success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail;

+ (void)bg_postWithTokenWithPath:(NSString *)path params:(NSDictionary *)params success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail;

#pragma mark - 纯净版GET接口，不允许出现提示框,判断返回码，拼接URL地址等业务逻辑！！！
// get方法
+ (void)bg_getWithPath:(NSString *)path params:(NSDictionary *)params success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail;

// get专用方法
+ (void)bg_getWithUpdatePath:(NSString *)path params:(NSDictionary *)params success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail;
 //测试联调接口
+ (void)bg_getWithTestPath:(NSString *)path params:(NSDictionary *)params success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail;

// get带token方法
+ (void)bg_getWithTokenWithPath:(NSString *)path params:(NSDictionary *)params success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail;

#pragma mark - 纯净版PUT接口，不允许出现提示框,判断返回码，拼接URL地址等业务逻辑！！！
/**
 *   put方法
 *
 *  @param path    请求网址字符串
 *  @param params  参数
 *  @param Success 成功回调
 *  @param Fail    失败回调
 */
+ (void)bg_putWithPath:(NSString *)path params:(NSDictionary *)params success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail;

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

+(void)bg_downloadFileFromUrlPath:(NSString *)fileUrlPath andSaveTo:(NSString *)localFullFilePath progress:(BGNetServiceProgressBlock)progress success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail;
-(AFHTTPSessionManager *)bg_sessionManagerWithUrlPath:(NSString *)fileUrl;

#pragma mark - 纯净版上传文件接口，不允许出现提示框，剪切图片，拼接文件地址等业务逻辑！！！
+ (void)bg_uploadDataTo:(NSString *)urlStr params:(NSDictionary *)params fileData:(NSData *)uploadData progress:(BGNetServiceProgressBlock)progress success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail;
//+ (void)bg_uploadFileTo:(NSString *)shortUrlPath params:(NSDictionary *)params file:(NSString *)loaclFileFullPath success:(BGNetServiceSuccessBlock)Success failure:(BGNetServiceFailBlock)Fail;
#pragma mark - 多图上传
+ (void)bg_uploadMostImageWithURLString:(NSString *)URLString
                             parameters:(NSDictionary *)params
                            uploadDatas:(NSArray *)uploadDatas
                             uploadName:(NSString *)uploadName
                                success:(BGNetServiceSuccessBlock)success
                                failure:(BGNetServiceFailBlock)failure;

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
@end

