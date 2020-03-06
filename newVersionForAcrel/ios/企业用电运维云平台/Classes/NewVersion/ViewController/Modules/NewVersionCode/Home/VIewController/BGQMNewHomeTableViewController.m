//
//  BGQMNewHomeTableViewController.m
//  变电所运维
//
//  Created by Acrel on 2019/6/12.
//  
//

#import "BGQMNewHomeTableViewController.h"
#import "BGQMSelectSubstationTVC.h"
#import "BGQMHomeTableViewCell.h"
#import "BGQMEventViewController.h"
#import "MJRefreshHeader.h"
#import "MJRefreshNormalHeader.h"
#import "BGQMCategoryListConViewController.h"
#import "BGCheckAppVersionMgr.h"

@interface BGQMNewHomeTableViewController ()<BGQMSelectSubstationTVCDelegate,BGQMHomeTableViewCellDelegate>
@property (nonatomic,weak) BGQMHomeHeadView *headView;
@property (nonatomic,strong) NSArray *listArrData;

@end

@implementation BGQMNewHomeTableViewController

- (void)didInitializeWithStyle:(UITableViewStyle)style {
    [super didInitializeWithStyle:style];
    // init 时做的事情请写在这里
//    真正的首页
}

- (void)initTableView {
    [super initTableView];
    // 对 self.tableView 的操作写在这里
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
//     self.title = DefLocalizedString(@"Home");
    self.title = DefLocalizedString(@"monitorSystem");
    self.view.backgroundColor = COLOR_BACKGROUND;
    // 对 self.view 的操作写在这里
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"筛选变电所" style:UIBarButtonItemStylePlain target:self action:@selector(clickLeftBtn)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"select"] style:UIBarButtonItemStylePlain target:self action:@selector(clickLeftBtn)];
//         self.headView = [[BGQMHomeHeadView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 122+SCREEN_WIDTH/3*2)];
//        NSDictionary *strdicArray = @{ @"headArr":@[@"供电电压等级",@"变压器台数",@"总装机容量",@"总负荷功率",@"测控装置",@"网关"]};
//        self.headView = [[BGQMHomeHeadView alloc] initHomeHeadViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 122+SCREEN_WIDTH/3*2) andHeadData:strdicArray];
  
    //影响性能的隐藏方法 支持ios9
    UIImageView *tmp = [self findNavBarBottomLine:self.navigationController.navigationBar];
    tmp.hidden=YES;
    
    self.tableView.separatorStyle =NO;
    //去上下滚动界限
