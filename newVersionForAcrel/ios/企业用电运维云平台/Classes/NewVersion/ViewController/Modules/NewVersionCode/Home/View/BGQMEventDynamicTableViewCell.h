//
//  BGQMEventDynamicTableViewCell.h
//  变电所运维
//
//  Created by Acrel on 2019/6/17.
//  
//

#import <QMUIKit/QMUIKit.h>

@interface BGQMEventDynamicTableViewCell : QMUITableViewCell

@property(nonatomic, strong) UIImageView *avatarImageView;
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UILabel *contentLabel;
@property(nonatomic, strong) UILabel *timeLabel;
@property(nonatomic, strong) UIView *bgview;

- (void)renderWithNameText:(NSString *)nameText contentText:(NSString *)contentText;


@end
