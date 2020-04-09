//
//  BGQMHomeViewController.m
//  变电所运维
//
//  Created by Acrel on 2019/6/3.
//  
//

#import "BGQMHomeViewController.h"
#import "MSCycleScrollView.h"
#import "BGQMloginViewController.h"
#import "MSExampleDotView.h"
#import "CustomGrid.h"
#import "BGQMMoveBtnViewController.h"
#import "BGQMSingletonManager.h"
#import "BGQMSelectSubstationTVC.h"
#import "BGQMNewHomeTableViewController.h"
#import "BGUIWebViewController.h"
#import "BGCheckAppVersionMgr.h"
#import "BGLoginViewController.h"
#import "CustomNavigationController.h"
#import "YYServiceManager.h"


/*
 监控系统 345
 设备管理 346
 待办事项 347
 巡视记录 348
 缺陷管理 349
 文档管理 350
 用户报告 351
 设备控制 352
 */

@interface BGQMHomeViewController ()<MSCycleScrollViewDelegate,CustomGridDelegate,UIScrollViewDelegate,BGQMSelectSubstationTVCDelegate>
{
    BOOL isSelected;
    BOOL contain;
    //是否可跳转应用对应的详细页面
    BOOL isSkip;
    UIScrollView * myScrollView;
    
    //选中格子的起始位置
    CGPoint startPoint;
    //选中格子的起始坐标位置
    CGPoint originPoint;
    
    UIImage *normalImage;
    UIImage *highlightedImage;
    UIImage *deleteIconImage;
    NSArray *homeList;
}
@end

@implementation BGQMHomeViewController{
    NSArray *_imagesURLStrings;
    MSCycleScrollView *_customCellScrollViewDemo;
    UIScrollView *_homeScrollView;
    MSCycleScrollView *_cycleScrollView2;
    
}

- (void)didInitialize {
    [super didInitialize];
    self.gridListArray = [[NSMutableArray alloc] initWithCapacity:12];

    self.showGridArray = [[NSMutableArray alloc] initWithCapacity:12];
    self.showGridImageArray = [[NSMutableArray alloc] initWithCapacity:12];
    self.showGridIDArray = [[NSMutableArray alloc] initWithCapacity:12];

    self.moreGridIdArray = [[NSMutableArray alloc] initWithCapacity:12];
    self.moreGridTitleArray = [[NSMutableArray alloc]initWithCapacity:12];
    self.moreGridImageArray = [[NSMutableArray alloc]initWithCapacity:12];
    
    // init 时做的事情请写在这里
}

- (void)initSubviews {
    [super initSubviews];
    // 对 subviews 的初始化写在这里
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = DefLocalizedString(@"Home");
    _homeScrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    _homeScrollView.contentSize = CGSizeMake(ScreenWidth, GridHeight * PerColumGridCount + 100);
    _homeScrollView.showsVerticalScrollIndicator = NO;

    [self.view addSubview:_homeScrollView];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"筛选变电所" style:UIBarButtonItemStylePlain target:self action:@selector(clickLeftBtn)];
//    [self creatView];
    [self addselfHeadView];
    //检查版本升级 迭代更新
    [[BGCheckAppVersionMgr sharedInstance] isUpdataApp:kAppleId andCompelete:^(NSString * _Nonnull respObjc) {
        
    }];
    //配置小红点
//    [[BGQMToolHelper bg_sharedInstance] bg_setTabbarBadge:YES withItemsNumber:1 withShowText:@"13"];
}

-(void)addselfHeadView{
    //背景图
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bghomeheadpic"]];
    if(isPad){
        self.imageView.frame =CGRectMake(0, 0, SCREEN_WIDTH, 280);
    }else{
        self.imageView.frame =CGRectMake(0, 0, SCREEN_WIDTH, ScreenHeight/3.5);
    }
    [_homeScrollView addSubview:self.imageView];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    isSelected = NO;
    self.navigationController.navigationBarHidden = YES;
    if (@available(iOS 11.0, *)) {
        _homeScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bigShadow"] forBarMetrics:UIBarMetricsCompact];
//    //compact：及时更新背景样式,让导航条彻底透明，不显示底部那条线。 maskToBounds：不让透明图片影响状态栏
//    self.navigationController.navigationBar.layer.masksToBounds = YES;
    
    [self createHomeData];
    UserManager *user = [UserManager manager];
    NSArray *uiArray = user.rootMenuData[@"rootMenu"];
    if (uiArray.count>0) {
        [self createDemoData];
        NSMutableArray *titleArr = [BGQMSingletonManager shareInstance].showGridArray;
        NSMutableArray *imageArr = [BGQMSingletonManager shareInstance].showImageGridArray;
        NSMutableArray *idArr = [BGQMSingletonManager shareInstance].showGridIDArray;
        _showGridArray = [[NSMutableArray alloc]initWithArray:titleArr];
        _showGridImageArray = [[NSMutableArray alloc]initWithArray:imageArr];
        _showGridIDArray = [[NSMutableArray alloc]initWithArray:idArr];
        [myScrollView removeFromSuperview];
        [self.gridListView removeFromSuperview];
        [self creatMyScrollView];
        //报警查询方法
        [self JudgeWhetherGetUnreadWarningMessage];
    }
}

-(void)JudgeWhetherGetUnreadWarningMessage{
    UserManager *user = [UserManager manager];
    if (!user.versionNo) {
        return;
    }
    if ([user.versionNo isEqualToString:@"v5"]) {
        [NetService bg_getWithTokenWithPath:@"/getUnConfirmedEventsNum" params:@{} success:^(id respObjc) {
               DefLog(@"%@",respObjc);
            NSDictionary *dict = [respObjc objectForKeyNotNull:kdata];
               NSArray *array = [dict objectForKeyNotNull:@"unConfirmedEventsNum"];
               if (array) {
                   NSInteger sum = 0;
                   for (NSDictionary *warningDic in array) {
                       NSInteger count = [[warningDic bg_StringForKeyNotNull:@"unConfirmNum"] integerValue];
                       sum += count;
                   }
                   if (sum>0) {
                       [[BGQMToolHelper bg_sharedInstance] bg_setTabbarBadge:YES withItemsNumber:1 withShowText:[NSString stringWithFormat:@"%ld",(long)sum]];
                   }else{
                       [[BGQMToolHelper bg_sharedInstance] bg_setTabbarBadge:NO withItemsNumber:1 withShowText:@""];
                   }
               }
           } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
               
           }];
    }else{
        [NetService bg_getWithTokenWithPath:@"/getUnreadWarningMessage" params:@{} success:^(id respObjc) {
            DefLog(@"%@",respObjc);
            NSArray *array = [respObjc objectForKeyNotNull:kdata];
            if (array) {
                NSInteger sum = 0;
                for (NSDictionary *warningDic in array) {
                    NSInteger count = [[warningDic bg_StringForKeyNotNull:@"count"] integerValue];
                    sum += count;
                }
                if (sum>0) {
                    [[BGQMToolHelper bg_sharedInstance] bg_setTabbarBadge:YES withItemsNumber:1 withShowText:[NSString stringWithFormat:@"%ld",(long)sum]];
                }else{
                    [[BGQMToolHelper bg_sharedInstance] bg_setTabbarBadge:NO withItemsNumber:1 withShowText:@""];
                }
            }
        } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
            
        }];
    }
}

