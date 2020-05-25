//
//  BGQMNavigationController.m
//  企业用电运维云平台
//
//  Created by Acrel on 2020/5/20.
//

#import "BGQMNavigationController.h"

@interface BGQMNavigationController ()

@end

@implementation BGQMNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // Do any additional setup after loading the view.
}

- (void)setupNavigationItems {
//    [super setupNavigationItems];
//    if (!self.title) {
//        self.title = @"照片";
//    }
     self.navigationItem.rightBarButtonItem = [UIBarButtonItem qmui_itemWithTitle:@"返回" target:self action:@selector(backToWebView)];
}

-(void)viewWillAppear:(BOOL)animated{
     self.navigationItem.rightBarButtonItem = [UIBarButtonItem qmui_itemWithTitle:@"返回" target:self action:@selector(backToWebView)];
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
