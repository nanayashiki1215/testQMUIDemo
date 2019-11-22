//
//  BGFileViewController.m
//  BusinessGo
//
//  Created by NanayaSSD on 2017/4/11.
//  Copyright © 2017年 com.Ideal. All rights reserved.
//

#import "BGFileViewController.h"
#import "BGFileDownLoadTableViewCell.h"
//#import "BGWebController.h"
//#import "BGUploadFileViewController.h"
//#import "CSImageBrowserViewController.h"
//#import "CSMoviePlayerViewController.h"
//#import "DSActionSheet.h"
#import <AssetsLibrary/ALAsset.h>

#import <AssetsLibrary/ALAssetsLibrary.h>

#import <AssetsLibrary/ALAssetsGroup.h>

#import <AssetsLibrary/ALAssetRepresentation.h>

@interface BGFileViewController ()<UITableViewDelegate,UITableViewDataSource,BGFileDownLoadTableViewCellDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property(nonatomic,assign) NSInteger pageType;
//@property (strong, nonatomic)  DSActionSheet *weakSheet;
@property(nonatomic,strong) NSMutableArray *filesArray;
@property(nonatomic,strong) NSString *imageFileName;
@end

@implementation BGFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatView];
}

-(void)creatView{
    self.filesArray = [NSMutableArray new];
    self.view.backgroundColor = [UIColor whiteColor];
//    self.upFileLine.hidden = YES;
//    [self.tableview registerNib:[UINib nibWithNibName:@"BGFileDownLoadTableViewCell" bundle:nil] forCellReuseIdentifier:@"fileDownloadcell"];
    self.tableview.tableFooterView = [[UIView alloc] init];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getFileDatas];

}
//
-(void)getFileDatas{
    __weak __typeof(self)weakSelf = self;
    NSDictionary *params = @{@"shareType":self.shareType,
                              @"orgId":self.orgId
                            };

//    [NetService postWithPath:@"" params:params isNeedAaaWaiting:NO isNeedShowError:YES success:^(id objc) {
//        if (!objc) {
//            return ;
//        }
//        [self.filesArray removeAllObjects];
//        NSArray *array = objc[@"data"];
//        if (array>0) {
//            for (int i = 0; i<array.count; i++) {
//                BGFileDownModel *model = [[BGFileDownModel alloc] init];
//                model.fileName = array[i][@"fileName"];
//                model.fileType = array[i][@"fileType"];
//                model.fileUrlString = array[i][@"fileUrl"];
//                model.fid = array[i][@"fid"];
//                NSString *fizesize = array[i][@"fileSize"];
//                if([fizesize integerValue] > 1024000){
//                    model.fileSize = [NSString stringWithFormat:@"%.2f MB",(CGFloat)[fizesize integerValue]/1024/1024];
//                }else{
//                    model.fileSize = [NSString stringWithFormat:@"%.2f KB",(CGFloat)[fizesize integerValue]/1024];
//                }
//                switch (self.FilelistTpye) {
//                    case 0://全部
//                        [weakSelf.filesArray addObject:model];
//                        break;
//                    case 1://图片
//                        if ([model.fileType isEqualToString:@"0"]) {
//                            [weakSelf.filesArray addObject:model];
//                        }
//                        break;
//                    case 2://影音
//                        if ([model.fileType isEqualToString:@"2"]||[model.fileType isEqualToString:@"3"]) {
//                            [weakSelf.filesArray addObject:model];
//                        }
//                        break;
//                    case 3://文档
//                        if ([model.fileType isEqualToString:@"1"]) {
//                            [weakSelf.filesArray addObject:model];
//                        }
//                        break;
//                    case 4://其他
//                        if ([model.fileType isEqualToString:@"4"]||[model.fileType isEqualToString:@"5"]) {
//                            [weakSelf.filesArray addObject:model];
//                        }
//                        break;
//                    default:
//                        break;
//                }
//            }
//            [weakSelf.tableview reloadData];
//        }
//    } failure:^(NSString *errorCode, NSString *errorMsg) {
//
//    }];
}

