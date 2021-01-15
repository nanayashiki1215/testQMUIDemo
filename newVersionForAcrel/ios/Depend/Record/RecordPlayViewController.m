//
//  RecordPlayViewController.m
//  lechangeDemo
//
//  Created by mac318340418 on 16/7/12.
//  Copyright © 2016年 dh-Test. All rights reserved.
//

#import "RecordPlayViewController.h"
//#import "LCOpenSDK_Prefix.h"
#import "LCOpenSDK_Utils.h"
#import "UIDevice+Lechange.h"

#define RECORD_BAR_HEIGHT 40.0
#define TIME_LAB_WIDTH 60.0
typedef NS_ENUM(NSInteger, PlayState) {
    Play = 0,
    Pause = 1,
    Stop = 2
};

@interface RecordPlayViewController () {
    LCOpenSDK_Utils* m_Utils;

    CGRect m_screenFrame;
    LCOpenSDK_PlayWindow* m_play;

    RecordType m_playType;
    PlayState m_playState;
    BOOL m_isSeeking;
    NSTimeInterval m_deltaTime;
    NSString* m_streamPath;
}

@end

@implementation RecordPlayViewController

- (void)viewDidLoad
{

    [super viewDidLoad];
    [self initWindowView];
    [self.view bringSubviewToFront:m_playBarView];
    self.title = @"乐橙回放";
    dispatch_queue_t playRecord = dispatch_queue_create("playRecord", nil);
    dispatch_async(playRecord, ^{
        [self onPlay];
    });

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onResignActive:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    signal(SIGPIPE, SIG_IGN);
}

- (void)initWindowView
{
    m_screenFrame = [UIScreen mainScreen].bounds;

    UINavigationItem* item = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(RECORD_PLAY_TITLE_TXT, nil)];

    UIButton* left = [UIButton buttonWithType:UIButtonTypeCustom];
    [left setFrame:CGRectMake(0, 0, 50, 30)];
    UIImage* img = [UIImage leChangeImageNamed:Back_Btn_Png];

    [left setBackgroundImage:img forState:UIControlStateNormal];
    [left addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* leftBtn = [[UIBarButtonItem alloc] initWithCustomView:left];
    [item setLeftBarButtonItem:leftBtn animated:NO];
    [super.m_navigationBar pushNavigationItem:item animated:NO];

    [self.view addSubview:super.m_navigationBar];

    m_playImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, super.m_yOffset, m_screenFrame.size.width, m_screenFrame.size.width * 9 / 16)];
    [m_playImg setImage:m_imgPicSelected];
    [self.view addSubview:m_playImg];
    [self layOutBar];

    m_tipLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, m_screenFrame.size.width - 20, 20)];
    m_tipLab.center = CGPointMake(m_playImg.center.x, m_playImg.center.y + CGRectGetHeight(m_playImg.frame) / 2 + 50);
    [m_tipLab setBackgroundColor:[UIColor clearColor]];
    m_tipLab.textAlignment = NSTextAlignmentCenter;
    [m_tipLab setFont:[UIFont systemFontOfSize:15.0]];
    [self.view addSubview:m_tipLab];
    m_play = [[LCOpenSDK_PlayWindow alloc] initPlayWindow:CGRectMake(0, super.m_yOffset, m_screenFrame.size.width, m_screenFrame.size.width * 9 / 16) Index:1];
    [m_play setSurfaceBGColor:[UIColor blackColor]];
    [self.view addSubview:[m_play getWindowView]];
    
    m_progressInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    m_progressInd.center = CGPointMake(self.view.center.x, m_playImg.center.y);
    [self.view addSubview:m_progressInd];

    [self.view bringSubviewToFront:m_playImg];
    [self.view bringSubviewToFront:m_playBarView];
    [self.view bringSubviewToFront:m_progressInd];
    [m_play setWindowListener:(id<LCOpenSDK_EventListener>)self];

    m_Utils = [[LCOpenSDK_Utils alloc] init];

    m_playState = Stop;
    m_isSeeking = NO;
    [self enableOtherBtn:NO];

    m_deltaTime = [self transformToDeltaTime:m_beginTimeSelected EndTime:m_endTimeSelected];

    signal(SIGPIPE, SIG_IGN);
}

