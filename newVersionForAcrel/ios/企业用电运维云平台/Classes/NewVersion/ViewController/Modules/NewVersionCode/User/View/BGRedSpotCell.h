//
//  BGRedSpotCell.h
//  BusinessGo
//
//  Created by feitian on 2017/12/22.
//  Copyright © 2017年 com.Ideal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BGRedSpotCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *redSpotBTN;
@property (weak, nonatomic) IBOutlet UIImageView *iconIV;
@property (weak, nonatomic) IBOutlet UILabel *leftLB;
@property (weak, nonatomic) IBOutlet UILabel *rightLB;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgWidth;

@end
