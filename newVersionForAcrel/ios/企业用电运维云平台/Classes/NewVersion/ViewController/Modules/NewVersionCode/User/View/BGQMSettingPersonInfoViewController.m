//
//  BGQMSettingPersonInfoViewController.m
//  变电所运维
//
//  Created by Acrel on 2019/8/7.
//

#import "BGQMSettingPersonInfoViewController.h"

@interface BGQMSettingPersonInfoViewController ()<QMUITextFieldDelegate>
@property (nonatomic,strong)QMUITextField *textField;
@property (nonatomic,copy) NSString *textString;
@end

@implementation BGQMSettingPersonInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = [NSString stringWithFormat:@"修改%@",self.settingName];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(clickSave)];
    [self.view setBackgroundColor:COLOR_BACKGROUND];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,BGSafeAreaTopHeight, SCREEN_WIDTH, 70)];
    view.backgroundColor = [UIColor whiteColor];
    self.textField = [[QMUITextField alloc] initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH-10, 60)];
    self.textField.text = self.settingChangeStr;
    self.textField.delegate = self;
    self.textField.placeholder = @"在此输入...";
    self.textField.placeholderColor = COLOR_NAVBAR;
    self.textField.clearButtonMode = UITextFieldViewModeAlways;
    self.textField.maximumTextLength = 20;
    self.textField.returnKeyType = UIReturnKeyDone;
    [self.textField addTarget:self
                   action:@selector(textFieldDidChange:)
         forControlEvents:UIControlEventEditingChanged]; // 监听事件
    [view addSubview:self.textField];
    [self.view addSubview:view];
//    [self.view addSubview:self.textField];
}

-(void)clickSave{
    DefLog(@"textString:%@",self.textString);
    if (!self.textString.length) {
        [MBProgressHUD showError:@"无任何修改"];
        return;
    }
    NSDictionary *param = [NSDictionary new];
    UserManager *user = [UserManager manager];
    if (!user.bguserId) {
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (self.uploadType == 0) {
        param = @{@"fUsername":self.textString,@"fUserid":user.bguserId};
    }else if (self.uploadType == 1){
        param = @{@"fUserphone":self.textString,@"fUserid":user.bguserId};
    }else{
        param = @{@"fUseremail":self.textString,@"fUserid":user.bguserId};
    }
    __weak __typeof(self)weakSelf = self;
   
    [NetService bg_postWithTokenWithPath:@"/updateUserInfo" params:param success:^(id respObjc) {
        DefLog(@"%@",respObjc);
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [MBProgressHUD showSuccess:@"保存成功"];
        switch (weakSelf.uploadType) {
            case 0:
                user.bgnickName = weakSelf.textString;
                break;
            case 1:
                user.bgtelphone = weakSelf.textString;
                break;
            default:
                user.bgaddress = weakSelf.textString;
                break;
        }
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [MBProgressHUD showError:@"请求失败"];
        
    }];
}

// 监听
- (void)textFieldDidChange:(UITextField*)sender{
    // 文本内容
    self.textString = sender.text;
    
}

//按下Done按钮的调用方法，我们让键盘消失
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.textField resignFirstResponder];
    // 文本内容
    self.textString = textField.text;
    [self clickSave];
    return YES;
    
}

//-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    self.textString = textField.text;
//    return YES;
//}


@end
