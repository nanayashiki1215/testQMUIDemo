//
//  EZLivePlayViewController.m
//  EZOpenSDKDemo
//
//  Created by DeJohn Dong on 15/10/28.
//  Copyright © 2015年 hikvision. All rights reserved.
//

#import <sys/sysctl.h>
#import <mach/mach.h>
#import <Photos/Photos.h>
#import "EZLivePlayViewController.h"
//#import "UIViewController+EZBackPop.h"
#import "EZDeviceInfo.h"
#import "EZPlayer.h"
#import "DDKit.h"
#import "Masonry.h"
#import "HIKLoadView.h"
#import "MBProgressHUD.h"
#import "EZCameraInfo.h"
#import <AVFoundation/AVFoundation.h>
#import "Toast+UIView.h"
#import "EZSettingViewController.h"

@interface EZLivePlayViewController ()<EZPlayerDelegate, UIAlertViewDelegate>
{
    NSOperation *op;
    BOOL _isPressed;
}

@property (nonatomic) BOOL isOpenSound;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic, strong) NSTimer *recordTimer;
@property (nonatomic) NSTimeInterval seconds;
@property (nonatomic, strong) CALayer *orangeLayer;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) EZPlayer *player;
@property (nonatomic, strong) EZPlayer *talkPlayer;
@property (nonatomic) BOOL isStartingTalk;
@property (nonatomic, strong) HIKLoadView *loadingView;
@property (nonatomic, weak) IBOutlet UIButton *playerPlayButton;
@property (nonatomic, weak) IBOutlet UIView *playerView;
@property (nonatomic, weak) IBOutlet UIView *toolBar;
@property (nonatomic, weak) IBOutlet UIView *bottomView;
@property (nonatomic, weak) IBOutlet UIButton *controlButton;
@property (nonatomic, weak) IBOutlet UIButton *talkButton;
@property (nonatomic, weak) IBOutlet UIButton *captureButton;
@property (nonatomic, weak) IBOutlet UIButton *localRecordButton;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UIButton *voiceButton;
@property (nonatomic, weak) IBOutlet UIButton *qualityButton;
@property (nonatomic, weak) IBOutlet UIButton *emptyButton;
@property (nonatomic, weak) IBOutlet UIButton *largeButton;
@property (nonatomic, weak) IBOutlet UIButton *largeBackButton;
@property (nonatomic, weak) IBOutlet UIView *ptzView;
@property (nonatomic, weak) IBOutlet UIButton *ptzCloseButton;
@property (nonatomic, weak) IBOutlet UIButton *ptzControlButton;
@property (nonatomic, weak) IBOutlet UIView *qualityView;
@property (nonatomic, weak) IBOutlet UIButton *highButton;
@property (nonatomic, weak) IBOutlet UIButton *middleButton;
@property (nonatomic, weak) IBOutlet UIButton *lowButton;
@property (nonatomic, weak) IBOutlet UIButton *ptzUpButton;
@property (nonatomic, weak) IBOutlet UIButton *ptzLeftButton;
@property (nonatomic, weak) IBOutlet UIButton *ptzDownButton;
@property (nonatomic, weak) IBOutlet UIButton *ptzRightButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *ptzViewContraint;
@property (nonatomic, weak) IBOutlet UILabel *localRecordLabel;
@property (nonatomic, weak) IBOutlet UIView *talkView;
@property (nonatomic, weak) IBOutlet UIButton *talkCloseButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *talkViewContraint;
@property (nonatomic, weak) IBOutlet UIImageView *speakImageView;
@property (nonatomic, weak) IBOutlet UILabel *largeTitleLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *localRecrodContraint;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *cloudBtn;
@property (weak, nonatomic) IBOutlet UILabel *currentHDStatus;
@property (nonatomic, strong) NSMutableData *fileData;
@property (nonatomic, weak) MBProgressHUD *voiceHud;
@property (nonatomic, strong) EZCameraInfo *cameraInfo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playViewAspect;

@end

@implementation EZLivePlayViewController

