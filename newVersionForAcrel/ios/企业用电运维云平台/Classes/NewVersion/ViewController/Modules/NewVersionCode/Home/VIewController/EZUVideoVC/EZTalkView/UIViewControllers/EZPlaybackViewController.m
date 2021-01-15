//
//  EZPlaybackViewController.m
//  EZOpenSDKDemo
//
//  Created by DeJohn Dong on 15/11/3.
//  Copyright © 2015年 hikvision. All rights reserved.
//

#import "EZPlaybackViewController.h"
//#import "UIViewController+EZBackPop.h"
#import "DDCollectionViewFlowLayout.h"
#import "MJRefresh.h"
#import "EZRecordDownloader.h"
#import "EZDeviceRecordDownloadTask.h"
#import "EZCloudRecordDownloadTask.h"
#import "EZRecordCell.h"
#import "DDKit.h"
#import "EZCloudRecordFile.h"
#import "EZDeviceRecordFile.h"
#import "EZPlayer.h"
#import "HIKLoadView.h"
#import "Masonry.h"
#import "EZCameraInfo.h"
#import "MBProgressHUD.h"
#import "Toast+UIView.h"
#import "EZCustomTableView.h"
#import <Photos/Photos.h>

@interface EZPlaybackViewController ()<DDCollectionViewDelegateFlowLayout, UICollectionViewDataSource,EZPlayerDelegate, UIAlertViewDelegate, EZRecordCellDelegate, EZCustomTableViewDelegate>
{
    BOOL _isOpenSound;
    BOOL _isPlaying;
    
    NSTimeInterval _playSeconds; //播放秒数
    NSTimeInterval _duringSeconds; //录像时长
    
    EZDeviceRecordFile *_deviceRecord;
    EZCloudRecordFile *_cloudRecord;
    
    BOOL _isShowToolbox;
    
    NSArray *cloudRate;
    NSArray *sdCardRate;
    NSArray *cloudRateStr;
    NSArray *sdCardRateStr;

//    BOOL _isDoBack;
}

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) NSMutableArray *records;
@property (nonatomic, strong) NSDate *beginTime;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic, strong) EZPlayer *player;
@property (nonatomic, strong) HIKLoadView *loadingView;
@property (nonatomic) BOOL isSelectedDevice;
@property (nonatomic, weak) IBOutlet UIView *playerView;
@property (nonatomic, weak) IBOutlet UILabel *largeTitleLabel;
@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, weak) IBOutlet UITextField *dateTextField;
@property (nonatomic, weak) IBOutlet UIToolbar *dateToolbar;
@property (nonatomic, weak) IBOutlet UIButton *dateButton;
@property (nonatomic, weak) IBOutlet UICollectionView *playbackList;
@property (nonatomic, weak) IBOutlet UIView *toolView;
@property (nonatomic, weak) IBOutlet UIButton *cloudButton;
@property (nonatomic, weak) IBOutlet UIButton *deviceButton;
@property (nonatomic, weak) IBOutlet UIView *selectedImageView;
@property (nonatomic, weak) IBOutlet UIView *playerToolbox;
@property (nonatomic, weak) IBOutlet UIButton *voiceButton;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UIButton *largeButton;
@property (weak, nonatomic) IBOutlet UIButton *rateBtn;
@property (nonatomic, weak) IBOutlet UILabel *playTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *duringTimeLabel;
@property (nonatomic, weak) IBOutlet UISlider *duringSlider;
@property (nonatomic, weak) IBOutlet UIButton *largeBackButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *selectedImageViewConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *playerToolboxConstraint;
@property (nonatomic, strong) NSTimer *playbackTimer;
@property (nonatomic, strong) NSTimer *rateBtnTimer;
@property (nonatomic, weak) IBOutlet UIImageView *noVideoImageView;
@property (nonatomic, weak) IBOutlet UILabel *noVideoLabel;
@property (nonatomic, strong) NSOperation *operation;
@property (nonatomic, strong) EZCameraInfo *cameraInfo;
@property (nonatomic, copy) NSString *verifyCode;
@property (nonatomic, strong) EZRecordDownloader *downloader;
@property (nonatomic, strong) EZCustomTableView *cloudRateView;
@property (nonatomic, strong) EZCustomTableView *sdCardRateView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playBackAspect;


@end

@implementation EZPlaybackViewController