- (void)layOutBar
{
    m_playBarView = [[UIView alloc] initWithFrame:CGRectMake(0, super.m_yOffset - RECORD_BAR_HEIGHT + m_playImg.frame.size.height, m_playImg.frame.size.width, RECORD_BAR_HEIGHT)];
    [m_playBarView setBackgroundColor:[UIColor grayColor]];
    m_playBarView.alpha = 0.5;
    [self.view addSubview:m_playBarView];

    m_playBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, RECORD_BAR_HEIGHT, RECORD_BAR_HEIGHT)];
    [m_playBtn setBackgroundImage:[UIImage leChangeImageNamed:VideoPlay_Play_Png] forState:UIControlStateNormal];
    [m_playBtn addTarget:self action:@selector(onPlay) forControlEvents:UIControlEventTouchUpInside];
    [m_playBarView addSubview:m_playBtn];

    m_scalBtn = [[UIButton alloc] initWithFrame:CGRectMake(m_playBarView.frame.size.width - RECORD_BAR_HEIGHT, 0, RECORD_BAR_HEIGHT, RECORD_BAR_HEIGHT)];
    [m_scalBtn setBackgroundImage:[UIImage leChangeImageNamed:VideoPlay_FullScreen_Png] forState:UIControlStateNormal];
    [m_scalBtn addTarget:self action:@selector(onFullScreen) forControlEvents:UIControlEventTouchUpInside];
    [m_playBarView addSubview:m_scalBtn];

    m_startTimeLab = [[UILabel alloc] initWithFrame:CGRectMake(RECORD_BAR_HEIGHT, 0, TIME_LAB_WIDTH, RECORD_BAR_HEIGHT)];
    m_startTimeLab.text = [self transformToShortTime:m_beginTimeSelected];
    [m_startTimeLab setBackgroundColor:[UIColor clearColor]];
    [m_startTimeLab setFont:[UIFont systemFontOfSize:12.0]];
    m_startTimeLab.textAlignment = NSTextAlignmentCenter;
    [m_playBarView addSubview:m_startTimeLab];

    m_endTimeLab = [[UILabel alloc] initWithFrame:CGRectMake(m_playBarView.frame.size.width - TIME_LAB_WIDTH - RECORD_BAR_HEIGHT, 0, TIME_LAB_WIDTH, RECORD_BAR_HEIGHT)];
    m_endTimeLab.text = [self transformToShortTime:m_endTimeSelected];
    [m_endTimeLab setBackgroundColor:[UIColor clearColor]];
    [m_endTimeLab setFont:[UIFont systemFontOfSize:12.0]];
    m_endTimeLab.textAlignment = NSTextAlignmentCenter;
    [m_playBarView addSubview:m_endTimeLab];

    m_playSlider = [[UISlider alloc] initWithFrame:CGRectMake(RECORD_BAR_HEIGHT + TIME_LAB_WIDTH, 0, m_playBarView.frame.size.width - 2 * (RECORD_BAR_HEIGHT + TIME_LAB_WIDTH), RECORD_BAR_HEIGHT)];
    m_playSlider.value = m_playSlider.minimumValue;
    [m_playSlider addTarget:self action:@selector(onSeek) forControlEvents:UIControlEventTouchUpInside];
    [m_playBarView addSubview:m_playSlider];
}

