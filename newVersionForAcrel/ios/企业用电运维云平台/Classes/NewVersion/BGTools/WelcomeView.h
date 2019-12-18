//
//  WelcomeView.h
//  SPDBCreditCardCenter
//
//  Created by newtouch on 14-7-22.
//  Copyright (c) 2014年 wind. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "MyWebView.h"

@class PDBaseViewController;

@protocol WelcomeDelegate <NSObject>
@optional
-(void)loadrequest;
@end
@interface WelcomeView : UIView
<UIScrollViewDelegate>
{
    NSInteger tempPage;
    UIPageControl* pageControl;
//    MyWebView* myWebView;//支持网页显示
}
@property (nonatomic ,strong) id<WelcomeDelegate> delegate;
-(void)showContentView;
@end
