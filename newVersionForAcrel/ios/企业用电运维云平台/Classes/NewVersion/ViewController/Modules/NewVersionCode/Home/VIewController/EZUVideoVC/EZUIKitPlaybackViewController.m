//
//  EZUIKitPlaybackViewController.m
//  EZUIKit
//
//  Created by linyong on 2017/2/17.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EZUIKitPlaybackViewController.h"
#import "EZUIKit.h"
#import "EZUIPlayer.h"
#import "EZUIError.h"
#import "Toast+UIView.h"
#import "EZPlaybackProgressBar.h"
#import "EZDeviceRecordFile.h"
#import "EZCloudRecordFile.h"
#import "WSDatePickerView.h"

#define BGBLACKVIEWHEIGHT SCREEN_HEIGHT/2 - BGSafeAreaTopHeight
#define pauseBtnWidth 80

@interface EZUIKitPlaybackViewController () <EZUIPlayerDelegate,EZPlaybackProgressDelegate>

@property (nonatomic,strong) EZUIPlayer *mPlayer;
@property (nonatomic,strong) UIButton *playBtn;
@property (nonatomic,strong) EZPlaybackProgressBar *playProgressBar;
@property (nonatomic,strong) UIButton *selectTimeBtn;
@property (nonatomic,strong) UIView *topbgView;
@property (nonatomic,strong) UIButton *pauseBtn;
@property (nonatomic,strong) UIButton *nextDayBtn;

@end

@implementation EZUIKitPlaybackViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.videoTitle) {
        self.title = [NSString stringWithFormat:@"%@回放模式",self.videoTitle];
    }else{
        self.title = @"回放模式";
    }
    
    //黑色背景层
    self.topbgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, BGBLACKVIEWHEIGHT)];
    self.topbgView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.topbgView];
    
//    self.playBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//    [self.playBtn setTitle:NSLocalizedString(@"播放", @"播放") forState:UIControlStateNormal];
//    [self.playBtn setTitle:NSLocalizedString(@"停止", @"停止") forState:UIControlStateSelected];
////    self.playBtn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-80)/2-40, 510, 80, 40);
//    [self.playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.playBtn];
    
    self.pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.pauseBtn setTitle:NSLocalizedString(@"暂停", @"暂停") forState:UIControlStateNormal];
//    [self.pauseBtn setTitle:NSLocalizedString(@"恢复", @"恢复") forState:UIControlStateSelected];
    [self.pauseBtn setImage:[UIImage imageNamed:@"pauseLarge"] forState:UIControlStateNormal];
    [self.pauseBtn setImage:[UIImage imageNamed:@"playLarge"] forState:UIControlStateSelected];
    self.pauseBtn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-pauseBtnWidth)/2, BGBLACKVIEWHEIGHT+ 100, pauseBtnWidth, pauseBtnWidth);
    [self.pauseBtn addTarget:self action:@selector(pauseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.pauseBtn];
    
    
    self.selectTimeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.selectTimeBtn setTitle:@"选择日期" forState:UIControlStateNormal];
    [self.selectTimeBtn setBackgroundImage:[UIImage imageNamed:@"selectBtnBackgroud"] forState:UIControlStateNormal];
    [self.selectTimeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    self.selectTimeBtn.layer.masksToBounds = YES;
//    self.selectTimeBtn.layer.cornerRadius = 10.f;
//    self.selectTimeBtn.backgroundColor = [UIColor lightGrayColor];
    NSString *showString = [self dateTransformToTimeString];
    [self.selectTimeBtn setTitle:showString forState:UIControlStateNormal];
    NSString *dateString = [self dateTransformToTimeStrWithNet];
    NSString *timerStr = [NSString stringWithFormat:@"%@?begin=%@000000&end=%@235959",self.urlStr,dateString,dateString];
    DefLog(@"timeStr:%@",timerStr);
    self.urlStr = timerStr;
    
    [self.mPlayer setEZOpenUrl:self.urlStr];
    //        weakSelf.mPlayer = [EZUIPlayer createPlayerWithUrl:weakSelf.urlStr];
    //        if ([EZUIPlayer getPlayModeWithUrl:weakSelf.urlStr] ==  EZUIKIT_PLAYMODE_REC)
    //        {
    //            [weakSelf createProgressBarWithList:weakSelf.mPlayer.recordList];
    //        }
    [self play];
    
    self.selectTimeBtn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-160)/2, BGBLACKVIEWHEIGHT+ 10, 160, 70);
    self.selectTimeBtn.titleEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 0);
    //373 171
    [self.selectTimeBtn addTarget:self action:@selector(selectTimeClickEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.selectTimeBtn];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.appKey || self.appKey.length == 0 ||
        !self.accessToken || self.accessToken.length == 0 ||
        !self.urlStr || self.urlStr == 0)
    {
        return;
    }
    
    if (self.apiUrl)
    {
        [EZUIKit initGlobalWithAppKey:self.appKey apiUrl:self.apiUrl];
    }
    else
    {
        [EZUIKit initWithAppKey:self.appKey];
    }
    
    [EZUIKit setAccessToken:self.accessToken];