- (void)dealloc
{
    DefLog(@"%@ dealloc", self.class);
    [EZOPENSDK releasePlayer:_player];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.isAutorotate = YES;
    self.largeTitleLabel.text = self.deviceInfo.deviceName;
    self.largeTitleLabel.hidden = YES;
    
    if(!_records)
        _records = [NSMutableArray new];
    
    DDCollectionViewFlowLayout *flowLayout = [[DDCollectionViewFlowLayout alloc] init];
    flowLayout.delegate = self;
    [self.playbackList setCollectionViewLayout:flowLayout];
    
    [self addHeaderRefresh];
    
    //demo只获取了设备的第一个通道
    _cameraInfo = [self.deviceInfo.cameraInfo dd_objectAtIndex:_cameraIndex];
    _player = [EZOPENSDK createPlayerWithDeviceSerial:_cameraInfo.deviceSerial cameraNo:_cameraInfo.cameraNo];
    _player.delegate = self;
    [_player setPlayerView:_playerView];
    //判断设备是否加密，加密就从demo的内存中获取设备验证码填入到播放器的验证码接口里，本demo只处理内存存储，本地持久化存储用户自行完成
    if (self.deviceInfo.isEncrypt)
    {
        _verifyCode = [[GlobalKit shareKit].deviceVerifyCodeBySerial objectForKey:_cameraInfo.deviceSerial];
        [_player setPlayVerifyCode:_verifyCode];
    }
    
    if(!_loadingView)
        _loadingView = [[HIKLoadView alloc] initWithHIKLoadViewStyle:HIKLoadViewStyleSqureClockWise];
    [self.view insertSubview:_loadingView aboveSubview:self.playerView];
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(@14);
        make.centerX.mas_equalTo(self.playerView.mas_centerX);
        make.centerY.mas_equalTo(self.playerView.mas_centerY);
    }];
    [_loadingView stopSquareClockwiseAnimation];
    _isOpenSound = YES;
    
    [self.duringSlider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    [self.duringSlider setThumbImage:[UIImage imageNamed:@"slider_sel"] forState:UIControlStateHighlighted];

    self.cloudButton.selected = YES;
    self.largeBackButton.hidden = YES;
    //配置顶部筛选颜色
    self.dateTextField.inputView = self.datePicker;
//    self.dateTextField.textColor = [UIColor whiteColor];
    self.dateTextField.inputAccessoryView = self.dateToolbar;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM-dd ▽";
    [self.dateButton setTitle:[dateFormatter stringFromDate:self.datePicker.date] forState:UIControlStateNormal];
    [self.dateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    dateFormatter.dateFormat = @"MM-dd △";
    [self.dateButton setTitle:[dateFormatter stringFromDate:self.datePicker.date] forState:UIControlStateSelected];
    [self.dateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    _isShowToolbox = YES;
    
    cloudRate = @[@(EZOPENSDK_PLAY_RATE_1),
                  @(EZOPENSDK_PLAY_RATE_4),
                  @(EZOPENSDK_PLAY_RATE_8),
                  @(EZOPENSDK_PLAY_RATE_16),
                  @(EZOPENSDK_PLAY_RATE_32)];
    
    
    sdCardRate = @[@(EZOPENSDK_PLAY_RATE_1),
                   @(EZOPENSDK_PLAY_RATE_4),
                   @(EZOPENSDK_PLAY_RATE_8),
                   @(EZOPENSDK_PLAY_RATE_16)];
    
    cloudRateStr = @[@"x1",@"x4",@"x8",@"x16",@"x32"];
    sdCardRateStr = @[@"x1",@"x4",@"x8",@"x16"];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self invalidateTimer];
    if (self.rateBtnTimer) {
        [self.rateBtnTimer invalidate];
        self.rateBtnTimer = nil;
    }
    [self.loadingView stopSquareClockwiseAnimation];
    [_player closeSound];
    [_player stopPlayback];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    self.navigationController.navigationBarHidden = NO;
    self.toolView.hidden = NO;
    self.playbackList.hidden = NO;
    self.largeBackButton.hidden = YES;
    self.largeTitleLabel.hidden = YES;
    self.playerToolboxConstraint.constant = 60.0f;
    self.largeButton.hidden = NO;
    self.voiceButton.hidden = NO;
    self.playButton.hidden = NO;
    //修改宽度比
    [NSLayoutConstraint deactivateConstraints:@[self.playBackAspect]];
     
    self.playBackAspect= [NSLayoutConstraint constraintWithItem:self.playerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.playerView attribute:NSLayoutAttributeHeight multiplier:1.7 constant:0];
     
    [NSLayoutConstraint activateConstraints:@[self.playBackAspect]];
    
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
       toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        self.playerToolboxConstraint.constant = 23.0f;
        self.playButton.hidden = YES;
        self.voiceButton.hidden = YES;
        self.largeButton.hidden = YES;
        self.toolView.hidden = YES;
        self.largeTitleLabel.hidden = NO;
        self.playbackList.hidden = YES;
        self.largeBackButton.hidden = NO;
        self.navigationController.navigationBarHidden = YES;
        
        //修改宽度比
           [NSLayoutConstraint deactivateConstraints:@[self.playBackAspect]];
            
           self.playBackAspect= [NSLayoutConstraint constraintWithItem:self.playerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.playerView attribute:NSLayoutAttributeHeight multiplier:2.1 constant:0];
            
           [NSLayoutConstraint activateConstraints:@[self.playBackAspect]];
    }
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.alertViewStyle == UIAlertViewStyleSecureTextInput)
    {
        if (buttonIndex == 1)
        {
            NSString *checkCode = [alertView textFieldAtIndex:0].text;
            [[GlobalKit shareKit].deviceVerifyCodeBySerial setValue:checkCode forKey:self.deviceInfo.deviceSerial];
            [self.player setPlayVerifyCode:checkCode];
            [self doPlayback];
        }
    }
    else
    {
        if (buttonIndex == 1)
        {
            [self showSetPassword];
            return;
        }
    }
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_records count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(DDCollectionViewFlowLayout *)layout numberOfColumnsInSection:(NSInteger)section
{
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EZRecordCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RecordCell" forIndexPath:indexPath];
    cell.deviceSerial = self.deviceInfo.deviceSerial;
    cell.isSelectedDevice = _isSelectedDevice;
    cell.delegate = self;
    
    if(_isSelectedDevice)
    {
        [cell setDeviceRecord:[_records dd_objectAtIndex:indexPath.row] selected:(indexPath.row == self.selectedIndexPath.row)];
    }
    else
    {
        [cell setCloudRecord:[_records dd_objectAtIndex:_records.count- 1 -indexPath.row] selected:(indexPath.row == self.selectedIndexPath.row)];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate Methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(106 * [UIScreen mainScreen].bounds.size.width / 320.0f, 80.0 * [UIScreen mainScreen].bounds.size.width / 320.0f);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self invalidateTimer];
    [_player stopPlayback];
    if(_isSelectedDevice)
    {
        _deviceRecord = [_records dd_objectAtIndex:indexPath.row];
        [_player startPlaybackFromDevice:_deviceRecord];
    }
    else
    {
        _cloudRecord = [_records dd_objectAtIndex:_records.count - 1 - indexPath.row];
        [_player startPlaybackFromCloud:_cloudRecord];
    }
    
    [self duringTimeShow];
    
    self.selectedIndexPath = indexPath;
    [collectionView reloadData];
    
    [self.loadingView startSquareClcokwiseAnimation];

}

#pragma mark - ValidateCode Methods

- (void)showSetPassword
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"device_input_verify_code", @"请输入视频图片加密密码")
                                                        message:NSLocalizedString(@"device_verify_code_tip", @"您的视频已加密，请输入密码进行查看，初始密码为机身标签上的验证码，如果没有验证码，请输入ABCDEF（密码区分大小写)")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"cancel", @"取消")
                                              otherButtonTitles:NSLocalizedString(@"done", @"确定"), nil];
    alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alertView show];
}

- (void)showRetry
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"device_tip_title", @"温馨提示")
                                                        message:NSLocalizedString(@"device_verify_code_wrong", @"设备密码错误")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"cancel", @"取消")
                                              otherButtonTitles:NSLocalizedString(@"retry", @"重试"), nil];
    [alertView show];
}
#pragma mark - EZRecordCellDelegate Methods
- (void) didClickDownlodBtn:(id)recordFile {
    
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    dateformatter.dateFormat = @"yyyyMMddHHmmss";
    
    if (_isSelectedDevice) {
        
        EZDeviceRecordFile *deviceFile = (EZDeviceRecordFile *)recordFile;
        NSString *path = [NSString stringWithFormat:@"%@/ezopensdk/DeviceRecord/%@.mov",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject], [dateformatter stringFromDate:deviceFile.startTime]];
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//
//        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//        NSString  *fullPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, @"jaibaili.mp4"];
        DefLog(@"path: %@ ", path);
        [self startDeviceRecordDownload:path deviceFile:deviceFile];
    }
    else {
        
        EZCloudRecordFile *cloudFile = (EZCloudRecordFile *)recordFile;
        NSString *path = [NSString stringWithFormat:@"%@/ezopensdk/CloudRecord/%@.mov",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject], [dateformatter stringFromDate:cloudFile.startTime]];
        DefLog(@"path: %@ ", path);
        [self startCloudRecordDownload:path cloudFile:cloudFile];
    }
}

- (void) startDeviceRecordDownload:(NSString*)path deviceFile:(EZDeviceRecordFile *)deviceFile {
    
    
//    NSString *string = @"2019-07-25T06:05:00";
//    NSDateFormatter *format = [[NSDateFormatter alloc] init];
//    format.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
//    NSDate *data = [format dateFromString:string];
//
//
//    deviceFile.startTime = data;
    //创建下载任务
    [[EZDeviceRecordDownloadTask alloc]initTaskWithID:@"1" DeviceRecordFileInfo:deviceFile deviceSerial:self.deviceInfo.deviceSerial cameraNo:self.cameraInfo.cameraNo verifyCode:self.verifyCode savePath:path completion:^(EZDeviceRecordDownloadTask * _Nonnull task) {
        
        [self.navigationController.view makeToast:[NSString stringWithFormat:@"SDD Task:%@-开始下载", task.taskID]];
        
        //设置回调函数
        __weak typeof(task) weakTask = task;
        [task setDownloadCallBackWithFinshed:^(EZRecordDownloaderStatus statusCode) {
            
            __strong typeof(weakTask) strongTask = weakTask;
            DefLog(@"statuCode:%ld", (long)statusCode);
            
            switch (statusCode) {
                case EZRecordDownloaderStatusFinish:
                    
                    [self.navigationController.view makeToast:[NSString stringWithFormat:@"SDD Task:%@-下载成功", strongTask.taskID]];
//                    [self saveVideo:path];
                    [self logAllAlbumName:path];
                    break;
                case EZRecordDownloaderStatusMoreToken:
                    
                    DefLog(@"EZRecordDownloaderStatusMoreToken.");
                    
                    break;
                default:
                    
                    break;
            }
            [[EZRecordDownloader shareInstane] stopDownloadTask:strongTask];
            
        } failed:^(NSError * _Nonnull error) {
            
            DefLog(@"EZDeviceRecordDownloader error:%@", error);
            __strong typeof(weakTask) strongTask = weakTask;
            
            if (error.code == 395416 || error.code == 380045) {
                [self.navigationController.view makeToast:[NSString stringWithFormat:@"SDD Task:%@-下载限制，达到最大连接数", strongTask.taskID]];
            }
            else {
                [self.navigationController.view makeToast:[NSString stringWithFormat:@"SDD Task:%@-下载失败", strongTask.taskID]];
            }
            
            [[EZRecordDownloader shareInstane] stopDownloadTask:strongTask];
        }];
        
        //加入下载队列下载
        [[EZRecordDownloader shareInstane] addDownloadTask:task];
    }];
}

