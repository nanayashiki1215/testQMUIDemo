//
//  BGQMHomeTableViewCell.m
//  变电所运维
//
//  Created by Acrel on 2019/6/12.
//  
//

#import "BGQMHomeTableViewCell.h"

#define isThreeORTwo 1

@implementation BGQMHomeTableViewCell

- (void)didInitializeWithStyle:(UITableViewCellStyle)style {
    [super didInitializeWithStyle:style];
    // init 时做的事情请写在这里
    //取消选中效果
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self setBackgroundColor:[UIColor clearColor]];
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withData:(NSArray *)dataArr
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubview:self.bgView];
        [self.bgView addSubview:self.secView];
        [self.secView addSubview:self.iconImage];
        [self.secView addSubview:self.titleLabel];
        self.cellGridView = [[QMUIGridView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/4, 0, SCREEN_WIDTH-SCREEN_WIDTH/4, 0)];
        self.cellGridView = [[QMUIGridView alloc] init];
        self.cellGridView.columnCount = 3;
        self.cellGridView.separatorWidth = 0;
        self.cellGridView.separatorColor = [UIColor clearColor];
        self.cellGridView.separatorDashed = NO;
        if (dataArr.count<=6) {
            self.cellGridView.rowHeight = (FixedDeathHeight-10)/2;
        }else{
            NSInteger fixeddeathH = dataArr.count;
            NSInteger count =  ceil(fixeddeathH/3.0);
            self.cellGridView.rowHeight = (FixedDeathHeight + (FixedDeathHeight/2*(count-2)-10))/count;
        }
        self.dataArr = dataArr;
        //    self.cellGridView.rowHeight = self.secView.frame.size.height/3;
        if (dataArr.count<=6) {
            for (NSInteger i = 0; i < 6; i++) {
                
                UIButton *insideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                insideBtn.backgroundColor = [UIColor clearColor];
                if (dataArr.count>i) {
                    NSString *titleStr = [dataArr[i] bg_StringForKeyNotNull:@"fMenuname"];
                    if (titleStr.length) {
                        [insideBtn setTitle:titleStr forState:UIControlStateNormal];
                    }
                }
                insideBtn.titleLabel.font = [UIFont systemFontOfSize:FixedDeathFontSmalleSize];
//                [insideBtn setFont:[UIFont systemFontOfSize:FixedDeathFontSmalleSize]];
                [insideBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [insideBtn addTarget:self action:@selector(clickTableCellBtn:) forControlEvents:UIControlEventTouchUpInside];
                insideBtn.tag = i+100;
                [self.cellGridView addSubview:insideBtn];
                
            }
        }else if (dataArr.count > 0) {
            for (NSInteger i = 0; i < dataArr.count; i++) {
                
                UIButton *insideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                insideBtn.backgroundColor = [UIColor clearColor];
                if (dataArr.count>i) {
                    NSString *titleStr = [dataArr[i] bg_StringForKeyNotNull:@"fMenuname"];
                    if (titleStr.length) {
                        [insideBtn setTitle:titleStr forState:UIControlStateNormal];
                    }
                }
                insideBtn.titleLabel.font = [UIFont systemFontOfSize:FixedDeathFontSmalleSize];
//                [insideBtn setFont:[UIFont systemFontOfSize:FixedDeathFontSmalleSize]];
                [insideBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [insideBtn addTarget:self action:@selector(clickTableCellBtn:) forControlEvents:UIControlEventTouchUpInside];
                insideBtn.tag = i+100;
                
                //        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(90, 10, 1, 45/2)];
                //        lineView.backgroundColor = [UIColor lightGrayColor];
                
                //        [insideBtn addSubview:lineView];
                //        [view addSubview:lineView];
                [self.cellGridView addSubview:insideBtn];
                //        [self.cellGridView addSubview:lineView];
                
            }
        }
        
        [self.secView addSubview:self.cellGridView];
    }
    return self;
}

-(void)clickTableCellBtn:(UIButton *)button{
    
    NSInteger tag = button.tag - 100;
    DefLog(@"点击的按钮是:%@ 与tag:%d",button,tag);
    [self.homeTableCelldelegate clickTableCellButtonModel:tag andClickInCell:self];
}

- (void)updateCellAppearanceWithIndexPath:(NSIndexPath *)indexPath {
    [super updateCellAppearanceWithIndexPath:indexPath];
    // 每次 cellForRow 时都要做的事情请写在这里
    // 将要布局的 item 以 addSubview: 的方式添加进去即可自动布局
    
}

