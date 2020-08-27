//
//  BGQMImouVideoCell.h
//  企业用电运维云平台
//
//  Created by Acrel on 2020/7/24.
//

#import <QMUIKit/QMUIKit.h>
#import "Toast+UIView.h"

NS_ASSUME_NONNULL_BEGIN
@class BGQMImouVideoCell;

@protocol BGQMImouVideoCellDelegate

//点击回放
- (void)clickPlayBackBtnInCell:(BGQMImouVideoCell *)cell withPushData:(NSDictionary *)param;

//点击播放
- (void)clickPlayBtnInCell:(BGQMImouVideoCell *)cell withPushData:(NSDictionary *)param;

//点击播放详情
- (void)clickPlayDetailBtnInCell:(BGQMImouVideoCell *)cell withPushData:(NSDictionary *)param;

@end

@interface BGQMImouVideoCell : QMUITableViewCell

@property (nonatomic,strong)UIView *bgView;
@property (nonatomic,strong)UIView *secView;
@property (nonatomic,strong)UIImageView *bgVideoView;
@property (nonatomic,strong)UILabel *nameLab;
@property (nonatomic,strong)UIImageView *iconCameraImage;
@property (nonatomic,strong)UIImageView *iconMoreImage;
//@property (nonatomic,strong) UIButton *playBtn;
@property (nonatomic,strong) UIButton *playBackBtn;
@property (nonatomic,strong) UIButton *playDetailBtn;
//@property (nonatomic,strong) EZUIPlayer *mPlayer;

@property (nonatomic,weak) id<BGQMImouVideoCellDelegate> videoPlayBackdelegate;
//@property (nonatomic,strong) NSString *playerString;//播放地址
@property (nonatomic,copy) NSString *appKey;
@property (nonatomic,copy) NSString *accessToken;
@property (nonatomic,copy) NSString *urlStr;
@property (nonatomic,copy) NSString *apiUrl;
@property (nonatomic,assign) CGFloat cellheight;
@property (nonatomic,assign) BOOL isChangeHeight;
@property (nonatomic,assign) BOOL isPLaying;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withPlayerData:(NSDictionary *)playData;
-(void)releasePlayer;
-(void)stop;
-(void)playBtnClick:(UIButton *) btn;

@end

NS_ASSUME_NONNULL_END
