//
//  YPAMapSearchPointViewController.m
//  linphone
//
//  Created by feitian on 2016/11/28.
//
//

#import "YPAMapSearchPointViewController.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "YPAMapChooseCell.h"

@interface YPAMapSearchPointViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,AMapSearchDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableV;
@property (strong, nonatomic) IBOutlet UISearchBar *searchB;
@property (strong,nonatomic) NSMutableArray *dataArray;
@property (nonatomic, strong) AMapSearchAPI *search;


@end

@implementation YPAMapSearchPointViewController

-(void)setChooseBlock:(void (^)(NSArray *, NSIndexPath *))chooseBlock{
    _chooseBlock = [chooseBlock copy];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.dataArray = [NSMutableArray array];
    [self creatView];
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.searchB resignFirstResponder];
}


- (void)creatView{
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.navigationItem.title = @"搜索地址";
    self.view.backgroundColor = [UIColor grayColor];
    
    [super initNavigationBarButtonItems];
    
    [self.tableV registerNib:[UINib nibWithNibName:@"YPAMapChooseCell" bundle:nil] forCellReuseIdentifier:@"YPAMapChooseCell"];
    self.tableV.bounces = NO;
    self.tableV.delegate = self;
    self.tableV.dataSource = self;
    self.tableV.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableV.showsVerticalScrollIndicator = NO;
    [self.tableV setFooterCellLineHidden];
    self.tableV.tableHeaderView = self.searchB;
    
    self.searchB.delegate = self;
    //self.searchBar为搜索栏
    UIButton *cancleBtn = [self.searchB valueForKey:@"cancelButton"];
    if (cancleBtn) {
        //修改标题和标题颜色
//        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:@"取消" attributes:@{NSForegroundColorAttributeName:COLOR_NAVIGATION}];
//        [cancleBtn setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    }
}


-(void)backButtonAction:(UIButton *)backBtn{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self searchPoiByKeyword:searchBar.text];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [self.dataArray removeAllObjects];
    [self.tableV reloadData];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self searchPoiByKeyword:searchBar.text];
}

#pragma mark - AMapSearchDelegate

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
}

/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    //    if (response.pois.count == 0)
    //    {
    //        return;
    //    }
    [self.dataArray removeAllObjects];
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        
        [self.dataArray addObject:obj];
        
    }];
    [self.tableV reloadData];
}

#pragma mark - Utility

- (void)searchPoiByKeyword:(NSString *)keyword
{
    if (keyword.length == 0) {
        [self.searchB resignFirstResponder];
        [self.dataArray removeAllObjects];
        [self.tableV reloadData];
        return;
    }
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
    request.keywords = keyword;
    //    request.keywords            = @"北京大学";
    if (self.citycode) {
        request.city = self.citycode;
    }else{
        request.city                = @"上海市";
    }
    
    //    request.types               = @"高等院校";
    request.requireExtension    = YES;
    //
    //    /*  搜索SDK 3.2.0 中新增加的功能，只搜索本城市的POI。*/
    request.cityLimit           = YES;
    request.requireSubPOIs      = YES;
    
    [self.search AMapPOIKeywordsSearch:request];
}

#pragma mark table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return DefCellHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YPAMapChooseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YPAMapChooseCell"];
    AMapPOI *model = self.dataArray[indexPath.row];
    //    cell.textLabel.text =  [NSString stringWithFormat:@"%@,%lf,%lf",model.name,model.location.longitude,model.location.latitude];
    cell.topLB.text = model.name;
    cell.bottomLB.text = model.address;
    //    cell.rightIV.hidden = YES;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    AMapPOI *model = self.dataArray[indexPath.row];
    NSLog(@"%@,%lf,%lf",model.name,model.location.longitude,model.location.latitude);
    if (_chooseBlock) {
        _chooseBlock(self.dataArray,indexPath);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
