//
//  BGFileDownModel.h
//  BusinessGo
//
//  Created by NanayaSSD on 2017/4/11.
//  Copyright © 2017年 com.Ideal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BGFileDownModel : RLMObject
@property(nonatomic,strong)NSString *fileName;
/**
 0-图片
 1-文档
 2-视频
 3-音乐
 4-应用
 5-其它
后台接口
 */
@property(nonatomic,strong)NSString *fileType;
/**
 网络地址
 */
@property(nonatomic,strong)NSString *fileUrlString;
@property(nonatomic,strong)NSData *fileData;
@property(nonatomic,strong)NSString *fileSize;
/**
 本地地址
 */
@property(nonatomic,strong)NSString *fileLocalString;

/**
 用于删除文件使用的fileID
 */
@property(nonatomic,strong)NSString *fid;
/**
 表示是否是个人文件
 */
@property(nonatomic) BOOL isOwnDownloaded;

//查文件
+(BGFileDownModel *)searchFileNameInRealm:(NSString *)fileName;
//删除


@end
RLM_ARRAY_TYPE(BGFileDownModel)

