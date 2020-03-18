//
//  EZRecordCell.h
//  EZOpenSDKDemo
//
//  Created by DeJohn Dong on 15/11/3.
//  Copyright © 2015年 hikvision. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EZCloudRecordFile;
@class EZDeviceRecordFile;

@protocol EZRecordCellDelegate <NSObject>

@optional
- (void) didClickDownlodBtn:(id)recordFile;

@end

@interface EZRecordCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (nonatomic, copy) NSString *deviceSerial;
@property (nonatomic, assign) BOOL isSelectedDevice;
@property (nonatomic, weak) id<EZRecordCellDelegate> delegate;

- (void)setCloudRecord:(EZCloudRecordFile *)cloudFile selected:(BOOL)selected;

- (void)setDeviceRecord:(EZDeviceRecordFile *)deviceFile selected:(BOOL)selected;

@end