- (void)dealloc
{
    NSLog(@"%@ dealloc", self.class);
    [EZOPENSDK releasePlayer:_player];
    [EZOPENSDK releasePlayer:_talkPlayer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = _deviceInfo.deviceName;
    self.largeTitleLabel.text = self.title;
    
//    self.isAutorotate = YES;
    self.isStartingTalk = NO;
    self.ptzView.hidden = YES;
    self.talkView.hidden = YES;
    
    self.talkButton.enabled = self.deviceInfo.isSupportTalk;
//    self.talkButton.enabled = 3;
//    self.controlButton.enabled = YES;
    self.controlButton.enabled = self.deviceInfo.isSupportPTZ;
    self.captureButton.enabled = NO;
    self.localRecordButton.enabled = NO;
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"select"] style:UIBarButtonItemStylePlain target:self action:@selector(clickSettingBtn)];
//    _url = @"rtsp://183.136.184.33:8554/demo://544542032:1:1:1:0:183.136.184.7:6500";
    
//    _url = @"ysproto://122.225.228.217:8554/live?dev=501694318&chn=1&stream=2&cln=1&isp=0&biz=3";
    
    if (_url)
    {
        _player = [EZOPENSDK createPlayerWithUrl:_url];
    }
    else
    {
        _cameraInfo = [self.deviceInfo.cameraInfo dd_objectAtIndex:_cameraIndex];
        _player = [EZOPENSDK createPlayerWithDeviceSerial:_cameraInfo.deviceSerial cameraNo:_cameraInfo.cameraNo];
//        _player.backgroundModeByPlayer = NO;
        _talkPlayer = [EZOPENSDK createPlayerWithDeviceSerial:_cameraInfo.deviceSerial cameraNo:_cameraInfo.cameraNo];
//        _player = [EZOPENSDK createPlayerWithDeviceSerial:info.deviceSerial cameraNo:info.cameraNo streamType:1];
        if (_cameraInfo.videoLevel == 2)
        {
            [self.qualityButton setTitle:NSLocalizedString(@"device_quality_high", @"高清") forState:UIControlStateNormal];
        }
        else if (_cameraInfo.videoLevel == 1)
        {
            [self.qualityButton setTitle:NSLocalizedString(@"device_quality_median", @"均衡") forState:UIControlStateNormal];
        }
        else
        {
            [self.qualityButton setTitle:NSLocalizedString(@"device_quality_low",@"流畅") forState:UIControlStateNormal];
        }
    }
    
#if DEBUG
    if (!_url)
    {
        //抓图接口演示代码
        [EZOPENSDK captureCamera:_cameraInfo.deviceSerial cameraNo:_cameraInfo.cameraNo completion:^(NSString *url, NSError *error) {
            NSLog(@"[%@] capture cameraNo is [%d] url is %@, error is %@", _cameraInfo.deviceSerial, (int)_cameraInfo.cameraNo, url, error);
        }];
    }
#endif
    
    _player.delegate = self;
    _talkPlayer.delegate = self;
    //判断设备是否加密，加密就从demo的内存中获取设备验证码填入到播放器的验证码接口里，本demo只处理内存存储，本地持久化存储用户自行完成
    if (self.deviceInfo.isEncrypt)
    {
        NSString *verifyCode = [[GlobalKit shareKit].deviceVerifyCodeBySerial objectForKey:self.deviceInfo.deviceSerial];
        [_player setPlayVerifyCode:verifyCode];
        [_talkPlayer setPlayVerifyCode:verifyCode];
    }
    [_player setPlayerView:_playerView];
    BOOL hdStatus = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"EZVideoPlayHardDecodingStatus_%@", self.deviceInfo.deviceSerial]];
    [_player setHDPriority:hdStatus];
    [_player startRealPlay];
    
    if(!_loadingView)
        _loadingView = [[HIKLoadView alloc] initWithHIKLoadViewStyle:HIKLoadViewStyleSqureClockWise];
    [self.view insertSubview:_loadingView aboveSubview:self.playerView];
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(@14);
        make.centerX.mas_equalTo(self.playerView.mas_centerX);
        make.centerY.mas_equalTo(self.playerView.mas_centerY);
    }];
    [self.loadingView startSquareClcokwiseAnimation];
    
    self.largeBackButton.hidden = YES;
    _isOpenSound = YES;
    
    [self.controlButton dd_centerImageAndTitle];
    [self.talkButton dd_centerImageAndTitle];
    [self.captureButton dd_centerImageAndTitle];
    [self.localRecordButton dd_centerImageAndTitle];
    
    [self.voiceButton setImage:[UIImage imageNamed:@"preview_unvoice_btn_sel"] forState:UIControlStateHighlighted];
    [self addLine];
    
    self.localRecordLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.localRecordLabel.layer.cornerRadius = 12.0f;
    self.localRecordLabel.layer.borderWidth = 1.0f;
    self.localRecordLabel.clipsToBounds = YES;
    self.playButton.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.ptzViewContraint.constant = self.bottomView.frame.size.height;
    self.talkViewContraint.constant = self.ptzViewContraint.constant;
}

