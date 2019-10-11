//
//  BGQMAlarmViewController.m
//  变电所运维
//
//  Created by Acrel on 2019/6/3.
//  
//

#import "BGQMAlarmViewController.h"
#import "GHDropMenu.h"
#import "GHDropMenuModel.h"

@interface BGQMAlarmViewController ()<GHDropMenuDelegate>
@property (nonatomic , strong) GHDropMenu *dropMenu;
@property (nonatomic , strong) GHDropMenuModel *configuration;

@end

@implementation BGQMAlarmViewController

- (void)didInitialize {
    [super didInitialize];
    // init 时做的事情请写在这里
}

- (void)initSubviews {
    [super initSubviews];
    // 对 subviews 的初始化写在这里
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [[BGQMToolHelper bg_sharedInstance] bg_setTabbarBadge:YES withItemsNumber:1 withShowText:@"12"];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"筛选" style:UIBarButtonItemStylePlain target:self action:@selector(clickItem)];
//
//    GHDropMenuModel *configuration = [[GHDropMenuModel alloc]init];
//
//    configuration.titles = [configuration creaFilterDropMenuData];
//    /** 配置筛选菜单是否记录用户选中 默认NO */
//    configuration.recordSeleted = NO;
//    self.configuration = configuration;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    self.title = DefLocalizedString(@"Alarm");
}

- (void)clickItem {
    
//    weakself(self);
//    GHDropMenu *dropMenu = [GHDropMenu creatDropFilterMenuWidthConfiguration:self.configuration dropMenuTagArrayBlock:^(NSArray * _Nonnull tagArray) {
//        [weakSelf getStrWith:tagArray];
//
//    }];
//    dropMenu.titleSeletedImageName = @"up_normal";
//    dropMenu.titleNormalImageName = @"down_normal";
//    dropMenu.delegate = self;
//    dropMenu.durationTime = 0.5;
//    self.dropMenu = dropMenu;
//    [dropMenu show];
}


#pragma mark - 代理方法
- (void)dropMenu:(GHDropMenu *)dropMenu dropMenuTitleModel:(GHDropMenuModel *)dropMenuTitleModel {
    self.navigationItem.title = [NSString stringWithFormat:@"筛选结果: %@",dropMenuTitleModel.title];
}

- (void)dropMenu:(GHDropMenu *)dropMenu tagArray:(NSArray *)tagArray {
    [self getStrWith:tagArray];
}

- (void)getStrWith: (NSArray *)tagArray {
    NSMutableString *string = [NSMutableString string];
    if (tagArray.count) {
        for (GHDropMenuModel *dropMenuTagModel in tagArray) {
            if (dropMenuTagModel.tagSeleted) {
                if (dropMenuTagModel.tagName.length) {
                    [string appendFormat:@"%@",dropMenuTagModel.tagName];
                }
            }
            if (dropMenuTagModel.maxPrice.length) {
                [string appendFormat:@"最大价格%@",dropMenuTagModel.maxPrice];
            }
            if (dropMenuTagModel.minPrice.length) {
                [string appendFormat:@"最小价格%@",dropMenuTagModel.minPrice];
            }
            if (dropMenuTagModel.singleInput.length) {
                [string appendFormat:@"%@",dropMenuTagModel.singleInput];
            }
            if (dropMenuTagModel.beginTime.length) {
                [string appendFormat:@"开始时间%@",dropMenuTagModel.beginTime];
            }
            if (dropMenuTagModel.endTime.length) {
                [string appendFormat:@"结束时间%@",dropMenuTagModel.endTime];
            }
        }
    }
    self.navigationItem.title = [NSString stringWithFormat:@"筛选结果: %@",string];
}
@end
