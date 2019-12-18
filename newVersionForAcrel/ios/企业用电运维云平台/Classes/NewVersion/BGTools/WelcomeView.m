//
//  WelcomeView.m
//  SPDBCreditCardCenter
//
//  Created by newtouch on 14-7-22.
//  Copyright (c) 2014年 wind. All rights reserved.
//

#import "WelcomeView.h"

@implementation WelcomeView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}


-(void)showContentView{
    
    
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kfirstShowApp];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:self.frame];
    scroll.backgroundColor = [UIColor clearColor];
    scroll.delegate = self;
    scroll.pagingEnabled = YES;
    
    for (NSInteger i = 0; i < 3; i ++) {
        UIImageView  *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0 + SCREEN_WIDTH *i, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"WechatIMG190225%ld.jpg",i+1]];
        [scroll addSubview:imageView];
        if(i == 2){
            //            NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"welcomeIndex.html" withExtension:nil];
            //            NSString *ruleStr=[fileURL absoluteString];
            //
            //            myWebView = [[MyWebView alloc]initWithFrame:CGRectMake(0 + SCREEN_WIDTH *i, 0, SCREEN_WIDTH, SCREEN_HEIGHT) requsttUrl:ruleStr];
            //
            //            [myWebView setScalesPageToFit:YES];
            //            myWebView.scrollView.scrollEnabled =NO;
            //            [scroll addSubview:myWebView];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(0 + SCREEN_WIDTH *i, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            [btn addTarget:self action:@selector(hideImage) forControlEvents:UIControlEventTouchUpInside];
            [scroll addSubview:btn];
        }
    }
    scroll.contentSize = CGSizeMake(self.frame.size.width * 3, self.window.frame.size.height);
    [self addSubview:scroll];
    //    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 100, SCREEN_WIDTH, 20)];
    //    pageControl.numberOfPages = 3;
    //    pageControl.currentPage = 0;
    //    pageControl.pageIndicatorTintColor =[UIColor lightGrayColor];
    //    [self addSubview:pageControl];
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollView.contentOffset.x > scrollView.frame.size.width * 2 ) {
        [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width * 2, 0) animated:NO];
        
    }else if (scrollView.contentOffset.x < 0 ){
        [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
    
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControl.currentPage = (scrollView.contentOffset.x / self.frame.size.width);
    if(pageControl.currentPage ==2 && pageControl.currentPage!=tempPage){
//        [myWebView reloadRequest];
        tempPage =pageControl.currentPage;
    }
    
}

-(void)hideImage{
    //    [self.delegate loadrequest];
    [self removeFromSuperview];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
