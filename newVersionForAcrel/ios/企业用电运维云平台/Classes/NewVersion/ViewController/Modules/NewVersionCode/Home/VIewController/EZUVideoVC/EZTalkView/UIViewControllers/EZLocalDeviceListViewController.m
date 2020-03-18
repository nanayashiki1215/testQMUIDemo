//
//  EZLocalDeviceListViewController.m
//  EZOpenSDKDemo
//
//  Created by linyong on 2017/8/16.
//  Copyright © 2017年 hikvision. All rights reserved.
//

#import "EZLocalDeviceListViewController.h"
#import "EZHCNetDeviceInfo.h"
#import "EZHCNetDeviceSDK.h"
#import "EZSADPDeviceInfo.h"
#import "Toast+UIView.h"
#import "EZLocalRealPlayViewController.h"
#import "EZLocalCameraListViewController.h"
#import "MBProgressHUD.h"


#define DEVICE_LIST_ID @"localDeviceList"
#define CELL_HEIGHT (50)

@interface EZLocalDeviceListViewController ()

@property (nonatomic,strong) NSMutableArray *deviceList;
@property (nonatomic,strong) EZHCNetDeviceInfo *loginedInfo;

@end

@implementation EZLocalDeviceListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initData];
    [self initSubviews];
    [self searchDevices];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];

}

- (void) dealloc
{
    [self stopSearch];
}

#pragma mark - table view delegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deviceList.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DEVICE_LIST_ID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:DEVICE_LIST_ID];
    }
    
    EZSADPDeviceInfo *info = [self.deviceList objectAtIndex:[indexPath row]];
    cell.textLabel.text = info.deviceSerial;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0];
    cell.detailTextLabel.text = info.localIp;

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EZSADPDeviceInfo *info = [self.deviceList objectAtIndex:[indexPath row]];
    
    
    if (info.actived)
    {
        [self loginWithDevice:info];
    }
    else
    {
        [self activeWithDevice:info];
    }
}

#pragma mark - override

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue destinationViewController] isKindOfClass:[EZLocalRealPlayViewController class]])
    {
        EZHCNetDeviceInfo *deviceInfo = sender;
        EZLocalRealPlayViewController *VC = (EZLocalRealPlayViewController *)[segue destinationViewController];
        VC.deviceInfo = deviceInfo;
        VC.cameraNo = deviceInfo.channelCount == 1?deviceInfo.startChannelNo:deviceInfo.dStartChannelNo;
    }
    else if ([[segue destinationViewController] isKindOfClass:[EZLocalCameraListViewController class]])
    {
        EZHCNetDeviceInfo *deviceInfo = sender;
        EZLocalCameraListViewController *VC = (EZLocalCameraListViewController *)[segue destinationViewController];
        VC.deviceInfo = deviceInfo;
    }
}


#pragma mark - support

- (void) initSubviews
{
    self.title = NSLocalizedString(@"device_lan_device_list_title", @"局域网设备列表");
    self.tableView.tableFooterView = [UIView new];
}

- (void) initData
{
    self.deviceList = [NSMutableArray array];
}

- (void) searchDevices
{
    [EZHCNetDeviceSDK startLocalSearch:^(EZSADPDeviceInfo *device, NSError *error) {
        if (!device)
        {
            return;
        }
        
        if ([self containtInfo:device])
        {
            return;
        }
        
        [self.deviceList addObject:device];
        [self.tableView reloadData];
    }];
}

- (void) stopSearch
{
    [EZHCNetDeviceSDK stopLocalSearch];
}

- (BOOL) containtInfo:(EZSADPDeviceInfo *) info
{
    if (!info)
    {
        return YES;
    }
    
    for (EZSADPDeviceInfo *tempInfo in self.deviceList)
    {
        if ([tempInfo.deviceSerial isEqualToString:info.deviceSerial])
        {
            return YES;
        }
    }
    
    return NO;
}