- (void)refreshSubView
{
    [m_playBtn setFrame:CGRectMake(0, 0, RECORD_BAR_HEIGHT, RECORD_BAR_HEIGHT)];
    [m_scalBtn setFrame:CGRectMake(m_playBarView.frame.size.width - RECORD_BAR_HEIGHT, 0, RECORD_BAR_HEIGHT, RECORD_BAR_HEIGHT)];
    [m_startTimeLab setFrame:CGRectMake(RECORD_BAR_HEIGHT, 0, TIME_LAB_WIDTH, RECORD_BAR_HEIGHT)];
    [m_endTimeLab setFrame:CGRectMake(m_playBarView.frame.size.width - TIME_LAB_WIDTH - RECORD_BAR_HEIGHT, 0, TIME_LAB_WIDTH, RECORD_BAR_HEIGHT)];
    [m_playSlider setFrame:CGRectMake(RECORD_BAR_HEIGHT + TIME_LAB_WIDTH, 0, m_playBarView.frame.size.width - 2 * (RECORD_BAR_HEIGHT + TIME_LAB_WIDTH), RECORD_BAR_HEIGHT)];
}

// 除播放按键以外的其他按键的使能操作
- (void)enableOtherBtn:(BOOL)bFalg
{
    m_playSlider.enabled = bFalg;
    m_scalBtn.enabled = bFalg;
}

- (void)setInfo:(NSString*)token Dev:(NSString*)deviceId Key:(NSString*)key Chn:(NSInteger)chn Type:(RecordType)type
{
    m_accessToken = [token mutableCopy];
    m_strDevSelected = [deviceId mutableCopy];
    m_encryptKey = [key mutableCopy];
    m_devChnSelected = chn;
    m_recordType = type;
}

- (void)setRecInfo:(NSString*)rec RecReg:(NSString*)recReg Begin:(NSString*)begin End:(NSString*)end Img:(UIImage*)img
{
    m_strRecSelected = [rec mutableCopy];
    m_strRecRegSelected = [recReg mutableCopy];
    m_beginTimeSelected = [begin mutableCopy];
    m_endTimeSelected = [end mutableCopy];
    m_imgPicSelected = img;
}

- (void)onPlay
{
    switch (m_recordType) {
    case DeviceRecord:
        [self playDeviceRecord];
        break;
    case CloudRecord:
        [self playCloudRecord];
        break;
    default:
        break;
    }
}

#pragma mark - 播放设备本地录像文件
- (void)playDeviceRecord
{
    if (!m_play) {
        DefLog(@"play failed\n");
        return;
    }
    if (m_playState == Stop) {
          [m_play stopDeviceRecord];
          m_isSeeking = NO;
          [self showLoading];
          [m_play playDeviceRecord:m_accessToken devID:m_strDevSelected psk:m_encryptKey channel:m_devChnSelected fileName:m_strRecSelected begin:[self timeIntervalOfString:m_beginTimeSelected] end:[self timeIntervalOfString:m_endTimeSelected] offsetTime:0 optimize:YES];
          //[m_play playDeviceRecordByUtcTime:m_accessToken devID:m_strDevSelected psk:m_encryptKey channel:m_devChnSelected begin:[self timeIntervalOfString:m_beginTimeSelected] end:[self timeIntervalOfString:m_endTimeSelected] definition:0  optimize:YES]
          m_playState = Play;
          dispatch_async(dispatch_get_main_queue(), ^{
             m_playBtn.enabled = NO;
             m_tipLab.text = @"ready play";
          });
    }
    else if (m_playState == Pause){
        [m_play resume];
        [m_playBtn setBackgroundImage:[UIImage leChangeImageNamed:VideoPlay_Pause_Png] forState:UIControlStateNormal];
        m_playState = Play;
        dispatch_async(dispatch_get_main_queue(), ^{
            m_tipLab.text = @"play";
        });
    }
    else if (m_playState == Play) {
        [m_play pause];
        [m_playBtn setBackgroundImage:[UIImage leChangeImageNamed:VideoPlay_Play_Png] forState:UIControlStateNormal];
        m_playState = Pause;
        dispatch_async(dispatch_get_main_queue(), ^{
            m_tipLab.text = @"pause";
        });
    }
}

