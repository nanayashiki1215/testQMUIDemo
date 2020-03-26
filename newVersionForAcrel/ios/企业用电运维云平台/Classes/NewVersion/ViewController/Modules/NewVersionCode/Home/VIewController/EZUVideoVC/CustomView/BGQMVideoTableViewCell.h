//
//  BGQMVideoTableViewCell.h
//  变电所运维
//
//  Created by Acrel on 2019/6/6.
//  
//

#import <QMUIKit/QMUIKit.h>
#import "EZUIKitViewController.h"
#import "Toast+UIView.h"
#import "EZUIPlayer.h"

@class BGQMVideoTableViewCell;

@protocol BGQMVideoTableViewCellDelegate

//点击回放
- (void)clickPlayBackBtnInCell:(BGQMVideoTableViewCell *)cell withPushData:(NSDictionary *)param;

//点击播放
- (void)clickPlayBtnInCell:(BGQMVideoTableViewCell *)cell withPushData:(CGFloat)param;

//点击播放详情
- (void)clickPlayDetailBtnInCell:(BGQMVideoTableViewCell *)cell withPushData:(NSDictionary *)param;

@end

@interface BGQMVideoTableViewCell : QMUITableViewCell<EZUIPlayerDelegate>

@property (nonatomic,strong)UIView *bgView;
@property (nonatomic,strong)UIView *secView;
@property (nonatomic,strong)UIView *bgVideoView;
@property (nonatomic,strong)UILabel *nameLab;
@property (nonatomic,strong)UIImageView *iconCameraImage;
@property (nonatomic,strong)UIImageView *iconMoreImage;
@property (nonatomic,strong) UIButton *playBtn;
@property (nonatomic,strong) UIButton *playBackBtn;
@property (nonatomic,strong) UIButton *playDetailBtn;
@property (nonatomic,strong) EZUIPlayer *mPlayer;

@property (nonatomic,weak) id<BGQMVideoTableViewCellDelegate> videoPlayBackdelegate;
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
