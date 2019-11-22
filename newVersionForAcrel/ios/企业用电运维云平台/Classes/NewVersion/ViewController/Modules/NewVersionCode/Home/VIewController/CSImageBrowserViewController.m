////
////  CSImageBrowserViewController.m
////  CloudService
////
////  Created by feitian on 15/12/23.
////  Copyright © 2015年 com.Ideal. All rights reserved.
////
//
//#import "CSImageBrowserViewController.h"
//
//@interface CSImageBrowserViewController ()<GreetViewDeletage,UIGestureRecognizerDelegate>{
//
//}
//@property(nonatomic,strong)UIButton *leftBtn;
//
//@end
//
//@implementation CSImageBrowserViewController
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
//        self.automaticallyAdjustsScrollViewInsets = NO;
//    }
//    self.view.backgroundColor = [UIColor blackColor];
//    [self.homeButton setImage:nil forState:UIControlStateNormal];
//
//    GreetView *grView = [[GreetView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) andImageModels:self.imageModelArr];
//    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
//    singleTap.delegate = self;
//    [self.view addGestureRecognizer:singleTap];
//    grView.greetDeletage = self;
//    [grView seekToImageIndex:_currentIndex];
//    [self.view addSubview:grView];
//
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//
//    return YES;
//
//}
//
//-(void)handleSingleTap:(UITapGestureRecognizer *)sender
//
//{
//
//    CGPoint point = [sender locationInView:self.view];
//
//    NSLog(@"handleSingleTap!pointx:%f,y:%f",point.x,point.y);
//    [self popViewControllerAnimation:YES];
//
//}
//
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//-(void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    self.navigationController.navigationBarHidden = YES;
//}
//-(void)viewWillDisappear:(BOOL)animated{
//    self.navigationController.navigationBarHidden = NO;
//    [super viewWillDisappear:animated];
//}
//#pragma mark-GreetViewDelegate
//
//-(void)GreetViewCurrentShowImageIndex:(NSInteger)index andTotalIndex:(NSInteger)totalIndex{
//    self.title =[NSString stringWithFormat:@"%ld / %ld",index+1,totalIndex];
//}
//
//-(UIButton *)leftBtn{
//    if (_leftBtn == nil) {
//        _leftBtn = [SKControllerTools createButtonWithFrame:CGRectMake(16, 24, 40, 40) normalBGImageName:@"back2" selectBGImageName:@"back2" Target:self Action:@selector(backButtonAction:) Title:nil];
//        [_leftBtn setBackgroundColor:[UIColor clearColor]];
//        _leftBtn.alpha = 0.4;
//    }
//    return _leftBtn;
//}
//-(void)backButtonAction:(UIButton *)backBtn{
//    [self popViewControllerAnimation:YES];
//}
//
//@end