#pragma mark - 播放云录像
- (void)playCloudRecord
{
    if (!m_play) {
        DefLog(@"play failed\n");
        return;
    }
    if (m_playState == Stop) {
        [m_play stopCloud];
        m_isSeeking = NO;
        [self showLoading];
        [m_play playCloud:m_accessToken devID:m_strDevSelected channelID:m_devChnSelected psk:m_encryptKey  recordRegionID:m_strRecRegSelected offsetTime:0 Type:1000 timeOut:60];
        m_playState = Play;
        dispatch_async(dispatch_get_main_queue(), ^{
            m_tipLab.text = @"ready play";
            m_playBtn.enabled = NO;
        });
    }
    else if (m_playState == Pause) {
        [m_play resume];
        [m_playBtn setBackgroundImage:[UIImage leChangeImageNamed:VideoPlay_Pause_Png] forState:UIControlStateNormal];
        m_playState = Play;
        dispatch_async(dispatch_get_main_queue(), ^{
            m_tipLab.text = @"play";
        });
    }
    else if (m_playState == Play) {
        [m_play pause];
        [m_playBtn setBackgroundImage:[UIImage leChangeImageNamed:VideoPlay_Play_Png] forState:UIControlStateNormal];
        m_playState = Pause;
        dispatch_async(dispatch_get_main_queue(), ^{
            m_tipLab.text = @"pause";
        });
    }
}

#pragma mark - 拖动
- (void)onSeek
{
    m_isSeeking = YES;
    [self showLoading];

    if (Pause == m_playState) {
        [m_play resume];
        [m_playBtn setBackgroundImage:[UIImage leChangeImageNamed:VideoPlay_Pause_Png] forState:UIControlStateNormal];
        if (DeviceRecord == m_recordType) {
            return;
        }
    }

    m_playState = Play;

    // seek到录像最后2秒内，录像可能无法播放,强制使seek在录像最后2秒以外
    Float64 delta = m_playSlider.maximumValue - m_playSlider.value;
    if (delta < (2.0 / m_deltaTime)) {
        m_playSlider.value = (m_playSlider.maximumValue - 2.0 / m_deltaTime) < m_playSlider.minimumValue ? m_playSlider.minimumValue : (m_playSlider.maximumValue - 2.0 / m_deltaTime);
    }
    Float64 rate = m_playSlider.value / (m_playSlider.maximumValue - m_playSlider.minimumValue);
    [m_play seek:rate * m_deltaTime];
}

#pragma mark - 全屏
- (void)onFullScreen
{
    [UIDevice lc_setRotateToSatusBarOrientation];
}

- (void)onControlClick:(CGFloat)dx dy:(CGFloat)dy Index:(NSInteger)index
{
    DefLog(@"11111111111");
}

#pragma mark - 双击屏幕
- (void)onWindowDBClick:(CGFloat)dx dy:(CGFloat)dy Index:(NSInteger)index
{
    m_playBarView.hidden = !m_playBarView.hidden;
}

- (void)onPlayerResult:(NSString*)code Type:(NSInteger)type Index:(NSInteger)index
{
    switch (m_recordType) {
    case DeviceRecord:
        [self onPlayDeviceRecordResult:code Type:type];
        break;
    case CloudRecord:
        [self onPlayCloudRecordResult:code Type:type];
    default:
        break;
    }
}

