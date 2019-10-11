//
//  BGQMEventTableViewCell.m
//  变电所运维
//
//  Created by Acrel on 2019/6/14.
//

#import "BGQMEventTableViewCell.h"

@implementation BGQMEventTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self.contentView setBackgroundColor:COLOR_BACKGROUND];
    //取消选中效果
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
