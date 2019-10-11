//
//  UITabBar+BGbadge.m
//  变电所运维
//
//  Created by Acrel on 2019/6/3.
//

#import "UITabBar+BGbadge.h"

@implementation UITabBar (BGbadge)

- (void)bg_updateTabbarBadge:(BOOL)isShow onItemIndex:(NSUInteger)index showText:(NSString *)showText{
    //按照tag值移除之前的小红点
    UILabel *redLB = [self viewWithTag:index];
    if (redLB) {
        redLB.text = nil;
        redLB.hidden = YES;
    }
    if (isShow == YES) {
        if (redLB == nil) {
            redLB = [[UILabel alloc]init];
            redLB.backgroundColor = [UIColor redColor];
            redLB.textColor = [UIColor whiteColor];
            redLB.font = [UIFont systemFontOfSize:10.f];
            redLB.textAlignment = NSTextAlignmentCenter;
            redLB.adjustsFontSizeToFitWidth = YES;
            redLB.clipsToBounds = YES;
            redLB.tag = index;
            [self addSubview:redLB];
        }
        redLB.hidden = NO;
        CGRect tabFrame = self.frame;
        NSUInteger itemsCount = self.items.count;
        //确定聊天小红点的位置
        float percentX = (index +0.56) / itemsCount;
        CGFloat x = ceilf(percentX * tabFrame.size.width);
        CGFloat y = 0;
        
        
        //        if (IS_IPHONE_X || SCREEN_HEIGHT == 480) {
        //            y = 11;
        //        }else if (SCREEN_HEIGHT == 736){
        //            y = 18;
        //        }else{
        //            y = 12;
        //        }
        
        
        /*******/
        //以667屏幕  y = 12 为基准
        CGFloat ratio = ([UIScreen mainScreen].bounds.size.height/667);
        if(SCREEN_HEIGHT == 480){
            y = 11;
        }else if(SCREEN_HEIGHT == 568){
            y = 12;
        }else if (SCREEN_HEIGHT == 667){
            y = 12;
        }else if (SCREEN_HEIGHT == 736){
            y = 12 *ratio;
        }else{
            //iphone x 往上
            y = 11;
        }
        
        if (showText == nil || [showText isEqualToString:@"0"]) {
            redLB.text = nil;
            redLB.frame = CGRectMake(x, y, 12, 12);
            redLB.layer.cornerRadius =redLB.frame.size.height/2;
        }else{
            redLB.text = showText;
            redLB.frame = CGRectMake(x, y-4, 20, 20);
            redLB.layer.cornerRadius =redLB.frame.size.height/2;
        }
    }
}
@end