- (void)setCellWithDataArr:(NSArray *)dataArr{
    
//    NSArray<UIColor *> *themeColors = @[UIColorTheme1, UIColorTheme2, UIColorTheme3, UIColorTheme4, UIColorTheme5, UIColorTheme6];
//    if (dataArr.count<=6) {
//        self.cellGridView.rowHeight = (100-10)/2;
//    }else if(dataArr.count > 6 && dataArr.count<=9){
//        self.cellGridView.rowHeight = (100-10)/3;
//    }else{
//        self.cellGridView.rowHeight = (100-10)/4;
//    }
//    //    self.cellGridView.rowHeight = self.secView.frame.size.height/3;
//    for (NSInteger i = 0; i < dataArr.count; i++) {
//
//        UIButton *insideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        //        if (isThreeORTwo) {
//        //
//        //        }else{
//        //        }
//        //        insideBtn.frame = CGRectMake(0,0, 45/2,45/2);
//        insideBtn.backgroundColor = [UIColor clearColor];
//        NSString *titleStr = [NSString changgeNonulWithString:dataArr[i][@"name"]];
//        if (titleStr.length) {
//            [insideBtn setTitle:titleStr forState:UIControlStateNormal];
//        }
//        [insideBtn setFont:[UIFont systemFontOfSize:14.f]];
//        [insideBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [insideBtn addTarget:self action:@selector(clickTableCellBtn:) forControlEvents:UIControlEventTouchUpInside];
//        insideBtn.tag = i+100;
//
//        //        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(90, 10, 1, 45/2)];
//        //        lineView.backgroundColor = [UIColor lightGrayColor];
//
//        //        [insideBtn addSubview:lineView];
//        //        [view addSubview:lineView];
//        [self.cellGridView addSubview:insideBtn];
//        //        [self.cellGridView addSubview:lineView];
//
//    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(0));
        make.right.equalTo(@(0));
        make.bottom.equalTo(@(0));
        make.top.equalTo(@(0));
    }];
    
    [_secView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView.mas_left).offset(0);
        make.top.equalTo(self.bgView.mas_top).offset(0);
        make.right.equalTo(self.bgView.mas_right).offset(0);
        make.bottom.equalTo(self.bgView.mas_bottom).offset(-10);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (!IS_IPAD) {
            make.centerY.equalTo(self.secView).offset((100-(40+20))/2);
            make.height.mas_offset(20);
        }else{
            make.centerY.equalTo(self.secView).offset((200-(60+20))/2);
            make.height.mas_offset(40);
        }
        make.left.equalTo(self.secView.mas_left).offset(0);
        make.width.mas_offset(SCREEN_WIDTH/4);
        
    }];
    
    [_iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
        if (!IS_IPAD) {
            make.centerX.equalTo(_titleLabel);
            make.bottom.equalTo(self.titleLabel.mas_top).offset(-1);
            make.width.mas_offset(40);
            make.height.mas_offset(40);
//            make.width.mas_offset(SCREEN_WIDTH/4-55);
//            make.height.mas_offset(SCREEN_WIDTH/4-55);
        }else{
            make.bottom.equalTo(self.titleLabel.mas_top).offset(-1);
            make.centerX.equalTo(_titleLabel);
            make.width.mas_offset(60);
            make.height.mas_offset(60);
        }
    }];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.iconImage.mas_bottom).offset(5);
        
    }];
    
    [_cellGridView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.secView.mas_left).offset(SCREEN_WIDTH/4);
        make.top.equalTo(self.secView.mas_top).offset(0);
        make.right.equalTo(self.secView.mas_right).offset(0);
        make.bottom.equalTo(self.secView.mas_bottom).offset(0);
    }];
    
   
}

#pragma mark setter and getter

-(UIView *)bgView{
    if (!_bgView) {
        _bgView  = [[UIView alloc] init];
        _bgView.backgroundColor = COLOR_BACKGROUND;
    }
    return _bgView;
}

-(UIView *)secView{
    if (!_secView) {
        _secView  = [[UIView alloc] init];
        _secView.backgroundColor = [UIColor whiteColor];
    }
    return _secView;
}

-(UIImageView *)iconImage{
    if (!_iconImage) {
        _iconImage  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Electric"]];
        _iconImage.contentMode = UIViewContentModeScaleAspectFit;
//        CGFloat rgb = 244 / 255.0;
//        _iconImage.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
    }
    return _iconImage;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
//        _titleLabel.textColor = [UIColor grayColor];
        _titleLabel.font = [UIFont systemFontOfSize:FixedDeathFontSmalleSize];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

//-(QMUIGridView *)cellGridView{
//    if (!_cellGridView) {
//        _cellGridView = [[QMUIGridView alloc] init];
//        _cellGridView.separatorWidth = 0;
//        _cellGridView.separatorColor = [UIColor clearColor];
//        _cellGridView.separatorDashed = NO;
//    }
//    return _cellGridView;
//}
@end
