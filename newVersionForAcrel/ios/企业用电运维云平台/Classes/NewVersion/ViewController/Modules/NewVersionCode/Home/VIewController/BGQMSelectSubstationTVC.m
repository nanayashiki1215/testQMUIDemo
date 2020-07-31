//
//  BGQMSelectSubstationTVC.m
//  变电所运维
//
//  Created by Acrel on 2019/6/10.
//  
//

#import "BGQMSelectSubstationTVC.h"
#import "NSString+BGExtension.h"
#import "NSString+PinYin.h"
#import "QDSearchViewController.h"
#import "IndexView.h"
#import "UIViewController+BackButtonHandler.h"
#import "BGUIWebViewController.h"

@interface BGQMSelectSubstationTVC ()<UISearchBarDelegate,IndexViewDelegate, IndexViewDataSource>

@property (nonatomic, strong) NSMutableArray *searchList;/**<搜索过滤后的数据源*/
@property (strong, nonatomic) NSArray * originalDataSource;/**<排序前的整个数据源*/
@property (strong, nonatomic) NSDictionary *displayDataSource;/**<排序后的整个数据源*/
@property (strong, nonatomic) NSArray *indexDataSource;/**<需要显示的索引数据源*/
@property (nonatomic, strong) IndexView *indexView;

@end

@implementation BGQMSelectSubstationTVC

- (void)didInitializeWithStyle:(UITableViewStyle)style {
    [super didInitializeWithStyle:style];
    // init 时做的事情请写在这里
}

- (void)initTableView {
    [super initTableView];
    
    // 对 self.tableView 的操作写在这里
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatView];
    [self initDataArray];
    [self.view addSubview:self.indexView];
    [self.indexView setSelectionIndex:0];
//    self.tableView.sectionHeaderHeight = 30.f;
//    [self hideTableHeaderViewInitialIfCanWithAnimated:NO force:NO];
    // 对 self.view 的操作写在这里
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ditu"] style:UIBarButtonItemStylePlain target:self action:@selector(changeShowMap)];
}

- (void)creatView{
    self.tableView.tableHeaderView.hidden = NO;
    self.shouldShowSearchBar = YES;
    self.searchController.searchResultsDelegate = self;
    self.searchBar.delegate = self;
//    self.searchController.launchView = [[QDRecentSearchView alloc] init];// launchView 会自动布局，无需处理 frame
//    self.searchController.searchBar.qmui_usedAsTableHeaderView = YES;// 以 tableHeaderView 的方式使用 searchBar 的话，将其置为 YES，以辅助兼容一些系统 bug
//    self.tableView.tableHeaderView = self.searchController.searchBar;
}

-(void)changeShowMap{
    UserManager *user = [UserManager manager];
//    NSString *versionURL = [user.rootMenuData objectForKeyNotNull:@"H5_2"];
//    NSString *fAction;
//         NSString *fFunctionurl;
//         for (NSDictionary *nodeDic in self.tableListArr) {
//             if ([nodeDic[@"fCode"] isEqualToString:@"MsgNotificationLower"]) {
//                 fAction = [NSString changgeNonulWithString:nodeDic[@"fActionurl"]];
//                 fFunctionurl = [NSString changgeNonulWithString:nodeDic[@"fFunctionfield"]];
//             }
//         }
//         if (fFunctionurl.length>0) {
            BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"monitorSubstation" ofType:@"html" inDirectory:@"aDevices"];
            nomWebView.isUseOnline = NO;
            nomWebView.localUrlString = filePath;
            nomWebView.showWebType = showWebTypeDevice;
            //        self.tabBarController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:nomWebView animated:YES];