//更新数据
-(void)createHomeData{
    BGWeakSelf;
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    UserManager *user = [UserManager manager];
    NSNumber *language = [NSNumber numberWithBool:NO];
    NSString *languageId = @"1";
    if (user.selectlanageArr && user.selectlanageArr.count>0) {
        for (NSDictionary *dic in user.selectlanageArr) {
                if ([dic[@"click"] integerValue] == 1) {
                    languageId = dic[@"id"];
                }
            }
            if ([languageId integerValue] == 1) {
                language = [NSNumber numberWithBool:NO];
            } else {
                language = [NSNumber numberWithBool:YES];
            }
    }
    [NetService bg_getWithTokenWithPath:BGGetRootMenu params:@{@"english":language} success:^(id respObjc) {
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UserManager *user = [UserManager manager];
        NSDictionary *rootData = [respObjc objectForKeyNotNull:kdata];
        if (rootData) {
           NSArray *menuArr = [rootData objectForKeyNotNull:@"rootMenu"];
           if (!menuArr || !menuArr.count) {
               DefQuickAlert(@"为确保正常显示，请前往网页端配置APP菜单功能，并至少添加一个tab页功能", nil);
               //确认处理
              NSUserDefaults *defatluts = [NSUserDefaults standardUserDefaults];
             NSDictionary *dictionary = [defatluts dictionaryRepresentation];
             for (NSString *key in [dictionary allKeys]){
                 if ([key isEqualToString:@"orderListUrl"]) {
                     continue;
                 }else if ([key isEqualToString:kaccount]) {
                     continue;
                 }else if ([key isEqualToString:kpassword]) {
                     continue;
                 }else if ([key isEqualToString:@"isSavePwd"]){
                     continue;
                 }else if ([key isEqualToString:@"orderUrlArray"]){
                     continue;
                 }else if ([key isEqualToString:@"selectlanageArr"]){
                     continue;
                 }else if ([key isEqualToString:@"myLanguage"]){
                     continue;
                 }
                 else{
                     [defatluts removeObjectForKey:key];
                     [defatluts synchronize];
                 }
             }
               // 停止采集轨迹
          if ([YYServiceManager defaultManager].isGatherStarted) {
              [YYServiceManager defaultManager].isGatherStarted = NO;
             
              [[YYServiceManager defaultManager] stopGather];
          }
             BGLoginViewController *loginVC = [[BGLoginViewController alloc] initWithNibName:@"BGLoginViewController" bundle:nil];
             UINavigationController *naVC = [[CustomNavigationController alloc] initWithRootViewController:loginVC];
             [UIApplication sharedApplication].keyWindow.rootViewController = naVC;
             
               return ;
           }
        }
        user.rootMenuData = respObjc[kdata];
        NSString *imageSysBaseUrl = respObjc[kdata][@"iconUrl"];
        [DefNSUD setObject:imageSysBaseUrl forKey:@"systemImageUrlstr"];
        DefNSUDSynchronize
        
        [weakSelf createDemoData];
        NSMutableArray *titleArr = [BGQMSingletonManager shareInstance].showGridArray;
        NSMutableArray *imageArr = [BGQMSingletonManager shareInstance].showImageGridArray;
        NSMutableArray *idArr = [BGQMSingletonManager shareInstance].showGridIDArray;
        _showGridArray = [[NSMutableArray alloc]initWithArray:titleArr];
        _showGridImageArray = [[NSMutableArray alloc]initWithArray:imageArr];
        _showGridIDArray = [[NSMutableArray alloc]initWithArray:idArr];
        [myScrollView removeFromSuperview];
        [weakSelf.gridListView removeFromSuperview];
        [weakSelf creatMyScrollView];
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

//更新数据
-(void)updateHomeData{
    BGWeakSelf;
    UserManager *user = [UserManager manager];
    NSNumber *language = [NSNumber numberWithBool:NO];
    NSString *languageId = @"1";
    if (user.selectlanageArr && user.selectlanageArr.count>0) {
        for (NSDictionary *dic in user.selectlanageArr) {
                if ([dic[@"click"] integerValue] == 1) {
                    languageId = dic[@"id"];
                }
            }
            if ([languageId integerValue] == 1) {
                language = [NSNumber numberWithBool:NO];
            } else {
                language = [NSNumber numberWithBool:YES];
            }
    }
        
    [NetService bg_getWithTokenWithPath:BGGetRootMenu params:@{@"english":language} success:^(id respObjc) {
        UserManager *user = [UserManager manager];
        NSDictionary *rootData = [respObjc objectForKeyNotNull:kdata];
       if (rootData) {
           NSArray *menuArr = [rootData objectForKeyNotNull:@"rootMenu"];
           if (!menuArr || !menuArr.count) {
               DefQuickAlert(@"为确保正常显示，请前往网页端配置APP菜单功能，并至少添加一个tab页功能", nil);
               NSUserDefaults *defatluts = [NSUserDefaults standardUserDefaults];
               NSDictionary *dictionary = [defatluts dictionaryRepresentation];
               for (NSString *key in [dictionary allKeys]){
                   if ([key isEqualToString:@"orderListUrl"]) {
                       continue;
                   }else if ([key isEqualToString:kaccount]) {
                       continue;
                   }else if ([key isEqualToString:kpassword]) {
                       continue;
                   }else if ([key isEqualToString:@"isSavePwd"]){
                       continue;
                   }else if ([key isEqualToString:@"orderUrlArray"]){
                       continue;
                   }else if ([key isEqualToString:@"selectlanageArr"]){
                       continue;
                   }else if ([key isEqualToString:@"myLanguage"]){
                       continue;
                   }
                   else{
                       [defatluts removeObjectForKey:key];
                       [defatluts synchronize];
                   }
               }
               // 停止采集轨迹
              if ([YYServiceManager defaultManager].isGatherStarted) {
                  [YYServiceManager defaultManager].isGatherStarted = NO;
                 
                  [[YYServiceManager defaultManager] stopGather];
              }
               BGLoginViewController *loginVC = [[BGLoginViewController alloc] initWithNibName:@"BGLoginViewController" bundle:nil];
               UINavigationController *naVC = [[CustomNavigationController alloc] initWithRootViewController:loginVC];
               [UIApplication sharedApplication].keyWindow.rootViewController = naVC;
               
               return ;
           }
           
       }
        user.rootMenuData = respObjc[kdata];
        NSString *imageSysBaseUrl = respObjc[kdata][@"iconUrl"];
        [DefNSUD setObject:imageSysBaseUrl forKey:@"systemImageUrlstr"];
        DefNSUDSynchronize
        
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
        
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
//    self.tabBarController.tabBar.hidden = YES;
//    self.tabBarController.hidesBottomBarWhenPushed = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)setupNavigationItems {
    [super setupNavigationItems];

}

- (void)creatView{
//    _homeScrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
//    _homeScrollView.contentSize = CGSizeMake(self.view.frame.size.width, GridHeight * PerColumGridCount + 180);
//
//    [self.view addSubview:_homeScrollView];
    // 对 self.view 的操作写在这里
    // 情景一：采用本地图片实现
//    NSArray *imageNames = @[@"timg1.jpeg",
//                            @"timg2.jpeg",
//                            @"timg3.jpeg",
//                            @"timg4.jpeg",
//                            @"timg7" // 本地图片请填写全名
//                            ];
//
//    // 情景二：采用网络图片实现
//    NSArray *imagesURLStrings = @[
//                                  @"http://c.hiphotos.baidu.com/image/w%3D400/sign=c2318ff84334970a4773112fa5c8d1c0/b7fd5266d0160924c1fae5ccd60735fae7cd340d.jpg",
//                                  @"https://ss0.baidu.com/-Po3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a41eb338dd33c895a62bcb3bb72e47c2/5fdf8db1cb134954a2192ccb524e9258d1094a1e.jpg",
//                                  @"http://c.hiphotos.baidu.com/image/w%3D400/sign=c2318ff84334970a4773112fa5c8d1c0/b7fd5266d0160924c1fae5ccd60735fae7cd340d.jpg"
//                                  ];
//    _imagesURLStrings = imagesURLStrings;
//    // 情景三：图片配文字
//    NSArray *titles = @[
//                        @"测试标题说明0",
//                        @"测试标题说明1",
//                        @"测试标题说明2",
//                        @"测试标题说明3",
//                        @"测试标题说明4"
//                        ];
//
//    CGFloat w = self.view.bounds.size.width;
//    // 本地加载 --- 创建不带标题的图片轮播器
//    // 网络加载 --- 创建带标题的图片轮播器
//    //    disableScrollGesture可以设置禁止拖动
//    _cycleScrollView2 = [MSCycleScrollView cycleViewWithFrame:CGRectMake(0, 0, w, 180) delegate:self placeholderImage:[UIImage imageNamed:@"placeholder"]];
//    _cycleScrollView2.imageUrls = _imagesURLStrings;
//    _cycleScrollView2.pageControlStyle = kMSPageContolStyleAnimated;
//    _cycleScrollView2.pageControlAliment = kMSPageContolAlimentRight;
//    _cycleScrollView2.titles = titles;
//    _cycleScrollView2.dotViewClass = [MSExampleDotView class];
//    _cycleScrollView2.pageControlDotSize = CGSizeMake(6, 6);
//    _cycleScrollView2.spacingBetweenDots = 10;
//    [_homeScrollView addSubview:_cycleScrollView2];

}

- (void)creatMyScrollView
{
#pragma mark - 可拖动的按钮
    //隐藏白色背景
//    normalImage = [UIImage imageNamed:@"app_item_bg"];
//    highlightedImage = [UIImage imageNamed:@"app_item_bg"];
    deleteIconImage = [UIImage imageNamed:@"app_item_plus"];

//    myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 180+64, ScreenWidth, ScreenHeight-64-180)];
//    myScrollView.contentInset = UIEdgeInsetsMake(0, 0, ScreenHeight*2, 0);
//    myScrollView.backgroundColor = [UIColor clearColor];
//    myScrollView.delegate = self;
//    [self.view addSubview:myScrollView];

    _gridListView = [[UIView alloc] init];
    [_gridListView setFrame:CGRectMake(0, self.imageView.frame.size.height, ScreenWidth, GridHeight * PerColumGridCount)];
//    [_gridListView setBackgroundColor:[UIColor whiteColor]];
    [_gridListView setBackgroundColor:[UIColor clearColor]];
    [_homeScrollView addSubview:_gridListView];

    [self.gridListArray removeAllObjects];
    for (NSInteger index = 0; index < [_showGridArray count]; index++)
    {
        NSString *gridTitle = _showGridArray[index];
        NSString *gridImage = _showGridImageArray[index];
        NSInteger gridID = [self.showGridIDArray[index] integerValue];
        BOOL isAddDelete = YES;
        if ([gridTitle isEqualToString:@"更多"]) {
            isAddDelete = NO;
        }
        NSString *number;
        if (gridID == 347) {
            number = [UserManager manager].privateUnreadNumStr;
        }else{
            number = @"0";
        }
        CustomGrid *gridItem = [[CustomGrid alloc] initWithFrame:CGRectZero title:gridTitle normalImage:normalImage highlightedImage:highlightedImage gridId:gridID atIndex:index isAddDelete:isAddDelete deleteIcon:deleteIconImage withIconImage:gridImage withBadgeNumber:number];
        [gridItem.layer setMasksToBounds:YES];
        [gridItem.layer setBorderWidth:0];
        gridItem.delegate = self;
        gridItem.gridTitle = gridTitle;
        gridItem.gridImageString = gridImage;
        gridItem.gridId = gridID;
        [self.gridListView addSubview:gridItem];
        [self.gridListArray addObject:gridItem];
    }

    //for test print out
    for (NSInteger i = 0; i < _gridListArray.count; i++) {
        CustomGrid *gridItem = _gridListArray[i];
        gridItem.gridCenterPoint = gridItem.center;
    }
    
//    self.navigationController.navigationBarHidden = YES;
//    self.navigationController.navigationBar.hidden = YES;
    
//    更新页面
    [self getNewData];
}

#pragma mark --- 更新页面
-(void) getNewData
{
    NSInteger gridHeight;
    if (self.showGridArray.count % 3 == 0) {
        gridHeight = 123 * self.showGridArray.count/3;
    }
    else{
        gridHeight = 123 * (self.showGridArray.count/3+1);
    }
    myScrollView.contentInset = UIEdgeInsetsMake(0, 0, gridHeight, 0);
}

#pragma mark - 可拖动按钮
#pragma mark - 点击格子
- (void)gridItemDidClicked:(CustomGrid *)gridItem
{
    DefLog(@"您点击的格子Tag是：%ld", (long)gridItem.gridId);
    isSkip = YES;
    if (gridItem.gridId == 347) {
        [UserManager manager].privateUnreadNumStr = @"0";
    }
    //查看是否有选中的格子，并且比较点击的格子是否就是选中的格子
    for (NSInteger i = 0; i < [_gridListArray count]; i++) {
        CustomGrid *item = _gridListArray[i];
        if (item.isChecked) {
            item.isChecked = NO;
            item.isMove = NO;
            isSelected = NO;
            isSkip = NO;
            
            //隐藏删除图标
            UIButton *removeBtn = (UIButton *)[self.gridListView viewWithTag:item.gridId];
            removeBtn.hidden = YES;
            [item setBackgroundImage:normalImage forState:UIControlStateNormal];

            if (gridItem.gridId == 0) {
                isSkip = YES;
            }
            //            break;
        }
        //        else if (item.isChecked && item.gridId == gridItem.gridId) {
        //            item.isChecked = NO;
        //            item.isMove = NO;
        //            isSelected = NO;
        //            isSkip = NO;
        //
        //            //隐藏删除图标
        //            UIButton *removeBtn = (UIButton *)[self.gridListView viewWithTag:gridItem.gridId];
        //            removeBtn.hidden = YES;
        //            [item setBackgroundImage:normalImage forState:UIControlStateNormal];
        //
        //            if (gridItem.gridId == 0) {
        //                isSkip = YES;
        //            }
        //        }
    }

    if (isSkip) {
        [self itemAction:gridItem.gridTitle andClickId:gridItem.gridId];
    }
}

#pragma mark - 删除格子
- (void)gridItemDidDeleteClicked:(UIButton *)deleteButton
{
    DefLog(@"您删除的格子是GridId：%ld", (long)deleteButton.tag);
    for (NSInteger i = 0; i < _gridListArray.count; i++) {
        CustomGrid *removeGrid = _gridListArray[i];
        if (removeGrid.gridId == deleteButton.tag) {
            [removeGrid removeFromSuperview];
            NSInteger count = _gridListArray.count - 1;
            for (NSInteger index = removeGrid.gridIndex; index < count; index++) {
                CustomGrid *preGrid = _gridListArray[index];
                CustomGrid *nextGrid = _gridListArray[index+1];
                [UIView animateWithDuration:0.5 animations:^{
                    nextGrid.center = preGrid.gridCenterPoint;
                }];
                nextGrid.gridIndex = index;
            }
            //排列格子顺序和更新格子坐标信息
            [self sortGridList];

            [_gridListArray removeObjectAtIndex:removeGrid.gridIndex];

            NSString *gridTitle = removeGrid.gridTitle;
            NSString *gridImage = removeGrid.gridImageString;
            NSString *gridID = [NSString stringWithFormat:@"%ld", (long)removeGrid.gridId];
            //删除的应用添加到更多应用数组
            [_moreGridTitleArray addObject:gridTitle];
            [_moreGridImageArray addObject:gridImage];
            [_moreGridIdArray addObject:gridID];

            [_showGridArray removeObject:gridTitle];
            [_showGridImageArray removeObject:gridImage];
            [_showGridIDArray removeObject:gridID];
        }
    }
    // 保存更新后数组
    [self saveArray];

    //更新页面
    [self getNewData];
}

#pragma mark - 长按格子
- (void)pressGestureStateBegan:(UILongPressGestureRecognizer *)longPressGesture withGridItem:(CustomGrid *) grid
{
    DefLog(@"长按.........");
    DefLog(@"isSelected: %d", isSelected);

    //判断格子是否已经被选中并且是否可移动状态,如果选中就加一个放大的特效
    if (isSelected && grid.isChecked) {
        grid.transform = CGAffineTransformMakeScale(1.1, 1.1);
    }

    //没有一个格子选中的时候
    if (!isSelected) {

        DefLog(@"没有一个格子选中............");
        grid.isChecked = YES;
        grid.isMove = YES;
        isSelected = YES;

        //选中格子的时候显示删除图标
//        UIButton *removeBtn = (UIButton *)[longPressGesture.view viewWithTag:grid.gridId];
//        removeBtn.hidden = NO;

        //获取移动格子的起始位置
        startPoint = [longPressGesture locationInView:longPressGesture.view];
        //获取移动格子的起始位置中心点
        originPoint = grid.center;

        //给选中的格子添加放大的特效
        [UIView animateWithDuration:0.5 animations:^{
            grid.transform = CGAffineTransformMakeScale(1.1, 1.1);
            grid.alpha = 1;
            [grid setBackgroundImage:highlightedImage forState:UIControlStateNormal];
        }];
    }
}

#pragma mark --- 拖动位置
- (void)pressGestureStateChangedWithPoint:(CGPoint) gridPoint gridItem:(CustomGrid *) gridItem
{
    if (isSelected && gridItem.isChecked) {
        //        DefLog(@"UIGestureRecognizerStateChanged.........");

        [_gridListView bringSubviewToFront:gridItem];
        //应用移动后的X坐标
        CGFloat deltaX = gridPoint.x - startPoint.x;
        //应用移动后的Y坐标
        CGFloat deltaY = gridPoint.y - startPoint.y;
        //拖动的应用跟随手势移动
        gridItem.center = CGPointMake(gridItem.center.x + deltaX, gridItem.center.y + deltaY);

        //移动的格子索引下标
        NSInteger fromIndex = gridItem.gridIndex;
        //移动到目标格子的索引下标
        NSInteger toIndex = [CustomGrid indexOfPoint:gridItem.center withButton:gridItem gridArray:_gridListArray];

        NSInteger borderIndex = [_showGridIDArray indexOfObject:@"0"];
        DefLog(@"borderIndex: %ld", (long)borderIndex);

        if (toIndex < 0 || toIndex >= borderIndex) {
            contain = NO;
        }else{
            //获取移动到目标格子
            CustomGrid *targetGrid = _gridListArray[toIndex];
            gridItem.center = targetGrid.gridCenterPoint;
            originPoint = targetGrid.gridCenterPoint;
            gridItem.gridIndex = toIndex;

            //判断格子的移动方向，是从后往前还是从前往后拖动
            if ((fromIndex - toIndex) > 0) {
                //                DefLog(@"从后往前拖动格子.......");
                //从移动格子的位置开始，始终获取最后一个格子的索引位置
                NSInteger lastGridIndex = fromIndex;
                for (NSInteger i = toIndex; i < fromIndex; i++) {
                    CustomGrid *lastGrid = _gridListArray[lastGridIndex];
                    CustomGrid *preGrid = _gridListArray[lastGridIndex-1];
                    [UIView animateWithDuration:0.5 animations:^{
                        preGrid.center = lastGrid.gridCenterPoint;
                    }];
                    //实时更新格子的索引下标
                    preGrid.gridIndex = lastGridIndex;
                    lastGridIndex--;
                }
                //排列格子顺序和更新格子坐标信息
                [self sortGridList];

            }else if((fromIndex - toIndex) < 0){
                //从前往后拖动格子
                //                DefLog(@"从前往后拖动格子.......");
                //从移动格子到目标格子之间的所有格子向前移动一格
                for (NSInteger i = fromIndex; i < toIndex; i++) {
                    CustomGrid *topOneGrid = _gridListArray[i];
                    CustomGrid *nextGrid = _gridListArray[i+1];
                    //实时更新格子的索引下标
                    nextGrid.gridIndex = i;
                    [UIView animateWithDuration:0.5 animations:^{
                        nextGrid.center = topOneGrid.gridCenterPoint;
                    }];
                }
                //排列格子顺序和更新格子坐标信息
                [self sortGridList];
            }
        }
    }
}

#pragma mark - 拖动格子结束
- (void)pressGestureStateEnded:(CustomGrid *) gridItem
{
    //    DefLog(@"拖动格子结束.........");
    if (isSelected && gridItem.isChecked) {
        //撤销格子的放大特效
        [UIView animateWithDuration:0.5 animations:^{
            gridItem.transform = CGAffineTransformIdentity;
            gridItem.alpha = 1.0;
            isSelected = NO;
            if (!contain) {
                gridItem.center = originPoint;
            }
        }];

        //排列格子顺序和更新格子坐标信息
        [self sortGridList];
    }
}

- (void)sortGridList
{
    //重新排列数组中存放的格子顺序
    [_gridListArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        CustomGrid *tempGrid1 = (CustomGrid *)obj1;
        CustomGrid *tempGrid2 = (CustomGrid *)obj2;
        return tempGrid1.gridIndex > tempGrid2.gridIndex;
    }];

    //更新所有格子的中心点坐标信息
    for (NSInteger i = 0; i < _gridListArray.count; i++) {
        CustomGrid *gridItem = _gridListArray[i];
        gridItem.gridCenterPoint = gridItem.center;
    }

    // 保存更新后数组
    [self saveArray];
}

#pragma mark - 保存更新后数组
-(void)saveArray
{
    // 保存更新后数组
    NSMutableArray * array1 = [[NSMutableArray alloc]init];
    NSMutableArray * array2 = [[NSMutableArray alloc]init];
    NSMutableArray * array3 = [[NSMutableArray alloc]init];
    for (int i = 0; i < _gridListArray.count; i++) {
        CustomGrid * grid = _gridListArray[i];
        [array1 addObject:grid.gridTitle];
        [array2 addObject:grid.gridImageString];
        [array3 addObject:[NSString stringWithFormat:@"%ld",(long)grid.gridId]];
    }
    NSArray * titleArray = [array1 copy];
    NSArray * imageArray = [array2 copy];
    NSArray * idArray = [array3 copy];

    [BGQMSingletonManager shareInstance].showGridArray = [[NSMutableArray alloc]initWithArray:titleArray];
    [BGQMSingletonManager shareInstance].showImageGridArray = [[NSMutableArray alloc]initWithArray:imageArray];
    [BGQMSingletonManager shareInstance].showGridIDArray = [[NSMutableArray alloc]initWithArray:idArray];

    //主页中的版块更改
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"title"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"image"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"gridID"];

    [[NSUserDefaults standardUserDefaults] setObject:titleArray forKey:@"title"];
    [[NSUserDefaults standardUserDefaults] setObject:imageArray forKey:@"image"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:idArray forKey:@"gridID"];

    //更多页面中的版块存储
    // 保存更新后数组
    NSMutableArray * moreTitleArray = [BGQMSingletonManager shareInstance].moreshowGridArray;
    NSMutableArray * moreImageArray = [BGQMSingletonManager shareInstance].moreshowImageGridArray;
    NSMutableArray * moreIdArray = [BGQMSingletonManager shareInstance].moreshowGridIDArray;
    for (int i = 0; i < self.moreGridTitleArray.count; i++) {
        [moreTitleArray addObject:self.moreGridTitleArray[i]];
        [moreImageArray addObject:self.moreGridImageArray[i]];
        [moreIdArray addObject:self.moreGridIdArray[i]];
    }
    [self.moreGridTitleArray removeAllObjects];
    [self.moreGridImageArray removeAllObjects];
    [self.moreGridIdArray removeAllObjects];

    [BGQMSingletonManager shareInstance].moreshowGridArray = [[NSMutableArray alloc]initWithArray:moreTitleArray];
    [BGQMSingletonManager shareInstance].moreshowImageGridArray = [[NSMutableArray alloc]initWithArray:moreImageArray];
    [BGQMSingletonManager shareInstance].moreshowGridIDArray = [[NSMutableArray alloc]initWithArray:moreIdArray];

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"moretitle"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"moreimage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"moregridID"];

    [[NSUserDefaults standardUserDefaults] setObject:moreTitleArray forKey:@"moretitle"];
    [[NSUserDefaults standardUserDefaults] setObject:moreImageArray forKey:@"moreimage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:moreIdArray forKey:@"moregridID"];
    
    DefLog(@"更新后imageArray = %@ titleArray = %@",imageArray,titleArray);

    NSInteger gridHeight;
    gridHeight = 123 * (self.showGridArray.count/3);

    myScrollView.contentInset = UIEdgeInsetsMake(0, 0, gridHeight + 123, 0);
}

#pragma mark 点击 按钮
- (void)itemAction:(NSString *)title andClickId:(NSInteger)codeId
{
//    componentViewController.isUseOnline = YES;
//                      UserManager *user = [UserManager manager];
//                      //外链H5
//                      if (user.rootMenuData) {
//                         NSString *versionURL = [user.rootMenuData objectForKeyNotNull:@"H5_2"];
//                         componentViewController.showWebType = showWebTypeAlarm;
//                         componentViewController.menuId = [NSString changgeNonulWithString:dic[@"fMenuid"]];
//                         NSString *urlstring = [NSString stringWithFormat:@"/%@/",versionURL];
//                         NSString *str = [GetBaseURL stringByAppendingString:urlstring];
//                         NSString *urlStr = [str stringByAppendingString:fActionurl];
//                         componentViewController.onlineUrlString = urlStr;
//                         componentViewController.hidesBottomBarWhenPushed = NO;
//                         QDNavigationController *componentNavController = [[QDNavigationController alloc] initWithRootViewController:componentViewController];
//                         componentNavController.tabBarItem = [QDUIHelper tabBarItemWithTitle:homePageText image:[UIImageMake(@"bgbaojing") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:UIImageMake(@"bgbaojingselect") tag:1];
//                         AddAccessibilityHint(componentNavController.tabBarItem, @"实时报警系统");
//                         [mainControllers addObject:componentNavController];
//                      }
     //外链H5
    UserManager *user = [UserManager manager];
    NSString *versionURL = [user.rootMenuData objectForKeyNotNull:@"H5_2"];

    if (codeId == 0)
    {
        BGQMMoveBtnViewController *otherView = [[BGQMMoveBtnViewController alloc] init];
        otherView.showMoreGridIdArray = self.moreGridIdArray;
        otherView.showMoreGridTitleArray = self.moreGridTitleArray;
        otherView.showMoreGridImageArray = self.moreGridImageArray;
        [self.navigationController pushViewController:otherView animated:YES];
    }else if (codeId == 345){
        //345 监控系统
        BGQMNewHomeTableViewController *homeSystemVC = [[BGQMNewHomeTableViewController alloc] init];
//        user.rootMenuData 获取首页相关数据
        for (NSDictionary *nodeDic in homeList) {
            if ([nodeDic[@"fCode"] isEqualToString:@"345"]) {
                user.homefMenuid = [NSString changgeNonulWithString:nodeDic[@"fMenuid"]];
            }
        }
        [self.navigationController pushViewController:homeSystemVC animated:YES];
    }
    else if (codeId == 346){
        //346 设备管理
        NSString *fAction;
        NSString *fFunctionurl;
        for (NSDictionary *nodeDic in homeList) {
            if ([nodeDic[@"fCode"] isEqualToString:@"346"]) {
                fAction = [NSString changgeNonulWithString:nodeDic[@"fActionurl"]];
                fFunctionurl = [NSString changgeNonulWithString:nodeDic[@"fFunctionfield"]];
            }
        }
        if (fFunctionurl.length>0) {
            BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"selectedSubstation" ofType:@"html" inDirectory:@"aDevices"];
            nomWebView.isUseOnline = NO;
            nomWebView.localUrlString = filePath;
            nomWebView.showWebType = showWebTypeDevice;
    //        self.tabBarController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:nomWebView animated:YES];
        }else{
            BGUIWebViewController *urlWebView = [[BGUIWebViewController alloc] init];
            urlWebView.isUseOnline = YES;
            if (versionURL.length>0) {
                NSString *urlstring = [NSString stringWithFormat:@"/%@/",versionURL];
                NSString *str = [GetBaseURL stringByAppendingString:urlstring];
                NSString *urlStr = [str stringByAppendingString:fAction];
                urlWebView.onlineUrlString = urlStr;
                urlWebView.showWebType = showWebTypeDevice;
               [self.navigationController pushViewController:urlWebView animated:YES];
             }
        }
    }else if (codeId == 347){
        //347 待办事项
        NSString *fAction;
        NSString *fFunctionurl;
        for (NSDictionary *nodeDic in homeList) {
            if ([nodeDic[@"fCode"] isEqualToString:@"347"]) {
                fAction = [NSString changgeNonulWithString:nodeDic[@"fActionurl"]];
                fFunctionurl = [NSString changgeNonulWithString:nodeDic[@"fFunctionfield"]];
            }
        }
        if (fFunctionurl.length>0) {
           BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
                   NSString *filePath = [[NSBundle mainBundle] pathForResource:@"todoItems" ofType:@"html" inDirectory:@"aDevices"];
           nomWebView.isUseOnline = NO;
           nomWebView.localUrlString = filePath;
           nomWebView.showWebType = showWebTypeDeviceForYY;
           //        self.tabBarController.hidesBottomBarWhenPushed = YES;
           [self.navigationController pushViewController:nomWebView animated:YES];
        }else{
            BGUIWebViewController *urlWebView = [[BGUIWebViewController alloc] init];
            urlWebView.isUseOnline = YES;
            if (versionURL.length>0) {
                NSString *urlstring = [NSString stringWithFormat:@"/%@/",versionURL];
                NSString *str = [GetBaseURL stringByAppendingString:urlstring];
                NSString *urlStr = [str stringByAppendingString:fAction];
                urlWebView.onlineUrlString = urlStr;
                urlWebView.showWebType = showWebTypeDeviceForYY;
               [self.navigationController pushViewController:urlWebView animated:YES];
             }
        }
    }else if (codeId == 348){
        //348 巡视记录
        NSString *fAction;
       NSString *fFunctionurl;
       for (NSDictionary *nodeDic in homeList) {
           if ([nodeDic[@"fCode"] isEqualToString:@"348"]) {
               fAction = [NSString changgeNonulWithString:nodeDic[@"fActionurl"]];
               fFunctionurl = [NSString changgeNonulWithString:nodeDic[@"fFunctionfield"]];
           }
       }
       if (fFunctionurl.length>0) {
          BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
          NSString *filePath = [[NSBundle mainBundle] pathForResource:@"allPatrolRecord" ofType:@"html" inDirectory:@"aDevices"];
          nomWebView.isUseOnline = NO;
          nomWebView.localUrlString = filePath;
          nomWebView.showWebType = showWebTypeDevice;
          //        self.tabBarController.hidesBottomBarWhenPushed = YES;
          [self.navigationController pushViewController:nomWebView animated:YES];
       }else{
           BGUIWebViewController *urlWebView = [[BGUIWebViewController alloc] init];
           urlWebView.isUseOnline = YES;
           if (versionURL.length>0) {
               NSString *urlstring = [NSString stringWithFormat:@"/%@/",versionURL];
               NSString *str = [GetBaseURL stringByAppendingString:urlstring];
               NSString *urlStr = [str stringByAppendingString:fAction];
               urlWebView.onlineUrlString = urlStr;
               urlWebView.showWebType = showWebTypeDevice;
              [self.navigationController pushViewController:urlWebView animated:YES];
            }
       }
    }else if (codeId == 349){
        //349 缺陷管理
          NSString *fAction;
          NSString *fFunctionurl;
          for (NSDictionary *nodeDic in homeList) {
              if ([nodeDic[@"fCode"] isEqualToString:@"349"]) {
                  fAction = [NSString changgeNonulWithString:nodeDic[@"fActionurl"]];
                  fFunctionurl = [NSString changgeNonulWithString:nodeDic[@"fFunctionfield"]];
              }
          }
          if (fFunctionurl.length>0) {
              BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
                NSString *filePath = [[NSBundle mainBundle] pathForResource:@"allDefectPage" ofType:@"html" inDirectory:@"aDevices"];
                nomWebView.isUseOnline = NO;
                nomWebView.localUrlString = filePath;
                nomWebView.showWebType = showWebTypeDevice;
                //        self.tabBarController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:nomWebView animated:YES];
          }else{
              BGUIWebViewController *urlWebView = [[BGUIWebViewController alloc] init];
              urlWebView.isUseOnline = YES;
              if (versionURL.length>0) {
                  NSString *urlstring = [NSString stringWithFormat:@"/%@/",versionURL];
                  NSString *str = [GetBaseURL stringByAppendingString:urlstring];
                  NSString *urlStr = [str stringByAppendingString:fAction];
                  urlWebView.onlineUrlString = urlStr;
                  urlWebView.showWebType = showWebTypeDevice;
                 [self.navigationController pushViewController:urlWebView animated:YES];
               }
          }
       
    }else if (codeId == 350){
        //350 文档管理
          NSString *fAction;
          NSString *fFunctionurl;
          for (NSDictionary *nodeDic in homeList) {
              if ([nodeDic[@"fCode"] isEqualToString:@"350"]) {
                  fAction = [NSString changgeNonulWithString:nodeDic[@"fActionurl"]];
                  fFunctionurl = [NSString changgeNonulWithString:nodeDic[@"fFunctionfield"]];
              }
          }
          if (fFunctionurl.length>0) {
              BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
                NSString *filePath = [[NSBundle mainBundle] pathForResource:@"fileList" ofType:@"html" inDirectory:@"aDevices"];
                nomWebView.isUseOnline = NO;
                nomWebView.localUrlString = filePath;
                nomWebView.showWebType = showWebTypeDevice;
                //        self.tabBarController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:nomWebView animated:YES];
          }else{
              BGUIWebViewController *urlWebView = [[BGUIWebViewController alloc] init];
              urlWebView.isUseOnline = YES;
              if (versionURL.length>0) {
                  NSString *urlstring = [NSString stringWithFormat:@"/%@/",versionURL];
                  NSString *str = [GetBaseURL stringByAppendingString:urlstring];
                  NSString *urlStr = [str stringByAppendingString:fAction];
                  urlWebView.onlineUrlString = urlStr;
                  urlWebView.showWebType = showWebTypeDevice;
                 [self.navigationController pushViewController:urlWebView animated:YES];
               }
          }
    }else if (codeId == 351){
        //351 用户报告
          NSString *fAction;
          NSString *fFunctionurl;
          for (NSDictionary *nodeDic in homeList) {
              if ([nodeDic[@"fCode"] isEqualToString:@"351"]) {
                  fAction = [NSString changgeNonulWithString:nodeDic[@"fActionurl"]];
                  fFunctionurl = [NSString changgeNonulWithString:nodeDic[@"fFunctionfield"]];
              }
          }
          if (fFunctionurl.length>0) {
              BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
                NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CustomReport" ofType:@"html" inDirectory:@"aDevices"];
                nomWebView.isUseOnline = NO;
                nomWebView.localUrlString = filePath;
                nomWebView.showWebType = showWebTypeReport;
                //        self.tabBarController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:nomWebView animated:YES];
          }else{
              BGUIWebViewController *urlWebView = [[BGUIWebViewController alloc] init];
              urlWebView.isUseOnline = YES;
              if (versionURL.length>0) {
                  NSString *urlstring = [NSString stringWithFormat:@"/%@/",versionURL];
                  NSString *str = [GetBaseURL stringByAppendingString:urlstring];
                  NSString *urlStr = [str stringByAppendingString:fAction];
                  urlWebView.onlineUrlString = urlStr;
                  urlWebView.showWebType = showWebTypeReport;
                 [self.navigationController pushViewController:urlWebView animated:YES];
               }
          }
    }else if (codeId == 352){
        //352 设备控制
          NSString *fAction;
          NSString *fFunctionurl;
          NSString *fMenuid = @"";
          for (NSDictionary *nodeDic in homeList) {
              if ([nodeDic[@"fCode"] isEqualToString:@"352"]) {
                  fAction = [NSString changgeNonulWithString:nodeDic[@"fActionurl"]];
                  fFunctionurl = [NSString changgeNonulWithString:nodeDic[@"fFunctionfield"]];
                  fMenuid = [NSString changgeNonulWithString:nodeDic[@"fMenuid"]];
              }
          }
          if (fFunctionurl.length>0) {
              BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
                NSString *filePath = [[NSBundle mainBundle] pathForResource:@"DeviceControlList" ofType:@"html" inDirectory:@"aDevices"];
                nomWebView.isUseOnline = NO;
                nomWebView.localUrlString = filePath;
                nomWebView.showWebType = showWebTypeDevice;
                nomWebView.menuId = fMenuid;
                //        self.tabBarController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:nomWebView animated:YES];
          }else{
              BGUIWebViewController *urlWebView = [[BGUIWebViewController alloc] init];
              urlWebView.isUseOnline = YES;
              if (versionURL.length>0) {
                  NSString *urlstring = [NSString stringWithFormat:@"/%@/",versionURL];
                  NSString *str = [GetBaseURL stringByAppendingString:urlstring];
                  NSString *urlStr = [str stringByAppendingString:fAction];
                  urlWebView.onlineUrlString = urlStr;
                  urlWebView.menuId = fMenuid;
                  urlWebView.showWebType = showWebTypeDevice;
                  [self.navigationController pushViewController:urlWebView animated:YES];
               }
          }
    }
    else {
        DefLog(@"点击了%@格子",title);
    }
}
#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(MSCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    DefLog(@"---点击了第%ld张图片", (long)index);
    [self.navigationController pushViewController:[BGQMloginViewController new] animated:YES];
}

//配置数据
-(void)createDemoData
{
    // 如果数组有改变
    NSArray * titleArray = [[NSArray alloc]init];
    NSArray * imageArray = [[NSArray alloc]init];
    NSArray * idArray = [[NSArray alloc]init];
    titleArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"title"];
    imageArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"image"];
    idArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"gridID"];
    DefLog(@"array = %@",titleArray);

    NSArray * moretitleArray = [[NSArray alloc]init];
    NSArray * moreimageArray = [[NSArray alloc]init];
    NSArray * moreidArray = [[NSArray alloc]init];
    moretitleArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"moretitle"];
    moreimageArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"moreimage"];
    moreidArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"moregridID"];

    // Home按钮数组 体验账号
    [BGQMSingletonManager shareInstance].showGridArray = [[NSMutableArray alloc]initWithCapacity:2];
    [BGQMSingletonManager shareInstance].showImageGridArray = [[NSMutableArray alloc]initWithCapacity:2];

