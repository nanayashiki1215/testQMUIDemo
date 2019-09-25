//
//  UITableView+Extension.m
//  CloudService
//
//  Created by feitian on 15/11/13.
//  Copyright © 2015年 com.Ideal. All rights reserved.
//

#import "UITableView+BGExtension.h"

@implementation UITableView (BGExtension)
-(void)setFooterCellLineHidden
{
    UIView *view = [UIView new];
    [self setTableFooterView:view];
}
-(void)settingSeparatorInsetFullLine{
    [self settingSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
}

-(void)settingSeparatorInset:(UIEdgeInsets)ed {
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:ed];
    }
    
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:ed];
    }
}
@end