//         }else{
//             BGUIWebViewController *urlWebView = [[BGUIWebViewController alloc] init];
//             urlWebView.isUseOnline = YES;
//             if (versionURL.length>0) {
//                 NSString *urlstring = [NSString stringWithFormat:@"/%@/",versionURL];
//                 NSString *str = [GetBaseURL stringByAppendingString:urlstring];
//                 NSString *urlStr = [str stringByAppendingString:fAction];
//                 urlWebView.onlineUrlString = urlStr;
//                 urlWebView.showWebType = showWebTypeDevice;
//                [self.navigationController pushViewController:urlWebView animated:YES];
//              }
//         }
}

- (void)initDataArray{
    __weak __typeof(self)weakSelf = self;
    UserManager *user = [UserManager manager];
//    if (user.subList) {
//        NSMutableArray *subnameArr = [NSMutableArray new];
//        for (NSDictionary *subDic in user.subList) {
//            //            NSString *fSubname = [NSString changgeNonulWithString:subDic[@"fSubname"]];
//            BGQMSubstationModel *subModel = [[BGQMSubstationModel alloc] initWithupdateUserInfo:subDic];
//            if (subModel) {
//                [subnameArr addObject:subModel];
//            }
//        }
//        self.originalDataSource = [subnameArr copy];
//        [self filterData];
//        [self.tableView reloadData];
//        [self.indexView reload];
//    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [NetService bg_getWithTokenWithPath:getSubstationListByUser params:nil success:^(id respObjc) {
        DefLog(@"%@",respObjc);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSArray *arrayList = respObjc[kdata][@"list"];
        user.subList = arrayList;
        
        NSMutableArray *subnameArr = [NSMutableArray new];
        for (NSDictionary *subDic in arrayList) {
//            NSString *fSubname = [NSString changgeNonulWithString:subDic[@"fSubname"]];
            BGQMSubstationModel *subModel = [[BGQMSubstationModel alloc] initWithupdateUserInfo:subDic];
            if (subModel) {
                 [subnameArr addObject:subModel];
            }
        }
        weakSelf.originalDataSource = [subnameArr copy];
        [weakSelf filterData];

        [weakSelf.tableView reloadData];
        [weakSelf.indexView reload];
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if([errorCode isEqualToString:@"5000"]){
            [MBProgressHUD showError:@"请求失败，服务器异常"];
        }
    }];
}

-(void)filterData{
    
    self.displayDataSource = [self changeListWithArr:self.originalDataSource];
    NSArray *indexArray = [self.displayDataSource allKeys];
    indexArray = [indexArray sortedArrayUsingComparator:^NSComparisonResult(NSString *  _Nonnull obj1, NSString*  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    NSMutableArray *mutlIndexArray = [NSMutableArray arrayWithArray:indexArray];
    if ([mutlIndexArray containsObject:kXp]) {
        [mutlIndexArray removeObject:kXp];
        [mutlIndexArray addObject:kXp];
    }
//    if ([mutlIndexArray containsObject:kXingXing]) {
//        [mutlIndexArray removeObject:kXingXing];
//        [mutlIndexArray insertObject:kXingXing atIndex:0];
//    }
//    [mutlIndexArray insertObject:@"" atIndex:0];
    self.indexDataSource = mutlIndexArray;
    [self.tableView reloadData];
}

-(NSDictionary *)changeListWithArr:(NSArray *) originalArr{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    NSMutableArray *vipArray = [NSMutableArray array];
    NSSortDescriptor *descripor=[NSSortDescriptor sortDescriptorWithKey:@"allWord" ascending:YES];
    NSSortDescriptor *descripor2=[NSSortDescriptor sortDescriptorWithKey:@"fSubname" ascending:YES];
    NSArray *arr = [originalArr sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descripor,descripor2,nil]];
    
    for (BGQMSubstationModel *contact in arr) {
//        if ([contact.isVip isEqualToString:@"1"]) {
//            [vipArray addObject:contact];
//        }else{
            NSString *allPinyin = [contact.allWord uppercaseString];
            NSString *charStr = kXp;
            if ([allPinyin notEmptyOrNull]) {
                NSString * firstChar = [allPinyin substringToIndex:1];
                if (firstChar && ([firstChar compare:@"A"] != NSOrderedAscending) && ([firstChar compare:@"Z"] != NSOrderedDescending)) {
                    charStr = firstChar;
                }
            }
        if([self isEnglishFirst:contact.fSubname]){
            NSString * firstChar = [contact.fSubname.uppercaseString substringToIndex:1];
            if (firstChar && ([firstChar compare:@"A"] != NSOrderedAscending) && ([firstChar compare:@"Z"] != NSOrderedDescending)) {
                charStr = firstChar;
            }
        }
            NSMutableArray *subAr = [dic objectForKey:charStr];
            if (subAr == nil) {
                subAr = [[NSMutableArray alloc] init];
                [dic setObject:subAr forKey:charStr];
            }
            if (![subAr containsObject:contact]) {
                [subAr addObject:contact];
            }
//        }
    }
//    if (vipArray.count) {
//        [dic setObject:vipArray forKey:kXingXing];
//    }
    return dic;
}

- (BOOL)isEnglishFirst:(NSString *)str {
    NSString *regular = @"^[A-Za-z].+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular];
    
    if ([predicate evaluateWithObject:str] == YES){
        return YES;
    }else{
        return NO;
    }
}
#pragma mark - filterDataWithString

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
    self.title = DefLocalizedString(@"selectsubstation");
}

