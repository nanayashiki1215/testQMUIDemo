//
//  BGQMImouVideoCell.m
//  企业用电运维云平台
//
//  Created by Acrel on 2020/7/24.
//

#import "BGQMImouVideoCell.h"
#import "BGQMVideoListTableVC.h"

#define leftOrRightMargin 5

@implementation BGQMImouVideoCell

//初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withPlayerData:(NSDictionary *)playData{
    
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
//        self.urlStr = [NSString changgeNonulWithString:playData[@"fHighurl"]];
//        if (self.urlStr) {
//            self.mPlayer = [EZUIPlayer createPlayerWithUrl:self.urlStr];
//            self.mPlayer.mDelegate = self;
//            self.isPLaying = NO;
//            self.mPlayer.previewView.frame = CGRectMake(0, 0, SCREEN_WIDTH-leftOrRightMargin *4, DefVideoCellHeight-40-leftOrRightMargin*2);
//            self.cellheight = CGRectGetHeight(self.mPlayer.previewView.frame);
//            [self.bgVideoView addSubview:self.mPlayer.previewView];
            //        [self.mPlayer startPlay];
//        }
    }
    return self;
}

- (void)didInitializeWithStyle:(UITableViewCellStyle)style {
    [super didInitializeWithStyle:style];
    // init 时做的事情请写在这里
    self.backgroundColor = COLOR_BACKGROUND;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self addSubview:self.bgView];
//    self.playBtn.selected = NO;
    
    [self.bgView addSubview:self.secView];
    [self.secView addSubview:self.bgVideoView];
    [self.bgView addSubview:self.nameLab];
    [self.bgView addSubview:self.iconCameraImage];
    [self.bgView addSubview:self.iconMoreImage];
//    [self.bgView addSubview:self.playBtn];
    [self.bgView addSubview:self.playBackBtn];
    [self.bgView addSubview:self.playDetailBtn];
}

- (void)updateCellAppearanceWithIndexPath:(NSIndexPath *)indexPath {
    [super updateCellAppearanceWithIndexPath:indexPath];
    // 每次 cellForRow 时都要做的事情请写在这里

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
    
//    [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.playBackBtn.mas_left).offset(5);
//        make.width.mas_offset(60);
//        make.centerY.equalTo(self.iconCameraImage.mas_centerY);
//    }];
    
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

-(UIImageView *)bgVideoView{
    if (!_bgVideoView) {
        _bgVideoView  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_defaultcover.png"]];
        _bgVideoView.contentMode = UIViewContentModeScaleAspectFill;
        _bgVideoView.clipsToBounds=YES;
        [_bgVideoView setUserInteractionEnabled:YES];
        [_bgVideoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCategory:)]];
//        [_bgVideoView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"localvideo_defaultpage.png"]]];
//        localvideo_defaultpage
//        _bgVideoView.backgroundColor = [UIColor blackColor];
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

//-(UIButton *)playBtn{
//    if (!_playBtn) {
//        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_playBtn setTitle:DefLocalizedString(@"play") forState:UIControlStateNormal];
//        _playBtn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
//        _playBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
//        [_playBtn setTitleColor:COLOR_NAVBAR forState:UIControlStateNormal];
//        [_playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
//        [_playBtn setTitle:DefLocalizedString(@"stop") forState:UIControlStateSelected];
//        [_playBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
//        [_playBtn setTitleColor:COLOR_NAVBAR forState:UIControlStateSelected];
//        //    self.playBtn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-80)/2, [UIScreen mainScreen].bounds.size.height - 100, 80, 40);
//        //    self.playBtn.frame = CGRectMake(100,0 , 40, 40);
//        [_playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _playBtn;
//}

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
        [_playDetailBtn setTitle:DefLocalizedString(@"play") forState:UIControlStateNormal];
        _playDetailBtn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
        _playDetailBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
        [_playDetailBtn setTitleColor:COLOR_NAVBAR forState:UIControlStateNormal];
        [_playDetailBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
//        [_playBackBtn setTitle:DefLocalizedString(@"stop") forState:UIControlStateSelected];
        //    self.playBtn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-80)/2, [UIScreen mainScreen].bounds.size.height - 100, 80, 40);
        //    self.playBtn.frame = CGRectMake(100,0 , 40, 40);
        [_playDetailBtn addTarget:self action:@selector(playDetailBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playDetailBtn;
}

- (void)dealloc
{
//    [self releasePlayer];
}

#pragma mark - player delegate

//
//- (void) EZUIPlayer:(EZUIPlayer *)player previewWidth:(CGFloat)pWidth previewHeight:(CGFloat)pHeight
//{
//        CGFloat destWidth = CGRectGetWidth(self.bgView.bounds);
//
//        [player setPreviewFrame:CGRectMake(0, 0, SCREEN_WIDTH-leftOrRightMargin *4, DefVideoCellHeight-40-leftOrRightMargin*2)];
//    self.isChangeHeight = YES;
//}
#pragma mark --- playEZUKit

//- (void) playBtnClick:(UIButton *) btn
//{
//
//    if(btn.selected)
//    {
//        [self stop];
//        self.isChangeHeight = NO;
//        self.isPLaying = NO;
//    }
//    else
//    {
////        [self play];
//        self.isPLaying =YES;
//    }
//    btn.selected = !btn.selected;
//}

//- (void) play
//{
//    if (self.mPlayer)
//    {
//        [self.mPlayer startPlay];
//
//        //        if (self.mPlayerOther)
//        //        {
//        //            [self.mPlayerOther startPlay];
//        //        }
//
//        return;
//    }
//    if (!self.urlStr.length) {
//        [MBProgressHUD showError:@"视频相关信息不全，需补全视频信息。"];
//        return;
//    }
//    self.mPlayer = [EZUIPlayer createPlayerWithUrl:self.urlStr];
//    self.mPlayer.mDelegate = self;
////        self.mPlayer.customIndicatorView = nil;//去除加载动画
//    self.mPlayer.previewView.frame = CGRectMake(0, 0,
//                                                SCREEN_WIDTH-leftOrRightMargin *4,
//                                                CGRectGetHeight(self.mPlayer.previewView.frame));
//
//    [self.bgVideoView addSubview:self.mPlayer.previewView];
//
//    //该处去除，调整到prepared回调中执行，如为预览模式也可直接调用startPlay
//    [self.mPlayer startPlay];
//
//}
//
//- (void) stop
//{
//    if (self.mPlayer)
//    {
//        [self.mPlayer stopPlay];
//    }
//
//}
//
//- (void) releasePlayer
//{
//    if (self.mPlayer)
//    {
//        [self.mPlayer.previewView removeFromSuperview];
//        [self.mPlayer releasePlayer];
//        self.mPlayer = nil;
//    }
//
//}

-(void)clickCategory:(UITapGestureRecognizer *)gestureRecognizer{
    [self.videoPlayBackdelegate clickPlayBtnInCell:self withPushData:nil];
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

@end