//    self.tableView.bounces = NO;
    //去除滚动条
    self.tableView.showsVerticalScrollIndicator = NO;
    //去分割线f
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    __weak __typeof(self)weakSelf = self;
//    self.tableView.mj_header.backgroundColor = COLOR_NAVBAR;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetDataWithModel:nil];
        // 这个地方是网络请求的处理
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.tableView.mj_header endRefreshing];
//        });
    }];
    [self getLocalDataWithModel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UserManager *user = [UserManager manager];
    if (user.singleSubFullData) {
        [self getNetDataWithModel:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [self hasUpdateVersion];
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
//    self.title = @"";
}

-(void)clickLeftBtn{
    BGQMSelectSubstationTVC *subTVC = [[BGQMSelectSubstationTVC alloc] init];
    subTVC.subTVCdelegate = self;
    [self.navigationController pushViewController:subTVC animated:YES];
}

- (void)sendSubModel:(BGQMSubstationModel *)subModel{
    //设置
    UserManager *user = [UserManager manager];
    if (subModel) {
        user.fsubID = subModel.fSubid;
        user.fsubName = subModel.fSubname;
        self.titleView.title = subModel.fSubname;
    }
    if(!user.fsubID){
        if (!subModel) {
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
    }else{
        [self.navigationController popViewControllerAnimated:YES];
        [self getNetDataWithModel:subModel];
        
    }
}

#pragma mark - <QMUITableViewDataSource, QMUITableViewDelegate>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *homeCellId = @"homeCell";
//    BGQMHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:homeCellId];
    //高速方案 避免重用机制
    NSArray *listInArr = self.listArrData[indexPath.row][@"nodes"];
    if (!listInArr) {
        return nil;
    }
    BGQMHomeTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[BGQMHomeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:homeCellId withData:listInArr];
    }
    if (self.listArrData.count>0) {
        NSString *titleStr = [NSString changgeNonulWithString:self.listArrData[indexPath.row][@"fMenuname"]];
        NSString *imageStr = [NSString changgeNonulWithString:self.listArrData[indexPath.row][@"fIconurl"]];
        if (titleStr.length) {
            cell.titleLabel.text = titleStr;
            if (imageStr.length>0) {
                 [cell.iconImage sd_setImageWithURL:[NSURL URLWithString:[getSystemIconADS stringByAppendingString:imageStr]] placeholderImage:[UIImage imageNamed:@"elec"]];
            }else{
                [cell.iconImage setImage:[UIImage imageNamed:@"Electric"]];
            }
        }
    }
    cell.homeTableCelldelegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DefLog(@"点击了%ld %@",(long)indexPath.row,self.listArrData[indexPath.row][@"fMenuname"]);
    BGQMHomeTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    BGQMCategoryListConViewController *eventVC = [[BGQMCategoryListConViewController alloc] init];
    if (cell.dataArr) {
        NSMutableArray *listArr = [NSMutableArray new];
        for (NSDictionary *cellData in cell.dataArr) {
            NSString *name = [NSString changgeNonulWithString:cellData[@"fMenuname"]];
            if (name.length) {
                 [listArr addObject:name];
            }
        }
        eventVC.titleArr = [listArr copy];
        eventVC.allDataArr = cell.dataArr;
    }
    eventVC.clickIndex = 0;
    eventVC.clickIndexOfSelectedCell = (long)indexPath.row;
    [self.navigationController pushViewController:eventVC animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //高速方案
//#define FixedDeathHeight1 100
    NSArray *listInArr = self.listArrData[indexPath.row][@"array"];
    NSInteger fixeddeathH = listInArr.count;
    double count = ceil(fixeddeathH/3.0);
    DefLog(@"%f",count);
    if (listInArr.count<=6) {
        return FixedDeathHeight;
    }else{
        return FixedDeathHeight+(FixedDeathHeight/2*(count-2));
    }
}

- (UIImageView *)findNavBarBottomLine:(UIView *)view{
    if ([view isKindOfClass:[UIImageView class]]&&view.bounds.size.height<1) {
        return (UIImageView *)view;
    }
    for (UIView *subView in view.subviews) {
        UIImageView *imageView=[self findNavBarBottomLine:subView];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

//点击事件
-(void)clickTableCellButtonModel:(NSInteger)btntag andClickInCell:(BGQMHomeTableViewCell *)cell{
    DefLog(@"btntag:%ld andCellArray:%@",(long)btntag,cell.dataArr);
//    BGQMEventViewController *eventVC = [[BGQMEventViewController alloc] init];
    long numOfSelectedCell = [self.tableView indexPathForCell:cell].row;
    BGQMCategoryListConViewController *eventVC = [[BGQMCategoryListConViewController alloc] init];
    if (cell.dataArr) {
        NSMutableArray *listArr = [NSMutableArray new];
        for (NSDictionary *cellData in cell.dataArr) {
            NSString *name = [NSString changgeNonulWithString:cellData[@"fMenuname"]];
            if (name.length) {
                 [listArr addObject:name];
            }
        }
        eventVC.titleArr = [listArr copy];
        eventVC.allDataArr = cell.dataArr;
    }
    eventVC.clickIndex = btntag;
    eventVC.clickIndexOfSelectedCell = numOfSelectedCell;
    [self.navigationController pushViewController:eventVC animated:YES];
}

-(void)getLocalDataWithModel{
    UserManager *user = [UserManager manager];
    if (user.singleSubFullData) {
        DefLog(@"当前token为：%@",user.token);
        NSArray *respfunctionsArr = [user.singleSubFullData objectForKeyNotNull:@"functions"];
//        NSDictionary *respInfoDic = [user.singleSubFullData objectForKeyNotNull:@"info"];
        NSArray *arrayMap = [user.singleSubFullData objectForKeyNotNull:@"arrayMap"];
            //配置head
        NSDictionary *baseInfoDic = [user.singleSubFullData objectForKeyNotNull:@"baseInfo"];
        if (baseInfoDic) {
            //配置head
            //            NSDictionary *baseInfoDic = [respInfoDic objectForKeyNotNull:@"baseInfo"];
//            NSArray *arrayMap = [respInfoDic objectForKeyNotNull:@"arrayMap"];
//            if (!arrayMap) {
//                return ;
//            }
//            NSDictionary *baseInfoDic = [respInfoDic objectForKeyNotNull:@"baseInfo"];
            NSString *titleString = [NSString changgeNonulWithString:baseInfoDic[@"fSubname"]];
            self.titleView.title = titleString;
            if (arrayMap.count == 0) {
                 self.headView = [[BGQMHomeHeadView alloc] initHomeHeadViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 122) andHeadData:baseInfoDic andDataArray:arrayMap];
            } else if(arrayMap.count<=3){
                self.headView = [[BGQMHomeHeadView alloc] initHomeHeadViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 122+SCREEN_WIDTH/3) andHeadData:baseInfoDic andDataArray:arrayMap];
            }else if (arrayMap.count<=6 ) {
                self.headView = [[BGQMHomeHeadView alloc] initHomeHeadViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 122+SCREEN_WIDTH/3*2) andHeadData:baseInfoDic andDataArray:arrayMap];
            }else{
                self.headView = [[BGQMHomeHeadView alloc] initHomeHeadViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 122+SCREEN_WIDTH) andHeadData:baseInfoDic andDataArray:arrayMap];
            }
        }
        if (respfunctionsArr) {
            //配置list
            self.listArrData = respfunctionsArr;
        }
        self.tableView.tableHeaderView = self.headView;
        [self.tableView reloadData];
    }else{
        __weak __typeof(self)weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            BGQMSelectSubstationTVC *subTVC = [[BGQMSelectSubstationTVC alloc] init];
            subTVC.subTVCdelegate = weakSelf;
            [weakSelf.navigationController pushViewController:subTVC animated:YES];
        });
    }
}

