//
//  BGQMEventDynamicTableViewCell.m
//  变电所运维
//
//  Created by Acrel on 2019/6/17.
//  
//

#import "BGQMEventDynamicTableViewCell.h"

const UIEdgeInsets kInsets = {15, 16, 15, 16};
const CGFloat kAvatarSize = 30;
const CGFloat kAvatarMarginRight = 12;
const CGFloat kAvatarMarginBottom = 6;
const CGFloat kContentMarginBotom = 10;

@implementation BGQMEventDynamicTableViewCell

- (void)didInitializeWithStyle:(UITableViewCellStyle)style {
    [super didInitializeWithStyle:style];
    self.contentView.backgroundColor = COLOR_BACKGROUND;
    //取消选中效果
    self.selectionStyle = UITableViewCellSelectionStyleNone;
//    self.bgview = [[UIView alloc] initWithFrame:CGRectMake(10, 10, self.contentView.frame.size.width-10, self.contentView.frame.size.height-10)];
    self.bgview = [[UIView alloc] init];
    
    self.bgview.backgroundColor = [UIColor whiteColor];
    self.bgview.layer.masksToBounds = YES;
    self.bgview.layer.cornerRadius = 10.f;

//    _bgview.maskVi
    [self.contentView addSubview:self.bgview];
    // init 时做的事情请写在这里
    UIImage *avatarImage = [UIImage qmui_imageWithStrokeColor:[QDCommonUI randomThemeColor] size:CGSizeMake(kAvatarSize, kAvatarSize) lineWidth:3 cornerRadius:6];
    _avatarImageView = [[UIImageView alloc] initWithImage:avatarImage];
    [self.bgview addSubview:self.avatarImageView];
    
    _nameLabel = [[UILabel alloc] qmui_initWithFont:UIFontBoldMake(16) textColor:UIColorGray2];
    [self.bgview addSubview:self.nameLabel];
    
    _contentLabel = [[UILabel alloc] qmui_initWithFont:UIFontMake(17) textColor:UIColorGray1];
    self.contentLabel.numberOfLines = 0;
    [self.bgview addSubview:self.contentLabel];
    
//    _timeLabel = [[UILabel alloc] qmui_initWithFont:UIFontMake(13) textColor:UIColorGray];
//    [self.bgview addSubview:self.timeLabel];
}

- (void)renderWithNameText:(NSString *)nameText contentText:(NSString *)contentText {
    
    self.nameLabel.text = nameText;
//    self.contentLabel.attributedText = [self attributeStringWithString:contentText lineHeight:26];
    self.contentLabel.text = contentText;
//    self.timeLabel.text = @"昨天 18:24";
    
    self.contentLabel.textAlignment = NSTextAlignmentJustified;
}

- (NSAttributedString *)attributeStringWithString:(NSString *)textString lineHeight:(CGFloat)lineHeight {
    if (textString.qmui_trim.length <= 0) return nil;
    NSAttributedString *attriString = [[NSAttributedString alloc] initWithString:textString attributes:@{NSParagraphStyleAttributeName:[NSMutableParagraphStyle qmui_paragraphStyleWithLineHeight:lineHeight lineBreakMode:NSLineBreakByCharWrapping textAlignment:NSTextAlignmentLeft]}];
    return attriString;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize resultSize = CGSizeMake(size.width, 0);
    CGFloat contentLabelWidth = size.width - UIEdgeInsetsGetHorizontalValue(kInsets);
    
//    CGFloat resultHeight = UIEdgeInsetsGetHorizontalValue(kInsets) + CGRectGetHeight(self.avatarImageView.bounds) + kAvatarMarginBottom + 20;
    
    CGFloat resultHeight = UIEdgeInsetsGetHorizontalValue(kInsets) + kAvatarMarginBottom + 10;
    
    if (self.contentLabel.text.length > 0) {
        CGSize contentSize = [self.contentLabel sizeThatFits:CGSizeMake(contentLabelWidth, CGFLOAT_MAX)];
        resultHeight += (contentSize.height + kContentMarginBotom);
    }
    
//    if (self.timeLabel.text.length > 0) {
//        CGSize timeSize = [self.timeLabel sizeThatFits:CGSizeMake(contentLabelWidth, CGFLOAT_MAX)];
//        resultHeight += timeSize.height;
//    }
    
    resultSize.height = resultHeight;
    NSLog(@"%@ 的 cell 的 sizeThatFits: 被调用（说明这个 cell 的高度重新计算了一遍）", self.nameLabel.text);
    return resultSize;
}

