//
//  openApiService.m
//  appDemo
//
//  Created by chenjian on 16/7/8.
//  Copyright (c) 2016年 yao_bao. All rights reserved.
//

#import "OpenApiClient.h"
#import "OpenApiService.h"

@implementation OpenApiService
- (NSInteger)getAccessToken:(NSString*)ip_In port:(NSInteger)port_In appId:(NSString*)appId_In appSecret:(NSString*)appSecret_In token:(NSString**)accessTok_Out errcode:(NSString**)strErrCode_Out errmsg:(NSString**)errMsg_Out
{
    OpenApiClient * client = [OpenApiClient shareMyInstance];
    [client setParams:ip_In port:port_In appId:appId_In appSecret:appSecret_In method:@"/openapi/accessToken"];
    
    NSDictionary *req = @{@"phone":@""};
    NSDictionary *resp = [client request:req];
    
    if (resp) {
        *strErrCode_Out = [resp[@"code"] copy];
        *errMsg_Out = [resp[@"msg"] copy];
        *accessTok_Out = [resp[@"data"][@"accessToken"] copy];
    }
    return [*strErrCode_Out isEqualToString:@"0"] ? 0 : -1;
}
- (NSInteger)getUserToken:(NSString*)ip_In port:(NSInteger)port_In appId:(NSString*)appId_In appSecret:(NSString*)appSecret_In phone:(NSString*)phoneNum_In token:(NSString**)accessTok_Out errcode:(NSString**)strErrCode_Out errmsg:(NSString**)errMsg_Out
{
    OpenApiClient * client = [OpenApiClient shareMyInstance];
    //[client setParams:ip_In port:port_In appId:appId_In appSecret:appSecret_In method:@"/openapi/userToken"];
    [client setParams:ip_In port:port_In appId:appId_In appSecret:appSecret_In method:@"/openapi/userTokenByAccount"];
    
    //NSDictionary *req = @{@"phone":phoneNum_In};
    NSDictionary *req = @{@"phone":phoneNum_In};
    NSDictionary *resp = [client request:req];
    
    if (resp) {
        *strErrCode_Out = [resp[@"code"] copy];
        *errMsg_Out = [resp[@"msg"] copy];
        //*accessTok_Out = [resp[@"data"][@"userToken"] copy];
        *accessTok_Out = [resp[@"data"][@"userTokenByAccount"] copy];
    }
    return [*strErrCode_Out isEqualToString:@"0"] ? 0 : -1;
}

- (NSInteger)userBindSms:(NSString*)ip_In port:(NSInteger)port_In appId:(NSString*)appId_In appSecret:(NSString*)appSecret_In phone:(NSString*)phoneNum_In errcode:(NSString**)strErrCode_Out errmsg:(NSString**)errMsg_Out
{
    OpenApiClient * client = [OpenApiClient shareMyInstance];
    [client setParams:ip_In port:port_In appId:appId_In appSecret:appSecret_In method:@"/openapi/userBindSms"];
    
    NSDictionary *req = @{@"phone":phoneNum_In};
    NSDictionary *resp = [client request:req];
    
    if (resp) {
        *strErrCode_Out = [resp[@"code"] copy];
        *errMsg_Out = [resp[@"msg"] copy];
    }
    return [*strErrCode_Out isEqualToString:@"0"] ? 0 : -1;
}

- (NSInteger)userBind:(NSString*)ip_In port:(NSInteger)port_In appId:(NSString*)appId_In appSecret:(NSString*)appSecret_In phone:(NSString*)phoneNum_In smscode:(NSString*)smsCode errmsg:(NSString**)errMsgOut
{
    OpenApiClient * client = [OpenApiClient shareMyInstance];
    //[client setParams:ip_In port:port_In appId:appId_In appSecret:appSecret_In method:@"/openapi/userBind"];
    [client setParams:ip_In port:port_In appId:appId_In appSecret:appSecret_In method:@"/openapi/userBindNoVerify"];
    
    NSDictionary *req = @{@"phone":phoneNum_In, @"smsCode":smsCode};
    NSDictionary *resp = [client request:req];
    
    if (resp) {
        *errMsgOut = [resp[@"msg"] copy];
    }
    return [resp[@"code"] isEqualToString:@"0"] ? 0 : -1;
}

- (NSInteger)userBindNoVerify:(NSString*)ip_In port:(NSInteger)port_In appId:(NSString*)appId_In appSecret:(NSString*)appSecret_In phone:(NSString*)phoneNum_In errmsg:(NSString**)errMsgOut
{
    OpenApiClient * client = [OpenApiClient shareMyInstance];
    [client setParams:ip_In port:port_In appId:appId_In appSecret:appSecret_In method:@"/openapi/userBindNoVerify"];
    
    NSDictionary *req = @{@"account":phoneNum_In};
    NSDictionary *resp = [client request:req];
    
    if (resp) {
        *errMsgOut = [resp[@"msg"] copy];
    }
    return [resp[@"code"] isEqualToString:@"0"] ? 0 : -1;
}

- (NSInteger)userTokenByAccount:(NSString*)ip_In port:(NSInteger)port_In appId:(NSString*)appId_In appSecret:(NSString*)appSecret_In phone:(NSString*)phoneNum_In token:(NSString**)accessTok_Out errcode:(NSString**)strErrCode_Out errmsg:(NSString**)errMsg_Out
{
    OpenApiClient * client = [OpenApiClient shareMyInstance];
    //[client setParams:ip_In port:port_In appId:appId_In appSecret:appSecret_In method:@"/openapi/userToken"];
    [client setParams:ip_In port:port_In appId:appId_In appSecret:appSecret_In method:@"/openapi/userTokenByAccount"];
    
    //NSDictionary *req = @{@"phone":phoneNum_In};
    NSDictionary *req = @{@"account":phoneNum_In};
    NSDictionary *resp = [client request:req];
    
    if (resp) {
        *strErrCode_Out = [resp[@"code"] copy];
        *errMsg_Out = [resp[@"msg"] copy];
        *accessTok_Out = [resp[@"data"][@"userToken"] copy];
    }
    return [*strErrCode_Out isEqualToString:@"0"] ? 0 : -1;
}

@end
