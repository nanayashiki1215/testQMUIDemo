//
//  TestSystemService.m
//  veryWallen
//
//  Created by qiuqiu's imac on 14/12/3.
//  Copyright (c) 2014年 qiuqiu's imac. All rights reserved.
//

#import "TestSystemService.h"
#import <CoreLocation/CLLocationManager.h>
//#include <AddressBook/ABAddressBook.h>
#import <AVFoundation/AVFoundation.h>
#define IS_IOS8_AND_UP ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)

@implementation TestSystemService


+(instancetype)shareTestSystemService
{
    static TestSystemService *testService;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        testService = [[TestSystemService alloc]init];
    });
    return testService;
}


+(BOOL) showLocationAlertWithService:(SystemService)service byShowAlert:(BOOL)show
{
    BOOL isSupport = YES;
    NSString *alertString = nil;
    switch (service) {
        case SystemServiceLocation:
        {
            isSupport = [CLLocationManager authorizationStatus] >= kCLAuthorizationStatusAuthorized;
            alertString = IS_IOS8_AND_UP?@"您的定位服务没有开启，请问是否前往设置" : @"您现在无法定位，请到系统“设置”-“隐私”中开启";
            break;
        }
        case SystemServicePhoto:
        {
            isSupport = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
            alertString = IS_IOS8_AND_UP?@"您的相册没有授权访问，请问是否前往设置" : @"您的相册没有授权访问，请到系统“设置”-“隐私”中开启";
            break;
        }
            
        case SystemServicePushMessage:
        {
            isSupport = IS_IOS8_AND_UP?([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]):([[UIApplication sharedApplication] enabledRemoteNotificationTypes]!=0);
            alertString = IS_IOS8_AND_UP?@"您现在没有开启消息服务，请问是否前往设置" : @"您现在没有开启消息服务，请到系统“设置”-“通知”中开启";
            break;
        }
            
        case SystemServiceCamera:
        {
            AVAuthorizationStatus stat = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if (stat) {
                isSupport = (stat== AVAuthorizationStatusAuthorized||stat == AVAuthorizationStatusNotDetermined);
            }
            alertString = IS_IOS8_AND_UP?@"您的相机没有授权访问，请问是否前往设置" : @"您的相机没有授权访问，请到系统“设置”-“隐私”中开启";
            break;
        }
        case SystemServiceAdressBook:
        {
            //            CFErrorRef err;
            //            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL,&err);
            //            if(ABAddressBookGetAuthorizationStatus()){
            //                isSupport = (ABAddressBookGetAuthorizationStatus()==kABAuthorizationStatusAuthorized);
            //            }
            //             ABAddressBookRequestAccessWithCompletion(addressBook, nil);
            //            alertString = IS_IOS8_AND_UP?@"您的通讯录没有授权访问，请问是否前往设置" : @"您的通讯录没有授权访问，请到系统“设置”-“隐私”中开启";
            break;
        }
        default:
            break;
    }
    if (show) {
        if (!isSupport) {
            if (IS_IOS8_AND_UP) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:alertString delegate:[TestSystemService shareTestSystemService]  cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
                alert.tag = 20000;
                [alert show];
            }else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:alertString delegate:[TestSystemService shareTestSystemService] cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            }
        }
    }
    return isSupport;
}

#pragma mark --------makeAlertView----------------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

@end
