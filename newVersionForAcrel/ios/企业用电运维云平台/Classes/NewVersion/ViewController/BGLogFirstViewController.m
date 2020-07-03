//
//  BGLogFirstViewController.m
//  企业用电运维云平台
//
//  Created by Acrel on 2020/7/2.
//

#import "BGLogFirstViewController.h"

@interface BGLogFirstViewController ()
@property(nonatomic,strong)QMUITextField * IPTextField;
//@property(nonatomic,strong)QMUIButton *sureBtn;
@property(nonatomic,strong)QMUILabel *IPLabel;//ipAdress
@property(nonatomic,strong)UIView *bgView;
@property(nonatomic,strong)UIImageView *imageV;
@end

@implementation BGLogFirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createView];
    
}

-(void)createView{
    
    UIView *lineView = [[UIView alloc] init];
    
    [self.bgView addSubview:self.imageV];
//    [self.bgView addSubview:lineView];
    [self.bgView addSubview:self.IPTextField];
    [self.view addSubview:self.bgView];
    
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@0);
        make.right.mas_equalTo(@0);
        make.top.mas_equalTo(@100);
        make.height.mas_offset(52);
//        make.bottom.equalTo(self.view).with.offset(0);
    }];
    
    [_imageV mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(@15);
        make.left.equalTo(self.bgView.mas_left).offset(5);
        make.top.mas_equalTo(@10);
        make.width.mas_offset(30);
        make.height.mas_offset(30);
    }];
    
    [self.IPTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imageV.mas_left).offset(15);
        make.right.equalTo(self.bgView.mas_right).offset(5);
        make.height.mas_offset(50);
    }];
    
//    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(image.mas_left).offset(0);
//        make.top.equalTo(self.IPTextField.mas_bottom).offset(1);
//        make.right.equalTo(self.IPTextField.mas_right).offset(0);
//        make.height.mas_offset(1);
//    }];
    
}



#pragma mark - Lazy
-(QMUITextField *)IPTextField{
    if (_IPTextField) {
        _IPTextField = [[QMUITextField alloc] init];
        _IPTextField.placeholder = DefLocalizedString(@"serverAddressText");
        
    }
    return _IPTextField;
}

-(QMUILabel *)IPLabel{
    if (_IPLabel) {
        _IPLabel = [[QMUILabel alloc] init];
        _IPLabel.text = DefLocalizedString(@"");
    }
    return _IPLabel;
}

-(UIView *)bgView{
    if (_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor redColor];
    }
    return _bgView;
}

-(UIImageView *)imageV{
    if (_imageV) {
        _imageV =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipAdress"]];
        
    }
    return _imageV;
}
@end
