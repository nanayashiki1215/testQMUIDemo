//
//  OpenApiNetworking.m
//  LCOpenSDKDemo
//
//  Created by bzy on 17/3/21.
//  Copyright © 2017年 lechange. All rights reserved.
//

#import "OpenApiNetworking.h"

@implementation OpenApiNetworking
+ (NSString *)requestByPost:(NSString*)url params:(NSString*)params
{
    NSLog(@"%@", params);
    NSURL *nsURL =[NSURL URLWithString:url];
    //2 创建请求对象
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:nsURL];
    
    //2.1 创建请求方式
    [request setHTTPMethod:@"post"];//get可以省略 但是post必须要写

    //3 设置请求参数
    NSData *tempData = [params dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:tempData];//设置请求主体 外界看不见数据
    [request setTimeoutInterval:10.0];
    
    //4 创建响应对象
    NSURLResponse *response = nil;
    
    //5 创建连接对象
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *resp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", resp);

    return resp;
}

@end
