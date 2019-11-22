//
//  BGFileDownLoadTableViewCell.h
//  BusinessGo
//
//  Created by NanayaSSD on 2017/4/11.
//  Copyright © 2017年 com.Ideal. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BGFileDownLoadTableViewCellDelegate<NSObject>;

@optional
//点击下载
-(void)didClickDownloadButton:(UIButton *)button;
//删除文件
-(void)didClickDeleteFileWithName:(NSString *)filename;

@end

@interface BGFileDownLoadTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *downLoadingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *fileImg;
@property (weak, nonatomic) IBOutlet UILabel *fileName;
@property (weak, nonatomic) IBOutlet UIButton *fileDownBtn;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeLabel;
@property id<BGFileDownLoadTableViewCellDelegate> delegate;
@property (nonatomic,strong) NSString *fileDownloadURL;

@end