//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filesArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    BGFileDownLoadTableViewCell *cell = [self.tableview dequeueReusableCellWithIdentifier:@"fileDownloadcell"];
//    cell.delegate = self;
//    BGFileDownModel *fileModel = self.filesArray[indexPath.row];
//    if (fileModel) {
//        cell.fileImg.image = [UIImage imageNamed:@"iconMySubscribe"];
//        cell.fileSizeLabel.text = fileModel.fileSize;
//        cell.fileName.text = fileModel.fileName;
//        cell.fileDownBtn.tag = indexPath.row;
//        //获取cell图片
//        cell.fileImg.image = [UIImage imageNamed:[self getImage:fileModel.fileName]];
//        //添加长按手势
//        //    UILongPressGestureRecognizer * longPressGesture =[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(cellLongPressForDeleteFile:)];
//        //    longPressGesture.minimumPressDuration=1.5f;//设置长按 时间
//        //    [cell addGestureRecognizer:longPressGesture];
//        if ([BGFileDownModel searchFileNameInRealm:fileModel.fileName]) {
//            cell.fileDownBtn.hidden = YES;
//        }else{
//            cell.fileDownBtn.hidden = NO;
//        }
//
//    }
    return nil;
}

-(NSString *)getImage:(NSString *)fileName{
     NSString *fileType = [[fileName componentsSeparatedByString:@"."] lastObject];
    if ([fileType isEqualToString:@"txt"]) {
        return @"soft_12";
    }else if ([fileType isEqualToString:@"pdf"]){
        return @"soft_14";
    }else if ([fileType isEqualToString:@"html"]){
        return @"soft_12";
    }else if ([fileType isEqualToString:@"docx"]){
        return @"soft_06";
    }else if ([fileType isEqualToString:@"doc"]){
        return @"soft_06";
    }else if ([fileType isEqualToString:@"ppt"]){
        return @"soft_10";
    }else if ([fileType isEqualToString:@"pptx"]){
        return @"soft_10";
    }else if ([fileType isEqualToString:@"xls"]){
        return @"soft_08";
    }else if ([fileType isEqualToString:@"xlsx"]){
        return @"soft_08";
    }else if ([fileType isEqualToString:@"mp3"] || [fileType isEqualToString:@"wav"] || [fileType isEqualToString:@"ape"] || [fileType isEqualToString:@"aac"]){
        return @"soft_16";
    }else if ([fileType isEqualToString:@"mp4"] || [fileType isEqualToString:@"wmv"] || [fileType isEqualToString:@"avi"] || [fileType isEqualToString:@"mpeg"] || [fileType isEqualToString:@"rmvb"] ||[fileType isEqualToString:@"rm"]){
        return @"soft_18";
    }else if ([fileType isEqualToString:@"png"] || [fileType isEqualToString:@"jpg"] ||[fileType isEqualToString:@"jpeg"] ||[fileType isEqualToString:@"bmp"]){
        return @"soft_03";
    }else{
        return @"soft_12";
    }
}

//
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BGFileDownModel *downloadmodel = self.filesArray[indexPath.row];
    BGFileDownModel *isDownloadedmodel = [BGFileDownModel searchFileNameInRealm:downloadmodel.fileName];
    if(isDownloadedmodel.fileLocalString){
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        documentPath = [documentPath stringByAppendingFormat:@"/Files/%@",downloadmodel.fileName];
        if ([isDownloadedmodel.fileType isEqualToString:@"1"] || [isDownloadedmodel.fileType isEqualToString:@"4"] || [isDownloadedmodel.fileType isEqualToString:@"5"]) {
            //文档，其他 支持格式 txt/pdf/html/doc/docx/xls/xlsx/ppt/pptx
            NSFileManager* fm = [NSFileManager defaultManager];
            NSData* data = [[NSData alloc] init];
            data = [fm contentsAtPath:documentPath];
            NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//            BGWebController *webVC = [[BGWebController alloc] initWithNibName:@"BGWebController" bundle:nil];
//            webVC.titleString = isDownloadedmodel.fileName;
//            webVC.Filelocaldata = data;
//            [self pushViewController:webVC animation:YES];
        }else if ([isDownloadedmodel.fileType isEqualToString:@"0"]){
            //图片 jpg/jpeg/png
//            CSImageBrowserViewController *imageBrowserVC = [[CSImageBrowserViewController alloc] init];
//            CSImageModel *imageModel = [[CSImageModel alloc] init];
//            imageModel.imageUrl = documentPath;
//            imageModel.imageName = [NSString changgeNonulWithString:isDownloadedmodel.fileName];
//            NSArray *array = [NSArray arrayWithObject:imageModel];
//            imageBrowserVC.imageModelArr = array;
//            [self pushViewController:imageBrowserVC animation:NO];
        }else if ([isDownloadedmodel.fileType isEqualToString:@"2"] || [isDownloadedmodel.fileType isEqualToString:@"3"]){
            //视频 mepg/avi/mp4
//            CSMoviePlayerViewController *VC = [[CSMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:documentPath]];
//            VC.moviePlayer.allowsAirPlay = YES;
//            //是否自动播放
//            //            VC.moviePlayer.shouldAutoplay = NO;
//            //显示模式。。
//            VC.moviePlayer.repeatMode = MPMovieRepeatModeOne;
//            VC.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
//            [self presentViewController:VC animated:YES completion:nil];
        }
//        else if ([isDownloadedmodel.fileType isEqualToString:@"3"]){
//            //音乐 mp3
//
//        }

    }
}