#pragma mark - 设备录像播放回调
- (void)onPlayDeviceRecordResult:(NSString*)code Type:(NSInteger)type
{
    NSString* displayLab;
    if (99 == type) {
        displayLab = [code isEqualToString:@"-1000"] ? NSLocalizedString(NETWORK_TIMEOUT_TXT, nil) : [NSLocalizedString(REST_LINK_FAILED_TXT, nil) stringByAppendingFormat:@",[%@]", code];
        dispatch_async(dispatch_get_main_queue(), ^{
            DefLog(@"RecordPlayViewController, OpenApi connect error!");
            [m_tipLab setText:displayLab];
            [self hideLoading];
            m_playState = Stop;
            m_playImg.hidden = NO;
            m_playBtn.enabled = YES;
            [self enableOtherBtn:NO];
        });
        return;
    }
    
    if(5 == type)
    {
        /* 优化拉流设备 */
        if([@"0" isEqualToString:code]){
            displayLab = @"start private protocol";
            return;
        }
        if([@"1000" isEqualToString:code] || [@"4000" isEqualToString:code])
        {
            displayLab = @"play private protocol Succeed!";
            return;
        }
    }
    
    if ([RTSP_Result_String(STATE_RTSP_TEARDOWN_ERROR) isEqualToString:code]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            m_tipLab.text = @"rtsp teardown";
        });
        return;
    }
    if ([RTSP_Result_String(STATE_RTSP_PLAY_READY) isEqualToString:code]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (YES == m_isSeeking) {
                if (Pause == m_playState) {
                    m_playState = Play;
                    Float64 m_Rate = m_playSlider.value / (m_playSlider.maximumValue - m_playSlider.minimumValue);
                    [m_play seek:m_Rate * m_deltaTime];
                } else {
                    m_isSeeking = NO;
                }
            }
        });
        return;
    }
    if ([RTSP_Result_String(STATE_RTSP_FILE_PLAY_OVER) isEqualToString:code]) {
        dispatch_async(dispatch_get_main_queue(), ^{

                       });
        return;
    }
    if ([RTSP_Result_String(STATE_RTSP_PLAY_PAUSE) isEqualToString:code]) {
        dispatch_async(dispatch_get_main_queue(), ^{

                       });
        return;
    }
    if ([RTSP_Result_String(STATE_RTSP_ERROR_KEY) isEqualToString:code]) {
        displayLab = @"Key Error";
    } else {
        displayLab = [NSString stringWithFormat:@"Rest Failed，[%@]", code];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [m_tipLab setText:displayLab];
        [self hideLoading];
        m_playImg.hidden = NO;
        m_playState = Stop;
        [m_playBtn setBackgroundImage:[UIImage leChangeImageNamed:VideoPlay_Play_Png] forState:UIControlStateNormal];
        m_playBtn.enabled = YES;
        [self enableOtherBtn:NO];
        [m_play stopDeviceRecord];

        m_startTimeLab.text = [self transformToShortTime:m_beginTimeSelected];
        [m_playSlider setValue:0];
    });
    return;
}