- (void)viewWillDisappear:(BOOL)animated {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideQualityView) object:nil];
    //结束本地录像
    if(self.localRecordButton.selected)
    {
        [_player stopLocalRecordExt:^(BOOL ret) {
            NSLog(@"%d", ret);
            [_recordTimer invalidate];
            _recordTimer = nil;
            self.localRecordLabel.hidden = YES;
            [self saveRecordToPhotosAlbum:_filePath];
            _filePath = nil;
        }];
    }
    
    NSLog(@"viewWillDisappear");
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"viewDidDisappear");
    [super viewDidDisappear:animated];
    [_player stopRealPlay];
    if (_talkPlayer)
    {
        [_talkPlayer stopVoiceTalk];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)clickSettingBtn{
    UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"EZMain" bundle:[NSBundle mainBundle]];
    EZSettingViewController *detailVC = [mainSB instantiateViewControllerWithIdentifier:@"EZSettingViewController"];
    detailVC.deviceInfo = self.deviceInfo;
    [self.navigationController pushViewController:detailVC animated:YES];
}

//全屏切换
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
//    [super viewWillTransitionToSize:size withTransitionCoordinator:duration];
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    self.navigationController.navigationBarHidden = NO;
    self.toolBar.hidden = NO;
    self.largeBackButton.hidden = YES;
    self.bottomView.hidden = NO;
    self.largeTitleLabel.hidden = YES;
    self.localRecrodContraint.constant = 10;
    //修改宽度比
    [NSLayoutConstraint deactivateConstraints:@[self.playViewAspect]];
     
    self.playViewAspect= [NSLayoutConstraint constraintWithItem:self.playerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.playerView attribute:NSLayoutAttributeHeight multiplier:1.7 constant:0];
     
    [NSLayoutConstraint activateConstraints:@[self.playViewAspect]];
    
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
       toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        self.navigationController.navigationBarHidden = YES;
        self.localRecrodContraint.constant = 50;
        self.toolBar.hidden = YES;
        self.largeTitleLabel.hidden = NO;
        self.largeBackButton.hidden = NO;
        self.bottomView.hidden = YES;
//        self.playerView
//        [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
////               make.height.mas_equalTo(SCREEN_HEIGHT);
////              make.width.mas_equalTo(SCREEN_WIDTH);
////            make.width.equalTo(self.view.mas_height).multipliedBy(1.0f);
//             make.width.equalTo(self.view.mas_height);
//        }];

        //修改宽度比
        [NSLayoutConstraint deactivateConstraints:@[self.playViewAspect]];
         
        self.playViewAspect= [NSLayoutConstraint constraintWithItem:self.playerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.playerView attribute:NSLayoutAttributeHeight multiplier:2.1 constant:0];
         
        [NSLayoutConstraint activateConstraints:@[self.playViewAspect]];
       
    }
}