#pragma mark - <QMUITableViewDataSource, QMUITableViewDelegate>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.searchController.active) {
        return 1;
    }else{
        return self.indexDataSource.count;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchController.active) {
        return [self.searchList count];
    }else {
        NSString *key = self.indexDataSource[section];
        NSArray *value = [self.displayDataSource objectForKey:key];
        return value.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *searchCellId = @"SearchCellID";
    QMUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:searchCellId];
    if (!cell) {
        cell = [[QMUITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:searchCellId];
    }
    
    if (self.searchController.active) {
        BGQMSubstationModel *subModel = self.searchList[indexPath.row];
        [cell.textLabel setText:subModel.fSubname];
//        [cell.detailTextLabel setText:subModel.fAddress];
//        [cell.textLabel setText:self.searchList[indexPath.row]];
    }else {
        NSString *key = self.indexDataSource[indexPath.section];
        NSArray *value = [self.displayDataSource objectForKey:key];
        BGQMSubstationModel *model = value[indexPath.row];
        [cell.textLabel setText:model.fSubname];
//        [cell.detailTextLabel setText:model.fAddress];
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //自定义Header标题
   
    if (!self.searchController.active) {
        UIView* myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 22)];
        myView.backgroundColor = UIColorGray9;//UIColorTheme7
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 90, 22)];
        titleLabel.textColor=[UIColor whiteColor];
        NSString *title = self.indexDataSource[section];
        titleLabel.text=title;
        [myView addSubview:titleLabel];
        
        return myView;
    }else{
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    0x10805f200
    if (self.searchController.active) {
        BGQMSubstationModel *subModel = self.searchList[indexPath.row];
        [self.subTVCdelegate sendSubModel:subModel];
    }else{
        NSString *key = self.indexDataSource[indexPath.section];
        NSArray *value = [self.displayDataSource objectForKey:key];
        BGQMSubstationModel *model = value[indexPath.row];
        [self.subTVCdelegate sendSubModel:model];
    }
//    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)navigationShouldPopOnBackButton{
//    [[[UIAlertView alloc] initWithTitle:@"提示" message:@"确定返回上一界面?"
//                               delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
    [self.subTVCdelegate sendSubModel:nil];
    return NO;
}

#pragma mark---tableView索引相关设置----
//添加TableView头视图标题
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSDictionary *dict = self.substationArray[section];
//    NSString *title = dict[@"firstLetter"];
//    return title;
//}

//添加索引栏标题数组
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//
//    return self.indexDataSource;
//}

