//
//  BGQMVideoListTableVC.m
//  变电所运维
//
//  Created by Acrel on 2019/6/6.
//  
//

#import "BGQMVideoListTableVC.h"
#import "BGQMVideoTableViewCell.h"
#import "EZUIKitViewController.h"
#import "Toast+UIView.h"
#import "EZUIKit.h"
#import "EZUIKitPlaybackViewController.h"

#import "EZLivePlayViewController.h"
#import "EZDeviceInfo.h"
#import "EZCameraInfo.h"
#import "EZVideoQualityInfo.h"
#import "EZPlaybackViewController.h"
#import "BGUIWebViewController.h"

@interface BGQMVideoListTableVC ()<BGQMVideoTableViewCellDelegate,QMUISearchControllerDelegate,QMUINavigationTitleViewDelegate,UISearchBarDelegate>
@property(nonatomic, strong) QMUIPopupMenuView *popupMenuView;
@property(nonatomic, strong) NSMutableArray *mutArray;//需要展示的数据
@property(nonatomic, strong) NSMutableArray *searchArray;//搜索后的数据
@property(nonatomic, strong) NSMutableArray *allDataArray;//原始全数据
@property(nonatomic, strong) NSMutableArray *cellNameArray;//保存cell

@property(nonatomic, strong) NSString *ezappkeystr;//临时AppKey
@property(nonatomic, strong) NSString *ezappTokenstr;//临时Apptoken
@property(nonatomic, assign) CGFloat cellChangeHeight;//改变高度

@end

static NSString *videoCellIdentifier = @"ezvideoCell";

@implementation BGQMVideoListTableVC

- (void)didInitializeWithStyle:(UITableViewStyle)style {
    [super didInitializeWithStyle:style];
    // init 时做的事情请写在这里
}