- (IBAction)pressed:(id)sender {
    
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
            if (!self.isStartingTalk)
            {
                [self.player setPlayVerifyCode:checkCode];
                [self.player startRealPlay];
            }
            else
            {
                [self.talkPlayer setPlayVerifyCode:checkCode];
                [self.talkPlayer startVoiceTalk];
            }
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

#pragma mark - PlayerDelegate Methods
//该方法废弃于v4.8.8版本，底层库不再支持。请使用getStreamFlow方法
- (void)player:(EZPlayer *)player didReceivedDataLength:(NSInteger)dataLength
{
    CGFloat value = dataLength/1024.0;
    NSString *fromatStr = @"%.1f KB/s";
    if (value > 1024)
    {
        value = value/1024;
        fromatStr = @"%.1f MB/s";
    }

    [_emptyButton setTitle:[NSString stringWithFormat:fromatStr,value] forState:UIControlStateNormal];
}


- (void)player:(EZPlayer *)player didPlayFailed:(NSError *)error
{
    NSLog(@"player: %@, didPlayFailed: %@", player, error);
    //如果是需要验证码或者是验证码错误
    if (error.code == EZ_SDK_NEED_VALIDATECODE) {
        [self showSetPassword];
        return;
    } else if (error.code == EZ_SDK_VALIDATECODE_NOT_MATCH) {
        [self showRetry];
        return;
    } else if (error.code == EZ_SDK_NOT_SUPPORT_TALK) {
        [UIView dd_showDetailMessage:[NSString stringWithFormat:@"%d", (int)error.code]];
        [self.voiceHud hideAnimated:YES];
        return;
    }
    else
    {
        if ([player isEqual:_player])
        {
            [_player stopRealPlay];
        }
        else
        {
            [_talkPlayer stopVoiceTalk];
        }
    }
    
    //错误提示
    NSString *code = [NSString stringWithFormat:@"%ld",error.code];
    NSString *str = [NSString changgeNonulWithString:[self retErrYinshiyunDic][code]];
    
    [self.voiceHud hideAnimated:YES];
    [self.loadingView stopSquareClockwiseAnimation];
   
    if (str.length) {
        [UIView dd_showDetailMessage:[NSString stringWithFormat:@"%d:%@", (int)error.code,str]];
        self.messageLabel.text = [NSString stringWithFormat:@"%@(%d:%@)",NSLocalizedString(@"device_play_fail", @"播放失败"),(int)error.code, str];
    }else{
        self.messageLabel.text = [NSString stringWithFormat:@"%@(%d)",NSLocalizedString(@"device_play_fail", @"播放失败"), (int)error.code];
    }
//    if (error.code > 370000)
    {
        self.messageLabel.hidden = NO;
    }
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.speakImageView.alpha = 0.0;
                         self.talkViewContraint.constant = self.bottomView.frame.size.height;
                         [self.bottomView setNeedsUpdateConstraints];
                         [self.bottomView layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         self.speakImageView.alpha = 0;
                         self.talkView.hidden = YES;
                     }];
}

- (void)player:(EZPlayer *)player didReceivedMessage:(NSInteger)messageCode
{
    NSLog(@"player: %@, didReceivedMessage: %d", player, (int)messageCode);
    if (messageCode == PLAYER_REALPLAY_START)
    {
        self.captureButton.enabled = YES;
        self.localRecordButton.enabled = YES;
        [self.loadingView stopSquareClockwiseAnimation];
        self.playButton.enabled = YES;
        [self.playButton setImage:[UIImage imageNamed:@"preview_stopplay_btn_sel"] forState:UIControlStateHighlighted];
        [self.playButton setImage:[UIImage imageNamed:@"preview_stopplay_btn"] forState:UIControlStateNormal];
        _isPlaying = YES;
        
        if (!_isOpenSound)
        {
            [_player closeSound];
        }
        self.messageLabel.hidden = YES;
        
        switch ([self.player getHDPriorityStatus]) {
        
            case 1:
                self.currentHDStatus.hidden = NO;
                self.currentHDStatus.text = @"当前解码状态: 软解码";
                break;
            case 2:
                self.currentHDStatus.hidden = NO;
                self.currentHDStatus.text = @"当前解码状态: 硬解码";
                break;
            default:
                break;
        }
        
        NSLog(@"GetInnerPlayerPort:%d", [self.player getInnerPlayerPort]);
        NSLog(@"GetStreamFetchType:%d", [self.player getStreamFetchType]);
    }
    else if(messageCode == PLAYER_VOICE_TALK_START)
    {
        self.messageLabel.hidden = YES;
        [_player closeSound];
//        [_talkPlayer changeTalkingRouteMode:NO];
        self.isStartingTalk = NO;
        [self.voiceHud hideAnimated:YES];
        [self.bottomView bringSubviewToFront:self.talkView];
        self.talkView.hidden = NO;
        self.speakImageView.alpha = 0;
        self.speakImageView.highlighted = self.deviceInfo.isSupportTalk == 1;
        self.speakImageView.userInteractionEnabled = self.deviceInfo.isSupportTalk == 3;
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.talkViewContraint.constant = 0;
                             self.speakImageView.alpha = 1.0;
                             [self.bottomView setNeedsUpdateConstraints];
                             [self.bottomView layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                         }];
    }
    else if (messageCode == PLAYER_VOICE_TALK_END)
    {
        //对讲结束开启声音
        [_player openSound];
    }
    else if (messageCode == PLAYER_NET_CHANGED)
    {
        [_player stopRealPlay];
        [_player startRealPlay];
    }
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
                                              cancelButtonTitle:NSLocalizedString(@"cancel",  @"取消")
                                              otherButtonTitles:NSLocalizedString(@"retry", @"重试"), nil];
    [alertView show];
}

