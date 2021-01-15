//
//  ZYSuspensionView.m
//  ZYSuspensionView
//
//  GitHub https://github.com/ripperhe
//  Created by ripper on 16-02-25.
//  Copyright (c) 2016年 ripper. All rights reserved.
//

#import "ZYSuspensionView.h"

#define kLeanProportion (8/55.0)
#define kVerticalMargin 15.0

static ZYSuspensionView *_instance;
//static ZYSuspensionView *_susView = nil;

@implementation ZYSuspensionView

- (void)dealloc
{
    fprintf(stderr,"[%s ● %s ● %d] Func ★ <%s: %p> ◉ %s\n", __TIME__, ([NSString stringWithFormat:@"%s", __FILE__].lastPathComponent).UTF8String, __LINE__, NSStringFromClass(self.class).UTF8String, self,  NSStringFromSelector(_cmd).UTF8String );
    
}

+ (instancetype)defaultSuspensionViewWithDelegate:(id<ZYSuspensionViewDelegate>)delegate
{
//    ZYSuspensionView *sus = [[ZYSuspensionView alloc] initwithFrame:CGRectMake(-kLeanProportion * 55, 100, 55, 55)];
////    [sus setFrame:CGRectMake(-kLeanProportion * 55, 100, 55, 55)
////                                                              color:[UIColor colorWithRed:0.21f green:0.45f blue:0.88f alpha:1.00f]
////                                                           delegate:delegate];
    
    ZYSuspensionView *sus = [[ZYSuspensionView alloc] initWithFrame:CGRectMake(-kLeanProportion * 55, 100, 55, 55)
                                                              color:[UIColor colorWithRed:0.21f green:0.45f blue:0.88f alpha:1.00f]
                                                           delegate:delegate];
    return sus;
}

+ (CGFloat)suggestXWithWidth:(CGFloat)width
{
    return - width * kLeanProportion;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame
                         color:[UIColor colorWithRed:0.21f green:0.45f blue:0.88f alpha:1.00f]
                      delegate:nil];
}

//+ (instancetype)shareInstanceWithFrame:(CGRect)frame color:(UIColor*)color delegate:(id<ZYSuspensionViewDelegate>)delegate{
//    if (_susView == nil) {
//        _susView = [[self alloc] initWithFrame:frame color:color delegate:delegate];
//    }
//    return _susView;
//}
//
//+ (instancetype)allocWithZone:(struct _NSZone *)zone{
//    static dispatch_once_t oneToken;
//
//    dispatch_once(&oneToken, ^{
//        if (_susView == nil) {
//            _susView = [super allocWithZone:zone];
//        }
//    });
//
//    return _susView;
//}

