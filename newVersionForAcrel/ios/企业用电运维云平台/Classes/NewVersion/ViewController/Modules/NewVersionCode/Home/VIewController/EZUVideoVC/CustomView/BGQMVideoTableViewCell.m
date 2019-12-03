//
//  BGQMVideoTableViewCell.m
//  变电所运维
//
//  Created by Acrel on 2019/6/6.
//  
//

#import "BGQMVideoTableViewCell.h"
#import "EZUIError.h"
#import "EZUIKitPlaybackViewController.h"
#import "BGQMVideoListTableVC.h"

#define leftOrRightMargin 5

@implementation BGQMVideoTableViewCell

//初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withPlayerData:(NSDictionary *)playData{
    
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.urlStr = [NSString changgeNonulWithString:playData[@"fHighurl"]];
        if (self.urlStr) {
            self.mPlayer = [EZUIPlayer createPlayerWithUrl:self.urlStr];
            self.mPlayer.mDelegate = self;
            self.isPLaying = NO;
//            self.mPlayer.previewView.frame = CGRectMake(0, 0,CGRectGetWidth(self.mPlayer.previewView.frame),CGRectGetHeight(self.mPlayer.previewView.frame));
//            self.mPlayer.customIndicatorView = nil;//去除加载动画
//            self.mPlayer.previewView.frame = CGRectMake(0, 0, SCREEN_WIDTH-leftOrRightMargin *4, CGRectGetHeight(self.mPlayer.previewView.frame)-leftOrRightMargin*2);
            self.mPlayer.previewView.frame = CGRectMake(0, 0, SCREEN_WIDTH-leftOrRightMargin *4, DefVideoCellHeight-40-leftOrRightMargin*2);
            self.cellheight = CGRectGetHeight(self.mPlayer.previewView.frame);
//            DefVideoCellHeight
            [self.bgVideoView addSubview:self.mPlayer.previewView];
            //        [self.mPlayer startPlay];
        }
    }
    return self;
}

- (void)didInitializeWithStyle:(UITableViewCellStyle)style {
    [super didInitializeWithStyle:style];
    // init 时做的事情请写在这里
    self.backgroundColor = COLOR_BACKGROUND;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self addSubview:self.bgView];
    self.playBtn.selected = NO;
    
    [self.bgView addSubview:self.secView];
    [self.secView addSubview:self.bgVideoView];
    [self.bgView addSubview:self.nameLab];
    [self.bgView addSubview:self.iconCameraImage];
    [self.bgView addSubview:self.iconMoreImage];
    [self.bgView addSubview:self.playBtn];
    [self.bgView addSubview:self.playBackBtn];
    
}

- (void)updateCellAppearanceWithIndexPath:(NSIndexPath *)indexPath {
    [super updateCellAppearanceWithIndexPath:indexPath];
    // 每次 cellForRow 时都要做的事情请写在这里
//    if (self.urlStr) {
//        self.mPlayer = [EZUIPlayer createPlayerWithUrl:self.urlStr];
//        self.mPlayer.mDelegate = self;
//        [self.secView addSubview:self.mPlayer.previewView];
//    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //建立videoCell
    [self setupVideoCell];
}

-(void)updateConstraints{
    [super updateConstraints];
    [self setupVideoCell];
}

- (void)setupVideoCell{
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(leftOrRightMargin));
        make.right.equalTo(@(-leftOrRightMargin));
        make.top.equalTo(@(10));
        make.bottom.equalTo(self.contentView).with.offset(-leftOrRightMargin);
    }];
    
    [_secView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView.mas_left).offset(0);
        make.top.equalTo(self.bgView.mas_top).offset(30);
        make.right.equalTo(self.bgView.mas_right).offset(0);
//        make.bottom.equalTo(self.contentView).with.offset(-8);
        make.bottom.equalTo(self.bgView.mas_bottom).offset(0);
    }];
    
    [_bgVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.secView.mas_left).offset(leftOrRightMargin);
        make.top.equalTo(self.secView.mas_top).offset(0);
        make.right.equalTo(self.secView.mas_right).offset(-leftOrRightMargin);
        make.bottom.equalTo(self.secView.mas_bottom).offset(-leftOrRightMargin);
//        make.height.mas_offset(self.cellheight);
    }];
  
    [_iconCameraImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.secView.mas_left).offset(8);