#pragma mark - Action Methods
//转屏幕
- (IBAction)large:(id)sender
{
//    NSNumber *orientationUnknown = [NSNumber numberWithInt:0];
//    [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
    
//    NSNumber *orientationTarget = [NSNumber numberWithInt:orientation];
//    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (IBAction)largeBack:(id)sender
{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (IBAction)capture:(id)sender
{
    UIImage *image = [_player capturePicture:100];
    [self saveImageToPhotosAlbum:image];
}

- (IBAction)talkButtonClicked:(id)sender
{
    if (self.deviceInfo.isSupportTalk != 1 && self.deviceInfo.isSupportTalk != 3)
    {
        [self.view makeToast:NSLocalizedString(@"not_support_talk", @"设备不支持对讲")
                    duration:1.5
                    position:@"center"];
        return;
    }
    
    __weak EZLivePlayViewController *weakSelf = self;
    [self checkMicPermissionResult:^(BOOL enable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (enable)
            {
                if (!weakSelf.voiceHud) {
                    weakSelf.voiceHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                }
                weakSelf.voiceHud.label.text = NSLocalizedString(@"device_restart_talk", @"正在开启对讲，请稍候...");
                weakSelf.isStartingTalk = YES;
                NSString *verifyCode = [[GlobalKit shareKit].deviceVerifyCodeBySerial objectForKey:weakSelf.deviceInfo.deviceSerial];
                if (verifyCode)
                {
                    [weakSelf.talkPlayer setPlayVerifyCode:verifyCode];
                }
                [weakSelf.talkPlayer startVoiceTalk];
            }
            else
            {
                [weakSelf.view makeToast:NSLocalizedString(@"no_mic_permission", @"未开启麦克风权限")
                                duration:1.5
                                position:@"center"];
            }
        });
    }];
    
    

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

- (IBAction)playButtonClicked:(id)sender
{
    if(_isPlaying)
    {
        [_player stopRealPlay];
        [_playerView setBackgroundColor:[UIColor blackColor]];
        [self.playButton setImage:[UIImage imageNamed:@"preview_play_btn_sel"] forState:UIControlStateHighlighted];
        [self.playButton setImage:[UIImage imageNamed:@"preview_play_btn"] forState:UIControlStateNormal];
        self.localRecordButton.enabled = NO;
        self.captureButton.enabled = NO;
        self.playerPlayButton.hidden = NO;
    }
    else
    {
        [_player startRealPlay];
        self.playerPlayButton.hidden = YES;
        [self.playButton setImage:[UIImage imageNamed:@"preview_stopplay_btn_sel"] forState:UIControlStateHighlighted];
        [self.playButton setImage:[UIImage imageNamed:@"preview_stopplay_btn"] forState:UIControlStateNormal];
        [self.loadingView startSquareClcokwiseAnimation];
    }
    _isPlaying = !_isPlaying;
}

- (IBAction)qualityButtonClicked:(id)sender
{
    if(self.qualityButton.selected)
    {
        self.qualityView.hidden = YES;
    }
    else
    {
        self.qualityView.hidden = NO;
        //停留5s以后隐藏视频质量View.
        [self performSelector:@selector(hideQualityView) withObject:nil afterDelay:5.0f];
    }
    self.qualityButton.selected = !self.qualityButton.selected;
}

- (void)hideQualityView
{
    self.qualityButton.selected = NO;
    self.qualityView.hidden = YES;
}

- (IBAction)qualitySelectedClicked:(id)sender
{
    BOOL result = NO;
    EZVideoLevelType type = EZVideoLevelLow;
    if (sender == self.highButton)
    {
        type = EZVideoLevelHigh;
    }
    else if (sender == self.middleButton)
    {
        type = EZVideoLevelMiddle;
    }
    else
    {
        type = EZVideoLevelLow;
    }
    [EZOPENSDK setVideoLevel:_cameraInfo.deviceSerial
                    cameraNo:_cameraInfo.cameraNo
                  videoLevel:type
                  completion:^(NSError *error) {
                      if (error)
                      {
                          return;
                      }
                      [_player stopRealPlay];
                      
                      _cameraInfo.videoLevel = type;
                      if (sender == self.highButton)
                      {
                          [self.qualityButton setTitle:NSLocalizedString(@"device_quality_high", @"高清") forState:UIControlStateNormal];
                      }
                      else if (sender == self.middleButton)
                      {
                          [self.qualityButton setTitle:NSLocalizedString(@"device_quality_median", @"均衡") forState:UIControlStateNormal];
                      }
                      else
                      {
                          [self.qualityButton setTitle:NSLocalizedString(@"device_quality_low", @"流畅") forState:UIControlStateNormal];
                      }
                      if (result)
                      {
                          [self.loadingView startSquareClcokwiseAnimation];
                      }
                      self.qualityView.hidden = YES;
                      [_player startRealPlay];
                  }];
}

- (IBAction)ptzControlButtonTouchDown:(id)sender
{
    EZPTZCommand command;
    NSString *imageName = nil;
    if(sender == self.ptzLeftButton)
    {
        command = EZPTZCommandLeft;
        imageName = @"ptz_left_sel";
    }
    else if (sender == self.ptzDownButton)
    {
        command = EZPTZCommandDown;
        imageName = @"ptz_bottom_sel";
    }
    else if (sender == self.ptzRightButton)
    {
        command = EZPTZCommandRight;
        imageName = @"ptz_right_sel";
    }
    else {
        command = EZPTZCommandUp;
        imageName = @"ptz_up_sel";
    }
    [self.ptzControlButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateDisabled];
    EZCameraInfo *cameraInfo = [_deviceInfo.cameraInfo firstObject];
    if (self.cameraIndex) {
        cameraInfo = [_deviceInfo.cameraInfo dd_objectAtIndex:self.cameraIndex];
    } else {
        cameraInfo = [_deviceInfo.cameraInfo firstObject];
    }
    [EZOPENSDK controlPTZ:cameraInfo.deviceSerial
                 cameraNo:cameraInfo.cameraNo
                  command:command
                   action:EZPTZActionStart
                    speed:2
                   result:^(NSError *error) {
                       NSLog(@"error is %@", error);
                   }];
}

- (IBAction)ptzControlButtonTouchUpInside:(id)sender
{
    EZPTZCommand command;
    if(sender == self.ptzLeftButton)
    {
        command = EZPTZCommandLeft;
    }
    else if (sender == self.ptzDownButton)
    {
        command = EZPTZCommandDown;
    }
    else if (sender == self.ptzRightButton)
    {
        command = EZPTZCommandRight;
    }
    else {
        command = EZPTZCommandUp;
    }
    [self.ptzControlButton setImage:[UIImage imageNamed:@"ptz_bg"] forState:UIControlStateDisabled];
    EZCameraInfo *cameraInfo = [_deviceInfo.cameraInfo firstObject];
    if (self.cameraIndex) {
        cameraInfo = [_deviceInfo.cameraInfo dd_objectAtIndex:self.cameraIndex];
    } else {
        cameraInfo = [_deviceInfo.cameraInfo firstObject];
    }
    [EZOPENSDK controlPTZ:cameraInfo.deviceSerial
                 cameraNo:cameraInfo.cameraNo
                  command:command
                   action:EZPTZActionStop
                    speed:2.0
                   result:^(NSError *error) {
                        NSLog(@"error is %@", error);
                   }];
}

- (IBAction)ptzViewShow:(id)sender
{
    self.ptzView.hidden = NO;
    [self.bottomView bringSubviewToFront:self.ptzView];
    self.ptzControlButton.alpha = 0;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.ptzViewContraint.constant = 0;
                         self.ptzControlButton.alpha = 1.0;
                         [self.bottomView setNeedsUpdateConstraints];
                         [self.bottomView layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (IBAction)closePtzView:(id)sender
{
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.ptzControlButton.alpha = 0.0;
                         self.ptzViewContraint.constant = self.bottomView.frame.size.height;
                         [self.bottomView setNeedsUpdateConstraints];
                         [self.bottomView layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         self.ptzControlButton.alpha = 0;
                         self.ptzView.hidden = YES;
                     }];
}

- (IBAction)closeTalkView:(id)sender
{
    [_talkPlayer stopVoiceTalk];
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.speakImageView.alpha = 0.0;
                         self.talkViewContraint.constant = self.bottomView.frame.size.height;
                         [self.bottomView setNeedsUpdateConstraints];
                         [self.bottomView layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         self.speakImageView.alpha = 0;
                         self.talkView.hidden = YES;
                     }];
}

- (IBAction)localButtonClicked:(id)sender
{
    
    //结束本地录像
    if(self.localRecordButton.selected)
    {
        [_player stopLocalRecordExt:^(BOOL ret) {
            
            NSLog(@"%d", ret);
            
            [_recordTimer invalidate];
            _recordTimer = nil;
            self.localRecordLabel.hidden = YES;
            [self saveRecordToPhotosAlbum:_filePath];
            _filePath = nil;
        }];
    }
    else
    {
        //开始本地录像
        NSString *path = @"/OpenSDK/EzvizLocalRecord";
        
        NSArray * docdirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * docdir = [docdirs objectAtIndex:0];
        
        NSString * configFilePath = [docdir stringByAppendingPathComponent:path];
        if(![[NSFileManager defaultManager] fileExistsAtPath:configFilePath]){
            NSError *error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:configFilePath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:&error];
        }
        NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
        dateformatter.dateFormat = @"yyyyMMddHHmmssSSS";
        _filePath = [NSString stringWithFormat:@"%@/%@.mp4",configFilePath,[dateformatter stringFromDate:[NSDate date]]];
        
        self.localRecordLabel.text = @"  00:00";
        
        if (!_recordTimer)
        {
            _recordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerStart:) userInfo:nil repeats:YES];
        }
        [_player startLocalRecordWithPathExt:_filePath];
        
        self.localRecordLabel.hidden = NO;
        _seconds = 0;
    }
    self.localRecordButton.selected = !self.localRecordButton.selected;
}

