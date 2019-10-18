//
//  BGHomeViewController.m
//  变电所运维
//
//  Created by Acrel on 2019/5/16.
//

#import "BGHomeViewController.h"
#import "PopoverView.h"
#import "BGLoginViewController.h"
#import "CustomNavigationController.h"
#import "BGHeadPortraitViewController.h"
//#import "YPAMapChooseViewController.h"
//#import "SingleLocDemoViewController.h"
#import "BGBaiduMapViewController.h"


@interface BGHomeViewController ()<UIImagePickerControllerDelegate>

@end

@implementation BGHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.homeButton.hidden = NO;
    QMUIButton *btn = [[QMUIButton alloc] initWithFrame:CGRectMake(50, 100, 140, 40)];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn setTitle:[NSString stringWithFormat:@"版本"] forState:UIControlStateNormal];
    [btn sizeToFit];
    [self.view addSubview:btn];
    [self.homeButton setImage:[UIImage imageNamed:@"gengduo"] forState:UIControlStateNormal];
    // Do any additional setup after loading the view from its nib.
}

- (void)moreButtonAction:(UIButton *)moreBtn {
    [self showMoreButtonMenu];
}

#pragma mark - MoreButtonMenu
-(void)showMoreButtonMenu{
    
//    if (menuArray && menuArray.count && [menuArray isKindOfClass:[NSArray class]] ) {
//        CGPoint startPoint = CGPointMake(self.view.bounds.size.width -37, BGSafeAreaTopHeight-6);
//    PopoverView *pop = [[PopoverView alloc] initWithPoint:startPoint titleAndImageInfoArray:@[@{@"title":@"退出登录",@"image":@"fstz",@"code":@"1001"},@{@"title":@"上传图片",@"image":@"fqdb",@"code":@"1002"},@{@"title":@"跳转Web",@"image":@"fqlt",@"code":@"1003"},@{@"title":@"上传位置",@"image":@"fstz",@"code":@"1004"}]];
//        __weak typeof(self) weakSelf = self;
//        pop.selectRowAtIndex = ^(NSInteger index,NSDictionary *selectedInfo){
//            NSString *code = selectedInfo[@"code"];
//            if ([code isEqualToString:@"1001"]) {
//                DefLog(@"点击了登出");
//                //登录接口
//                [NetService bg_postWithPath:@"http://192.168.112.212:8080/web_manage/addGoods.do?name=xuhang" params:nil success:^(id respObjc) {
//                    //登出接口
//                    DefLog(@"%@",respObjc);
//                } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
//                    DefLog(@"%@",errorMsg);
//                }];
//                BGLoginViewController *loginVC = [[BGLoginViewController alloc] initWithNibName:@"BGLoginViewController" bundle:nil];
//                UINavigationController *naVC = [[CustomNavigationController alloc] initWithRootViewController:loginVC];
//                [UIApplication sharedApplication].keyWindow.rootViewController = naVC;
//            }else if([code isEqualToString:@"1002"]){
//                BGHeadPortraitViewController *hpvc = [[BGHeadPortraitViewController alloc] initWithNibName:@"BGHeadPortraitViewController" bundle:nil];
//                [weakSelf pushViewController:hpvc animation:YES];
//            }else if([code isEqualToString:@"1003"]){
//
//            }else if([code isEqualToString:@"1004"]){
//                //显示高德地理位置
//                YPAMapChooseViewController *locationC = [[YPAMapChooseViewController alloc] initWithNibName:@"YPAMapChooseViewController" bundle:nil];
////                __weak typeof(self) weakSelf = self;
//                [locationC setChooseLocationBlock:^(NSDictionary *locationData) {
//                    //                    [weakSelf showNothing:YES];
////                    [self sendLocationData:locationData];
//
//                }];
//                [weakSelf pushViewController:locationC animation:YES];
//                CustomNavigationController *locationNav = [[CustomNavigationController alloc] initWithRootViewController:locationC];
//                [self presentViewController:locationNav animated:YES completion:nil];
                //显示百度地理位置
//                BGBaiduMapViewController *locVC = [[BGBaiduMapViewController alloc] initWithNibName:@"BGBaiduMapViewController" bundle:nil];
//                [weakSelf pushViewController:locVC animation:YES];
//            }
//        };
//        [pop show];
        
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