//点击下载
-(void)didClickDownloadButton:(UIButton *)button{
    RLMRealm *realm = [RLMRealm defaultRealm];
    BGFileDownLoadTableViewCell* downloadCell = [self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]];
    DefLog(@"我点击了第%ld行",(long)button.tag);
    BGFileDownModel *downloadModel = self.filesArray[button.tag];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    documentPath = [documentPath stringByAppendingFormat:@"/Files"];
//    documentPath = [documentPath stringByAppendingPathComponent:downloadModel.fileName];//不用加“/”
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager createDirectoryAtPath:documentPath withIntermediateDirectories:YES attributes:nil error:nil];
//    documentPath = [documentPath stringByAppendingFormat:@"/%@",downloadModel.fileName];

    NSString *fileName = [downloadModel.fileName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //    urlString = [urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [downloadModel.fileUrlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];

    documentPath = [documentPath stringByAppendingFormat:@"/%@",fileName];

//    NSString *fileType = [[documentPath componentsSeparatedByString:@"."] lastObject];
    BOOL exist = [manager fileExistsAtPath:documentPath];
    DefLog(@"%@",documentPath);
    if (exist) {
        DefLog(@"找到本地缓存的文件");
        downloadCell.fileDownBtn.hidden = YES;
    }else{
    //网络请求下载文件
    __weak __typeof(self)weakSelf = self;
//    [NetService downloadFile:urlString andSaveTo:documentPath progress:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
//        DefLog(@"%p %f/completed=%lld/total=%lld",downloadTask,(double)totalBytesWritten/(double)totalBytesExpectedToWrite, totalBytesWritten , totalBytesExpectedToWrite);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            downloadCell.fileDownBtn.hidden = YES;
//            downloadCell.downLoadingLabel.hidden = NO;
//            [downloadCell.fileDownBtn setNeedsDisplay];
//            [downloadCell.downLoadingLabel setNeedsDisplay];
//        });
//    } success:^(id objc) {
//        DefLog(@"succeed:%@",objc);
//        if (objc) {
//            NSString *localString = [(NSURL *)objc absoluteString];
//            [realm beginWriteTransaction];
//            downloadModel.fileLocalString = localString;
//            downloadModel.isOwnDownloaded = NO;
//            if ([self.shareType isEqualToString:@"0"]) {
//                downloadModel.isOwnDownloaded = YES;
//            }
//            [realm addObject:downloadModel];
//            [realm commitWriteTransaction];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                downloadCell.downLoadingLabel.text = @"下载完成";
//                downloadCell.downLoadingLabel.hidden = YES;
//                downloadCell.fileDownBtn.hidden = YES;
//                [downloadCell.fileDownBtn setNeedsDisplay];
//                [downloadCell.downLoadingLabel setNeedsDisplay];
//                [weakSelf.tableview reloadData];
//            });
//        }
//
//    } failure:^(NSString *errorCode, NSString *errorMsg) {
//        DefLog(@"error");
//         dispatch_async(dispatch_get_main_queue(), ^{
//            downloadCell.fileDownBtn.hidden = NO;
//            downloadCell.downLoadingLabel.hidden = YES;
//             });
//    }];
    }
}