#pragma mark - 云录像播放回调
- (void)onPlayCloudRecordResult:(NSString*)code Type:(NSInteger)type
{

    DefLog(@"code[%@] type[%ld]", code, (long)type);
    if (99 == type) {
        NSString* hint = [code isEqualToString:@"-1000"] ? NSLocalizedString(NETWORK_TIMEOUT_TXT, nil) : [NSLocalizedString(REST_LINK_FAILED_TXT, nil) stringByAppendingFormat:@",[%@]", code];
        dispatch_async(dispatch_get_main_queue(), ^{
            DefLog(@"RecordPlayViewController, OpenApi connect error!");
            m_tipLab.text = hint;
            [self hideLoading];
            m_playState = Stop;
            m_playImg.hidden = NO;
            m_playBtn.enabled = YES;
            [self enableOtherBtn:NO];
        });
        return;
    }
    if ([HLS_Result_String(HLS_DOWNLOAD_FAILD) isEqualToString:code]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            DefLog(@"HLS DOWNLOAD FAILED!");
            m_tipLab.text = @"HLS download failed";
            [self hideLoading];
            m_playState = Stop;
            m_playImg.hidden = NO;
            m_playBtn.enabled = YES;
            [self enableOtherBtn:NO];
            [m_playBtn setBackgroundImage:[UIImage leChangeImageNamed:VideoPlay_Play_Png] forState:UIControlStateNormal];

            m_startTimeLab.text = [self transformToShortTime:m_beginTimeSelected];
            [m_playSlider setValue:0];
        });
        return;
    }
    if ([HLS_Result_String(HLS_DOWNLOAD_BEGIN) isEqualToString:code]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            DefLog(@"HLS DOWNLOAD BEGIN!");
        });
        return;
    }
    if ([HLS_Result_String(HLS_DOWNLOAD_END) isEqualToString:code]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            DefLog(@"HLS DOWNLOAD END!");
        });
        return;
    }
    if ([HLS_Result_String(HLS_SEEK_SUCCESS) isEqualToString:code]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            DefLog(@"HLS SEEK SUCCESS!");
            m_isSeeking = NO;
            [self hideLoading];
        });
        return;
    }
    if ([HLS_Result_String(HLS_SEEK_FAILD) isEqualToString:code]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            DefLog(@"HLS SEEK FAILD!");
            [m_play stopCloud];
            m_playState = Stop;
            [self hideLoading];
            [m_playBtn setBackgroundImage:[UIImage leChangeImageNamed:VideoPlay_Play_Png] forState:UIControlStateNormal];

            m_startTimeLab.text = [self transformToShortTime:m_beginTimeSelected];
            [m_playSlider setValue:0];
        });
        return;
    }
    if ([HLS_Result_String(HLS_ABORT_DONE) isEqualToString:code]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            DefLog(@"HLS ABORT DONE!");
            m_startTimeLab.text = [self transformToShortTime:m_beginTimeSelected];
            [m_playSlider setValue:0];
        });
        return;
    }
    if ([HLS_Result_String(HLS_RESUME_DONE) isEqualToString:code]) {

        dispatch_async(dispatch_get_main_queue(), ^{
            DefLog(@"HLS RESUME DONE!");
        });
        return;
    }
    // 密钥错误码STATE_HLS_KEY_ERROR = 11
    if ([HLS_Result_String(HLS_KEY_ERROR) isEqualToString:code]) {
        dispatch_async(dispatch_get_main_queue(), ^{

            [m_play stopCloud];
            [self hideLoading];
            m_tipLab.text = @"Key Error";
            m_playState = Stop;
            m_playImg.hidden = NO;
            m_playBtn.enabled = YES;
            [self enableOtherBtn:NO];
            [m_playBtn setBackgroundImage:[UIImage leChangeImageNamed:VideoPlay_Play_Png] forState:UIControlStateNormal];
        });
        return;
    }
}

#pragma mark - 录像开始播放回调
- (void)onPlayBegan:(NSInteger)index
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [m_playBtn setBackgroundImage:[UIImage leChangeImageNamed:VideoPlay_Pause_Png] forState:UIControlStateNormal];
        m_tipLab.text = @"start to play";
        m_playState = Play;
        m_isSeeking = NO;
        [self hideLoading];
        m_playImg.hidden = YES;
        m_playBtn.enabled = YES;
        [self enableOtherBtn:YES];
    });
}

#pragma mark - 录像播放结束回调
- (void)onPlayFinished:(NSInteger)index
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (DeviceRecord == m_playType) {
            [m_play stopDeviceRecord];
        } else if (CloudRecord == m_playType) {
            [m_play stopCloud];
        }
        m_tipLab.text = @"play over";
        [self hideLoading];
        m_playImg.hidden = NO;
        [self enableOtherBtn:NO];
        [m_startTimeLab setText:[self transformToShortTime:m_beginTimeSelected]];
        [m_playSlider setValue:m_playSlider.minimumValue animated:YES];
        m_playState = Stop;
        [m_playBtn setBackgroundImage:[UIImage leChangeImageNamed:VideoPlay_Play_Png] forState:UIControlStateNormal];
    });
}

#pragma mark - 录像时间状态回调
- (void)onPlayerTime:(long)time Index:(NSInteger)index
{
    if (YES == m_isSeeking) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* currentTime = [self transformTimeFromLong:time];
        [m_startTimeLab setText:[self transformToShortTime:currentTime]];
        DefLog(@"_m_startTimeLab.text = %@", m_startTimeLab.text);
        Float64 rate = [self transformToDeltaTime:m_beginTimeSelected EndTime:currentTime] / m_deltaTime;
        Float64 slider_value = rate * (m_playSlider.maximumValue - m_playSlider.minimumValue);
        [m_playSlider setValue:slider_value animated:YES];
    });
}

