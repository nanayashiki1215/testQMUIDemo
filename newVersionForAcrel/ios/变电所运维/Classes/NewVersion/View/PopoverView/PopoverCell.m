//
//  PopoverCell.m
//  BusinessGo
//
//  Created by 智慧  李 on 2018/1/17.
//  Copyright © 2018年 com.Ideal. All rights reserved.
//

#import "PopoverCell.h"
#import "UIColor+BGExtension.h"

@interface PopoverCell()

@property(nonatomic,weak)UILabel *titleNameLab;

@property(nonatomic,weak)UIImageView *leftImageView;

@end

@implementation PopoverCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self setUPUI];
        
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
            self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
    }
    return self;
}

-(void)setUPUI{
    UILabel * titleNameLab = [[UILabel alloc] init];
    titleNameLab.font = [UIFont systemFontOfSize:14];
    titleNameLab.textColor = [UIColor bg_colorWithHexString:@"707070"];
    [self.contentView addSubview:titleNameLab];
    self.titleNameLab = titleNameLab;
    
    UIImageView *leftImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:leftImageView];
    self.leftImageView = leftImageView;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self.leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(20);
        make.left.offset(11);
        make.centerY.offset(0);
    }];
    [self.titleNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftImageView.mas_right).offset(11);
        make.centerY.equalTo(self.leftImageView);
    }];
}

-(void)setDic:(NSDictionary *)dic{
    _dic = dic;
    self.titleNameLab.text = dic[@"title"];
    self.leftImageView.image = [UIImage imageNamed:dic[@"image"]];
}

@end
