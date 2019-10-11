//
//  UITabBar+BGbadge.h
//  变电所运维
//
//  Created by Acrel on 2019/6/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITabBar (BGbadge)
- (void)bg_updateTabbarBadge:(BOOL)isShow onItemIndex:(NSUInteger)index showText:(NSString *)showText;

@end

NS_ASSUME_NONNULL_END
