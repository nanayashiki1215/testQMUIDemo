//
//  BGTopNoticeView.m
//  BusinessGo
//
//  Created by leo on 2019/1/18.
//  Copyright © 2019 com.Ideal. All rights reserved.
//

#import "BGTopNoticeView.h"

@interface BGTopNoticeView ()


@property (nonatomic, strong) UIButton * okBtn;
@property (nonatomic, strong) UIButton * bacBtn;

@property (nonatomic, strong) UIView * bgView;

@property (nonatomic, strong) UIView * line;

@end
@implementation BGTopNoticeView

static BGTopNoticeView * window;

+ (instancetype)share{
    static BGTopNoticeView *window;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        window  =  [[BGTopNoticeView alloc] init];
    });
    return window;
}

- (instancetype)init{
    self=[super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.frame = [UIScreen mainScreen].bounds;
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelAlert + 10000;
    }
    return self;
}

- (void)dealloc{
    [self resignKeyWindow];
    [self removeFromSuperview];
}

#pragma mark - UI
-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
-(UIView *)bgView{
    if (!_bgView) {
        _bgView= [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.cornerRadius = 8;
        [self addSubview:_bgView];
        [self addShadowToView:_bgView withColor:[UIColor blackColor]];
        
    }
    return _bgView;
}
- (UILabel *)titleTextLabel{
    if (!_titleTextLabel) {
        _titleTextLabel = [[UILabel alloc] init];
        _titleTextLabel.font = [UIFont systemFontOfSize:14];
        _titleTextLabel.textAlignment = NSTextAlignmentLeft;
        [self.bgView addSubview:_titleTextLabel];
    }
    return _titleTextLabel;
}

-(UIView *)line{
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = DefColorFromRGB(207, 207, 207, 1);
        [self.bgView addSubview:_line];
    }
    return _line;
}

- (UILabel *)creatorTextLabel{
    if (!_creatorTextLabel) {
        _creatorTextLabel = [[UILabel alloc] init];
        _creatorTextLabel.font = [UIFont systemFontOfSize:14];
        _creatorTextLabel.textAlignment = NSTextAlignmentLeft;
        _creatorTextLabel.textColor = DefColorFromRGB(169, 169, 169, 1);
        [self.bgView addSubview:_creatorTextLabel];
    }
    return _creatorTextLabel;
}
- (UILabel *)messageTextLabel{
    if (!_messageTextLabel) {
        _messageTextLabel = [[UILabel alloc] init];
        _messageTextLabel.font = [UIFont systemFontOfSize:14];
        _messageTextLabel.textAlignment = NSTextAlignmentLeft;
        _messageTextLabel.numberOfLines = 0;
        [self.bgView addSubview:_messageTextLabel];
    }
    return _messageTextLabel;
}



-(UIButton *)okBtn{
    if (!_okBtn) {
        _okBtn = [[UIButton alloc] init];
        [_okBtn setTitle:@"知道了" forState:UIControlStateNormal];
        [_okBtn addTarget:self action:@selector(okClick:) forControlEvents:UIControlEventTouchUpInside];
        //        [_okBtn setTitleColor:DefColorFromRGB(0, 133, 207, 1) forState:UIControlStateNormal];
//        [_okBtn setBackgroundColor:DefColorFromRGB(89, 170, 255, 1)];
         [_okBtn setBackgroundColor:COLOR_NAVBAR];
        _okBtn.layer.cornerRadius = 5;
        //        _okBtn.layer.borderWidth = 0.5f;
        _okBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        
        [self.bgView addSubview:_okBtn];
    }
    return _okBtn;
}

-(UIButton *)bacBtn{
    if (!_bacBtn) {
        _bacBtn = [[UIButton alloc] init];
        [_bacBtn setTitle:@"忽略" forState:UIControlStateNormal];
        [_bacBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
        _bacBtn.layer.cornerRadius = 5;
        _bacBtn.layer.borderWidth = 0.5f;
        _bacBtn.layer.borderColor = DefColorFromRGB(122, 122, 122, 1).CGColor;
        _bacBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_bacBtn setTitleColor:DefColorFromRGB(78, 78, 78, 1) forState:UIControlStateNormal];
        [self.bgView addSubview:_bacBtn];
    }
    return _bacBtn;
}

-(void)createView{
    self.titleTextLabel.text = self.titleText;
    self.creatorTextLabel.text = self.creatorText;
    self.messageTextLabel.text = self.messageText;
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(40);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        //        make.height.mas_equalTo(200);
    }];
    
    [self.titleTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(8);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(24);
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleTextLabel.mas_bottom).with.offset(8);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.creatorTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.line.mas_bottom).with.offset(15);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-10);
//        make.height.mas_equalTo(30);
        make.height.mas_equalTo(0);
    }];
    
    [self.messageTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.creatorTextLabel.mas_bottom).with.offset(15);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-10);
        //        make.height.mas_equalTo(60);
    }];
    
    
    [self.bacBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.messageTextLabel.mas_bottom).with.offset(20);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(self.bgView.mas_centerXWithinMargins).with.offset(-22);
        make.height.mas_equalTo(32);
        make.bottom.mas_equalTo(-29);
    }];
    [self.okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.messageTextLabel.mas_bottom).with.offset(20);
        make.left.mas_equalTo(self.bgView.mas_centerXWithinMargins).with.offset(22);
        make.right.mas_equalTo(-22);
        make.height.mas_equalTo(32);
        make.bottom.mas_equalTo(-29);
    }];
}
- (void)backClick
{
    [self dismiss];
}
#pragma mark - 公共方法
- (void)show {
    [self disposeData];
    [self createView];
    
    self.hidden = NO;
    [self makeKeyAndVisible];
    
}

