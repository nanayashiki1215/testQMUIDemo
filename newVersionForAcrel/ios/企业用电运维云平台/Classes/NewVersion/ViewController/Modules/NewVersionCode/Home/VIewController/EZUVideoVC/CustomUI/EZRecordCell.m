//
//  EZRecordCell.m
//  EZOpenSDKDemo
//
//  Created by DeJohn Dong on 15/11/3.
//  Copyright © 2015年 hikvision. All rights reserved.
//

#import "EZRecordCell.h"
#import "EZDeviceRecordFile.h"
#import "EZCloudRecordFile.h"
//#import "UIImageView+AFNetworking.h"
#import "DDKit.h"

@implementation EZRecordCell {
    
    EZDeviceRecordFile *deviceFile;
    EZCloudRecordFile *cloudFile;
}

- (void)setCloudRecord:(EZCloudRecordFile *)cloudFile selected:(BOOL)selected
{
    //暂时隐藏下载功能
    self.downloadBtn.hidden = YES;
    
    if (![cloudFile isKindOfClass:[EZCloudRecordFile class]])
    {
        return;
    }
    self.imageView.backgroundColor = [UIColor clearColor];
    //https://cloud.ys7.com:8089/api/cloud?method=download&fid=bf883130-8e13-11e5-8000-a4b5707128a7&session=hik%24shipin7%231%23USK%23at.05idkxni22jmnf4x4f3o380e0oum07ve-7sjmcfm1m8-18q74ue-zhxrqgkur
    NSURL *url = [NSURL URLWithString:cloudFile.coverPic];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *file = [cloudFile.coverPic dd_getSubStringBeginKey:@"fid=" endKey:@"&session"];
    NSString *password = @"";
    //判断是否加密
    if(![cloudFile.encryption isEqualToString:@""])
    {
        //注意该密码是一定要正确的，或者会得不到图片数据
        password = [[GlobalKit shareKit].deviceVerifyCodeBySerial valueForKey:self.deviceSerial];
    }
    NSString *body = [NSString stringWithFormat:@"fid=%@&x=%d&decodekey=%@", file, 200, password];
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
//    [self.imageView setImageWithURLRequest:request
//                          placeholderImage:[UIImage imageNamed:@"message_callhelp"]
//                                   success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
//                                       self.imageView.image = image;
//                                   }
//                                   failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
//                                       DefLog(@"error = %@",error);
//                                   }];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm";
    self.timeLabel.text = [formatter stringFromDate:cloudFile.startTime];
    
    UIColor *tintColor = [UIColor grayColor];
    if(selected)
        tintColor = [UIColor dd_hexStringToColor:@"0x1b9ee2"];
    self.imageView.layer.borderColor = tintColor.CGColor;
    self.imageView.layer.borderWidth = 1.0f;
    self.timeLabel.textColor = tintColor;
    
    self->cloudFile = cloudFile;
}

- (void)setDeviceRecord:(EZDeviceRecordFile *)deviceFile selected:(BOOL)selected
{
    //暂时隐藏下载功能
    self.downloadBtn.hidden = YES;
    
    self.imageView.image = nil;
    self.imageView.backgroundColor = [UIColor grayColor];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm";
    self.timeLabel.text = [formatter stringFromDate:deviceFile.startTime];
    self.imageView.image = [UIImage imageNamed:@"message_callhelp"];
    
    UIColor *tintColor = [UIColor grayColor];
    if(selected)
        tintColor = [UIColor dd_hexStringToColor:@"0x1b9ee2"];
    self.imageView.layer.borderColor = tintColor.CGColor;
    self.imageView.layer.borderWidth = 1.0f;
    self.timeLabel.textColor = tintColor;
    
    self->deviceFile = deviceFile;
}

- (IBAction)clickDownloadBtn:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(didClickDownlodBtn:)]) {
        [self.delegate didClickDownlodBtn:_isSelectedDevice ? deviceFile : cloudFile];
    }
}

@end
