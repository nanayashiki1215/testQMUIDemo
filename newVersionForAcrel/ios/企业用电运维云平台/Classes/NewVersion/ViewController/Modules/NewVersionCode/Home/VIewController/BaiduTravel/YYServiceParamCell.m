//
//  YYServiceParamCell.m
//  YYObjCDemo
//
//  Created by Daniel Bey on 2017年06月16日.
//  Copyright © 2017 百度鹰眼. All rights reserved.
//

#import "YYServiceParamCell.h"

@implementation YYServiceParamCell

-(void)setCustomView:(UIView *)customView {
    _customView = customView;
    if ([customView isMemberOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)customView;
        self.textLabel.text = label.text;
    } else {
        [self addSubview:_customView];
    }
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    return [super initWithStyle:style reuseIdentifier:reuseIdentifier];
}

@end