//videoPath为视频下载到本地之后的本地路径
- (void)saveVideo:(NSString *)videoPath{
    BOOL videoCompatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoPath);
    //检查视频能否保存至相册
//    if (videoCompatible) {
        UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self,
    @selector(video:didFinishSavingWithError:contextInfo:), nil);
//    } else {
//        DefLog(@"该视频无法保存至相册");
//    }
//    if (videoPath) {
//        NSURL *url = [NSURL URLWithString:videoPath];
//        BOOL compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([url path]);
//        if (compatible)
//        {
//            //保存相册核心代码
//            UISaveVideoAtPathToSavedPhotosAlbum([url path], self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
//        }
//    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        DefLog(@"保存视频失败：%@", error);
    } else {
        DefLog(@"保存视频成功");
    }
}

//保存视频完成之后的回调
-(void)savedPhotoImage:(UIImage*)image didFinishSavingWithError: (NSError *)error contextInfo: (void *)contextInfo {
    if (error) {
        DefLog(@"保存视频失败%@", error.localizedDescription);
        [MBProgressHUD showError:@"视频保存失败"];
    }
    else {
        DefLog(@"保存视频成功");
        [MBProgressHUD showSuccess:@"视频保存成功"];
    }
}

-(void)logAllAlbumName:(NSString *)path{
//    PHAssetCollection *desCollection;
//    PHAssetCollectionChangeRequest *collectionRuquest;
//    PHFetchResult <PHAssetCollection*>*result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
//    for (PHAssetCollection *collect in result) {
//        desCollection = collect;
//        DefLog(@"%@",collect.localizedTitle);
//        if ([collect.localizedTitle containsString:@"aaa"]) {
//           collectionRuquest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collect];
//        }
//    }
//    __block NSString *colID = nil;
//    NSError *error = nil;
//
//    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
//        colID = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:@"aaa"].placeholderForCreatedAssetCollection.localIdentifier;
//    } error:&error];
//    if (error) {
//        DefLog(@"创建相册: %@ 失败",colID);
//    }
//    DefLog(@"相册: %@ ",colID);
//    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//           //请求创建一个Asset
//           PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:path]];
//           //视频存储的相册
////           PHAssetCollectionChangeRequest *collectonRequest = [PHPhotoLibrary photoCollectionWithAlbumName:@"相册名"];
//           //为Asset创建一个占位符，放到相册编辑请求中
//           PHObjectPlaceholder *placeHolder = [assetRequest placeholderForCreatedAsset];
//           //相册中添加视频
//           [collectionRuquest addAssets:@[placeHolder]];
//
//       } completionHandler:^(BOOL success, NSError *error) {
//           if (success) {
//               DefLog(@"已将视频保存至相册");
//           } else {
//               DefLog(@"未能保存视频到相册");
//           }
//       }];
    
//    [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[colID] options:nil];
    
//    __block PHObjectPlaceholder *placeholderAsset=nil;
//    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//        PHAssetChangeRequest*changeRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"Prepare" ofType:@"mp4"] ]];
//        PHAssetChangeRequest*changeRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL URLWithString:path]];
//        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:path]];
//        placeholderAsset = changeRequest.placeholderForCreatedAsset;
//    } completionHandler:^(BOOL success, NSError * _Nullable error) {
//        if (success) {
//            DefLog(@"已将视频保存至相册");
//        } else {
//            DefLog(@"未能保存视频到相册");
//        }
//        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//
//            PHAsset *asset = [[PHAsset fetchAssetsWithLocalIdentifiers:@[placeholderAsset.localIdentifier] options:nil] lastObject];
//
//            [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:desCollection] addAssets:@[asset]];
//        } completionHandler:^(BOOL success, NSError * _Nullable error) {
//            if (success) {
//                DefLog(@"存入相册成功");
//            }
//        }];
//    }];
    
    PHPhotoLibrary *library = [PHPhotoLibrary sharedPhotoLibrary];
 
    NSError *error = nil;
    __block NSString *assetId = nil;

    // 保存视频到【Camera Roll】(相机胶卷)
    [library performChangesAndWait:^{

//    assetId = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:path]].placeholderForCreatedAsset.localIdentifier;
    assetId = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:path]].placeholderForCreatedAsset.localIdentifier;
    } error:&error];

    DefLog(@"error1: %@", error);

   
   

    
}


- (void) startCloudRecordDownload:(NSString*)path cloudFile:(EZCloudRecordFile *)cloudFile {
    
    EZCloudRecordDownloadTask *task = [[EZCloudRecordDownloadTask alloc] initTaskWithID:@"2" cloudRecordFile:cloudFile verifyCode:self.verifyCode savePath:path];
    [self.navigationController.view makeToast:[NSString stringWithFormat:@"CD Task:%@-开始下载", task.taskID]];
    //设置回调函数
    __weak typeof(task) weakTask = task;
    [task setDownloadCallBackWithFinshed:^(EZRecordDownloaderStatus statusCode) {
        
        __strong typeof(weakTask) strongTask = weakTask;
        DefLog(@"statuCode:%ld", (long)statusCode);
        
        switch (statusCode) {
            case EZRecordDownloaderStatusFinish:
                
                [self.navigationController.view makeToast:[NSString stringWithFormat:@"CD Task:%@-下载成功", strongTask.taskID]];
                
                break;
            case EZRecordDownloaderStatusMoreToken:
                
                DefLog(@"EZRecordDownloaderStatusMoreToken.");
                
                break;
            default:
                
                break;
        }
        [[EZRecordDownloader shareInstane] stopDownloadTask:strongTask];
        
    } failed:^(NSError * _Nonnull error) {
        
        DefLog(@"EZDeviceRecordDownloader error:%@", error);
        __strong typeof(weakTask) strongTask = weakTask;
        
        [self.navigationController.view makeToast:[NSString stringWithFormat:@"CD Task:%@-下载失败", strongTask.taskID]];
        
        [[EZRecordDownloader shareInstane] stopDownloadTask:strongTask];
    }];
    
    //加入下载队列下载
    [[EZRecordDownloader shareInstane] addDownloadTask:task];
}

#pragma mark - PlayerDelegate Methods

- (void)player:(EZPlayer *)player didPlayFailed:(NSError *)error
{
    [self invalidateTimer];
    [player stopPlayback];
    
    DefLog(@"player: %@ didPlayFailed: %@", player, error);
    //如果是需要验证码或者是验证码错误
    if (error.code == EZ_SDK_NEED_VALIDATECODE) {
        [self showSetPassword];
        return;
    } else if (error.code == EZ_SDK_VALIDATECODE_NOT_MATCH) {
        [self showRetry];
        return;
    }
  
    if (error.code == 400409) {
        _isPlaying = NO;
        [self.playButton setImage:[UIImage imageNamed:@"preview_play_btn_sel"] forState:UIControlStateHighlighted];
        [self.playButton setImage:[UIImage imageNamed:@"preview_play_btn"] forState:UIControlStateNormal];
    }
    
    NSString *code = [NSString stringWithFormat:@"%ld",error.code];
    NSString *str = [NSString changgeNonulWithString:[self retErrYinshiyunDic][code]];
    if (str) {
        [UIView dd_showDetailMessage:[NSString stringWithFormat:@"%d:%@", (int)error.code,str]];
    }else{
        [UIView dd_showDetailMessage:[NSString stringWithFormat:@"%d", (int)error.code]];
    }
}

