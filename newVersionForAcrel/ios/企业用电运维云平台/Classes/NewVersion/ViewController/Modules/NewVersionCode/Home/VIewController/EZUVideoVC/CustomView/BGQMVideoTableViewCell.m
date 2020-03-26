//
//  BGQMVideoTableViewCell.m
//  变电所运维
//
//  Created by Acrel on 2019/6/6.
//  
//

#import "BGQMVideoTableViewCell.h"
#import "EZUIError.h"
#import "EZOpenSDK.h"
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
    [self.bgView addSubview:self.playDetailBtn];
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
    
    [_playDetailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.secView.mas_right).offset(-5);
        make.width.mas_offset(60);
        make.centerY.equalTo(self.iconCameraImage.mas_centerY);
    }];
    
    [_playBackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.playDetailBtn.mas_left).offset(5);
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

-(UIButton *)playDetailBtn{
    if (!_playDetailBtn) {
        _playDetailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playDetailBtn setTitle:DefLocalizedString(@"playDetail") forState:UIControlStateNormal];
        _playDetailBtn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
        _playDetailBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
        [_playDetailBtn setTitleColor:COLOR_NAVBAR forState:UIControlStateNormal];
        [_playDetailBtn setImage:[UIImage imageNamed:@"playDetail"] forState:UIControlStateNormal];
//        [_playBackBtn setTitle:DefLocalizedString(@"stop") forState:UIControlStateSelected];
        //    self.playBtn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-80)/2, [UIScreen mainScreen].bounds.size.height - 100, 80, 40);
        //    self.playBtn.frame = CGRectMake(100,0 , 40, 40);
        [_playDetailBtn addTarget:self action:@selector(playDetailBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playDetailBtn;
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
    }else if ([error.errorString isEqualToString:UE_ERROR_PLAY_FAIL])
    {
        NSString *errStr = [NSString stringWithFormat:@"%ld",error.internalErrorCode];
        NSString *str = [NSString changgeNonulWithString:[self retErrYinshiyunDic][errStr]];
        if (str.length) {
            [self.bgView makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                      str,
                      error.errorString,
                      error.internalErrorCode]
            duration:1.5
            position:@"center"];
        }else{
            [self.bgView makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                              NSLocalizedString(@"play_fail", @"播放失败，请联系萤石云官方人员处理"),
                              error.errorString,
                              error.internalErrorCode]
                    duration:1.5
                    position:@"center"];
        }
    }
    else
    {
       NSString *errStr = [NSString stringWithFormat:@"%ld",error.internalErrorCode];
       NSString *str = [NSString changgeNonulWithString:[self retErrYinshiyunDic][errStr]];
       if (str.length) {
           [self.bgView makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                     str,
                     error.errorString,
                     error.internalErrorCode]
           duration:1.5
           position:@"center"];
       }else{
           [self.bgView makeToast:[NSString stringWithFormat:@"%@(%@[%ld])",
                      NSLocalizedString(@"play_fail", @"播放失败，请联系萤石云官方人员处理"),
                      error.errorString,
                      error.internalErrorCode]
            duration:1.5
              position:@"center"];
           
       }
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

//点击了播放详情
- (void)playDetailBtnClick:(UIButton *)btn{
    [self.videoPlayBackdelegate clickPlayDetailBtnInCell:self withPushData:nil];
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