- (void)initTableView {
    [super initTableView];
    // 对 self.tableView 的操作写在这里
    self.tableView.backgroundColor = COLOR_BACKGROUND;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = DefVideoCellHeight;
//    self.shouldShowSearchBar = YES;
//    [self.searchController ]
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.titleView.userInteractionEnabled = YES;// 要titleView支持点击，需要打开它的 userInteractionEnabled，这个属性默认是 NO
//    self.titleView.title = @"";
//    self.titleView.accessoryType = QMUINavigationTitleViewAccessoryTypeDisclosureIndicator;
//    self.titleView.delegate = self;// 要监听 titleView 的点击事件以及状态切换，需要通过 delegate 的形式
//    [self initPopupContainerViewIfNeeded];
    self.mutArray = [NSMutableArray new];
    self.searchArray = [NSMutableArray new];
   
    [self getVideoListData];
//    UIView *searchTextField = nil;
    // 经测试, 需要设置barTintColor后, 才能拿到UISearchBarTextField对象
//    self.searchBar.barTintColor = [UIColor whiteColor];
//    searchTextField = [[[self.searchBar.subviews firstObject] subviews] lastObject];
//    if([searchTextField isKindOfClass:[UITextField class]]){
//        searchTextField.frame = CGRectMake(0, 0, SCREEN_WIDTH - 36, 44);
//    }
//    NSDictionary *dic =@{@"DeviceSerial":@"183414608",@"DeviceName":@"球型摄像机（演示）",@"EZAPPKEY":@"cec0dca73dfc4782bc84375a57cd8170",@"EZAPPAccessToken":@"at.0hjtlhp177bkoj4v3hkwdfildn39hbha-51c0n1ncr7-09zb4kg-6dy9v2dcd",@"urlStr":@"ezopen://open.ys7.com/183414608/1.hd.live"};
//    NSDictionary *dic2 =@{@"DeviceSerial":@"183414608",@"DeviceName":@"111333机（演示）",@"EZAPPKEY":@"cec0dca73dfc4782bc84375a57cd8170",@"EZAPPAccessToken":@"at.0hjtlhp177bkoj4v3hkwdfildn39hbha-51c0n1ncr7-09zb4kg-6dy9v2dcd",@"urlStr":@"ezopen://open.ys7.com/183414608/1.hd.live"};
//    NSDictionary *dic3 =@{@"DeviceSerial":@"183414608",@"DeviceName":@"测试机（演示）",@"EZAPPKEY":@"cec0dca73dfc4782bc84375a57cd8170",@"EZAPPAccessToken":@"at.0hjtlhp177bkoj4v3hkwdfildn39hbha-51c0n1ncr7-09zb4kg-6dy9v2dcd",@"urlStr":@"ezopen://open.ys7.com/183414608/1.hd.live"};
//    NSDictionary *dic4 =@{@"DeviceSerial":@"183414608",@"DeviceName":@"测试机（演示）",@"EZAPPKEY":@"cec0dca73dfc4782bc84375a57cd8170",@"EZAPPAccessToken":@"at.0hjtlhp177bkoj4v3hkwdfildn39hbha-51c0n1ncr7-09zb4kg-6dy9v2dcd",@"urlStr":@"ezopen://open.ys7.com/183414608/1.hd.live"};
//    NSDictionary *dic5 =@{@"DeviceSerial":@"183414608",@"DeviceName":@"测试机（演示）",@"EZAPPKEY":@"cec0dca73dfc4782bc84375a57cd8170",@"EZAPPAccessToken":@"at.0hjtlhp177bkoj4v3hkwdfildn39hbha-51c0n1ncr7-09zb4kg-6dy9v2dcd",@"urlStr":@"ezopen://open.ys7.com/183414608/1.hd.live"};
//    [self.mutArray addObject:dic];
//    [self.mutArray addObject:dic2];
//    [self.mutArray addObject:dic3];
//    [self.mutArray addObject:dic4];
//    [self.mutArray addObject:dic5];
//    self.allDataArray = [NSMutableArray arrayWithArray:[self.mutArray copy]];
//
//    if (!self.mutArray.count) {
////        [self showEmptyViewWithText:@"请求失败" detailText:@"请检查网络连接后点击重试" buttonTitle:@"重试" buttonAction:@selector(reload:)];
//        [self showEmptyViewWithText:@"未获取到任何设备" detailText:@"如需接入监控设备，请联系我们。" buttonTitle:nil buttonAction:nil];
//    }
    
}