#pragma mark - TS/PS标准流数据回调
- (void)onStreamCallback:(NSData*)data Index:(NSInteger)index
{
    if (m_streamPath) {
        NSFileHandle* fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:m_streamPath];

        [fileHandle seekToEndOfFile]; //将节点跳到文件的末尾

        [fileHandle writeData:data]; //追加写入数据

        [fileHandle closeFile];
        return;
    }
    NSDateFormatter* dataFormat = [[NSDateFormatter alloc] init];
    [dataFormat setDateFormat:@"yyyyMMddHHmmss"];
    NSString* strDate = [dataFormat stringFromDate:[NSDate date]];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
        NSUserDomainMask, YES);
    NSString* libraryDirectory = [paths objectAtIndex:0];

    NSString* myDirectory =
        [libraryDirectory stringByAppendingPathComponent:@"lechange"];
    NSString* davDirectory =
        [myDirectory stringByAppendingPathComponent:@"HLSexportStream"];
    m_streamPath = [davDirectory stringByAppendingFormat:@"/%@.ps", strDate];
    NSFileManager* fileManage = [NSFileManager defaultManager];
    NSError* pErr;
    BOOL isDir;
    if (NO == [fileManage fileExistsAtPath:myDirectory isDirectory:&isDir]) {
        [fileManage createDirectoryAtPath:myDirectory
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:&pErr];
    }
    if (NO == [fileManage fileExistsAtPath:davDirectory isDirectory:&isDir]) {
        [fileManage createDirectoryAtPath:davDirectory
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:&pErr];
    }
    if (NO == [fileManage fileExistsAtPath:m_streamPath]) //如果不存在
    {
        [data writeToFile:m_streamPath atomically:YES];
    }
}

#pragma mark - 返回
- (void)onBack
{
    if (m_play) {
        switch (m_playType) {
        case DeviceRecord:
            [m_play stopDeviceRecord];
            break;
        case CloudRecord:
            [m_play stopCloud];
        default:
            break;
        }
        m_playState = Stop;
    }

    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSTimeInterval)timeIntervalOfString:(NSString*)strTime
{
    NSString* regex = @"[1-9]\\d{3}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}"; //正常字符范围
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex]; //比较处理

    //不符合格式的返回0
    if (![pred evaluateWithObject:strTime]) {
        DefLog(@"Time format error:%@", strTime);
        return 0;
    }

    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* date = [formatter dateFromString:strTime];
    return [date timeIntervalSince1970];
}

- (NSTimeInterval)transformToDeltaTime:(NSString*)beginTime EndTime:(NSString*)endTime
{
    NSTimeInterval t_beginTime;
    NSTimeInterval t_endTime;
    NSTimeInterval t_deltaTime;

    t_beginTime = [self timeIntervalOfString:beginTime];
    t_endTime = [self timeIntervalOfString:endTime];

    if (t_endTime >= t_beginTime && t_beginTime != 0 && t_endTime != 0) {
        t_deltaTime = t_endTime - t_beginTime;
    } else {
        return 0;
    }
    return t_deltaTime;
}

- (NSString*)transformToShortTime:(NSString*)time
{
    NSString* regex = @"[1-9]\\d{3}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}"; //正常字符范围
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex]; //比较处理
    if (![pred evaluateWithObject:time]) {
        DefLog(@"Time format error:%@", time);
        return 0;
    }
    NSString* shortTime;
    NSArray* array = [time componentsSeparatedByString:@" "]; //从字符' '中分隔成2个元素的数组
    DefLog(@"array:%@", array); //结果是"yyyy-mm-dd"和"HH:MM:SS"
    shortTime = array[1];

    return shortTime;
}

