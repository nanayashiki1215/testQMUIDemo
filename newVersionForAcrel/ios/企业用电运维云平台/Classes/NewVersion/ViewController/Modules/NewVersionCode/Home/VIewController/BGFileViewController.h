//
//  BGFileViewController.h
//  BusinessGo
//
//  Created by NanayaSSD on 2017/4/11.
//  Copyright © 2017年 com.Ideal. All rights reserved.
//

#import "BaseViewController.h"
#import "CSFileManage.h"
#import "BGFileDownModel.h"

@interface BGFileViewController : BaseViewController
/**
 0.我的文件
 1.群文件
 2.活动文件
 */
@property(nonatomic,assign)NSString *shareType;
/**
 0.用户ID
 1.群组ID
 2.活动ID
 */
@property(nonatomic,strong)NSString *orgId;

/**
 0:全部
 1:图片 对应接口type：0
 2：影音 对应2、3
 3：文档 1
 4：对应 4、5
 
 */
@property(nonatomic,assign)NSInteger FilelistTpye;

@property(weak, nonatomic) IBOutlet UIButton *upLoadFileBtn;
@property (weak, nonatomic) IBOutlet UIView *upFileLine;


@end
