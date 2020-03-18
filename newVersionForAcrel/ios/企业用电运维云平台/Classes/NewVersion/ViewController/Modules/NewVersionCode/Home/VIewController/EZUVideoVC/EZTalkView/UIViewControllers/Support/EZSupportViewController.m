//
//  EZSupportViewController.m
//  EZOpenSDKDemo
//
//  Created by linyong on 2018/7/5.
//  Copyright © 2018年 linyong. All rights reserved.
//

#import "EZSupportViewController.h"
#import "Toast+UIView.h"
#import "EZOpenSDK.h"
#import "GlobalKit.h"

#define test2AppKey         @"a8bc553b576c430a9c4bcf96cc7de377"
#define test2AppAPIUrl      @"https://test2.ys7.com:9000"
#define test2AppAuthUrl     @"https://test2auth.ys7.com:8643"
#define testAppKey          @"ae1b9af9dcac4caeb88da6dbbf2dd8d5"
#define testAppAPIUrl       @"https://test.ys7.com:65"
#define testAppAuthUrl      @"https://testopenauth.ys7.com:8447"


@interface EZSupportViewController ()

@property (weak, nonatomic) IBOutlet UITextField *appKeyInput;
@property (weak, nonatomic) IBOutlet UITextField *accessTokenInput;
@property (weak, nonatomic) IBOutlet UITextField *apiUrlInput;
@property (weak, nonatomic) IBOutlet UITextField *authUrlInput;
@property (weak, nonatomic) IBOutlet UITextField *devSerialInput;

@end

@implementation EZSupportViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initSubviews];
}

- (void) initSubviews
{
    self.title = @"支持界面";
    [self createBackBtn];
    [self createDoneBtn];
}

- (void) showToastWithText:(NSString *) text
{
    if (!text)
    {
        return;
    }
    
    [self.view makeToast:text duration:2.0 position:@"center"];
}

- (void)createBackBtn
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(backClick:)];
}

- (void)backClick:(id) sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)createDoneBtn
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(doneClick:)];
}

- (void)doneClick:(id) sender
{
    [GlobalKit shareKit].configDevSerial = self.devSerialInput.text.length > 0 ? self.devSerialInput.text : @"";
    
    if (self.appKeyInput.text.length == 0 )
    {
        [self showToastWithText:@"appKey不正确."];
        return;
    }
    
    if (self.apiUrlInput.text.length > 0)
    {
        [EZOpenSDK initLibWithAppKey:self.appKeyInput.text
                              url:self.apiUrlInput.text
                             authUrl:self.authUrlInput.text.length>0?self.authUrlInput.text:nil];
    }
    else
    {
        [EZOpenSDK initLibWithAppKey:self.appKeyInput.text];
    }
    
    if (self.accessTokenInput.text.length > 0)
    {
        [EZOpenSDK setAccessToken:self.accessTokenInput.text];
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)test2BtnClick:(id)sender
{
    [EZOpenSDK logout:^(NSError *error) {
        
    }];
    [EZOpenSDK initLibWithAppKey:test2AppKey
                          url:test2AppAPIUrl
                         authUrl:test2AppAuthUrl];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)testBtnClick:(id)sender
{
    [EZOpenSDK logout:^(NSError *error) {
        
    }];
    [EZOpenSDK initLibWithAppKey:testAppKey
                          url:testAppAPIUrl
                         authUrl:testAppAuthUrl];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}



@end