//    [self play];
    self.playBtn.selected = YES;
}

- (void)dealloc
{
    [self releasePlayer];
}

- (NSString *)dateTransformToTimeString
{
    NSDate *currentDate = [NSDate date];//获得当前时间为UTC时间 2014-07-16 07:54:36 UTC  (UTC时间比标准时间差8小时)
    //转为字符串
    NSDateFormatter*df = [[NSDateFormatter alloc]init];//实例化时间格式类
    [df setDateFormat:@"yyyy年MM月dd日"];//格式化
    //2014-07-16 07:54:36(NSString类)
    NSString *timeString = [df stringFromDate:currentDate];
    
    return timeString;
}

- (NSString *)dateTransformToTimeStrWithNet
{
    NSDate *currentDate = [NSDate date];//获得当前时间为UTC时间 2014-07-16 07:54:36 UTC  (UTC时间比标准时间差8小时)
    //转为字符串
    NSDateFormatter*df = [[NSDateFormatter alloc]init];//实例化时间格式类
    [df setDateFormat:@"yyyyMMdd"];//格式化
    //2014-07-16 07:54:36(NSString类)
    NSString *timeString = [df stringFromDate:currentDate];
    
    return timeString;
}

#pragma mark - play bar delegate

- (void) EZPlaybackProgressBarScrollToTime:(NSDate *)time
{
    if (!self.mPlayer)
    {
        return;
    }
    
    self.playBtn.selected = YES;
    [self.mPlayer seekToTime:time];
}

#pragma mark - player delegate

- (void) EZUIPlayerPlayTime:(NSDate *)osdTime
{
    [self.playProgressBar scrollToDate:osdTime];
}

- (void) EZUIPlayerFinished:(EZUIPlayer*) player
{
    [self stop];
    self.playBtn.selected = NO;
}

- (void) EZUIPlayerPrepared:(EZUIPlayer*) player
{
    if ([EZUIPlayer getPlayModeWithUrl:self.urlStr] ==  EZUIKIT_PLAYMODE_REC)
    {
        [self createProgressBarWithList:self.mPlayer.recordList];
    }
    [self play];
}

- (void) EZUIPlayerPlaySucceed:(EZUIPlayer *)player
{
    self.playBtn.selected = YES;
}

- (void) EZUIPlayer:(EZUIPlayer *)player didPlayFailed:(EZUIError *) error
{
    [self stop];
    self.playBtn.selected = NO;
    
    if ([error.errorString isEqualToString:UE_ERROR_INNER_VERIFYCODE_ERROR])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"verify_code_wrong", @"验证码错误"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_TRANSF_DEVICE_OFFLINE])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"device_offline", @"设备不在线"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_CAMERA_NOT_EXIST] ||
             [error.errorString isEqualToString:UE_ERROR_DEVICE_NOT_EXIST])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"camera_not_exist", @"通道不存在"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_INNER_STREAM_TIMEOUT])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"connect_out_time", @"连接超时"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_CAS_MSG_PU_NO_RESOURCE])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"connect_device_limit", @"设备连接数过大"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }else if ([error.errorString isEqualToString:UE_ERROR_NOT_FOUND_RECORD_FILES])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"not_found_record_files", @"未查找到录像文件"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }else if ([error.errorString isEqualToString:UE_ERROR_PARAM_ERROR])
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"param_error", @"参数错误"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    else
    {
        [self.view makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"play_fail", @"播放失败"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    
    NSLog(@"play error:%@(%ld)",error.errorString,error.internalErrorCode);
}

- (void) EZUIPlayer:(EZUIPlayer *)player previewWidth:(CGFloat)pWidth previewHeight:(CGFloat)pHeight
{
    CGFloat ratio = pWidth/pHeight;
    
    CGFloat destWidth = CGRectGetWidth(self.view.bounds);
    CGFloat destHeight = destWidth/ratio;
    
    [player setPreviewFrame:CGRectMake(0, CGRectGetMinY(player.previewView.frame), destWidth, destHeight)];
}

#pragma mark - actions

- (void) playBtnClick:(UIButton *) btn
{
    if(btn.selected)
    {
        [self stop];
    }
    else
    {
        [self play];
    }
    btn.selected = !btn.selected;
}

- (void)pauseBtnClick:(UIButton *) btn{
    if (btn.selected) {
        [self resume];
    }else{
        [self pause];
    }
    btn.selected = !btn.selected;
}

- (void)selectTimeClickEvent:(UIButton *)clickSelectBtn{
    __weak __typeof(self)weakSelf = self;
    WSDatePickerView *datepicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDay CompleteBlock:^(NSDate *selectDate) {

        NSString *showString = [selectDate stringWithFormat:@"yyyy年MM月dd日"];
        NSString *dateString = [selectDate stringWithFormat:@"yyyyMMdd"];
        NSLog(@"选择的日期：%@",dateString);
        [clickSelectBtn setTitle:showString forState:UIControlStateNormal];
        NSString *timerStr = [NSString stringWithFormat:@"%@?begin=%@000000&end=%@235959",weakSelf.urlStr,dateString,dateString];
        DefLog(@"timeStr:%@",timerStr);
        weakSelf.urlStr = timerStr;
        
        [weakSelf.mPlayer setEZOpenUrl:weakSelf.urlStr];
//        weakSelf.mPlayer = [EZUIPlayer createPlayerWithUrl:weakSelf.urlStr];
//        if ([EZUIPlayer getPlayModeWithUrl:weakSelf.urlStr] ==  EZUIKIT_PLAYMODE_REC)
//        {
//            [weakSelf createProgressBarWithList:weakSelf.mPlayer.recordList];
//        }
        [weakSelf play];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//
//        });
    }];
    datepicker.dateLabelColor = COLOR_NAVBAR;//年-月-日-时-分 颜色
    datepicker.datePickerColor = [UIColor blackColor];//滚轮日期颜色
    datepicker.doneButtonColor = COLOR_NAVBAR;//确定按钮的颜色
    [datepicker show];
}