- (void)player:(EZPlayer *)player didReceivedMessage:(NSInteger)messageCode
{
    DefLog(@"player: %@ didReceivedMessage: %d", player, (int)messageCode);
    if(messageCode == PLAYER_PLAYBACK_START)
    {
        _isPlaying = YES;
        [self.playButton setImage:[UIImage imageNamed:@"pause_sel1"] forState:UIControlStateHighlighted];
        [self.playButton setImage:[UIImage imageNamed:@"pause1"] forState:UIControlStateNormal];
        [self.loadingView stopSquareClockwiseAnimation];
        
        if (!_isOpenSound)
        {
            [player closeSound];
        }
        
        [self invalidateTimer];
        
        self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                              target:self
                                                            selector:@selector(playBoxToolRefresh:)
                                                            userInfo:nil
                                                             repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.playbackTimer forMode:NSRunLoopCommonModes];
        
        [self performSelector:@selector(hiddenPlayerToolbox:) withObject:nil afterDelay:5.0f];
        
        DefLog(@"GetStreamFetchType:%d", [self.player getStreamFetchType]);
    }
    else if (messageCode == PLAYER_PLAYBACK_STOP)
    {
        [self invalidateTimer];
        
        self.duringSlider.value = 1.0;
        self.playTimeLabel.text = self.duringTimeLabel.text;
        
        [self.playButton setImage:[UIImage imageNamed:@"preview_play_btn_sel"] forState:UIControlStateHighlighted];
        [self.playButton setImage:[UIImage imageNamed:@"preview_play_btn"] forState:UIControlStateNormal];
    }
}

- (void) invalidateTimer {
 
    if(self.playbackTimer)
    {
        [self.playbackTimer invalidate];
        self.playbackTimer = nil;
    }
}

- (IBAction)showToolBar:(id)sender
{
    if(!_isShowToolbox){
        _isShowToolbox = YES;
        [UIView animateWithDuration:0.3 animations:^{
            self.playerToolbox.alpha = 1.0f;
        }];
        [self performSelector:@selector(hiddenPlayerToolbox:) withObject:nil afterDelay:5.0f];
    }
    else{
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenPlayerToolbox:) object:nil];
        [self hiddenPlayerToolbox:nil];
    }
}

- (IBAction)hiddenPlayerToolbox:(id)sender
{
//    [UIView animateWithDuration:0.3
//                     animations:^{
//                         self.playerToolbox.alpha = 0.0f;
//                     }
//                     completion:^(BOOL finished) {
//                         _isShowToolbox = NO;
//                     }];
}

#pragma mark - MJRefresh Methods

- (void)addHeaderRefresh
{
    [self.operation cancel];
    [self.playbackList.header endRefreshing];
    __weak __typeof(self) weakSelf = self;
    EZCameraInfo *cameraInfo = [self.deviceInfo.cameraInfo objectAtIndex:_cameraIndex];
    self.playbackList.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.noVideoImageView.hidden = YES;
        weakSelf.noVideoLabel.hidden = YES;
        if (weakSelf.isSelectedDevice) {
            weakSelf.operation = [EZOPENSDK searchRecordFileFromDevice:cameraInfo.deviceSerial
                                                              cameraNo:cameraInfo.cameraNo
                                                             beginTime:weakSelf.beginTime
                                                               endTime:weakSelf.endTime
                                                            completion:^(NSArray *deviceRecords, NSError *error) {
                                                                DefLog(@"deviceRecords is %@, error is %@", deviceRecords, error);
                                                                if (!error)
                                                                {
                                                                    [weakSelf.records removeAllObjects];
                                                                    if(deviceRecords.count == 0)
                                                                    {
                                                                        weakSelf.noVideoLabel.hidden = NO;
                                                                        weakSelf.noVideoImageView.hidden = NO;
                                                                        [weakSelf.playbackList reloadData];
                                                                        [weakSelf.playbackList.header endRefreshing];
                                                                        return;
                                                                    }
                                                                    
                                                                    [weakSelf.records addObjectsFromArray:deviceRecords];
                                                                    [weakSelf.playbackList reloadData];
                                                                    [weakSelf.playbackList.header endRefreshing];
                                                                    [weakSelf doPlayback];
                                                                }
                                                                else
                                                                {
                                                                    NSString *code = [NSString stringWithFormat:@"%ld",error.code];
                                                                    NSString *str = [NSString changgeNonulWithString:[self retErrYinshiyunDic][code]];
                                                                    if (str) {
                                                                         [UIView dd_showMessage:[NSString stringWithFormat:@"error code  (%d:%@)",(int) error.code,str] onParentView:self.view];
                                                                    }else{
                                                                        [UIView dd_showMessage:[NSString stringWithFormat:@"error code  %d",(int) error.code] onParentView:self.view];
                                                                    }
                                                                    
                                                                    [weakSelf.playbackList.header endRefreshing];
                                                                    [weakSelf.records removeAllObjects];
                                                                    [weakSelf.playbackList reloadData];
                                                                }
                                                            }];
        }
        else
        {
            weakSelf.operation =  [EZOPENSDK searchRecordFileFromCloud:cameraInfo.deviceSerial
                                                              cameraNo:cameraInfo.cameraNo
                                                             beginTime:weakSelf.beginTime
                                                               endTime:weakSelf.endTime
                                                            completion:^(NSArray *cloudRecords, NSError *error) {
                                                                
                                                                DefLog(@"cloudRecords is %@, error is %@", cloudRecords, error);
                                                                if (error)
                                                                {
                                                                    if (error.code > 0) {
                                                                       NSString *code = [NSString stringWithFormat:@"%ld",error.code];
                                                                        NSString *str = [NSString changgeNonulWithString:[self retErrYinshiyunDic][code]];
                                                                        if (str) {
                                                                             [UIView dd_showMessage:[NSString stringWithFormat:@"error code  (%d:%@)",(int) error.code,str] onParentView:self.view];
                                                                        }else{
                                                                            [UIView dd_showMessage:[NSString stringWithFormat:@"error code  %d",(int) error.code] onParentView:self.view];
                                                                        }
                                                                    }
                                                                    [weakSelf.playbackList.header endRefreshing];
                                                                    [weakSelf.records removeAllObjects];
                                                                    [weakSelf.playbackList reloadData];
                                                                    return ;
                                                                }
                                                                [weakSelf.records removeAllObjects];
                                                                if(cloudRecords.count == 0)
                                                                {
                                                                    weakSelf.noVideoLabel.hidden = NO;
                                                                    weakSelf.noVideoImageView.hidden = NO;
                                                                    [weakSelf.playbackList reloadData];
                                                                    [weakSelf.playbackList.header endRefreshing];
                                                                    return;
                                                                }
                                                                
                                                                [weakSelf.records addObjectsFromArray:cloudRecords];
                                                                [weakSelf.playbackList reloadData];
                                                                [weakSelf.playbackList.header endRefreshing];
                                                                [weakSelf doPlayback];
                                                            }];
        }
    }];
    self.playbackList.header.automaticallyChangeAlpha = YES;
    [self.playbackList.header beginRefreshing];
}

#pragma mark - Action Methods

