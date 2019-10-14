//
//  ProjectDefine.h
//  变电所运维
//
//  Created by Acrel on 2019/5/16.
//

#ifndef ProjectDefine_h
#define ProjectDefine_h

//打印log
#if 0
#define DefLog(format,...) NSLog(format,##__VA_ARGS__)
#else
#define DefLog(format,...)
#endif

#define COLOR_NAVBAR DefColorFromRGB(80,172,172, 1)
#define COLOR_WEBNAVBAR DefColorFromRGB(2,168,166, 1)
// 83, 187, 226
#define COLOR_BACKGROUND DefColorFromRGB(244, 244, 244, 1)
#define COLOR_LightLWithChange DefColorFromRGB(86, 198, 118, 1)
#define COLOR_DeepLWithChange DefColorFromRGB(2, 172, 148, 1)//最深 也是字体色
#define COLOR_LightLWithChangeIn16 @"#56C676"
#define COLOR_DeepLWithChangeIn16 @"#02AC94"

#define DefColorFromRGB(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
//系统版本判断
#define UIDEVICE_SYSTEMVERSION  [[UIDevice currentDevice].systemVersion floatValue]
#define iOS11 [[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0
#define UNDERiOS12 [[[UIDevice currentDevice] systemVersion] floatValue] < 13.0
#define iOS9 [[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0
#define iOS8 [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0
#define iOS7 [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0
//屏幕宽高
//#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
//#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

//判断机型
#define IS_IPHONE_X (SCREEN_HEIGHT == 812.0f) ? YES : NO
//判断iPHoneXr
#define IS_IPHONE_Xr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
//判断iPhoneXs
#define IS_IPHONE_Xs ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
//判断iPhoneXs Max
#define IS_IPHONE_Xs_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)

#define isPad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#define BGAdjustsScrollViewInsetNever(controller,view) if(@available(iOS 11.0, *)) {view.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;} else if([controller isKindOfClass:[UIViewController class]]) {controller.automaticallyAdjustsScrollViewInsets = false;}

#define BGHeightCoefficient (SCREEN_HEIGHT == 812.0 ? 667.0/667.0 : kWJScreenHeight/667.0)

#define BGSafeAreaTopHeight ((IS_IPHONE_X==YES || IS_IPHONE_Xr ==YES || IS_IPHONE_Xs== YES || IS_IPHONE_Xs_Max== YES) ? 88.0 : 64.0)

#define BGSafeAreaBottomHeight ((IS_IPHONE_X==YES || IS_IPHONE_Xr ==YES || IS_IPHONE_Xs== YES || IS_IPHONE_Xs_Max== YES) ? 20.0 : 0.0)

#define BGHeight_StatusBar ((IS_IPHONE_X==YES || IS_IPHONE_Xr ==YES || IS_IPHONE_Xs== YES || IS_IPHONE_Xs_Max== YES) ? 44.0 : 20.0)

#define BGHeight_TabBar ((IS_IPHONE_X==YES || IS_IPHONE_Xr ==YES || IS_IPHONE_Xs== YES || IS_IPHONE_Xs_Max== YES) ? 83.0 : 49.0)

#define BGSafeAreaTopHeightForWEB ((IS_IPHONE_X==YES || IS_IPHONE_Xr ==YES || IS_IPHONE_Xs== YES || IS_IPHONE_Xs_Max== YES) ? 20.0 : 0.0)

//常用系统类
#define BGWeakSelf __weak typeof(self) weakSelf = self
#define DefAPPDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)
#define DefWindow ((UIWindow *)DefAPPDelegate.window)
#define DefNSUD [NSUserDefaults standardUserDefaults]
#define DefNSUDSynchronize [DefNSUD synchronize];
#define DefFileManager [NSFileManager defaultManager]
#define DefNotification [NSNotificationCenter defaultCenter]
#define DefDocumentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
#define DefKeyWindow [UIApplication sharedApplication].keyWindow

//本地化语言
#define DefLocalizedString(__str) NSLocalizedString(__str, nil)

//快速弹出alertView
#define DefQuickAlert(__str,__tar) {UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:__str message:nil delegate:__tar cancelButtonTitle:DefLocalizedString(@"确定") otherButtonTitles:nil, nil];[alertView show];}

//底部菜单栏
#define BottomTabBarHeight (49)

//分类顶部bar
#define BGTopBarHeight 44

#define DefCellHeight (SCREEN_HEIGHT == 480)?44:((SCREEN_HEIGHT == 568)?50:((SCREEN_HEIGHT == 667)?52:((SCREEN_HEIGHT == 736)?60:((SCREEN_HEIGHT == 736)?60:68))))

#define FixedDeathHeight IS_IPAD?200:100
#define FixedDeathFontLargeSize IS_IPAD?20:16
#define FixedDeathFontMinSize IS_IPAD?20:14
#define FixedDeathFontSmalleSize IS_IPAD?19:15
//812.0f 414 896
#define DefVideoCellHeight (SCREEN_HEIGHT == 480)?310:((SCREEN_HEIGHT == 568)?310:((SCREEN_HEIGHT == 667)?310:((SCREEN_HEIGHT == 736)?310:((SCREEN_HEIGHT == 812)?310:((SCREEN_HEIGHT == 896)?310:500)))))


//腾讯bugly
#define BGBuglyApi @"7286a5b272"

//百度地图
#define BGBaiduMapApi @"sTYHQCTNY0H8L4k5vPtdXqRcaEgYfYtZ"

//萤石云
#define EZUIKitAppKey           @"EZUIKitAppKey"
#define EZUIKitAccessToken      @"EZUIKitAccessToken"
#define EZUIKitUrlStr           @"EZUIKitUrlStr"
#define EZUIKitUrlStrOhter      @"EZUIKitUrlStrOhter"
#define EZUIKitApiUrl           @"EZUIKitApiUrl"
#define EZUIKitMode           @"EZUIKitMode"

#define EZAPPKEY @"cec0dca73dfc4782bc84375a57cd8170"
#define EZAPPTestAccessToken @"at.4rg8drrp61vxbdnjcwy7qv9pa4ta9t26-41vxl12n5l-0gbiy8d-3iqf5ouvx"
#define EZBASEURL @"ezopen://open.ys7.com/"
//1.hd.live 高清
//1.live 流畅
//1.rec?begin=20190619000000&end=20190620235959 回放

//个人中心
#define BGPersonalPage @"userPage"


#endif /* ProjectDefine_h */