//+ (instancetype)shareInstance
//{
//    if (!_instance) {
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^{
//            _instance = [[ZYSuspensionView alloc] init];
//        });
//    }
//    return _instance;
//}
//
//+ (instancetype)allocWithZone:(struct _NSZone *)zone
//{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _instance = [super allocWithZone:zone];
//    });
//    return _instance;
//}


- (instancetype)initWithFrame:(CGRect)frame color:(UIColor*)color delegate:(id<ZYSuspensionViewDelegate>)delegate
{
    if(self = [super initWithFrame:frame])
    {
        self.delegate = delegate;
        self.userInteractionEnabled = YES;
        self.backgroundColor = color;
        self.alpha = .9;
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 1.0;
        self.clipsToBounds = YES;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
        pan.delaysTouchesBegan = YES;
        [self addGestureRecognizer:pan];
        [self addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

//- (instancetype)initWithFrame:(CGRect)frame color:(UIColor*)color delegate:(id<ZYSuspensionViewDelegate>)delegate
//{
//    if(self = [super initWithFrame:frame])
//    {
//        self.delegate = delegate;
//        self.userInteractionEnabled = YES;
//        self.backgroundColor = color;
//        self.alpha = .7;
//        self.titleLabel.font = [UIFont systemFontOfSize:14];
//        self.layer.borderColor = [UIColor whiteColor].CGColor;
//        self.layer.borderWidth = 1.0;
//        self.clipsToBounds = YES;
//
//        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
//        pan.delaysTouchesBegan = YES;
//        [self addGestureRecognizer:pan];
//        [self addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return self;
//}

- (NSString *)memoryAddressKey
{
    return @"ZYSuspensionView";
//    return [NSString stringWithFormat:@"%p", self];
}

#pragma mark - event response
- (void)handlePanGesture:(UIPanGestureRecognizer*)p
{
    UIWindow *appWindow = [UIApplication sharedApplication].delegate.window;
    CGPoint panPoint = [p locationInView:appWindow];
    
    if(p.state == UIGestureRecognizerStateBegan) {
        self.alpha = 1;
    }else if(p.state == UIGestureRecognizerStateChanged) {
        self.containerWindow.center = CGPointMake(panPoint.x, panPoint.y);
    }else if(p.state == UIGestureRecognizerStateEnded
             || p.state == UIGestureRecognizerStateCancelled) {
        self.alpha = .7;
        
        CGFloat ballWidth = self.frame.size.width;
        CGFloat ballHeight = self.frame.size.height;
        CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;

        CGFloat left = fabs(panPoint.x);
        CGFloat right = fabs(screenWidth - left);
        CGFloat top = fabs(panPoint.y);
        CGFloat bottom = fabs(screenHeight - top);
        
        CGFloat minSpace = 0;
        if (self.leanType == ZYSuspensionViewLeanTypeHorizontal) {
            minSpace = MIN(left, right);
        }else{
            minSpace = MIN(MIN(MIN(top, left), bottom), right);
        }
        CGPoint newCenter = CGPointZero;
        CGFloat targetY = 0;
        
        //Correcting Y
        if (panPoint.y < kVerticalMargin + ballHeight / 2.0) {
            targetY = kVerticalMargin + ballHeight / 2.0;
        }else if (panPoint.y > (screenHeight - ballHeight / 2.0 - kVerticalMargin)) {
            targetY = screenHeight - ballHeight / 2.0 - kVerticalMargin;
        }else{
            targetY = panPoint.y;
        }
        
        CGFloat centerXSpace = (0.5 - kLeanProportion) * ballWidth;
        CGFloat centerYSpace = (0.5 - kLeanProportion) * ballHeight;

        if (minSpace == left) {
            newCenter = CGPointMake(centerXSpace, targetY);
        }else if (minSpace == right) {
            newCenter = CGPointMake(screenWidth - centerXSpace, targetY);
        }else if (minSpace == top) {
            newCenter = CGPointMake(panPoint.x, centerYSpace);
        }else {
            newCenter = CGPointMake(panPoint.x, screenHeight - centerYSpace);
        }
        
        [UIView animateWithDuration:.25 animations:^{
            self.containerWindow.center = newCenter;
        }];
    }else{
        DefLog(@"pan state : %zd", p.state);
    }
}

- (void)click
{
    if([self.delegate respondsToSelector:@selector(suspensionViewClick:)])
    {
        [self.delegate suspensionViewClick:self];
    }
}

#pragma mark - public methods
- (void)show
{
    if ([ZYSuspensionManager windowForKey:self.memoryAddressKey]) return;
    
    ZYSuspensionContainer *backWindow = [[ZYSuspensionContainer alloc] initWithFrame:self.frame];
    backWindow.rootViewController = [[ZYSuspensionViewController alloc] init];
    
    self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.layer.cornerRadius = self.frame.size.width <= self.frame.size.height ? self.frame.size.width / 2.0 : self.frame.size.height / 2.0;
    [backWindow.rootViewController.view addSubview:self];
    [backWindow setHidden:NO];
    [ZYSuspensionManager saveWindow:backWindow forKey:self.memoryAddressKey];
}

- (void)removeFromScreen
{
    [ZYSuspensionManager destroyWindowForKey:self.memoryAddressKey];
}

#pragma mark - getter
- (ZYSuspensionContainer *)containerWindow
{
    return (ZYSuspensionContainer *)[ZYSuspensionManager windowForKey:self.memoryAddressKey];
}

@end
