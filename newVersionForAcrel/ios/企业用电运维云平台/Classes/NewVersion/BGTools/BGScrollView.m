//
//  BGScrollView.m
//  BusinessUCSDK
//
//  Created by feitian on 2019/2/24.
//  Copyright © 2019 com.Ideal. All rights reserved.
//

#import "BGScrollView.h"

@implementation BGScrollView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view{
    NSLog(@"用户点击了scroll上的视图%@,是否开始滚动scroll",view);
    //返回yes 是不滚动 scroll 返回no 是滚动scroll
    return YES;
}
- (BOOL)touchesShouldCancelInContentView:(UIView *)view{
    
    NSLog(@"用户点击的视图 %@",view);
    
    //NO scroll不可以滚动 YES scroll可以滚动
    return YES;
}

@end