-(void)getVideoListData{
    UserManager *user = [UserManager manager];
    NSInteger subid;
    if (self.pushSubid) {
        subid = [self.pushSubid integerValue];
    } else {
        subid = [user.fsubID integerValue];
    }
    NSDictionary *param = @{@"fSubid":@(subid)};
    __weak __typeof(self)weakSelf = self;
    [NetService bg_getWithTokenWithPath:getVideoInfoList params:param success:^(id respObjc) {
        DefLog(@"respObjc:%@",respObjc);
        NSDictionary *platformdic = respObjc[@"data"][@"platformSetList"];
        if (platformdic) {
            NSString *ysAppKey = [NSString changgeNonulWithString:platformdic[@"ysAppKey"]];
            NSString *ysToken = [NSString changgeNonulWithString:platformdic[@"ysToken"]];
            if (!ysAppKey && !ysToken) {
                [weakSelf showEmptyViewWithText:@"未获取到任何设备" detailText:@"可前往网页端系统设置->视频设置->修改对应变电所中添加视频监控地址信息。" buttonTitle:@"" buttonAction:@selector(pushAuthorization)];
//                [weakSelf showEmptyViewWithText:@"未获取到任何设备" detailText:@"可前往网页端系统设置->视频设置->修改对应变电所中添加视频监控地址信息。" buttonTitle:@"萤石云授权" buttonAction:@selector(pushAuthorization)];
                return ;
            }else if(!ysAppKey){
                 [weakSelf showEmptyViewWithText:@"未获取到任何设备" detailText:@"可前往网页端系统设置->视频设置->修改对应变电所中添加视频监控地址信息。" buttonTitle:@"" buttonAction:@selector(pushAuthorization)];
//                [weakSelf showEmptyViewWithText:@"萤石云Appkey或Secret为空" detailText:@"可前往网页端系统设置->组织机构管理->修改对应变电所->附加信息中添加萤石云Appkey与Secret。" buttonTitle:@"萤石云授权" buttonAction:@selector(pushAuthorization)];
                return ;
            }else if(!ysToken){
                 [weakSelf showEmptyViewWithText:@"未获取到任何设备" detailText:@"可前往网页端系统设置->视频设置->修改对应变电所中添加视频监控地址信息。" buttonTitle:@"" buttonAction:@selector(pushAuthorization)];
//                [weakSelf showEmptyViewWithText:@"萤石云Appkey或Secret为空" detailText:@"可前往网页端系统设置->组织机构管理->修改对应变电所->附加信息中添加萤石云Appkey与Secret。" buttonTitle:@"萤石云授权" buttonAction:@selector(pushAuthorization)];
                return ;
            }else{
                //初始化
                [EZUIKit initWithAppKey:ysAppKey];
                [EZUIKit setAccessToken:    ysToken];
            }
            NSArray *VideoinfoList = respObjc[@"data"][@"VideoinfoList"];
            if (VideoinfoList.count>0) {
                for (NSDictionary *videoDic in VideoinfoList) {
                    NSString *playbackurl = [NSString changgeNonulWithString:videoDic[@"fPlaybackurl"]];
                    NSString *highurl = [NSString changgeNonulWithString:videoDic[@"fHighurl"]];
                    if (!playbackurl.length || !highurl.length) {
                        [MBProgressHUD showError:@"视频相关信息不全，需补全视频信息。"];
                        continue;
                    }else{
                        [weakSelf.mutArray addObject:videoDic];
                    }
                }
            }
        }
        weakSelf.allDataArray = [NSMutableArray arrayWithArray:[weakSelf.mutArray copy]];
        if (!weakSelf.mutArray.count) {
             [weakSelf showEmptyViewWithText:@"未获取到任何设备" detailText:@"可前往网页端系统设置->视频设置->修改对应变电所中添加视频监控地址信息。" buttonTitle:@"" buttonAction:@selector(pushAuthorization)];
//            [weakSelf showEmptyViewWithText:@"未获取到任何设备" detailText:@"可前往网页端系统设置->视频设置->修改对应变电所中添加视频监控地址信息。" buttonTitle:@"萤石云授权" buttonAction:@selector(pushAuthorization)];
        }else{
            [weakSelf.tableView reloadData];
        }
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
            [weakSelf showEmptyViewWithText:@"请求失败" detailText:@"请检查网络连接后点击重试" buttonTitle:@"重试" buttonAction:@selector(reload:)];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     self.cellNameArray = [NSMutableArray new];
//    self.shouldShowSearchBar = YES;
//    self.searchBar.delegate = self;
}

//跳转萤石云授权
-(void)pushAuthorization{
    NSInteger subid;
    if (self.pushSubid) {
        subid = [self.pushSubid integerValue];
    } else {
        subid = [[UserManager manager].fsubID integerValue];
    }
    BGUIWebViewController *webview = [[BGUIWebViewController alloc] init];
    webview.isUseOnline = YES;
    webview.onlineUrlString =   [NSString stringWithFormat:@"https://openauth.ys7.com/trust/device?client_id=cec0dca73dfc4782bc84375a57cd8170&response_type=code&state=%ld",(long)subid];
    if (self.pushSubid) {
        [self.navigationController pushViewController:webview animated:YES];
    }else{
        [self.ownNaviController pushViewController:webview animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSInteger sections = self.tableView.numberOfSections;
    if (sections>0) {
         for (int section = 0; section < sections; section++) {
            NSInteger rows = [self.tableView numberOfRowsInSection:section];
            for (int row = 0; row < rows; row++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                BGQMVideoTableViewCell *videoCell = [self.tableView cellForRowAtIndexPath:indexPath];
                if (videoCell.isPLaying) {
                     [videoCell playBtnClick:videoCell.playBtn];
                }
//                [videoCell stop];
            }
        }
    }
       
//    }
//    [self.searchBar resignFirstResponder];
//    self.shouldShowSearchBar = NO;
//    [self.searchController dismissViewControllerAnimated:NO completion:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    UserManager *user = [UserManager manager];
    if(self.pushTitleName){
        self.title = self.pushTitleName;
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem qmui_itemWithTitle:@"返回" target:self action:@selector(backToWebView)];
    }else{
        self.title = user.fsubName;
    }
//    if (self.mutArray.count>0) {
//        self.title = self.mutArray.firstObject;
//    }else{
//       self.title = self.titleFromHomepage;
//    }
}

-(void)backToWebView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - <QMUITableViewDataSource, QMUITableViewDelegate>

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    BGQMVideoTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    if (cell.isChangeHeight) {
//       return 100+self.cellChangeHeight;
//    }else{
       return DefVideoCellHeight;
//    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.searchController.active){
         return self.searchArray.count;
    }else{
         return self.mutArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    BGQMVideoTableViewCell *videoCell = [tableView dequeueReusableCellWithIdentifier:videoCellIdentifier];
    NSString *CellIdentifier = [NSString stringWithFormat:@"cell%ld%ld",indexPath.section,indexPath.row];
    BGQMVideoTableViewCell *videoCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [self.cellNameArray addObject:CellIdentifier];
    if (self.searchController.active) {
        if (!videoCell) {
            videoCell = [[BGQMVideoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier withPlayerData:self.searchArray[indexPath.row]];
            //        videoCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if (self.searchArray.count>0) {
//            videoCell.iconCameraImage.image = [UIImage imageNamed:@"app-vision"];
            videoCell.nameLab.text = self.searchArray[indexPath.row][@"fVideoname"];
            //    NSString *urlStr = @"ezopen://open.ys7.com/183414608/1.hd.live";
            videoCell.urlStr = self.searchArray[indexPath.row][@"fHighurl"];
            videoCell.videoPlayBackdelegate = self;
        }
    }else{
        if (!videoCell) {
            videoCell = [[BGQMVideoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier withPlayerData:self.mutArray[indexPath.row]];
            //        videoCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
//        videoCell.iconCameraImage.image = [UIImage imageNamed:@"app-vision"];
        NSString *namestr = [NSString changgeNonulWithString:self.mutArray[indexPath.row][@"fVideoname"]];
        if (namestr.length) {
            videoCell.nameLab.text = namestr;
        }
        NSString *URLStr= [NSString changgeNonulWithString:self.mutArray[indexPath.row][@"fHighurl"]];
        if (URLStr.length) {
            videoCell.urlStr = URLStr;
        }else{
            videoCell.urlStr = @"";
        }
        //    NSString *urlStr = @"ezopen://open.ys7.com/183414608/1.hd.live";
        videoCell.videoPlayBackdelegate = self;
    }
    return videoCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

//    if (self.mutArray.count>0) {
//        NSDictionary *deviceInfo = self.mutArray[indexPath.row];
//        NSString *deviceStr = [NSString changgeNonulWithString:deviceInfo[@"fVideokey"]];
//        if (!deviceStr || [deviceStr isEqualToString:@""]) {
//            DefQuickAlert(@"未配置设备序列号，请前往Web端配置", nil);
//            return;
//        }
//        UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"EZMain" bundle:[NSBundle mainBundle]];
//
//        EZLivePlayViewController *selfdetailVC = [mainSB instantiateViewControllerWithIdentifier:@"EZLivePlayViewController"];
//
//           [EZOPENSDK getDeviceInfo:deviceStr completion:^(EZDeviceInfo *deviceInfo, NSError *error) {
//                     if (deviceInfo) {
//
//                         selfdetailVC.deviceInfo = deviceInfo;
//                         [self.ownNaviController pushViewController:selfdetailVC animated:YES];
//        //                         [self presentViewController:selfdetailVC animated:YES completion:nil];
//                     }
//                     else {
//                         [self.tableView makeToast:@"无此设备，请检查设备序列号" duration:2.0 position:@"center"];
//                     }
//            }];
//    }
    

}

- (void) showPlayerControllerWithAppKey:(NSString *) appKey
                                 access:(NSString *) accessToken
                                    url:(NSString *) urlStr
                                 apiUrl:(NSString *) apiUrl
                                   mode:(NSString *) modeStr
{
    NSString *alertMsg = nil;
    if (!appKey || appKey.length == 0)
    {
        alertMsg = NSLocalizedString(@"app_key_msg", @"AppKey不能为空");
    }
    
    if (!accessToken || accessToken.length == 0)
    {
        if (!alertMsg)
        {
            alertMsg =NSLocalizedString(@"access_token_msg", @"accessToken不能为空");
        }
    }
    
    if (!urlStr || urlStr.length == 0)
    {
        if (!alertMsg)
        {
            alertMsg = NSLocalizedString(@"url_msg", @"播放url不能为空");
        }
    }
//    if (self.globalMode &&(!apiUrl || apiUrl.length == 0))
//    {
//        if (!alertMsg)
//        {
//            alertMsg = NSLocalizedString(@"api_url_msg", @"服务器地址不能为空");
//        }
//    }
    if (alertMsg)
    {
        [self.view makeToast:alertMsg duration:1.5 position:@"center"];
        return;
    }
    
    NSString *urlStrOther = nil;
    NSArray *tempArr = [urlStr componentsSeparatedByString:@","];
    if (tempArr.count == 2)
    {
        urlStr = [tempArr firstObject];
        urlStrOther = [tempArr lastObject];
    }
    
//    [self stroeAppkey:appKey accessToken:accessToken url:urlStr urlStrOther:urlStrOther apiUrl:apiUrl mode:modeStr];
    
//    if (self.playerSwitch.on && [EZUIPlayer getPlayModeWithUrl:urlStr] == EZUIKIT_PLAYMODE_REC)
//    {
//        EZUIKitPlaybackViewController *vc = [[EZUIKitPlaybackViewController alloc] init];
//        vc.appKey = appKey;
//        vc.accessToken = accessToken;
//        vc.urlStr = urlStr;
////        if (self.globalMode)
////        {
////            vc.apiUrl = apiUrl;
////        }
//        [self.ownNaviController pushViewController:vc animated:YES];
//    }
//    else
//    {
//        EZUIKitViewController *vc = [[EZUIKitViewController alloc] init];
//        vc.appKey = appKey;
//        vc.accessToken = accessToken;
//        vc.urlStr = urlStr;
//        vc.urlStrOhter = urlStrOther;
////        if (self.globalMode)
////        {
////            vc.apiUrl = apiUrl;
////        }
//        [self.ownNaviController pushViewController:vc animated:YES];
    
}
#pragma mark ----UISearchResultsUpdating----

- (void)searchController:(QMUISearchController *)searchController updateResultsForSearchString:(NSString *)searchString{
//    if (self.searchArray != nil) {
//        [self.searchArray removeAllObjects];
//
//    }
//    //    if (self.mutArray != nil) {
//    //        [self.mutArray removeAllObjects];
//    //    }
//    if (searchString != nil && searchString.length > 0) {
//        for (NSDictionary *videoModel in self.allDataArray) {
//            if ([videoModel[@"DeviceName"] rangeOfString:searchString options:NSCaseInsensitiveSearch].length > 0) {
//                [self.searchArray addObject:videoModel];
//            }
//        }
//    }
//    //刷新表格
//    [self.searchController.tableView reloadData];
}

#pragma mark - searchBar 代理

//输入了文字的监听
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (self.searchArray != nil) {
        [self.searchArray removeAllObjects];
        
    }
    if (searchText != nil && searchText.length > 0) {
        for (NSDictionary *videoModel in self.allDataArray) {
            if ([videoModel[@"DeviceName"] rangeOfString:searchText options:NSCaseInsensitiveSearch].length > 0) {
                [self.searchArray addObject:videoModel];
            }
        }
    }
    //刷新表格
    if (!self.searchController.tableView) {
        [self.tableView reloadData];
    }else{
        [self.searchController.tableView reloadData];
    }
}

//确认搜索按钮
//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//    [searchBar resignFirstResponder];
////    [self.tableView reloadData];
////    [self filterData];
//}

//点了取消按钮
//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
//    searchBar.text = @"";
////    self.mutArray = self.allDataArray;
////    [self.tableView reloadData];
////    self.topFunctionDataSource = [NSArray array];
////    [self createTopFunctionData];
////    [self filterData];
//}


#pragma mark - ClickEvents

- (void)reload:(id)sender {
    [self hideEmptyView];
    [self getVideoListData];
//    [self.mutArray addObject:@"变电所 1"];
    [self.tableView reloadData];
}

- (void)initPopupContainerViewIfNeeded {
    if (!self.popupMenuView) {
        self.popupMenuView = [[QMUIPopupMenuView alloc] init];
        self.popupMenuView.automaticallyHidesWhenUserTap = YES;// 点击空白地方自动消失
        self.popupMenuView.preferLayoutDirection = QMUIPopupContainerViewLayoutDirectionBelow;
        self.popupMenuView.maximumWidth = 220;
        __weak __typeof(self)weakSelf = self;
        self.popupMenuView.items = @[[QMUIPopupMenuButtonItem itemWithImage:UIImageMake(@"icon_emotion") title:@"变电所 1" handler:^(QMUIPopupMenuButtonItem *aItem) {
            weakSelf.titleView.title = aItem.title;
            [aItem.menuView hideWithAnimated:YES];
        }],
                                     [QMUIPopupMenuButtonItem itemWithImage:UIImageMake(@"icon_emotion") title:@"变电所 2" handler:^(QMUIPopupMenuButtonItem *aItem) {
                                         [aItem.menuView hideWithAnimated:YES];
                                         weakSelf.titleView.title = aItem.title;
                                     }],
                                     [QMUIPopupMenuButtonItem itemWithImage:UIImageMake(@"icon_emotion") title:@"变电所 3" handler:^(QMUIPopupMenuButtonItem *aItem) {
                                         [aItem.menuView hideWithAnimated:YES];
                                         weakSelf.titleView.title = aItem.title;
                                     }]];
        self.popupMenuView.sourceView = self.titleView;
        
        self.popupMenuView.didHideBlock = ^(BOOL hidesByUserTap) {
            weakSelf.titleView.active = NO;

        };
    }
}
- (void) stroeAppkey:(NSString *) appKey
         accessToken:(NSString *) token
                 url:(NSString *) urlStr
         urlStrOther:(NSString *) urlStrOther
              apiUrl:(NSString *) apiUrl
                mode:(NSString *) modeStr
{
    [self storeString:appKey key:EZUIKitAppKey];
    [self storeString:token key:EZUIKitAccessToken];
    [self storeString:urlStr key:EZUIKitUrlStr];
    
    if (urlStrOther)
    {
        [self storeString:urlStrOther key:EZUIKitUrlStrOhter];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:EZUIKitUrlStrOhter];
    }
    
    if (apiUrl)
    {
        [self storeString:apiUrl key:EZUIKitApiUrl];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:EZUIKitApiUrl];
    }
    
    if (modeStr)
    {
        [self storeString:modeStr key:EZUIKitMode];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:EZUIKitMode];
    }
}

- (NSString *) readStringWithKey:(NSString *) key
{
    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return value;
}

- (void) storeString:(NSString *) value key:(NSString *) key
{
    if (!value || !key || key.length <= 0)
    {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
}
#pragma mark - <QMUINavigationTitleViewDelegate>

- (void)didChangedActive:(BOOL)active forTitleView:(QMUINavigationTitleView *)titleView {
    if (active) {
        [self.popupMenuView showWithAnimated:YES];
    }
}


#pragma mark - JXCategoryListCollectionContentViewDelegate

- (UIView *)listView {
    return self.view;
}

- (void)listDidAppear {
    DefLog(@"%@", NSStringFromSelector(_cmd));
    //因为`JXCategoryListCollectionContainerView`内部通过`UICollectionView`的cell加载列表。当切换tab的时候，之前的列表所在的cell就被回收到缓存池，就会从视图层级树里面被剔除掉，即没有显示出来且不在视图层级里面。这个时候MJRefreshHeader所持有的UIActivityIndicatorView就会被设置hidden。所以需要在列表显示的时候，且isRefreshing==YES的时候，再让UIActivityIndicatorView重新开启动画。
    //    if (self.showScrollerView.mj_header.isRefreshing) {
    //        UIActivityIndicatorView *activity = [self.showScrollerView.mj_header valueForKey:@"loadingView"];
    //        [activity startAnimating];
    //    }
}

- (void)listDidDisappear {
    DefLog(@"%@", NSStringFromSelector(_cmd));
}

//跳转回放
- (void)clickPlayBackBtnInCell:(BGQMVideoTableViewCell *)cell withPushData:(NSDictionary *)param{
    //点击了回放
//    EZUIKitPlaybackViewController *vc = [[EZUIKitPlaybackViewController alloc] init];
//    NSIndexPath *path = [self.tableView indexPathForCell:cell];
//    vc.videoTitle = self.mutArray[path.row][@"fVideoname"];
//    vc.appKey = self.ezappkeystr;
//    vc.accessToken = self.ezappTokenstr;
//    vc.urlStr =  self.mutArray[path.row][@"fPlaybackurl"];
//    [self.ownNaviController pushViewController:vc animated:YES];
    NSIndexPath *indexP = [self.tableView indexPathForCell:cell];
    NSDictionary *deviceInfo = self.mutArray[indexP.row];
    NSString *deviceStr = [NSString changgeNonulWithString:deviceInfo[@"fVideokey"]];
    
    if (!deviceStr || [deviceStr isEqualToString:@""]) {
       DefQuickAlert(@"未配置设备序列号，请前往Web端配置", nil);
       return;
    }
    UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"EZMain" bundle:[NSBundle mainBundle]];
    NSString *deviceNo = [NSString changgeNonulWithString:deviceInfo[@"fChannelno"]];
    EZPlaybackViewController *backVC = [mainSB instantiateViewControllerWithIdentifier:@"EZPlaybackViewController"];
    if (deviceNo) {
        [EZOPENSDK getDeviceInfo:deviceStr completion:^(EZDeviceInfo *deviceInfo, NSError *error) {
            if (deviceInfo) {
                NSArray *cameraArr = deviceInfo.cameraInfo;
                 if (cameraArr.count>0) {
                     for (int index = 0; index<cameraArr.count; index++) {
                         EZCameraInfo *camera = cameraArr[index];
                         NSInteger deviceno = [deviceNo integerValue];
                         if (deviceno == camera.cameraNo) {
                             //给控制器添附index
                             backVC.cameraIndex = index;
                         }
                     }
                 }
                backVC.deviceInfo = deviceInfo;
                if (self.pushSubid) {
                    
                    [self.navigationController pushViewController:backVC animated:YES];
                }else{
                    [self.ownNaviController pushViewController:backVC animated:YES];
                }
            }
            else {
                [self.tableView makeToast:@"无此设备，请检查设备序列号" duration:2.0 position:@"center"];
            }
       }];
    }else{
        [EZOPENSDK getDeviceInfo:deviceStr completion:^(EZDeviceInfo *deviceInfo, NSError *error) {
            if (deviceInfo) {
                backVC.deviceInfo = deviceInfo;
                [self.ownNaviController pushViewController:backVC animated:YES];
            }
            else {
                [self.tableView makeToast:@"无此设备，请检查设备序列号" duration:2.0 position:@"center"];
            }
       }];
    }
   
}

//跳转详情 点击了播放详情
-(void)clickPlayDetailBtnInCell:(BGQMVideoTableViewCell *)cell withPushData:(NSDictionary *)param{
    if (self.mutArray.count>0) {
        //点击了详情
        NSIndexPath *indexP = [self.tableView indexPathForCell:cell];
        NSDictionary *deviceInfo = self.mutArray[indexP.row];
        NSString *deviceStr = [NSString changgeNonulWithString:deviceInfo[@"fVideokey"]];
        if (!deviceStr || [deviceStr isEqualToString:@""]) {
           
            [self.tableView makeToast:@"未配置设备序列号，请前往Web端配置" duration:2.0 position:@"center"];
            return;
        }
        UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"EZMain" bundle:[NSBundle mainBundle]];
        NSString *deviceNo = [NSString changgeNonulWithString:deviceInfo[@"fChannelno"]];
        EZLivePlayViewController *selfdetailVC = [mainSB instantiateViewControllerWithIdentifier:@"EZLivePlayViewController"];
//        fChannelno
        if (deviceNo) {
            [EZOPENSDK getDeviceInfo:deviceStr completion:^(EZDeviceInfo *deviceInfo, NSError *error) {
                      if (deviceInfo) {
                          NSArray *cameraArr = deviceInfo.cameraInfo;
                          if (cameraArr.count>0) {
                              for (int index = 0; index<cameraArr.count; index++) {
                                  EZCameraInfo *camera = cameraArr[index];
                                  NSInteger deviceno = [deviceNo integerValue];
                                  if (deviceno == camera.cameraNo) {
                                      //给控制器添附index
                                      selfdetailVC.cameraIndex = index;
                                  }
                              }
                          }
                         selfdetailVC.deviceInfo = deviceInfo;
                         if (self.pushSubid) {
                        
                            [self.navigationController pushViewController:selfdetailVC animated:YES];
                        }else{
                              [self.ownNaviController pushViewController:selfdetailVC animated:YES];
                          }
                      }
                      else {
                          [self.tableView makeToast:@"无此设备，请检查设备序列号" duration:2.0 position:@"center"];
                      }
             }];
        }else{
            [EZOPENSDK getDeviceInfo:deviceStr completion:^(EZDeviceInfo *deviceInfo, NSError *error) {
                    if (deviceInfo) {
                        selfdetailVC.deviceInfo = deviceInfo;
                      
                        [self.ownNaviController pushViewController:selfdetailVC animated:YES];
       //                         [self presentViewController:selfdetailVC animated:YES completion:nil];
                    }
                    else {
                        [self.tableView makeToast:@"无此设备，请检查设备序列号" duration:2.0 position:@"center"];
                    }
           }];
        }
    }else{
        [self.tableView makeToast:@"无此设备，请检查Web端设备序列号" duration:2.0 position:@"center"];
    }
}

-(void)clickPlayBtnInCell:(BGQMVideoTableViewCell *)cell withPushData:(CGFloat)param{
//    DefLog(@"param:%f",param);
//    NSIndexPath *path = [self.tableView indexPathForCell:cell];
//    self.cellChangeHeight = param;
//    [self.tableView beginUpdates];
//    [self.tableView endUpdates];
}




@end
