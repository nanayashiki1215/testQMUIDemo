//
//  HintViewController.h
//  LCOpenSDKDemo
//
//  Created by chenjian on 16/7/11.
//  Copyright (c) 2016年 lechange. All rights reserved.
//
#ifndef LCOpenSDKDemo_UserBindModeViewController_h
#define LCOpenSDKDemo_UserBindModeViewController_h
#import "MyViewController.h"
#import <UIKit/UIKit.h>

@interface UserBindModeViewController : MyViewController <UITextFieldDelegate> {
    NSString* m_strAppId;
    NSString* m_strAppSecret;
    NSString* m_strSrv;
    NSInteger m_iPort;

    NSString* m_strPhone;
    NSInteger m_interval;

    NSTimer* m_timer;

    UIActivityIndicatorView* m_progressInd;
}

@property IBOutlet UITextField* m_textSms;
@property IBOutlet UILabel* m_lblHint;
@property IBOutlet UIButton* m_btnBind;
@property IBOutlet UIButton* m_btnSms;
@property UIColor* m_btnOldColor;
@property UIColor* m_btnChangeColor;

- (IBAction)onBindUser:(id)sender;
- (IBAction)onSendSms:(id)sender;
- (void)setUserInfo:(NSString*)appId appsecret:(NSString*)appSecret svrIp:(NSString*)ip port:(NSInteger)port phone:(NSString*)phoneNum;

- (void)onBack:(id)sender;
- (void)onSmsTimer:(id)sender;
- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField;
- (BOOL)textFieldShouldEndEditing:(UITextField*)textField;
- (BOOL)textFieldShouldReturn:(UITextField*)textField;
@end
#endif