- (IBAction)clickCloudBtn:(id)sender {

//    [EZOPENSDK openCloudPage:self.deviceInfo.deviceSerial channelNo:_cameraInfo.cameraNo];
}

- (void)timerStart:(NSTimer *)timer
{
    NSInteger currentTime = ++_seconds;
    self.localRecordLabel.text = [NSString stringWithFormat:@"  %02d:%02d", (int)currentTime/60, (int)currentTime % 60];
    if (!_orangeLayer)
    {
        _orangeLayer = [CALayer layer];
        _orangeLayer.frame = CGRectMake(10.0, 8.0, 8.0, 8.0);
        _orangeLayer.backgroundColor = [UIColor dd_hexStringToColor:@"0xff6000"].CGColor;
        _orangeLayer.cornerRadius = 4.0f;
    }
    if(currentTime % 2 == 0)
    {
        [_orangeLayer removeFromSuperlayer];
    }
    else
    {
        [self.localRecordLabel.layer addSublayer:_orangeLayer];
    }
}

- (IBAction)talkPressed:(id)sender
{
    if (!_isPressed)
    {
        self.speakImageView.highlighted = YES;
        [self.talkPlayer audioTalkPressed:YES];
    }
    else
    {
        self.speakImageView.highlighted = NO;
        [self.talkPlayer audioTalkPressed:NO];
    }
    _isPressed = !_isPressed;
}

