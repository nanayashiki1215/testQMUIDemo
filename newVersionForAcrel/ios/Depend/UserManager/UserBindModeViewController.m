//
//  HintViewController.m
//  LCOpenSDKDemo
//
//  Created by chenjian on 16/7/11.
//  Copyright (c) 2016年 lechange. All rights reserved.
//

//#import "LCOpenSDK_Prefix.h"
#import "UserBindModeViewController.h"
#import "openApiService.h"
#import "RestApiService.h"
#import <Foundation/Foundation.h>

typedef enum {
    DARK_BIND_BTN = 0,
    BRIGHT_BIND_BTN = 1
} BindBtnColor;

@interface UserBindModeViewController ()
@end

@implementation UserBindModeViewController
@synthesize m_btnChangeColor, m_btnOldColor;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    UINavigationItem* item = [[UINavigationItem alloc] initWithTitle:@"用户绑定"];

    UIButton* left = [UIButton buttonWithType:UIButtonTypeCustom];
    //left.backgroundColor = [UIColor whiteColor];
    [left setFrame:CGRectMake(0, 0, 50, 30)];
    UIImage* img = [UIImage leChangeImageNamed:Back_Btn_Png];

    [left setBackgroundImage:img forState:UIControlStateNormal];
    [left addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* leftBtn = [[UIBarButtonItem alloc] initWithCustomView:left];
    [item setLeftBarButtonItem:leftBtn animated:NO];

    [super.m_navigationBar pushNavigationItem:item animated:NO];
    super.m_navigationBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];

    [self.view addSubview:super.m_navigationBar];

    m_progressInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    m_progressInd.transform = CGAffineTransformMakeScale(2.0, 2.0);
    m_progressInd.center = CGPointMake(self.view.center.x, self.view.center.y);
    [self.view addSubview:m_progressInd];

    self.m_textSms.delegate = self;

    self.m_btnOldColor = [UIColor colorWithRed:0 / 255 green:122.0 / 255 blue:255.0 / 255 alpha:1];
    self.m_btnChangeColor = [UIColor colorWithRed:195.0 / 255 green:195.0 / 255 blue:200.0 / 255 alpha:1];
    self.m_lblHint.lineBreakMode = NSLineBreakByWordWrapping;
    self.m_lblHint.numberOfLines = 0;

    [self setBindButtonColor:DARK_BIND_BTN];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setBindButtonColor:(BindBtnColor)color
{
    switch (color) {
    case DARK_BIND_BTN:
        [self.m_btnBind setBackgroundColor:[UIColor colorWithRed:138.0 / 255 green:185.0 / 255 blue:225.0 / 255 alpha:1]];
        [self.m_btnBind setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        break;
    case BRIGHT_BIND_BTN:
        [self.m_btnBind setBackgroundColor:[UIColor colorWithRed:78.0 / 255 green:167.0 / 255 blue:242.0 / 255 alpha:1]];
        break;
    default:
        break;
    }
}

- (void)setUserInfo:(NSString*)appId appsecret:(NSString*)appSecret svrIp:(NSString*)ip port:(NSInteger)port phone:(NSString*)phoneNum
{
    m_strAppId = [appId mutableCopy];
    m_strAppSecret = [appSecret mutableCopy];

    m_strSrv = [ip mutableCopy];
    m_iPort = port;
    m_strPhone = [phoneNum mutableCopy];
}

- (void)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onSmsTimer:(id)sender
{
    m_interval--;
    NSLog(@"onSmsTimer-----[%ld]", (long)m_interval);
    [self.m_btnSms setTitle:[NSString stringWithFormat:@"重新获取(%ld)", (long)m_interval] forState:UIControlStateNormal];
    [self.m_btnSms setTitleColor:self.m_btnChangeColor forState:UIControlStateNormal];

    if (0 >= m_interval) {
        [m_timer invalidate];
        m_interval = 60;
        [self.m_btnSms setTitle:[NSString stringWithFormat:@"重新获取"] forState:UIControlStateNormal];
        [self.m_btnSms setTitleColor:self.m_btnOldColor forState:UIControlStateNormal];
        self.m_btnSms.enabled = YES;
    }
}
- (void)onBindUser:(id)sender
{
    [self showLoading];
    dispatch_queue_t bind_user = dispatch_queue_create("bind_user", nil);
    dispatch_async(bind_user, ^{
        NSString* errMsg;
        NSInteger iret;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            if (iret < 0) {
                if (nil != errMsg) {
                    self.m_lblHint.text = [NSString stringWithFormat:@"绑定失败[%@]", errMsg];
                }
                else {
                    self.m_lblHint.text = @"绑定超时，请重试";
                    self.m_lblHint.lineBreakMode = NSLineBreakByWordWrapping;
                    self.m_lblHint.numberOfLines = 0;
                }
                return;
            }
            else {
                self.m_lblHint.text = @"绑定成功";
                [self.navigationController popViewControllerAnimated:NO];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        });
    });
}
- (void)onSendSms:(id)sender
{
    NSString* errCode;
    NSString* errMsg;

    NSInteger iret = [[[OpenApiService alloc] init] userBindSms:m_strSrv port:m_iPort appId:m_strAppId appSecret:m_strAppSecret phone:m_strPhone errcode:&errCode errmsg:&errMsg];
    if (iret < 0) {
        if (nil == errCode || 0 == errCode.length) {
            self.m_lblHint.text = @"发送验证码失败";
        }
        else {
            self.m_lblHint.text = [errMsg mutableCopy];
        }
        return;
    }

    self.m_lblHint.text = [NSString stringWithFormat:@"验证码短信已发送至手机%@", m_strPhone];

    m_timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onSmsTimer:) userInfo:self repeats:YES];
    m_interval = 60;
    self.m_btnSms.enabled = NO;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField
{
    if (self.m_textSms == textField) {
        self.m_textSms.text = @"";
        self.m_textSms.textColor = [UIColor blackColor];
    }
    [self setBindButtonColor:DARK_BIND_BTN];
    CGFloat offset = self.view.frame.size.height - (textField.frame.origin.y + textField.frame.size.height + 216 + 50);
    if (offset <= 0) {
        [UIView animateWithDuration:0.1 animations:^{
            CGRect frame = self.view.frame;
            frame.origin.y = offset;
            self.view.frame = frame;
        }];
    }
    return YES;
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    // 输入框中有字符，显示亮色；无字符，显示暗色。
    if (1 == self.m_textSms.text.length && 0 == string.length) {
        [self setBindButtonColor:DARK_BIND_BTN];
    }
    else if (self.m_textSms.text.length > 1 || string.length > 0) {
        [self setBindButtonColor:BRIGHT_BIND_BTN];
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField*)textField
{
    [UIView animateWithDuration:0.1 animations:^{
        CGRect rect = self.view.frame;
        rect.origin.y = 0;
        self.view.frame = rect;
    }];
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField*)textField
{

    [textField resignFirstResponder];
    return YES;
}

// 显示滚动轮指示器
- (void)showLoading
{
    [m_progressInd startAnimating];
}

// 消除滚动轮指示器
- (void)hideLoading
{
    if ([m_progressInd isAnimating]) {
        [m_progressInd stopAnimating];
    }
}
@end