//    [BGQMSingletonManager shareInstance].showGridArray = [NSMutableArray arrayWithObjects:@"监控系统",@"档案管理",@"更多", nil];
//
//    [BGQMSingletonManager shareInstance].showImageGridArray =
//    [NSMutableArray arrayWithObjects:
//     @"dsbgl1",@"dsbgl2",@"icon_grid_floatView", nil];
//
//    [BGQMSingletonManager shareInstance].showGridIDArray =
//    [NSMutableArray arrayWithObjects:
//     @"1000",@"1001",@"0", nil];
    
    UserManager *user = [UserManager manager];
    NSArray *uiArray = user.rootMenuData[@"rootMenu"];
//    homeList = [NSArray new];
    for (NSDictionary *homeDic in uiArray) {
        NSString *fCode = [NSString changgeNonulWithString:homeDic[@"fCode"]];
        if ([fCode isEqualToString:@"homePage"]) {
            homeList = homeDic[@"nodes"];
            NSString *imageStr = [NSString changgeNonulWithString:homeDic[@"fIconurl"]];
                    
            //        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(insideImageOpionX, 8, insideHeight/5*3-15, insideHeight/5*3-15)];
                    
            DefLog(@"%@",[getSystemIconADS stringByAppendingString:imageStr]);
            if (!imageStr.length) {
                self.imageView.image = [UIImage imageNamed:@"bghomeheadpic"];
            }else{
                 [self.imageView sd_setImageWithURL:[NSURL URLWithString:[getSystemIconADS stringByAppendingString:imageStr]] placeholderImage:[UIImage imageNamed:@" bghomeheadpic"]];
            }
        }
    }
    if (homeList.count>0) {
        NSMutableArray *showMutaiArray = [NSMutableArray new];
        NSMutableArray *showfIconurlArr = [NSMutableArray new];
        NSMutableArray *showfParentidArr = [NSMutableArray new];
        for (NSDictionary *showDic in homeList) {
            NSString *showStrTitle = [NSString changgeNonulWithString:showDic[@"fMenuname"]];
            NSString *showStrIcon = [NSString changgeNonulWithString:showDic[@"fIconurl"]];
            NSString *showfCode = [NSString changgeNonulWithString:showDic[@"fCode"]];
            if (!showStrIcon.length) {
                if ([showfCode isEqualToString:@"345"]) {
                    showStrIcon = @"dsbgl1";
                } else if([showfCode isEqualToString:@"346"]){
                    showStrIcon = @"dsbgl2";
                }else if([showfCode isEqualToString:@"347"]){
                    showStrIcon = @"dsbgl3";
                }else if([showfCode isEqualToString:@"348"]){
                    showStrIcon = @"dsbgl4";
                }else if([showfCode isEqualToString:@"349"]){
                    showStrIcon = @"dsbgl5";
                }else if([showfCode isEqualToString:@"350"]){
                    showStrIcon = @"dsbgl6";
                }else if([showfCode isEqualToString:@"351"]){
                    showStrIcon = @"dsbgl7";
                }else if([showfCode isEqualToString:@"352"]){
                    showStrIcon = @"dsbgl8";
                }
            }
            [showMutaiArray addObject:showStrTitle];
            [showfIconurlArr addObject:showStrIcon];
            [showfParentidArr addObject:showfCode];
        }
        
        [BGQMSingletonManager shareInstance].showGridArray = showMutaiArray;
        
        [BGQMSingletonManager shareInstance].showImageGridArray = showfIconurlArr;
    
        [BGQMSingletonManager shareInstance].showGridIDArray = showfParentidArr;
        // 对比数组
        NSMutableString * defaString = [[NSMutableString alloc]init];
        NSMutableString * localString = [[NSMutableString alloc]init];
        
        // 默认
        for (int i = 0; i< [BGQMSingletonManager shareInstance].showGridArray.count; i++) {
            [defaString appendString:[BGQMSingletonManager shareInstance].showGridArray[i]];
            //        DefLog(@"defaString = %@",defaString);
        }
        // 本地
        for (int i = 0; i< titleArray.count; i++) {
            [localString appendString:titleArray[i]];
            //        DefLog(@"localString = %@",localString);
        }
        
        // 如果本地数组有改变
        if (![localString isEqualToString:defaString] && localString.length>2) {
            [BGQMSingletonManager shareInstance].showGridArray = [[NSMutableArray alloc]initWithArray:titleArray];
            [BGQMSingletonManager shareInstance].showImageGridArray = [[NSMutableArray alloc]initWithArray:imageArray];
            [BGQMSingletonManager shareInstance].showGridIDArray = [[NSMutableArray alloc]initWithArray:idArray];
            
            [BGQMSingletonManager shareInstance].moreshowGridArray = [[NSMutableArray alloc]initWithArray:moretitleArray];
            [BGQMSingletonManager shareInstance].moreshowImageGridArray = [[NSMutableArray alloc]initWithArray:moreimageArray];
            [BGQMSingletonManager shareInstance].moreshowGridIDArray = [[NSMutableArray alloc]initWithArray:moreidArray];
        }
    }
    
//    [BGQMSingletonManager shareInstance].showGridArray = [NSMutableArray arrayWithObjects:DefLocalizedString(@"monitorSystem"),DefLocalizedString(@"deviceManage"), nil];
//
//    [BGQMSingletonManager shareInstance].showImageGridArray =
//    [NSMutableArray arrayWithObjects:
//     @"dsbgl1",@"dsbgl2", nil];
//
//    [BGQMSingletonManager shareInstance].showGridIDArray =
//    [NSMutableArray arrayWithObjects:
//     @"1000",@"1001", nil];
    
}

-(void)clickLeftBtn{
    BGQMSelectSubstationTVC *subTVC = [[BGQMSelectSubstationTVC alloc] init];
    subTVC.subTVCdelegate = self;
    [self.navigationController pushViewController:subTVC animated:YES];
}

- (void)sendSubModel:(BGQMSubstationModel *)subModel{
    self.title = subModel.fSubname;
}

@end