#pragma mark - Private Methods

- (void) checkMicPermissionResult:(void(^)(BOOL enable)) retCb
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    switch (authStatus)
    {
        case AVAuthorizationStatusNotDetermined://未决
        {
            AVAudioSession *avSession = [AVAudioSession sharedInstance];
            [avSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted)
                {
                    if (retCb)
                    {
                        retCb(YES);
                    }
                }
                else
                {
                    if (retCb)
                    {
                        retCb(NO);
                    }
                }
            }];
        }
            break;
            
        case AVAuthorizationStatusRestricted://未授权，家长限制
        case AVAuthorizationStatusDenied://未授权
            if (retCb)
            {
                retCb(NO);
            }
            break;
            
        case AVAuthorizationStatusAuthorized://已授权
            if (retCb)
            {
                retCb(YES);
            }
            break;
            
        default:
            if (retCb)
            {
                retCb(NO);
            }
            break;
    }
}

- (void)saveImageToPhotosAlbum:(UIImage *)savedImage
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined)
    {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if(status == PHAuthorizationStatusAuthorized)
            {
                UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), NULL);
            }else if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied){
                DefQuickAlert(@"没有相册访问权限，请前往系统设置开启照片访问权限", nil);
            }
        }];
//        [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
//            [PHAssetChangeRequest creationRequestForAssetFromImage:savedImage];
//        } completionHandler:^(BOOL success, NSError * _Nullable error) {
//            if (error) {
//                NSLog(@"%@",@"保存失败");
//            } else {
//                NSLog(@"%@",@"保存成功");
//            }
//        }];
    }
    else
    {
        if (status == PHAuthorizationStatusAuthorized)
        {
            UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), NULL);
        }else if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied){
            DefQuickAlert(@"没有相册访问权限，请前往系统设置开启照片访问权限", nil);
        }
    }
}