////长按删除文件功能
//-(void)didClickDeleteFileWithName:(NSString *)filename{
//    BGFileDownModel *fileModel = [BGFileDownModel searchFileNameInRealm:filename];
//    if(fileModel.fileName){
//        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//        documentPath = [documentPath stringByAppendingFormat:@"/Files"];
//        //    documentPath = [documentPath stringByAppendingPathComponent:downloadModel.fileName];//不用加“/”
//        NSFileManager *manager = [NSFileManager defaultManager];
//        [manager createDirectoryAtPath:documentPath withIntermediateDirectories:YES attributes:nil error:nil];
//        //    documentPath = [documentPath stringByAppendingFormat:@"/%@",downloadModel.fileName];
////        NSString *fileName = [fileModel.fileName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        documentPath = [documentPath stringByAppendingFormat:@"/%@",fileModel.fileName];
//        //    NSString *fileType = [[documentPath componentsSeparatedByString:@"."] lastObject];
//        BOOL exist = [manager fileExistsAtPath:documentPath];
//        DefLog(@"%@",documentPath);
//        if (exist) {
//            DefLog(@"找到本地缓存的文件");
////            [self.filesArray removeObject:fileModel];
//            NSError *err;
//            [manager removeItemAtPath:documentPath error:&err];
//            if ([self.shareType isEqualToString:@"0"]) {
//                //删除服务器自己的文件
//                [self sendServerDeleteShareFile:fileModel];
//
//            }else{
//                //活动文件、群文件删除
//                RLMRealm *realm = [RLMRealm defaultRealm];
//                [realm beginWriteTransaction];
//                [realm deleteObject:fileModel];
//                [realm commitWriteTransaction];
//                //        [self.filesArray removeAllObjects];
//                [self getFileDatas];
//            }
//        }
//
//    }else{
//
//        DefQuickAlert(@"请先下载文件", nil);
//
//    }
//}

//删除个人后台文件
-(void)sendServerDeleteShareFile:(BGFileDownModel *)fileOwnModel{
    if(!fileOwnModel){
        return;
    }
    __weak __typeof(self)weakSelf = self;
//    [NetService postWithPath:shareDel params:@{@"fid":fileOwnModel.fid} success:^(id objc) {
//        DefLog(@"%@",objc);
//        RLMRealm *realm = [RLMRealm defaultRealm];
//        [realm beginWriteTransaction];
//        [realm deleteObject:fileOwnModel];
//        [realm commitWriteTransaction];
//        //        [self.filesArray removeAllObjects];
//        [weakSelf getFileDatas];
//    } failure:^(NSString *errorCode, NSString *errorMsg) {
//
//    }];
}

//点击跳转上传页
- (IBAction)uploadBtn:(UIButton *)sender {
    [self showSheet];
}

-(void)showSheet{
//    DSWeak;
//    [DSActionSheet ds_showActionSheetWithStyle:DSCustomActionSheetStyleTitle contentArray:@[@"本地文件",@"相册",@"拍照"]
//                                    imageArray:nil
//                                      redIndex:-1
//                                         title:@"上传内容"
//                                 configuration:^(DSActionSheet *tempView) {
//                                     weakSelf.weakSheet = tempView;
//                                 } ClikckButtonIndex:^(NSInteger index) {
//                                     NSLog(@"你点击了第 %ld 行！",(long)index);
//                                     [weakSelf.weakSheet ds_dismissDSActionSheet];
//                                     if (index == 0) {
//                                         [weakSelf pushUpLoafFileVC];
//                                     }else if (index == 1){
//                                         [weakSelf pushLocalPhoto];
//                                     }else {
//                                         [weakSelf pushTabkeImage];
//                                     }
//                                 }];
}

//上传文件
-(void)pushUpLoafFileVC{
//    BGUploadFileViewController *uploadFileVC = [[BGUploadFileViewController alloc]initWithNibName:@"BGUploadFileViewController" bundle:nil];
//    uploadFileVC.orgId = self.orgId;
//    uploadFileVC.shareType = self.shareType;
//    [self pushViewController:uploadFileVC animation:YES];

}
//显示相册
-(void)pushLocalPhoto{

    UIImagePickerController *pickerC = [[UIImagePickerController alloc] init];
    pickerC.delegate = self;
    pickerC.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
    pickerC.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:pickerC.sourceType];
    [self presentViewController:pickerC animated:YES completion:nil];

}