- (void) activeWithDevice:(EZSADPDeviceInfo *) deviceInfo
{
    if (!deviceInfo)
    {
        return;
    }
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"device_active_device", @"激活设备")
                                                                     message:NSLocalizedString(@"device_set_pw_tip", @"请设置密码,密码为8-16位的字符")
                                                              preferredStyle:UIAlertControllerStyleAlert];
    
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"device_set_pw", @"设置密码");
        textField.keyboardType = UIKeyboardTypeASCIICapable;
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"取消")
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                         }];
    
    UIAlertAction *actionDone = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"确定")
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           
                                                           UITextField *pwdInput = [alertVC.textFields firstObject];
                                                           if (pwdInput.text.length == 0)
                                                           {
                                                               [self showToastWithStr:NSLocalizedString(@"device_pw_empty", @"密码不能为空")];
                                                               return;
                                                           }
                                                           
                                                           if (pwdInput.text.length < 8 || pwdInput.text.length > 16)
                                                           {
                                                               [self showToastWithStr:NSLocalizedString(@"device_pw_length_error", @"密码长度不正确")];
                                                               return;
                                                           }
                                                           
                                                           [self doActiveWithInfo:deviceInfo pwd:pwdInput.text];
                                                       }];
    [alertVC addAction:actionDone];
    [alertVC addAction:actionCancel];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void) doActiveWithInfo:(EZSADPDeviceInfo *) deviceInfo pwd:(NSString *) pwd
{
    if (!deviceInfo || !pwd)
    {
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //激活可能为耗时处理过程，可考虑异步处理
        BOOL ret = [EZHCNetDeviceSDK activeDeviceWithSerial:deviceInfo.deviceSerial
                                                        pwd:pwd];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];

            if (ret)
            {
                deviceInfo.actived = YES;
                [self loginWithDevice:deviceInfo];
            }
            else
            {
                [self showToastWithStr:NSLocalizedString(@"device_active_fail", @"激活失败")];
            }
        });
    });
}

- (void) doLoginWithInfo:(EZSADPDeviceInfo *) deviceInfo userName:(NSString *) userName pwd:(NSString *) pwd
{
    if (!deviceInfo || !userName || !pwd)
    {
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //登录可能为耗时处理过程，可考虑异步处理
        self.loginedInfo = [EZHCNetDeviceSDK loginDeviceWithUerName:userName
                                                                pwd:pwd
                                                             ipAddr:deviceInfo.localIp
                                                               port:deviceInfo.localPort];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            
            if (self.loginedInfo)
            {
                if (self.loginedInfo.channelCount + self.loginedInfo.dChannelCount > 1)
                {
                    [self go2CameraListWithInfo:self.loginedInfo];
                }
                else
                {
                    [self go2LocalRealPlayWithInfo:self.loginedInfo];
                }
            }
            else
            {
                [self showToastWithStr:NSLocalizedString(@"device_login_fail", @"登录失败")];
            }
        });
    });
}


- (void) loginWithDevice:(EZSADPDeviceInfo *) deviceInfo
{
    if (!deviceInfo)
    {
        return;
    }
    
    self.loginedInfo = nil;
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"device_login_device", @"登录设备")
                                                                     message:NSLocalizedString(@"device_input_account_pw", @"请输入帐号和密码")
                                                              preferredStyle:UIAlertControllerStyleAlert];
    
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"admin";
        textField.placeholder = NSLocalizedString(@"device_account", @"帐号");
        textField.keyboardType = UIKeyboardTypeASCIICapable;
    }];
    
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.secureTextEntry = YES;
        textField.placeholder = NSLocalizedString(@"device_password", @"密码");
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"取消")
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                         }];
    
    UIAlertAction *actionDone = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"确定")
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           UITextField *nameInput = [alertVC.textFields firstObject];
                                                           UITextField *pwdInput = [alertVC.textFields lastObject];

                                                           if (nameInput.text == 0 || pwdInput.text.length == 0)
                                                           {
                                                               [self showToastWithStr:NSLocalizedString(@"device_account_pw_empty", @"帐号或密码不能为空")];
                                                               return;
                                                           }
                                                           
                                                           [self doLoginWithInfo:deviceInfo
                                                                        userName:nameInput.text
                                                                             pwd:pwdInput.text];
                                                       }];
    [alertVC addAction:actionDone];
    [alertVC addAction:actionCancel];
    
    [self presentViewController:alertVC animated:YES completion:^{
        UITextField *pwdInput = [alertVC.textFields lastObject];
        [pwdInput becomeFirstResponder];
    }];
}

- (void) go2LocalRealPlayWithInfo:(EZHCNetDeviceInfo *) deviceInfo
{
    if (!deviceInfo)
    {
        return;
    }
    
    [self performSegueWithIdentifier:@"go2LocalRealPlay" sender:deviceInfo];
}

- (void) go2CameraListWithInfo:(EZHCNetDeviceInfo *) deviceInfo
{
    if (!deviceInfo)
    {
        return;
    }
    
    [self performSegueWithIdentifier:@"go2CameraList" sender:deviceInfo];
}


- (void) showToastWithStr:(NSString *) str
{
    if (!str)
    {
        return;
    }
    [self.navigationController.view makeToast:str duration:1.5 position:@"center"];
}


@end