-(void)getNetDataWithModel:(BGQMSubstationModel *)model{
    UserManager *user = [UserManager manager];
    NSInteger subid = [user.fsubID integerValue];
    //配置国际化
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
    NSDictionary *param = @{@"fSubid":@(subid),@"pid":user.homefMenuid,@"english":language};
    __weak __typeof(self)weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [NetService bg_getWithTokenWithPath:getSubinfoVo params:param success:^(id respObjc) {
        DefLog(@"%@",respObjc);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSDictionary *respData = [respObjc objectForKeyNotNull:kdata];
//        NSDictionary *respsubInfoVo = [respData objectForKeyNotNull:@"subInfoVo"];
        user.singleSubFullData = respData;
        //list
        NSArray *respfunctionsArr = [respData objectForKeyNotNull:@"functions"];
        //head
//        NSDictionary *respInfoDic = [respsubInfoVo objectForKeyNotNull:@"info"];
        NSArray *arrayMap = [respData objectForKeyNotNull:@"arrayMap"];
        if (arrayMap) {
            //配置head
            NSDictionary *baseInfoDic = [respData objectForKeyNotNull:@"baseInfo"];
            if (arrayMap.count == 0) {
                weakSelf.headView = [[BGQMHomeHeadView alloc] initHomeHeadViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 122) andHeadData:baseInfoDic andDataArray:arrayMap];
            } else if(arrayMap.count<=3){
                weakSelf.headView = [[BGQMHomeHeadView alloc] initHomeHeadViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 122+SCREEN_WIDTH/3) andHeadData:baseInfoDic andDataArray:arrayMap];
            }else if (arrayMap.count<=6 ) {
                weakSelf.headView = [[BGQMHomeHeadView alloc] initHomeHeadViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 122+SCREEN_WIDTH/3*2) andHeadData:baseInfoDic andDataArray:arrayMap];
            }else{
                weakSelf.headView = [[BGQMHomeHeadView alloc] initHomeHeadViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 122+SCREEN_WIDTH) andHeadData:baseInfoDic andDataArray:arrayMap];
            }
        }
        if (respfunctionsArr) {
            //配置list
            weakSelf.listArrData = respfunctionsArr;
        }
        weakSelf.tableView.tableHeaderView = weakSelf.headView;
        [weakSelf.tableView reloadData];
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (errorMsg) {
            [MBProgressHUD showError:errorMsg];
        }else{
            [MBProgressHUD showError:@"请求失败"];
        }
    }];
}


@end
