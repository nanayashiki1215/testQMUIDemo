//
//  BGHeadPortraitViewController.h
//  BusinessGo
//
//  Created by Beryl on 2018/1/22.
//  Copyright © 2018年 com.Ideal. All rights reserved.
//

#import "BaseViewController.h"
typedef void (^selectedBlock)(UIImage *bigImage);

@interface BGHeadPortraitViewController : BaseViewController
@property (nonatomic,copy)selectedBlock block;
@property (nonatomic,strong)UIImage *headerImage;
@end