- (void)doPlayback
{   
    if (_isSelectedDevice)
    {
        if (self.selectedIndexPath)
        {
            _deviceRecord = [_records dd_objectAtIndex:self.selectedIndexPath.row];
            [_player startPlaybackFromDevice:_deviceRecord];
        }
        else
        {
            _deviceRecord = [_records firstObject];
        }
//        EZDeviceRecordFile *firstFile = [_records firstObject];
//        EZDeviceRecordFile *lastFile = [_records lastObject];
//        _deviceRecord = [[EZDeviceRecordFile alloc] init];
//        _deviceRecord.startTime = firstFile.startTime;
//        _deviceRecord.stopTime = lastFile.stopTime;
        [_player startPlaybackFromDevice:_deviceRecord];
    }
    else
    {
        if (self.selectedIndexPath)
        {
            _cloudRecord = [_records dd_objectAtIndex:_records.count - 1 - self.selectedIndexPath.row];
            [_player startPlaybackFromCloud:_cloudRecord];
        }
        else
        {
            _cloudRecord = [_records lastObject];
            [_player startPlaybackFromCloud:_cloudRecord];
        }
    }
    
    [self duringTimeShow];
    [self.loadingView startSquareClcokwiseAnimation];
    
    _isPlaying = YES;
}

- (IBAction)large:(id)sender
{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (IBAction)largeBack:(id)sender
{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (IBAction)voiceButtonClicked:(id)sender
{
    if(_isOpenSound){
        [_player closeSound];
        [self.voiceButton setImage:[UIImage imageNamed:@"preview_unvoice_btn_sel"] forState:UIControlStateHighlighted];
        [self.voiceButton setImage:[UIImage imageNamed:@"preview_unvoice_btn"] forState:UIControlStateNormal];
    }
    else
    {
        [_player openSound];
        [self.voiceButton setImage:[UIImage imageNamed:@"preview_voice_btn_sel"] forState:UIControlStateHighlighted];
        [self.voiceButton setImage:[UIImage imageNamed:@"preview_voice_btn"] forState:UIControlStateNormal];
    }
    _isOpenSound = !_isOpenSound;
}

#pragma mark - EZCustomTableViewDelegate
- (void) EZCustomTableView:(EZCustomTableView *)customTableView didSelectedTableViewCell:(NSIndexPath *)indexPath {
    
    [self hideRateView];
    
    if(_isSelectedDevice) {
        
        EZPlaybackRate rate = [sdCardRate[indexPath.row] intValue];
        [_player setPlaybackRate:rate];
    }
    else {

        EZPlaybackRate rate = [cloudRate[indexPath.row] intValue];
        [_player setCloudPlaybackRate:rate];
    }
}

- (EZCustomTableView *)sdCardRateView {
    
    if (!_sdCardRateView) {
        _sdCardRateView = [[EZCustomTableView alloc] initTableViewWith:sdCardRateStr delegate:self];
        _sdCardRateView.hidden = YES;
        
        [self.view addSubview:_sdCardRateView];
        [_sdCardRateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self.rateBtn);
            make.width.mas_equalTo(70);
            make.height.mas_equalTo(150);
        }];
    }
    return _sdCardRateView;
}

- (EZCustomTableView *)cloudRateView {
    
    if (!_cloudRateView) {
        _cloudRateView = [[EZCustomTableView alloc] initTableViewWith:cloudRateStr delegate:self];
        _cloudRateView.hidden = YES;
        
        [self.view addSubview:_cloudRateView];
        [_cloudRateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self.rateBtn);
            make.width.mas_equalTo(70);
            make.height.mas_equalTo(150);
        }];
    }
    return _cloudRateView;
}

- (IBAction)clickRateBtn:(UIButton *)sender {

    self.rateBtnTimer = [NSTimer scheduledTimerWithTimeInterval:2.5f target:self selector:@selector(hideRateView) userInfo:nil repeats:NO];
    
    if(_isSelectedDevice) {
        
        self.sdCardRateView.hidden = NO;
    }
    else {
        
        self.cloudRateView.hidden = NO;
    }
}

- (void) hideRateView {
    self.cloudRateView.hidden = YES;
    self.sdCardRateView.hidden = YES;
    [self.rateBtnTimer invalidate];
    self.rateBtnTimer = nil;
}

- (IBAction)duringValueChange:(id)sender
{
    NSDate *offsetTime = nil;
    if(_isSelectedDevice)
    {
        offsetTime = [_deviceRecord.startTime dateByAddingTimeInterval:_duringSeconds * self.duringSlider.value];
    }
    else
    {
        offsetTime = [_cloudRecord.startTime dateByAddingTimeInterval:_duringSeconds * self.duringSlider.value];
    }
    
    [self invalidateTimer];
    
    [_player seekPlayback:offsetTime];
    [self.loadingView startSquareClcokwiseAnimation];
}

- (IBAction)playButtonClicked:(id)sender
{
    if(_isPlaying)
    {
        if (!self.records.count) {
            [self.navigationController.view makeToast:@"无可回放文件"];
            return;
        }
        [_player pausePlayback];
        [self.playButton setImage:[UIImage imageNamed:@"preview_play_btn_sel"] forState:UIControlStateHighlighted];
        [self.playButton setImage:[UIImage imageNamed:@"preview_play_btn"] forState:UIControlStateNormal];
        if(_playbackTimer && !_isSelectedDevice)
        {
            [_playbackTimer invalidate];
            _playbackTimer = nil;
        }
    }
    else
    {
        
        [_player resumePlayback];
        [self.playButton setImage:[UIImage imageNamed:@"pause_sel1"] forState:UIControlStateHighlighted];
        [self.playButton setImage:[UIImage imageNamed:@"pause1"] forState:UIControlStateNormal];
        if(!_isSelectedDevice)
            [self.loadingView startSquareClcokwiseAnimation];
    }
    _isPlaying = !_isPlaying;
}

- (IBAction)cloudButtonClicked:(id)sender
{
    if (self.player)
    {
        [self invalidateTimer];
        [self.player stopPlayback];
    }
    self.selectedIndexPath = nil;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.selectedImageViewConstraint.constant = 0;
                         [self.toolView setNeedsUpdateConstraints];
                         [self.toolView layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         self.cloudButton.selected = YES;
                         self.deviceButton.selected = NO;
                     }];
    _isSelectedDevice = NO;
    [self.records removeAllObjects];
    [self.playbackList reloadData];
    [self addHeaderRefresh];
}

- (IBAction)deviceButtonClicked:(id)sender
{
    if (self.player)
    {
        [self invalidateTimer];
        [self.player stopPlayback];
    }
    self.selectedIndexPath = nil;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.selectedImageViewConstraint.constant = self.view.bounds.size.width / 2.0f;
                         [self.toolView setNeedsUpdateConstraints];
                         [self.toolView layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         self.cloudButton.selected = NO;
                         self.deviceButton.selected = YES;
                     }];
    _isSelectedDevice = YES;
    [self.records removeAllObjects];
    [self.playbackList reloadData];
    [self addHeaderRefresh];
}

- (IBAction)cancel:(id)sender
{
    [self.dateTextField resignFirstResponder];
    self.dateButton.selected = NO;
}

- (IBAction)confirm:(id)sender
{
    [self.dateTextField resignFirstResponder];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM-dd ▽";
    [self.dateButton setTitle:[dateFormatter stringFromDate:self.datePicker.date] forState:UIControlStateNormal];
    dateFormatter.dateFormat = @"MM-dd △";
    [self.dateButton setTitle:[dateFormatter stringFromDate:self.datePicker.date] forState:UIControlStateSelected];
    self.dateButton.selected = NO;
    
    [self.playbackList.header beginRefreshing];
}

- (IBAction)dateButtonClicked:(id)sender
{
    [self.dateTextField becomeFirstResponder];
    self.datePicker.maximumDate = [NSDate date];
    self.dateButton.selected = YES;
}

