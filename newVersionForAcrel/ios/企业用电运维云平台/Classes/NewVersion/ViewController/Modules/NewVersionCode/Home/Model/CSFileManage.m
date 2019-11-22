////
////  CSFileManage.m
////  CloudService
////
////  Created by feitian on 16/3/4.
////  Copyright © 2016年 com.Ideal. All rights reserved.
////
//
//#import "CSFileManage.h"
//#import "MyMD5.h"
////#import "CSProgressView.h"
//
//@implementation CSFileManage
//
//-(void)getLocalFilePath:(NSString *)onlineFilePath sessionId:(NSString *)sessionId willDownloadHandler:(id (^)(void))willDownload completionHandler:(void (^)(NSString *))competion{
//
//    NSString *fileName = [MyMD5 md5:onlineFilePath];
//    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//    cachesPath = [cachesPath stringByAppendingFormat:@"/mediaFiles/%@",sessionId];
//
//    DefLog(@"%@",cachesPath);
//    NSFileManager *manager = [NSFileManager defaultManager];
//    [manager createDirectoryAtPath:cachesPath withIntermediateDirectories:YES attributes:nil error:nil];
//    NSString *fileType = [[onlineFilePath componentsSeparatedByString:@"."] lastObject];
//    cachesPath = [cachesPath stringByAppendingFormat:@"/%@.%@",fileName,fileType];
//    BOOL exist = [manager fileExistsAtPath:cachesPath];
//    if (exist) {
//        DefLog(@"找到本地缓存的文件");
//        competion(cachesPath);
//    }else{
//        DefLog(@"准备从网上下载文件");
//        id obj = willDownload();
//        __block typeof (obj) blockObj = obj;
//        if (blockObj!=nil) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [(CSProgressView *)blockObj startAnimations];
//            });
//        }
//        [NetService downloadFile:onlineFilePath andSaveTo:cachesPath progress:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
//            if (blockObj!=nil) {
//                //暂时放弃次方案
////                NSNumber *progess = [NSNumber numberWithDouble:(double)totalBytesWritten/(double)totalBytesExpectedToWrite];
////                [blockObj setValue:progess forKeyPath:@"downloadProgess"];
//            }
//        } success:^(id objc) {
//            DefLog(@"网上下载文件成功");
//            competion(cachesPath);
//            if (blockObj!=nil) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [(CSProgressView *)blockObj stopAnimations];
//                });
//            }
//        } failure:^(NSString *errorCode, NSString *errorMsg) {
//            DefLog(@"网上下载文件失败");
//            competion(nil);
//            if (blockObj!=nil) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [(CSProgressView *)blockObj stopAnimations];
//                });
//            }
//        }];
//    }
//}
//
//-(void)getLocalFilePathForAllFile:(NSString *)onlineFilePath sessionId:(NSString *)sessionId willDownloadHandler:(id (^)(void))willDownload completionHandler:(void (^)(NSString *))competion{
//    NSString *fileName = [MyMD5 md5:onlineFilePath];
//    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//    cachesPath = [cachesPath stringByAppendingFormat:@"/mediaFiles/%@",sessionId];
//
//    DefLog(@"%@",cachesPath);
//    NSFileManager *manager = [NSFileManager defaultManager];
//    [manager createDirectoryAtPath:cachesPath withIntermediateDirectories:YES attributes:nil error:nil];
//    NSString *fileType = [[onlineFilePath componentsSeparatedByString:@"."] lastObject];
//    cachesPath = [cachesPath stringByAppendingFormat:@"/%@.%@",fileName,fileType];
//    BOOL exist = [manager fileExistsAtPath:cachesPath];
//    if (exist) {
//        DefLog(@"找到本地缓存的文件");
//        competion(cachesPath);
//    }else{
//        DefLog(@"准备从网上下载文件");
//        id obj = willDownload();
//        __block typeof (obj) blockObj = obj;
//        if (blockObj!=nil) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [(CSProgressView *)blockObj startAnimations];
//            });
//        }
//        [NetService downloadFile:onlineFilePath andSaveTo:cachesPath progress:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
//            if (blockObj!=nil) {
//                //暂时放弃次方案
//                //                NSNumber *progess = [NSNumber numberWithDouble:(double)totalBytesWritten/(double)totalBytesExpectedToWrite];
//                //                [blockObj setValue:progess forKeyPath:@"downloadProgess"];
//            }
//        } success:^(id objc) {
//            DefLog(@"网上下载文件成功");
//            competion(cachesPath);
//            if (blockObj!=nil) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [(CSProgressView *)blockObj stopAnimations];
//                });
//            }
//        } failure:^(NSString *errorCode, NSString *errorMsg) {
//            DefLog(@"网上下载文件失败");
//            competion(nil);
//            if (blockObj!=nil) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [(CSProgressView *)blockObj stopAnimations];
//                });
//            }
//        }];
//    }
//}
//
//+(void)deleteMediaFiles{
//    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//    cachesPath = [cachesPath stringByAppendingFormat:@"/mediaFiles"];
//    [CSFileManage deleteFolderAtPath:cachesPath];
//}
//
//+(float)getMediaFilesSize{
//    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//    cachesPath = [cachesPath stringByAppendingFormat:@"/mediaFiles"];
//    return[CSFileManage folderSizeAtPath:cachesPath];
//}
//
////单个文件的大小
//+ (long long) fileSizeAtPath:(NSString*) filePath{
//    NSFileManager* manager = [NSFileManager defaultManager];
//    if ([manager fileExistsAtPath:filePath]){
//        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
//    }
//    return 0;
//}
////遍历文件夹获得文件夹大小，返回多少M
//+ (float ) folderSizeAtPath:(NSString*) folderPath{
//    NSFileManager* manager = [NSFileManager defaultManager];
//    if (![manager fileExistsAtPath:folderPath]) return 0;
//    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
//    NSString* fileName;
//    long long folderSize = 0;
//    while ((fileName = [childFilesEnumerator nextObject]) != nil){
//        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
//        folderSize += [self fileSizeAtPath:fileAbsolutePath];
//    }
//    return folderSize;
//}
//
////删除文件夹
//+(void)deleteFolderAtPath:(NSString*) folderPath{
//    BOOL isDir = NO;
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    BOOL existed = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
//    if ( isDir == YES && existed == YES ){
//        [fileManager removeItemAtPath:folderPath error:nil];
//    }
//}
//
//@end