- (void)updateCellAppearanceWithIndexPath:(NSIndexPath *)indexPath {
    [super updateCellAppearanceWithIndexPath:indexPath];
    // 每次 cellForRow 时都要做的事情请写在这里
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_bgview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(10);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
        make.top.equalTo(self.contentView.mas_top).offset(10);
    }];
    [_avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgview.mas_left).offset(1);
        make.top.equalTo(self.bgview.mas_top).offset(1);
        
    }];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgview.mas_left).offset(5);
        make.top.equalTo(self.bgview.mas_top).offset(5);
       if (self.nameLabel.text.length > 0) {
            make.width.mas_equalTo(250);
            CGSize nameSize = [self.nameLabel sizeThatFits:CGSizeMake(50, CGFLOAT_MAX)];
            make.height.mas_equalTo(nameSize.height);
        }
    }];
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgview.mas_left).offset(5);
        make.top.equalTo(self.nameLabel.mas_top).offset(5);
        make.right.equalTo(self.bgview.mas_right).offset(-5);
        make.bottom.equalTo(self.bgview.mas_bottom).offset(-5);
        if (self.contentLabel.text.length > 0) {
            CGSize contentSize = [self.contentLabel sizeThatFits:CGSizeMake(self.bgview.frame.size.width -10, CGFLOAT_MAX)];
            make.height.mas_equalTo(contentSize.height);
        }
    }];
    
    
//    CGFloat contentLabelWidth = CGRectGetWidth(self.bgview.bounds) - UIEdgeInsetsGetHorizontalValue(kInsets);
//    self.avatarImageView.frame = CGRectSetXY(self.avatarImageView.frame, kInsets.left, kInsets.top);
//    if (self.nameLabel.text.length > 0) {
//        CGFloat nameLabelWidth = contentLabelWidth - CGRectGetWidth(self.avatarImageView.bounds) - kAvatarMarginRight;
//        CGSize nameSize = [self.nameLabel sizeThatFits:CGSizeMake(nameLabelWidth, CGFLOAT_MAX)];
//        self.nameLabel.frame = CGRectFlatMake(CGRectGetMaxX(self.avatarImageView.frame) + kAvatarMarginRight, CGRectGetMinY(self.avatarImageView.frame) + (CGRectGetHeight(self.avatarImageView.bounds) - nameSize.height) / 2, nameLabelWidth, nameSize.height);
//    }
//    if (self.contentLabel.text.length > 0) {
//        CGSize contentSize = [self.contentLabel sizeThatFits:CGSizeMake(contentLabelWidth, CGFLOAT_MAX)];
//        self.contentLabel.frame = CGRectFlatMake(kInsets.left, CGRectGetMaxY(self.avatarImageView.frame) + kAvatarMarginBottom, contentLabelWidth, contentSize.height);
//    }
//    if (self.timeLabel.text.length > 0) {
//        CGSize timeSize = [self.timeLabel sizeThatFits:CGSizeMake(contentLabelWidth, CGFLOAT_MAX)];
//        self.timeLabel.frame = CGRectFlatMake(CGRectGetMinX(self.contentLabel.frame), CGRectGetMaxY(self.contentLabel.frame) + kContentMarginBotom, contentLabelWidth, timeSize.height);
//    }
}

@end