- (void)duringTimeShow
{
    if(_isSelectedDevice)
    {
        _duringSeconds = [_deviceRecord.stopTime timeIntervalSinceDate:_deviceRecord.startTime];
    }
    else
    {
        _duringSeconds = [_cloudRecord.stopTime timeIntervalSinceDate:_cloudRecord.startTime];
    }
    
    if(_duringSeconds >= 3600)
    {
        int hour = (int)_duringSeconds / 3600;
        int minute =  ((int)_duringSeconds % 3600) / 60;
        int seconds = (int)_duringSeconds % 60;
        self.duringTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, seconds];
        self.playTimeLabel.text = @"00:00:00";
    }
    else
    {
        int minute =  (int)_duringSeconds / 60;
        int seconds = (int)_duringSeconds % 60;
        self.duringTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", minute, seconds];
        self.playTimeLabel.text = @"00:00";
    }
}

- (void)playBoxToolRefresh:(NSTimer *)timer
{
    NSDate *currentTime = [_player getOSDTime];

    if(_isSelectedDevice)
    {
        _playSeconds = [currentTime timeIntervalSinceDate:_deviceRecord.startTime];
    }
    else
    {
        _playSeconds = [currentTime timeIntervalSinceDate:_cloudRecord.startTime];
    }

    if(_playSeconds >= 3600)
    {
        int hour = (int)_playSeconds / 3600;
        int minute =  ((int)_playSeconds % 3600) / 60;
        int seconds = (int)_playSeconds % 60;
        self.playTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, seconds];
    }
    else
    {
        int minute =  (int)_playSeconds / 60;
        int seconds = (int)_playSeconds % 60;
        self.playTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", minute, seconds];
    }
    
    self.duringSlider.value = _playSeconds/_duringSeconds;
}

#pragma mark - Get Methods

- (NSDate *)beginTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *beginTimeString = [NSString stringWithFormat:@"%@ 00:00:00", [dateFormatter stringFromDate:self.datePicker.date]];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    _beginTime = [dateFormatter dateFromString:beginTimeString];
    return _beginTime;
}

- (NSDate *)endTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *beginTimeString = [NSString stringWithFormat:@"%@ 23:59:59", [dateFormatter stringFromDate:self.datePicker.date]];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    _endTime = [dateFormatter dateFromString:beginTimeString];
    return _endTime;
}