- (void)saveRecordToPhotosAlbum:(NSString *)path
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined)
    {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if(status == PHAuthorizationStatusAuthorized)
            {
                UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), NULL);
            }
        }];
    }
    else
    {
        if (status == PHAuthorizationStatusAuthorized)
        {
            UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), NULL);
        }
    }
}

// 指定回调方法
- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *message = nil;
    if (!error) {
        message = NSLocalizedString(@"device_save_gallery", @"已保存至手机相册");
    }
    else
    {
        message = [error description];
    }
    [UIView dd_showMessage:message];
}

- (void)addLine
{
    for (UIView *view in self.toolBar.subviews) {
        if ([view isKindOfClass:[UIImageView class]])
        {
            [view removeFromSuperview];
        }
    }
    CGFloat averageWidth = [UIScreen mainScreen].bounds.size.width/5.0;
    UIImageView *lineImageView1 = [UIView dd_instanceVerticalLine:20 color:[UIColor grayColor]];
    lineImageView1.frame = CGRectMake(averageWidth, 7, lineImageView1.frame.size.width, lineImageView1.frame.size.height);
    [self.toolBar addSubview:lineImageView1];
    UIImageView *lineImageView2 = [UIView dd_instanceVerticalLine:20 color:[UIColor grayColor]];
    lineImageView2.frame = CGRectMake(averageWidth * 2, 7, lineImageView2.frame.size.width, lineImageView2.frame.size.height);
    [self.toolBar addSubview:lineImageView2];
    UIImageView *lineImageView3 = [UIView dd_instanceVerticalLine:20 color:[UIColor grayColor]];
    lineImageView3.frame = CGRectMake(averageWidth * 3, 7, lineImageView3.frame.size.width, lineImageView3.frame.size.height);
    [self.toolBar addSubview:lineImageView3];
    UIImageView *lineImageView4 = [UIView dd_instanceVerticalLine:20 color:[UIColor grayColor]];
    lineImageView4.frame = CGRectMake(averageWidth * 4, 7, lineImageView4.frame.size.width, lineImageView4.frame.size.height);
    [self.toolBar addSubview:lineImageView4];
}

#pragma mark - 屏幕旋转

// 这个方法返回支持的方向
-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    [super supportedInterfaceOrientations];
    return UIInterfaceOrientationMaskAll;
}

-(BOOL)shouldAutorotate {
    [super shouldAutorotate];
    return YES;

}

//-(BOOL)shouldAutorotateToInterfaceOrientation{
//    
//    return YES;
//}

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//
//return UIInterfaceOrientationPortrait;
//
//}


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
@"395547":@"并发路数超限，请升级为企业版",
@"395548":@"并发路数超限，请升级为企业版",
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
