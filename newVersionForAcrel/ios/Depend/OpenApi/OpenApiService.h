//
//  openApiService.h
//  appDemo
//
//  Created by chenjian on 16/7/8.
//  Copyright (c) 2016年 yao_bao. All rights reserved.
//

#ifndef LCOpenSDKDemo_openApiService_h
#define LCOpenSDKDemo_openApiService_h

#import <Foundation/Foundation.h>

@interface OpenApiService : NSObject

- (NSInteger)getAccessToken:(NSString*)ip_In port:(NSInteger)port_In appId:(NSString*)appId_In appSecret:(NSString*)appSecret_In token:(NSString**)accessTok_Out errcode:(NSString**)strErrCode_Out errmsg:(NSString**)errMsg_Out;

- (NSInteger)getUserToken:(NSString*)ip_In port:(NSInteger)port_In appId:(NSString*)appId_In appSecret:(NSString*)appSecret_In phone:(NSString*)phoneNum_In token:(NSString**)accessTok_Out errcode:(NSString**)strErrCode_Out errmsg:(NSString**)errMsg_Out;

- (NSInteger)userBindSms:(NSString*)ip_In port:(NSInteger)port_In appId:(NSString*)appId_In appSecret:(NSString*)appSecret_In phone:(NSString*)phoneNum_In errcode:(NSString**)strErrCode_Out errmsg:(NSString**)errMsg_Out;

- (NSInteger)userBind:(NSString*)ip_In port:(NSInteger)port_In appId:(NSString*)appId_In appSecret:(NSString*)appSecret_In phone:(NSString*)phoneNum_In smscode:(NSString*)smsCode errmsg:(NSString**)errMsgOut;

- (NSInteger)userBindNoVerify:(NSString*)ip_In port:(NSInteger)port_In appId:(NSString*)appId_In appSecret:(NSString*)appSecret_In phone:(NSString*)phoneNum_In errmsg:(NSString**)errMsgOut;

- (NSInteger)userTokenByAccount:(NSString*)ip_In port:(NSInteger)port_In appId:(NSString*)appId_In appSecret:(NSString*)appSecret_In phone:(NSString*)phoneNum_In token:(NSString**)accessTok_Out errcode:(NSString**)strErrCode_Out errmsg:(NSString**)errMsg_Out;

@end

#endif
