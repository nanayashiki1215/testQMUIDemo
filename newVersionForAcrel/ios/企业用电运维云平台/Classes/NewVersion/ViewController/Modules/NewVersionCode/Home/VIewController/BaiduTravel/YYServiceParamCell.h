//
//  YYServiceParamCell.h
//  YYObjCDemo
//
//  Created by Daniel Bey on 2017年06月16日.
//  Copyright © 2017 百度鹰眼. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYServiceParamCell : UITableViewCell

@property (nonatomic, strong) UIView *customView;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