- (void)dismiss {
    
    [self.dataArray removeObject:self.data];
    
    if (self.dataArray.count>0) {
        self.data = self.dataArray.lastObject;
        [self show];
    }else{
        [self resignKeyWindow];
        self.hidden = YES;
    }
    
}


- (void)okClick:(UIButton *)btn{
    
    
    if (_confirm) {
        _confirm(btn,_data);
    }
    for (UIView * view in self.subviews) {
        [view resignFirstResponder];
    }
    [self dismiss];
    
}
-(void)didConfirm:(void (^)(UIButton * button ,NSDictionary *data))didConfirm{
    _confirm = didConfirm;
    
}


/// 添加四边阴影效果
- (void)addShadowToView:(UIView *)theView withColor:(UIColor *)theColor {
    // 阴影颜色
    theView.layer.shadowColor = theColor.CGColor;
    // 阴影偏移，默认(0, -3)
    theView.layer.shadowOffset = CGSizeMake(0,0);
    // 阴影透明度，默认0
    theView.layer.shadowOpacity = 0.5;
    // 阴影半径，默认3
    theView.layer.shadowRadius = 5;
}

//数据处理
-(void)disposeData{
    NSDictionary *dict = self.data;
//    NSDictionary *alarmEventLog = dict[@"alarmEventLogById"];
//    NSDictionary *taskInfo = dict[@"taskInfo"];
//    if (alarmEventLog) {
//        self.titleText = [NSString changgeNonulWithString:alarmEventLog[@"fMessInfoTypeExplain"]];
//        [self.okBtn setTitle:@"查看详情" forState:UIControlStateNormal];
//        self.creatorText = [NSString changgeNonulWithString:alarmEventLog[@"fSubname"]];
//        self.messageText = [NSString changgeNonulWithString:alarmEventLog[@"fAlarmdesc"]];
//    }else if (taskInfo) {
//        self.titleText = [NSString changgeNonulWithString:taskInfo[@"fTasktypeexplain"]];
//        [self.okBtn setTitle:@"查看详情" forState:UIControlStateNormal];
//        self.creatorText = [NSString changgeNonulWithString:taskInfo[@"fSubName"]];
//        self.messageText = [NSString changgeNonulWithString:taskInfo[@"fTaskcontent"]];
//    }
//    NSString *taskStr;
    
//     NSString *pushType = [dict bg_StringForKeyNotNull:@"pushType"];
//    if ([pushType isEqualToString:@"alarm"] || [pushType isEqualToString:]) {
//
//    }
    self.titleText = [NSString changgeNonulWithString:dict[@"title"]];
    [self.okBtn setTitle:@"查看详情" forState:UIControlStateNormal];
//    self.creatorText = [NSString changgeNonulWithString:dict[@"title"]];
    self.messageText = [NSString changgeNonulWithString:dict[@"content"]];
    
    //任务展示
    
  
//    if ([[self.data objectForKey:kactionType] isEqualToString:kactionType20]) {
//        self.titleText = @"提醒";
//        [self.okBtn setTitle:@"知道了" forState:UIControlStateNormal];
//        self.creatorText = [NSString stringWithFormat:@"来自%@",[[self.data objectForKeyNotNull:kmsgDetail] objectForKeyNotNull:kcreatorName]];
//        self.messageText = [[self.data objectForKeyNotNull:kmsgDetail] objectForKeyNotNull:kcontent];
//    }else if ([[self.data objectForKey:kactionType] isEqualToString:kactionType21]) {
//        [self.okBtn setTitle:@"去完成" forState:UIControlStateNormal];
//
//        self.titleText = @"待办";
//        self.creatorText = [NSString stringWithFormat:@"来自%@",[[self.data objectForKeyNotNull:kmsgDetail] objectForKeyNotNull:kcreatorName]];
//        self.messageText = [[self.data objectForKeyNotNull:kmsgDetail] objectForKeyNotNull:kcontent];
//    }else if ([[self.data objectForKey:kactionType] isEqualToString:@"101"]){
//        [self.okBtn setTitle:@"去完成" forState:UIControlStateNormal];
//
//        self.titleText = @"待办";
//
//
//        NSString *creator = [NSString stringWithFormat:@"%@",[[[self.data objectForKeyNotNull:kmsgDetail] objectForKeyNotNull:kcontent] objectForKeyNotNull:kcreator]];
//
//        self.creatorText = [NSString stringWithFormat:@"来自%@",emp.nickName];
//        self.messageText =[ [[self.data objectForKeyNotNull:kmsgDetail] objectForKeyNotNull:kcontent] objectForKeyNotNull:kcontent];
//    }
    
}
@end