//        make.bottom.equalTo(self.secView.mas_top).offset(3);
        make.top.equalTo(@(7));
        make.width.mas_offset(18);
        make.height.mas_offset(20);
    }];
    
    [_nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconCameraImage.mas_right).offset(5);
        make.width.mas_offset(150);
        make.centerY.equalTo(self.iconCameraImage.mas_centerY);
    }];
    
    [_playBackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.secView.mas_right).offset(-5);
        make.width.mas_offset(60);
        make.centerY.equalTo(self.iconCameraImage.mas_centerY);
    }];
    [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.playBackBtn.mas_left).offset(5);
        make.width.mas_offset(60);
        make.centerY.equalTo(self.iconCameraImage.mas_centerY);
    }];
    
}

#pragma mark --- setter and getter

-(UIView *)bgView{
    if (!_bgView) {
        _bgView  = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor whiteColor];
    }
    return _bgView;
}

-(UIView *)secView{
    if (!_secView) {
        _secView  = [[UIView alloc] init];
        _secView.backgroundColor = [UIColor whiteColor];
//        _secView.backgroundColor = [UIColor blackColor];
    }
    return _secView;
}

-(UIView *)bgVideoView{
    if (!_bgVideoView) {
        _bgVideoView  = [[UIView alloc] init];
        _bgVideoView.backgroundColor = [UIColor blackColor];
    }
    return _bgVideoView;
}

-(UIImageView *)iconCameraImage{
    if (!_iconCameraImage) {
        _iconCameraImage  = [[UIImageView alloc] init];
//        CGFloat rgb = 244 / 255.0;
//        _iconCameraImage.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
        _iconCameraImage.image = [UIImage imageNamed:@"shexiangtou"];
    }
    return _iconCameraImage;
}

-(UILabel *)nameLab{
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] init];
        _nameLab.textColor = [UIColor grayColor];
        _nameLab.font = [UIFont systemFontOfSize:14.0f];
        _nameLab.textAlignment=NSTextAlignmentLeft;
    }
    return _nameLab;
}

-(UIImageView *)iconMoreImage{
    if (!_iconMoreImage) {
        _iconMoreImage  = [[UIImageView alloc] init];
        CGFloat rgb = 244 / 255.0;
        _iconMoreImage.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
    }
    return _iconMoreImage;
}

