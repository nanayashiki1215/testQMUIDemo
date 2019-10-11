//
//  BGQMToolHelper.h
//  变电所运维
//
//  Created by Acrel on 2019/6/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//往后拓展协议
@interface BGQMToolHelper : NSObject

@property(nonatomic,strong)NSDictionary *bgTabBarItemIndexSetting;
//1.初始化单例
+ (BGQMToolHelper *_Nonnull)bg_sharedInstance;

- (void)bg_updateTabbarBadge:(BOOL)isShow withTypeCode:(NSString *)typeCode withShowText:(NSString *)showText;

- (void)bg_setTabbarBadge:(BOOL)isShow withItemsNumber:(NSUInteger)itemnumber withShowText:(NSString *)showText;

@end

NS_ASSUME_NONNULL_END