-(NSDictionary *)retErrYinshiyunDic{
    return @{@"101001":@"用户名不合法",
@"101002":@"用户名已被占用",
@"101003":@"密码不合法",
@"101004":@"密码为同一字符",
@"101006":@"手机号码已经被注册",
@"101007":@"手机号未注册",
@"101008":@"手机号码不合法",
@"101009":@"用户名与手机不匹配",
@"101010":@"获取验证码失败",
@"101011":@"验证码错误",
@"101012":@"验证码失效",
@"101013":@"用户不存在",
@"101014":@"密码不正确或者appKey不正确",
@"101015":@"用户被锁住",
@"101021":@"验证参数异常",
@"101026":@"邮箱已经被注册",
@"101031":@"邮箱未注册",
@"101032":@"邮箱不合法",
@"101041":@"获取验证码过于频繁",
@"101043":@"手机验证码输入错误超过规定次数",
@"102000":@"设备不存在",
@"102001":@"摄像机不存在",
@"102003":@"设备不在线",
@"102004":@"设备异常",
@"102007":@"设备序列号不正确",
@"102009":@"设备请求响应超时异常",
@"105000":@"设备已被自己添加",
@"105001":@"设备已被别人添加",
@"105002":@"设备验证码错误",
@"107001":@"邀请不存在",
@"107002":@"邀请验证失败",
@"107003":@"邀请用户不匹配",
@"107004":@"无法取消邀请",
@"107005":@"无法删除邀请",
@"107006":@"不能邀请自己",
@"107007":@"重复邀请",
@"110001":@"参数错误",
@"110002":@"accessToken异常或过期",
@"110004":@"用户不存在",
@"110005":@"appKey异常",
@"110006":@"ip受限",
@"110007":@"调用接口总次数达到上限请升级企业版",
@"110008":@"签名错误",
@"110009":@"签名参数错误",
@"110010":@"签名超时",
@"110011":@"未开通萤石云服务",
@"110012":@"第三方账户与萤石账号已经绑定",
@"110013":@"应用没有权限调用此接口",
@"110014":@"APPKEY下对应的第三方userId和phone未绑定",
@"110017":@"appKey不存在",
@"110018":@"AccessToken与Appkey不匹配",
@"110019":@"密码错误",
@"110020":@"请求方法为空",
@"110021":@"ticket校验失败",
@"110022":@"透传目的地非法",
@"110023":@"appKey与bundleId不匹配",
@"110024":@"无透传权限",
@"110025":@"appKey被禁止使用通明通道",
@"110026":@"设备数量超出个人版限制，当前设备无法操作请升级企业版",
@"110027":@"appKey数量超出安全限制，升级企业版可取消限制",
@"110028":@"个人版账户抓图接口日调用次数超出限制请升级企业版",
@"110029":@"调用频率超过个人版账户频率限制20次/分钟 请升级企业版",
@"110030":@"appKey和appSecret不匹配 请检查appKey和appSecret是否对应",
@"110031":@"子账户或萤石用户没有权限",
@"110032":@"子账户不存在",
@"110033":@"子账户未设置授权策略",
@"110034":@"子账户已存在",
@"110035":@"获取子账户AccessToken异常,子账户不存在或子账户不属于该开发者",
@"110036":@"子账户被禁用",
@"110051":@"无权限进行抓图",
@"120001":@"通道不存在",
@"120002":@"设备不存在",
@"120003":@"参数异常，SDK版本过低",
@"120004":@"参数异常，SDK版本过低",
@"120005":@"安全认证失败",
@"120006":@"网络异常",
@"120007":@"设备不在线",
@"120008":@"设备响应超时",
@"120009":@"子账号不能添加设备",
@"120010":@"设备验证码错误",
@"120012":@"设备添加失败",
@"120013":@"设备已被别人添加",
@"120014":@"设备序列号不正确",
@"120015":@"设备不支持该功能",
@"120016":@"当前设备正在格式化",
@"120017":@"设备已被自己添加",
@"120018":@"该用户不拥有该设备",
@"120019":@"设备不支持云存储服务",
@"120020":@"设备在线，被自己添加",
@"120021":@"设备在线，但是未被用户添加",
@"120022":@"设备在线，但是已经被别的用户添加",
@"120023":@"设备不在线，未被用户添加",
@"120024":@"设备不在线，但是已经被别的用户添加",
@"120025":@"重复申请分享",
@"120026":@"视频广场不存在该视频",
@"120027":@"视频转码失败",
@"120028":@"设备固件升级包不存在",
@"120029":@"设备不在线，但是已经被自己添加",
@"120030":@"该用户不拥有该视频广场视频",
@"120031":@"开启终端绑定，请在萤石客户端关闭终端绑定",
@"120032":@"该用户下通道不存在",
@"120033":@"无法收藏自己分享的视频",
@"120034":@"该用户下无设备",
@"120090":@"用户反馈失败",
@"120095":@"APP包下载失败",
@"120096":@"APP包信息删除失败",
@"120101":@"视频不支持分享给本人",
@"120102":@"无相应邀请信息",
@"120103":@"好友已存在",
@"120104":@"好友不存在",
@"120105":@"好友状态错误",
@"120106":@"对应群组不存在",
@"120107":@"不能添加自己为好友",
@"120108":@"当前用户和所添加用户不是好友关系",
@"120109":@"对应分享不存在",
@"120110":@"好友群组不属于当前用户",
@"120111":@"好友不是等待验证状态",
@"120112":@"添加应用下的用户为好友失败",
@"120201":@"操作报警信息失败",
@"120202":@"操作留言信息失败",
@"120301":@"根据UUID查询报警消息不存在",
@"120302":@"根据UUID查询图片不存在",
@"120303":@"根据FID查询图片不存在",
@"120305":@"设备ip解析错误",
@"120401":@"用户云空间信息不存在",
@"120402":@"云空间操作失败",
@"120403":@"用户目录不存在",
@"120404":@"要操作的目标目录不存在",
@"120405":@"要删除的文件信息不存在",
@"120406":@"已开通云存储",
@"120407":@"开通记录失败",
@"120500":@"获取数据错误",
@"120501":@"开锁失败",
@"120502":@"室内机未收到呼叫",
@"120503":@"正在响铃",
@"120504":@"室内机正在通话",
@"120505":@"设备操作失败",
@"120506":@"非法命令",
@"120507":@"智能锁密码错误",
@"120508":@"开关锁失败",
@"120509":@"开关锁超时",
@"120510":@"智能锁设备繁忙",
@"120511":@"远程开锁功能未打开",
@"120600":@"临时密码数已达上限",
@"120601":@"添加临时密码失败",
@"120602":@"删除临时密码失败",
@"120603":@"该临时密码不存在",
@"120604":@"指纹锁射频通信失败,请稍后再试",
@"120605":@"其他用户正在认证中",
@"120606":@"验证已启动,请在120s内进行本地验证和调用添加设备接口",
@"120607":@"删除用户失败",
@"120608":@"用户不存在",
@"120609":@"设备响应超时,门锁通信故障或者电量不足",
@"120610":@"获取临时密码列表失败",
@"130001":@"用户不存在",
@"130002":@"手机号码已经注册",
@"130003":@"手机验证码错误",
@"130004":@"终端绑定操作失败",
@"149999":@"数据异常",
@"150000":@"服务器异常",
@"160000":@"设备不支持云台控制",
@"160001":@"用户无云台控制权限",
@"160002":@"设备云台旋转达到上限位",
@"160003":@"设备云台旋转达到下限位",
@"160004":@"设备云台旋转达到左限位",
@"160005":@"设备云台旋转达到右限位",
@"160006":@"云台当前操作失败",
@"160007":@"预置点个数超过最大值",
@"160009":@"正在调用预置点",
@"160010":@"该预置点已经是当前位置",
@"160011":@"预置点不存在",
@"160013":@"设备版本已是最新",
@"160014":@"设备正在升级",
@"160015":@"设备正在重启",
@"160016":@"加密未开启，无须关闭",
@"160017":@"设备抓图失败",
@"160018":@"设备升级失败",
@"160019":@"加密已开启",
@"160020":@"不支持该命令",
@"160023":@"订阅操作失败",
@"160024":@"取消订阅操作失败",
@"160025":@"客流统计配置失败",
@"160026":@"设备处于隐私遮蔽状态",
@"160027":@"设备正在镜像操作",
@"160028":@"设备正在键控动作",
@"160029":@"设备处于语音对讲状态",
@"160030":@"卡密输入错误次数过多，24小时后再输入",
@"160031":@"卡密信息不存在",
@"160032":@"卡密状态不对或已过期",
@"160033":@"卡密非卖品，只能开通对应的绑定设备",
@"160035":@"购买云存储服务失败",
@"160040":@"添加的设备不在同一局域网",
@"160041":@"添加的设备被其他设备关联或响应超时",
@"160042":@"添加的设备密码错误",
@"160043":@"添加的设备超出最大数量",
@"160044":@"添加的设备网络不可达超时",
@"160045":@"添加的设备的IP和其他通道的IP冲突",
@"160046":@"添加的设备的IP和本设备的IP冲突",
@"160047":@"码流类型不支持",
@"160048":@"带宽超出系统接入带宽",
@"160049":@"IP或者端口不合法",
@"160050":@"添加的设备版本不支持需要升级才能接入",
@"160051":@"添加的设备不支持接入",
@"160052":@"添加的设备通道号出错",
@"160053":@"添加的设备分辨率不支持",
@"160054":@"添加的设备账号被锁定",
@"160055":@"添加的设备取码流出错",
@"160056":@"删除设备失败",
@"160057":@"删除的设备未关联",
@"160060":@"地址未绑定",
@"160061":@"账户流量已超出或未购买，限制开通",
@"160062":@"该通道直播已开通",
@"160063":@"直播未使用或直播已关闭",
@"160070":@"设备不能转移给自己",
@"160071":@"设备不能转移，设备与其他设备存在关联关系",
@"160072":@"设备不能转移，通道被分享给其他用户或者分享到视频广场",
@"160073":@"云存储转移失败",
@"160080":@"当前正在声源定位",
@"160081":@"当前正在轨迹巡航",
@"160082":@"设备正在响应本次声源定位",
@"160083":@"当前正在开启隐私遮蔽",
@"160084":@"当前正在关闭隐私遮蔽",
@"170003":@"refreshToken不存在",
@"170004":@"refreshToken已过期",
@"320001":@"未知错误",
@"320002":@"参数无效",
@"320003":@"暂不支持此操作",
@"320004":@"内存溢出",
@"320005":@"创建CAS session失败",
@"320006":@"创建cloud session失败",
@"320007":@"token失效",
@"320008":@"token池里面没有token,请传入token",
@"320009":@"传入新的INIT_PARAM并reset",
@"320010":@"请重试",
@"320011":@"500毫秒后请重试",
@"320012":@"token池已满",
@"320013":@"P2P client超过限制",
@"320014":@"sdk未初始化",
@"320015":@"超时",
@"320016":@"正在打洞中",
@"320017":@"没有视频文件头",
@"320018":@"解码错误/超时",
@"320019":@"取消",
@"320020":@"播放过程中预连接被用户清除预操作信息",
@"320021":@"流加密码不对",
@"320022":@"未传入播放窗口",
@"360001":@"客户端请求超时",
@"360002":@"对讲发起超时",
@"360003":@"TTS的设备端发生错误",
@"360004":@"TTS内部发生错误",
@"360005":@"客户端发送的消息错误",
@"360006":@"客户端接收发生错误",
@"360007":@"TTS关闭了与客户端的连接",
@"360010":@"设备正在对讲中",
@"360011":@"设备响应超时",
@"360012":@"设备不在线",
@"360013":@"设备开启了隐私保护",
@"360014":@"token校验无权限",
@"360016":@"验证token失败",
@"360102":@"TTS初始化失败",
@"361001":@"对讲服务端排队超时",
@"361002":@"对讲服务端处理超时",
@"361003":@"设备链接对讲服务器超时",
@"361004":@"服务器内部错误",
@"361005":@"解析消息失败",
@"361006":@"请求重定向",
@"361007":@"请求url非法",
@"361008":@"token失效",
@"361009":@"设备验证码或者通信秘钥不匹配",
@"361010":@"设备已经在对讲",
@"361011":@"设备10s响应超时",
@"361012":@"设备不在线",
@"361013":@"设备开启隐私保护拒绝对讲",
@"361014":@"token无权限",
@"361015":@"设备返回session不存在",
@"361016":@"验证token其他异常错误",
@"361017":@"服务端监听设备建立端口超时",
@"361018":@"设备链路异常",
@"361019":@"对讲服务端不支持的信令消息",
@"361020":@"对讲服务端解析对讲请求未携带会话描述能力集",
@"361021":@"对讲服务端优先能力集结果为空",
@"361022":@"cas链路异常",
@"361023":@"对讲服务端分配对讲会话资源失败",
@"361024":@"对讲服务端解析信令消息失败",
@"380011":@"设备隐私保护中",
@"380045":@"设备直连取流连接数量过大",
@"380047":@"设备不支持该命令",
@"380077":@"设备正在对讲中",
@"380102":@"数据接收异常",
@"380205":@"设备检测入参异常",
@"380209":@"网络连接超时",
@"380212":@"设备端网络连接超时",
@"390001":@"通用错误返回",
@"390002":@"入参为空指针",
@"390003":@"入参值无效",
@"390004":@"信令消息解析非法",
@"390005":@"内存资源不足",
@"390006":@"协议格式不对或者消息体长度超过STREAM_MAX_MSGBODY_LEN",
@"390007":@"设备序列号长度不合法",
@"390008":@"取流url长度不合法",
@"390009":@"解析vtm返回vtdu地址不合法",
@"390010":@"解析vtm返回级联vtdu地址不合法",
@"390011":@"解析vtm返回会话标识长度不合法",
@"390012":@"vtdu返回流头长度不合法",
@"390013":@"vtdu会话长度非法",
@"390014":@"回调函数未注册",
@"390015":@"vtdu成功响应未携带会话标识",
@"390016":@"vtdu成功响应未携带流头",
@"390017":@"无数据流，尚未使用",
@"390018":@"信令消息体PB解析失败",
@"390019":@"信令消息体PB封装失败",
@"390020":@"申请系统内存资源失败",
@"390021":@"vtdu地址尚未获取到",
@"390022":@"客户端尚未支持",
@"390023":@"获取系统socket资源失败",
@"390024":@"上层填充的StreamSsnId不匹配",
@"390025":@"链接服务器失败",
@"390026":@"客户端请求未收到服务端应答",
@"390027":@"链路断开",
@"390028":@"没有取流链接",
@"390029":@"流成功停止",
@"390030":@"客户端防串流校验失败",
@"390031":@"应用层tcp粘包处理缓冲区满",
@"390032":@"无效状态迁移",
@"390033":@"无效客户端状态",
@"390034":@"向vtm取流流媒体信息请求超时",
@"390035":@"向代理取流请求超时",
@"390036":@"向代理保活取流请求超时",
@"390037":@"向vtdu取流请求超时",
@"390038":@"向vtdu保活取流请求超时",
@"391001":@"vtm地址或端口非法",
@"391002":@"vtm生成文件描述符失败",
@"391003":@"vtm设置文件描述符非阻塞失败",
@"391004":@"vtm设置文件描述符阻塞失败",
@"391005":@"vtm解析服务器ip失败",
@"391006":@"vtm描述符select失败",
@"391007":@"vtm文件描述符不在可读中",
@"391008":@"vtm网络发生错误getsockopt",
@"391009":@"vtm描述符select超时",
@"391101":@"proxy地址或端口非法",
@"391102":@"proxy生成文件描述符失败",
@"391103":@"proxy设置文件描述符非阻塞失败",
@"391104":@"proxy设置文件描述符阻塞失败",
@"391105":@"proxy解析服务器ip失败",
@"391106":@"proxy描述符select失败",
@"391107":@"proxy文件描述符不在可读中",
@"391108":@"proxy网络发生错误getsockopt",
@"391109":@"proxy描述符select超时",
@"391201":@"vtdu地址或端口非法",
@"391202":@"vtdu生成文件描述符失败",
@"391203":@"vtdu设置文件描述符非阻塞失败",
@"391204":@"vtdu设置文件描述符阻塞失败",
@"391205":@"vtdu解析服务器ip失败",
@"391206":@"vtdu描述符select失败",
@"391207":@"vtdu文件描述符不在可读中",
@"391208":@"vtdu网络发生错误getsockopt",
@"391209":@"vtdu描述符select超时，请稍候再试",
@"395000":@"cas回复信令，发现内存已经释放，刷新重试",
@"395400":@"私有化协议vtm检测到非法参数，刷新重试",
@"395402":@"回放找不到录像文件",
@"395403":@"操作码或信令密钥与设备不匹配",
@"395404":@"设备不在线",
@"395405":@"流媒体向设备发送或接受信令超时/cas响应超时",
@"395406":@"token失效",
@"395407":@"客户端的URL格式错误",
@"395409":@"预览开启隐私保护",
@"395410":@"设备达到最大连接数(最新版本已调整为395416)",
@"395411":@"token无权限",
@"395412":@"session不存在",
@"395413":@"验证token其他异常",
@"395415":@"设备通道错误",
@"395416":@"设备达到最大连接数",
@"395451":@"设备不支持的码流类型",
@"395452":@"设备链接流媒体服务器失败，刷新重试",
@"395500":@"服务器处理失败，刷新重试",
@"395501":@"流媒体vtdu达到最大负载，请稍后重试",
@"395503":@"vtm返回分配vtdu失败，服务器负载达到上限，请稍后重试",
@"395544":@"设备返回无视频源，请检查设备是否接触良好",
@"395545":@"视频分享时间已经结束",
@"395546":@"vtdu返回达到取流并发路数限制，请升级为企业版",
@"395560":@"蚁兵代理不支持的用户取流类型，会重定向到vtdu取流",
@"395557":@"回放服务器等待流头超时，刷新重试",
@"395600":@"分享设备不在分享时间内",
@"395601":@"群组分享用户没权限",
@"395602":@"群组分享权限变更",
@"395556":@"ticket取流验证失败",
@"395530":@"机房故障不可用，请稍后重试",
@"395701":@"cas信令返回格式错误，刷新重试",
@"396001":@"客户端参数出错",
@"396099":@"客户端默认错误",
@"396101":@"不支持的命令",
@"396102":@"设备流头发送失败，刷新重试",
@"396103":@"cas/设备返回错误1",
@"396104":@"cas/设备返回错误-1",
@"396105":@"设备返回错误码3",
@"396106":@"设备返回错误码4",
@"396107":@"设备返回错误码5",
@"396108":@"cas信令回应重复",
@"396109":@"视频广场取消分享",
@"396110":@"设备信令默认错误",
@"396501":@"设备数据链路和实际链路不匹配，刷新重试",
@"396502":@"设备数据链路重复建立连接，刷新重试",
@"396503":@"设备数据链路端口不匹配，刷新重试",
@"396504":@"缓存设备数据链路失败，刷新重试",
@"396505":@"设备发送确认头消息重复，刷新重试",
@"396506":@"设备数据先于确定头部到达，刷新重试",
@"396508":@"设备数据头部长度非法，刷新重试或者重启设备",
@"396509":@"索引找不到设备数据管理块，刷新重试",
@"396510":@"设备数据链路vtdu内存块协议状态不匹配",
@"396511":@"设备数据头部没有streamkey错误",
@"396512":@"设备数据头部非法",
@"396513":@"设备数据长度过小",
@"396514":@"设备老协议推流头部没有streamkey错误",
@"396515":@"设备老协议推流数据非法",
@"396516":@"设备老协议索引找不到内存管理块",
@"396517":@"设备老协议推流数据非法",
@"396518":@"设备数据包过大，刷新重试或者重启设备",
@"396519":@"设备推流链路网络不稳定",
@"396520":@"设备推流链路网络不稳定",
@"400001":@"参数为空",
@"400002":@"参数错误",
@"400025":@"设备不支持对讲",
@"400029":@"没有初始化或资源被释放",
@"400030":@"json解析异常",
@"400031":@"网络异常",
@"400032":@"设备信息异常为空",
@"400034":@"取流超时，刷新重试",
@"400035":@"设备已加密，需要输入验证码",
@"400036":@"播放验证码错误",
@"400037":@"surfacehold错误",
@"400100":@"未知错误",
@"400200":@"player sdk出错",
@"400300":@"内存溢出",
@"400901":@"设备不在线",
@"400902":@"accesstoken异常或失效",
@"400903":@"当前账号开启了终端绑定",
@"400904":@"设备正在对讲中",
@"400905":@"设备开启了隐私保护，不允许预览、对讲等"};
}
@end