- (NSString*)transformTimeFromLong:(long)time
{
    NSDate* resDate = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";

    NSString* strTime = [formatter stringFromDate:resDate];
    DefLog(@"时间戳转日期%@", strTime);
    return strTime;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self layoutViews:toInterfaceOrientation force:NO];
}

- (void)viewWillLayoutSubviews
{
    DefLog(@"do nothing, but rewrite method! ");
}

- (void)layoutViews:(UIInterfaceOrientation)InterfaceOrientation force:(BOOL)beForce
{
    CGFloat width = [[[UIDevice currentDevice] systemVersion] floatValue] < 7 ? m_screenFrame.size.width - 20 : m_screenFrame.size.width;
    if (UIInterfaceOrientationIsPortrait(InterfaceOrientation)) {
        [m_scalBtn setBackgroundImage:[UIImage leChangeImageNamed:VideoPlay_FullScreen_Png] forState:UIControlStateNormal];
        [m_play setWindowFrame:CGRectMake(0, super.m_yOffset, m_screenFrame.size.width, m_screenFrame.size.width * 9 / 16)];
        m_playImg.frame = CGRectMake(0, super.m_yOffset, m_screenFrame.size.width, m_screenFrame.size.width * 9 / 16);
        m_progressInd.center = m_playImg.center;
        m_playBarView.frame = CGRectMake(0, super.m_yOffset + m_playImg.frame.size.height - RECORD_BAR_HEIGHT, m_playImg.frame.size.width, RECORD_BAR_HEIGHT);
        [self refreshSubView];
//        super.m_navigationBar.hidden = NO;
        self.navigationController.navigationBar.hidden = NO;
    } else {
        [m_scalBtn setBackgroundImage:[UIImage leChangeImageNamed:VideoPlay_SmallScreen_Png] forState:UIControlStateNormal];
        [m_play setWindowFrame:CGRectMake(0, 0, m_screenFrame.size.height, width)];
        m_playImg.frame = CGRectMake(0, 0, m_screenFrame.size.height, width);
        m_progressInd.center = m_playImg.center;
        m_playBarView.frame = CGRectMake(0, width - RECORD_BAR_HEIGHT, m_screenFrame.size.height, RECORD_BAR_HEIGHT);
        [self refreshSubView];
        [self.view bringSubviewToFront:m_playBarView];
        super.m_navigationBar.hidden = YES;
        self.navigationController.navigationBar.hidden = YES;
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

// 显示滚动轮指示器
- (void)showLoading
{
    dispatch_async(dispatch_get_main_queue(), ^{
         [m_progressInd startAnimating];
    });
}
// 消除滚动轮指示器
- (void)hideLoading
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([m_progressInd isAnimating]) {
            [m_progressInd stopAnimating];
        }
    });
}

- (void)onActive:(id)sender
{
}

- (void)onResignActive:(id)sender
{
    if (m_play) {
        [m_play stopCloud];
        [m_play stopDeviceRecord];
        [m_play stopAudio];
        m_playState = Stop;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        //        m_tipLab.text = @"rtsp connection closed";
        [self hideLoading];
        m_playImg.hidden = NO;
        [m_playBtn setBackgroundImage:[UIImage leChangeImageNamed:VideoPlay_Play_Png] forState:UIControlStateNormal];
        [self enableOtherBtn:NO];

        m_startTimeLab.text = [self transformToShortTime:m_beginTimeSelected];
        [m_playSlider setValue:0];
    });
}

//页面将要消失时释放
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (m_play) {
       [m_play stopCloud];
        [m_play stopDeviceRecord];
        [m_play stopAudio];
        m_playState = Stop;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
           //        m_tipLab.text = @"rtsp connection closed";
           [self hideLoading];
           m_playImg.hidden = NO;
           [m_playBtn setBackgroundImage:[UIImage leChangeImageNamed:VideoPlay_Play_Png] forState:UIControlStateNormal];
           [self enableOtherBtn:NO];

           m_startTimeLab.text = [self transformToShortTime:m_beginTimeSelected];
           [m_playSlider setValue:0];
    });
}
@end