-(UIButton *)playBtn{
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setTitle:DefLocalizedString(@"play") forState:UIControlStateNormal];
        _playBtn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
        _playBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
        [_playBtn setTitleColor:COLOR_NAVBAR forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [_playBtn setTitle:DefLocalizedString(@"stop") forState:UIControlStateSelected];
        [_playBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
        [_playBtn setTitleColor:COLOR_NAVBAR forState:UIControlStateSelected];
        //    self.playBtn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-80)/2, [UIScreen mainScreen].bounds.size.height - 100, 80, 40);
        //    self.playBtn.frame = CGRectMake(100,0 , 40, 40);
        [_playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

-(UIButton *)playBackBtn{
    if (!_playBackBtn) {
        _playBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBackBtn setTitle:DefLocalizedString(@"playBack") forState:UIControlStateNormal];
        _playBackBtn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
        _playBackBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
        [_playBackBtn setTitleColor:COLOR_NAVBAR forState:UIControlStateNormal];
        [_playBackBtn setImage:[UIImage imageNamed:@"playback"] forState:UIControlStateNormal];
//        [_playBackBtn setTitle:DefLocalizedString(@"stop") forState:UIControlStateSelected];
        //    self.playBtn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-80)/2, [UIScreen mainScreen].bounds.size.height - 100, 80, 40);
        //    self.playBtn.frame = CGRectMake(100,0 , 40, 40);
        [_playBackBtn addTarget:self action:@selector(playBackBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBackBtn;
}


- (void)dealloc
{
    [self releasePlayer];
}

#pragma mark - player delegate

- (void) EZUIPlayerFinished:(EZUIPlayer*) player
{
    [player stopPlay];
    self.playBtn.selected = NO;
}

- (void) EZUIPlayerPrepared:(EZUIPlayer*) player
{
//    [player startPlay];
}

- (void) EZUIPlayerPlaySucceed:(EZUIPlayer *)player
{
    self.playBtn.selected = YES;
}

- (void) EZUIPlayer:(EZUIPlayer *)player didPlayFailed:(EZUIError *) error
{
    [player stopPlay];
    self.playBtn.selected = NO;
    
    if ([error.errorString isEqualToString:UE_ERROR_INNER_VERIFYCODE_ERROR])
    {
        [self.bgView makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",NSLocalizedString(@"verify_code_wrong", @"验证码错误,请重新获取url地址增加验证码"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_APPKEY_ERROR])
    {
        [self.bgView makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"Appkeyaccesstokendonotmatch", @"appkey和AccessToken不匹配,建议更换appkey或者AccessToken"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_TRANSF_DEVICE_OFFLINE])
    {
        [self.bgView makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"device_offline", @"设备不在线，确认设备上线之后重试"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_ACCESSTOKEN_ERROR_OR_EXPIRE])
    {
        [self.bgView makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                               NSLocalizedString(@"accesstoken_fail", @"accesstoken异常或失效，需要重新获取"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_DEVICE_NOT_EXIST])
    {
        [self.bgView makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"device_not_exist", @"设备不存在,请前往网页端进行配置"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_CAMERA_NOT_EXIST])
    {
        [self.bgView makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"camera_not_exist", @"通道不存在，设备参数错误，请前往网页端进行配置"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_INNER_STREAM_TIMEOUT])
    {
        [self.bgView makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"connect_out_time", @"连接设备超时，请检测设备网路连接是否正常"),
                              error.errorString,error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_CAS_MSG_PU_NO_RESOURCE])
    {
        [self.bgView makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"connect_device_limit", @"设备连接数过大，可咨询客服获取升级流程"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_NOT_FOUND_RECORD_FILES])
    {
        [self.bgView makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"not_find_file", @"未找到录像文件，请前往网页端进行配置"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_PARAM_ERROR])
    {
        [self.bgView makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"param_error", @"参数错误，请前往网页端进行配置"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_URL_FORMAT_ERROR])
    {
        [self.bgView makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"play_url_format_wrong", @"播放地址格式错误，请前往网页端进行配置"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_TRANSF_TERMINAL_BINDING])
    {
        [self.bgView makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"currentAccount", @"当前账号开启了终端绑定，只允许指定设备登录操作"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_INNER_DEVICE_NULLINFO])
    {
        [self.bgView makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"informationEmpty", @"设备信息异常为空，请前往网页端进行配置"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    else if ([error.errorString isEqualToString:UE_ERROR_STREAM_CLIENT_LIMIT])
    {
        [self.bgView makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"Limitofconcurrentaccess", @"取流并发路数限制"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    else
    {
        [self.bgView makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"play_fail", @"播放失败，请联系萤石云官方人员处理"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
    }
    
    DefLog(@"play error:%@(%ld)",error.errorString,(long)error.internalErrorCode);
}

- (void) EZUIPlayer:(EZUIPlayer *)player previewWidth:(CGFloat)pWidth previewHeight:(CGFloat)pHeight
{
//    if (self.urlStrOhter)
//    {
//        CGFloat ratio = pWidth/pHeight;
//        CGFloat destWidth = 0,destHeight = 0,px = 0,py = 0;
//        if (ratio < 3/4)
//        {
//            destWidth = [UIScreen mainScreen].bounds.size.width;
//            destHeight = destWidth/ratio;
//            px = 0;
//            py = ([UIScreen mainScreen].bounds.size.width/3*4-destHeight)/2;
//        }
//        else
//        {
//            destHeight = [UIScreen mainScreen].bounds.size.width/3*4;
//            destWidth = destHeight*ratio;
//            px = ([UIScreen mainScreen].bounds.size.width - destWidth)/2;
//            py = 0;
//        }
//
//        [player setPreviewFrame:CGRectMake(px, py, destWidth, destHeight)];
//    }
//    else
//    {
//        CGFloat ratio = pWidth/pHeight;
//
        CGFloat destWidth = CGRectGetWidth(self.bgView.bounds);
//        CGFloat destHeight = destWidth/ratio;
        [player setPreviewFrame:CGRectMake(0, 0, SCREEN_WIDTH-leftOrRightMargin *4, DefVideoCellHeight-40-leftOrRightMargin*2)];
    self.isChangeHeight = YES;
//    [self.videoPlayBackdelegate clickPlayBtnInCell:self withPushData:CGRectGetHeight(self.mPlayer.previewView.frame)];
//    DefLog(@"player:%@",player);
//    [self.bgVideoView addSubview:player.previewView];
//    [self setNeedsUpdateConstraints];
//    [self updateConstraintsIfNeeded];
//    [self setNeedsLayout];
//    [self layoutIfNeeded];

//    }
}
#pragma mark --- playEZUKit

- (void) playBtnClick:(UIButton *) btn
{
    if(btn.selected)
    {
        [self stop];
        self.isChangeHeight = NO;
        self.isPLaying = NO;
    }
    else
    {
        [self play];
        self.isPLaying =YES;
    }
    btn.selected = !btn.selected;
}

- (void) play
{
    if (self.mPlayer)
    {
        [self.mPlayer startPlay];
        
        //        if (self.mPlayerOther)
        //        {
        //            [self.mPlayerOther startPlay];
        //        }
        
        return;
    }
    if (!self.urlStr.length) {
        [MBProgressHUD showError:@"视频相关信息不全，需补全视频信息。"];
        return;
    }
    self.mPlayer = [EZUIPlayer createPlayerWithUrl:self.urlStr];
    self.mPlayer.mDelegate = self;
//        self.mPlayer.customIndicatorView = nil;//去除加载动画
    self.mPlayer.previewView.frame = CGRectMake(0, 0,
                                                SCREEN_WIDTH-leftOrRightMargin *4,
                                                CGRectGetHeight(self.mPlayer.previewView.frame));
    
    [self.bgVideoView addSubview:self.mPlayer.previewView];
   
    //该处去除，调整到prepared回调中执行，如为预览模式也可直接调用startPlay
    [self.mPlayer startPlay];
    
}

- (void) stop
{
    if (self.mPlayer)
    {
        [self.mPlayer stopPlay];
    }
    
}

- (void) releasePlayer
{
    if (self.mPlayer)
    {
        [self.mPlayer.previewView removeFromSuperview];
        [self.mPlayer releasePlayer];
        self.mPlayer = nil;
    }
    
}

- (void)playBackBtnClick:(UIButton *)btn
{
//    NSDictionary *param = @{@""};
    [self.videoPlayBackdelegate clickPlayBackBtnInCell:self withPushData:nil];
//    EZUIKitPlaybackViewController *vc = [[EZUIKitPlaybackViewController alloc] init];
//    vc.appKey = self.appKey;
//    vc.accessToken = self.accessToken;
//    NSString *urlStr = @"ezopen://open.ys7.com/183414608/1.rec?begin=20190619000000&end=20190620235959";
//    vc.urlStr = urlStr;
    //    if (self.globalMode)
    //    {
    //        vc.apiUrl = apiUrl;
    //    }
//    [self.navigationController pushViewController:vc animated:YES];
//    [self.qmui_viewController presentViewController:vc animated:YES completion:nil];
}

- (void)timeCheckUpdateNetworkAccessToken{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    //    DefLog(@"之前时间：%@", [userDefault objectForKey:@"nowDate"]);//之前存储的时间
    //    DefLog(@"现在时间%@",[NSDate date]);//现在的时间
    NSDate *now = [NSDate date];
    NSDate *agoDate = [userDefault objectForKey:@"nowDate"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *ageDateString = [dateFormatter stringFromDate:agoDate];
    NSString *nowDateString = [dateFormatter stringFromDate:now];
    DefLog(@"日期比较：之前：%@ 现在：%@",ageDateString,nowDateString);
    
    if ([ageDateString isEqualToString:nowDateString]) {
        DefLog(@"一天就显示一次");
        
    }else{
        __weak typeof(self) weakSelf = self;
        NSString *param = [NSString stringWithFormat:@"https://open.ys7.com/api/lapp/token/get?appKey=%@&appSecret=%@",@"cec0dca73dfc4782bc84375a57cd8170",@"ded9a969ec3abc6de7f675e04fa549a8"];
        [BGHttpService bg_httpPostWithPath:param params:nil success:^(id respObjc) {
            NSString *code = [NSString bg_changgeNullStringWithString:respObjc[@"code"]];
            if(code && [code isEqualToString:@"200"]){
//                weakSelf.accessTokenInput.text = respObjc[@"data"][@"accessToken"];
            }
            // 需要执行的方法写在这里
            NSDate *nowDate = [NSDate date];
            NSUserDefaults *dataUser = [NSUserDefaults standardUserDefaults];
            [dataUser setObject:nowDate forKey:@"nowDate"];
            [dataUser synchronize];
        } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
            //        返回码    返回消息    描述
            //        200    操作成功    请求成功
            //        10001    参数错误    参数为空或格式不正确
            //        10005    appKey异常    appKey被冻结
            //        10017    appKey不存在    确认appKey是否正确
            //        10030    appkey和appSecret不匹配
            //        49999    数据异常    接口调用异常
        }];
    }
}

@end