//显示拍照
-(void)pushTabkeImage{

    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您的设备不支持拍照" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    UIImagePickerController *pickerC = [[UIImagePickerController alloc] init];
    pickerC.sourceType = UIImagePickerControllerSourceTypeCamera;
    pickerC.delegate = self;
    [self presentViewController:pickerC animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{


//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    UIImage *image = [[UIImage alloc] init];
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if([mediaType isEqualToString:@"public.movie"])
    {
        return;
        //        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        //        NSLog(@"found a video");
        //        //获取视频的thumbnail
        //        MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:videoURL];
        //        image = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
        //        player = nil;
    }else{
        image = info[UIImagePickerControllerOriginalImage];
        NSString *documentPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingFormat:@"/Files"];
        //    documentPath = [documentPath stringByAppendingPathComponent:downloadModel.fileName];//不用加“/”
        NSFileManager *manager = [NSFileManager defaultManager];
        [manager createDirectoryAtPath:documentPath withIntermediateDirectories:YES attributes:nil error:nil];

        NSString *fileDateName = [NSString stringWithFormat:@"%.f.jpg",[[NSDate date] timeIntervalSince1970]];
        documentPath = [documentPath stringByAppendingFormat:@"/%@",fileDateName];
        [UIImageJPEGRepresentation(image,0.2) writeToFile:documentPath atomically:YES];
        [self uploadPickImage:documentPath andImageFileName:fileDateName];
//    NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
//    assets-library://asset/asset.JPG?id=106E99A1-4F6A-45A2-B320-B0AD4A8E8473&ext=JPG
//    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
//    {
//        ALAssetRepresentation *representation = [myasset defaultRepresentation];
//        self.imageFileName = [representation filename];
//        NSLog(@"imageFileName : %@",self.imageFileName);
//    };
//    [self dismissViewControllerAnimated:YES completion:nil];
//    [self uploadPickImage:[imageURL absoluteString]];
//    [self sendImageMessage:image];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableview reloadData];
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }
//    });
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self popViewControllerAnimation:YES];
}

-(void)uploadPickImage:(NSString *)ImageUrl andImageFileName:(NSString *)imageName{
//    [BGMBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak __typeof(self)weakSelf = self;
    RLMRealm *realm = [RLMRealm defaultRealm];
    NSDictionary *params = @{@"fileName":imageName,
                             @"shareType":self.shareType,
                             @"orgId":self.orgId};
//    NSString *localString = [model.fileLocalString substringFromIndex:7];
//    [NetService uploadFileTo:ShareUpload params:params file:ImageUrl success:^(id objc) {
//        [BGMBProgressHUD dismissProgressingHUDForView:self.view];
//        DefLog(@"上传文件成功：%@",objc);
//        DefQuickAlert(@"上传成功", nil);
//        [realm beginWriteTransaction];
//        BGFileDownModel *downModel = [[BGFileDownModel alloc] init];
//        downModel.fileName = imageName;
//        downModel.fileType = @"0";
//        downModel.fileUrlString = objc[@"data"][@"fileUrl"];
//        downModel.fileSize = objc[@"data"][@"fileSize"];
//        downModel.fileLocalString = ImageUrl;
//        downModel.isOwnDownloaded = NO;
//        if([weakSelf.shareType isEqualToString:@"0"]){
//            downModel.isOwnDownloaded = YES;
//        }
//        [realm addObject:downModel];
//        //添加进数组
//        [self.filesArray addObject:downModel];
//        [realm commitWriteTransaction];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tableview reloadData];
//        });
//    } failure:^(NSString *errorCode, NSString *errorMsg) {
//        [BGMBProgressHUD showProgressingHUDForView:self.view andMessage:@"上传失败！" andAfterDelay:1.5 andUserInteractionEnabled:NO];
//    }];
}

- (void)didReceiveMemoryWarning {
    [self clearCache];
}

- (void)clearCache {
    NSLog(@"内存警告");
}
@end
