//
//  BaseViewController.h
//  IdealCallCenter
//
//  Created by feitian on 15/9/2.
//  Copyright © 2015年 com.Ideal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QMUIKit/QMUIKit.h>

@interface BaseViewController : QMUICommonViewController
@property (nonatomic, strong) UIButton *backButton;/**< 左上角返回按钮 */
@property (nonatomic, strong) UIButton *homeButton;/**< 右上角按钮 */
@property (copy, nonatomic) void (^baseAssistBlock)(BaseViewController *currentBaseVC,id objc);/** 辅助的回传Block，可以将数据回传上级VC **/

-(void)setBaseAssistBlock:(void (^)(BaseViewController *, id))baseAssistBlock;

- (void)initNavigationBarButtonItems;/**< 设置导航栏上面的内容 */
-(void)initNavigationBarButtonItemsWithTitle:(NSString *)backTitle;
-(void)initNavigationBarButtonItemsWithTitle:(NSString *)backTitle image:(NSString *)image highlightImage:(NSString *)highlightImage;

- (void)backButtonAction:(UIButton *)backBtn;/**< 左上角事件 */
- (void)moreButtonAction:(UIButton *)moreBtn;/**< 右上角事件 */
- (void)pushViewController:(UIViewController*)viewController animation:(BOOL)animation;/**< 页面跳转 */
- (void)popViewControllerAnimation:(BOOL)animation;/**< 跳转返回 */
- (void)popToRootViewControllerAnimation:(BOOL)animation;/**< 跳转至基层 */
- (void)popToViewControllerClass:(Class)viewControllerClass animated:(BOOL)animation;/**< 返回指定vc */
- (void)bg_popViewControllerClass:(Class)viewControllerClass animated:(BOOL)animation ;
- (void)popToViewControllerWithBackNumber:(NSUInteger)backNumber animated:(BOOL)animation ;/**< 返回指定层数 */
- (void)popNouseViewControllerWithClassName:(NSString*)className;/**< 返回指定VC */
- (void)popNouseViewController:(UIViewController*)vc;/**< 返回指定VC */
-(void)removeAllVCOnlyFirstVC;

//添加页面通知，空方法，由子类实现
-(void)bg_addNotification;

//删除页面通知，空方法，由子类实现
-(void)bg_removeNotification;

//配置导航栏相关设置项，空方法，由子类实现
- (void)bg_setNavigationBar;
-(void)viewDidLayoutSubviews;

@end
