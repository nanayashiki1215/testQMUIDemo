//
//  BGQMHomeTableViewCell.h
//  变电所运维
//
//  Created by Acrel on 2019/6/12.
//  
//

#import <QMUIKit/QMUIKit.h>

@class BGQMHomeTableViewCell;

@protocol BGQMHomeTableViewCellDelegate

- (void)clickTableCellButtonModel:(NSInteger)btntag andClickInCell:(BGQMHomeTableViewCell *)cell;

@end

@interface BGQMHomeTableViewCell : QMUITableViewCell
@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UIView *secView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIImageView *iconImage;
@property (nonatomic,strong) UIView *VerticalLLine;
@property (nonatomic,strong) QMUIGridView *cellGridView;
@property (nonatomic,weak) id<BGQMHomeTableViewCellDelegate> homeTableCelldelegate;
@property (nonatomic,strong) NSArray *dataArr;

- (void)setCellWithDataArr:(NSArray *)dataArr;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withData:(NSArray *)dataArr;

@end