#pragma mark - support

- (void) createProgressBarWithList:(NSArray *) list
{    
    NSMutableArray *destList = [NSMutableArray array];
    for (id fileInfo in list)
    {
        EZPlaybackInfo *info = [[EZPlaybackInfo alloc] init];
        
        if  ([fileInfo isKindOfClass:[EZDeviceRecordFile class]])
        {
            info.beginTime = ((EZDeviceRecordFile*)fileInfo).startTime;
            info.endTime = ((EZDeviceRecordFile*)fileInfo).stopTime;
            info.recType = 2;
        }
        else
        {
            info.beginTime = ((EZCloudRecordFile*)fileInfo).startTime;
            info.endTime = ((EZCloudRecordFile*)fileInfo).stopTime;
            info.recType = 1;
        }
        
        [destList addObject:info];
    }
    
    if (self.playProgressBar)
    {
        [self.playProgressBar updateWithDataList:destList];
        [self.playProgressBar scrollToDate:((EZPlaybackInfo*)[destList firstObject]).beginTime];
        return;
    }
    
    self.playProgressBar = [[EZPlaybackProgressBar alloc] initWithFrame:CGRectMake(0, BGBLACKVIEWHEIGHT+ 115 + pauseBtnWidth,
                                                                                   [UIScreen mainScreen].bounds.size.width,
                                                                                   120)
                                                               dataList:destList];
    UIImageView *imagejiantou = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timejiantou1"]];
    imagejiantou.frame = CGRectMake(SCREEN_WIDTH/2-7.5, BGBLACKVIEWHEIGHT+ 115 + pauseBtnWidth + 24, 15, 95);
    
    self.playProgressBar.delegate = self;
    self.playProgressBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.playProgressBar];
    [self.view addSubview:imagejiantou];
}

#pragma mark - player

- (void) play
{
    if (self.mPlayer)
    {
        [self.mPlayer startPlay];
        return;
    }
    self.mPlayer = [EZUIPlayer createPlayerWithUrl:self.urlStr];
    self.mPlayer.mDelegate = self;
//    self.mPlayer.customIndicatorView = nil;//设置为nil则去除加载动画
    self.mPlayer.previewView.frame = CGRectMake(0, (BGBLACKVIEWHEIGHT-CGRectGetHeight(self.mPlayer.previewView.frame))/2,
                                                CGRectGetWidth(self.mPlayer.previewView.frame),
                                                CGRectGetHeight(self.mPlayer.previewView.frame));
    
    [self.topbgView addSubview:self.mPlayer.previewView];
}

- (void) stop
{
    if (!self.mPlayer)
    {
        return;
    }
    
    [self.mPlayer stopPlay];
}

- (void) pause
{
    if (!self.mPlayer)
    {
        return;
    }
    
    [self.mPlayer pausePlay];
}

- (void) resume
{
    if (!self.mPlayer)
    {
        return;
    }
    
    [self.mPlayer resumePlay];
}

- (void) releasePlayer
{
    if (!self.mPlayer)
    {
        return;
    }
    
    [self.mPlayer.previewView removeFromSuperview];
    [self.mPlayer releasePlayer];
    self.mPlayer = nil;
}

#pragma mark - orientation

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    CGRect frame = CGRectZero;
    if (size.height > size.width)
    {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        frame = CGRectMake(0, 64,size.width,size.width*9/16);
    }
    else
    {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        frame = CGRectMake(0, 0,size.width,size.height);
    }
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self.mPlayer setPreviewFrame:frame];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
}


@end