//点击索引栏标题时执行
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//    //这里是为了指定索引index对应的是哪个section的，默认的话直接返回index就好。其他需要定制的就针对性处理
////    if ([title isEqualToString:UITableViewIndexSearch])
////    {
////        [tableView setContentOffset:CGPointZero animated:NO];//tabview移至顶部
////        return NSNotFound;
////    }
////    else
////    {
////        return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index] - 1; // -1 添加了搜索标识
////    }
//    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    return index;
//}

#pragma mark ----UISearchResultsUpdating----

- (void)searchController:(QMUISearchController *)searchController updateResultsForSearchString:(NSString *)searchString{
    
    if (self.searchList != nil) {
        [self.searchList removeAllObjects];
    }

    if (searchString != nil && searchString.length > 0) {
        for (BGQMSubstationModel *subModel in self.originalDataSource) {
            if ([subModel.allWord rangeOfString:searchString options:NSCaseInsensitiveSearch].length > 0) {
                [self.searchList addObject:subModel];
            }else if([subModel.firstWord rangeOfString:searchString options:NSCaseInsensitiveSearch].length > 0) {
                [self.searchList addObject:subModel];
            }else if([subModel.FirstLetter rangeOfString:searchString options:NSCaseInsensitiveSearch].length > 0) {
                [self.searchList addObject:subModel];
            }else if([subModel.fSubname rangeOfString:searchString options:NSCaseInsensitiveSearch].length > 0) {
                [self.searchList addObject:subModel];
            }
        }
    }else {
        self.searchList = [NSMutableArray arrayWithArray:self.originalDataSource];
    }
    //刷新表格
    [self.searchController.tableView reloadData];
}

#pragma mark - IndexView
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    [self.indexView tableView:tableView willDisplayHeaderView:view forSection:section];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
    [self.indexView tableView:tableView didEndDisplayingHeaderView:view forSection:section];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.indexView scrollViewDidScroll:scrollView];
}
- (IndexView *)indexView {
    if (!_indexView) {
        _indexView = [[IndexView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 30, 64, 30, SCREEN_HEIGHT - 64)];
        _indexView.delegate = self;
        _indexView.dataSource = self;
        
    }
    return _indexView;
}
- (NSArray<NSString *> *)sectionIndexTitles {
    //搜索符号  [NSMutableArray arrayWithObject:UITableViewIndexSearch]; [NSMutableArray array];
//    NSMutableArray *resultArray = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
//    for (NSDictionary *dict in self.brandArray) {
//        NSString *title = dict[@"firstLetter"];
//        if (title) {
//            [resultArray addObject:title];
//        }
//    }
//    return resultArray;
    return self.indexDataSource;
}

//当前选中组
- (void)selectedSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
//    if (self.isSearchMode && (index == 0)) {
//        //搜索视图头视图(这里不能使用scrollToRowAtIndexPath，因为搜索组没有cell)
//        [self.demoTableView setContentOffset:CGPointZero animated:NO];
//        return;
//    }
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

//将指示器视图添加到当前视图上
- (void)addIndicatorView:(UIView *)view {
    [self.view addSubview:view];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    DefLog(@"输入字符串为：%@ -- %lu", searchText, (unsigned long)searchText.length);
  
}



//-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
//    for (UIView *view in [tableView subviews]) {
//        if ([view isKindOfClass:[NSClassFromString(@"UITableViewIndex") class]]) {
//            // 设置字体大小
//            [view setValue:[UIFont fontWithName:@"AmericanTypewriter" size:18] forKey:@"_font"];
//            //设置view的大小
//            view.bounds = CGRectMake(0, 0, 30, view.frame.height);
////            view.bounds = CGRectMake(0, 0, 30, );
//            [view setBackgroundColor:[UIColor clearColor]];
//            //单单设置其中一个是无效的
//        }
//    }
//
//}
@end
