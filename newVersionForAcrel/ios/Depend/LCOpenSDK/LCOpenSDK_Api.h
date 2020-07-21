//
//  LCOpenSDK_Api.h
//  LCOpenSDK
//
//  Created by chenjian on 16/5/16.
//  Copyright (c) 2016年 lechange. All rights reserved.
//

#ifndef LCOpenSDK_LCOpenSDK_Api_h
#define LCOpenSDK_LCOpenSDK_Api_h
#import <Foundation/Foundation.h>

/** [int]：协议类型 0-http 1-https */
typedef NS_ENUM(NSInteger, ProcotolType) {
    PROCOTOL_TYPE_HTTP = 0,
    PROCOTOL_TYPE_HTTPS
};

@interface LCOpenSDK_Api: NSObject
/**
 *  获取LCOpenSDK_Api单例
 *
 *  @return LCOpenSDK_Api单例指针
 */
+ (LCOpenSDK_Api*) shareMyInstance;

/**
 *  初始化LCOpenSDK_Api
 *
 *  @param procotol 协议
 *  @param addr     域名
 *  @param port     端口
 *  @param caPath   CA证书路径
 *
 *  @return LCOpenSDK_Api指针
 */
- (id)initOpenApi:(ProcotolType)procotol addr:(NSString*)addr port:(NSInteger)port CA_PATH:(NSString*)caPath;
/**
 *  LCOpenSDK_Api请求返回值
 *
 *  @param req     结构化请求体
 *  @param resp    结构化返回体
 *  @param timeout 超时时长
 *
 *  @return      0, 接口调用成功
 *              -1, 接口调用失败
 */
- (NSInteger)request:(void*)req resp:(void*)resp timeout:(NSInteger)timeout;
/**
 *  反初始化LCOpenSDK_Api接口
 */
- (void)uninitOpenApi;

@end

#endif
