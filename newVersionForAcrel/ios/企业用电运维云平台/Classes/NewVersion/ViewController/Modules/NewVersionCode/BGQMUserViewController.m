//
//  BGQMUserViewController.m
//  变电所运维
//
//  Created by Acrel on 2019/6/3.
//  
//

#import "BGQMUserViewController.h"
#import "BGHeadTableViewCell.h"
#import "BGRedSpotCell.h"
#import "BGHeadPortraitViewController.h"

#import "BGLoginViewController.h"
#import "CustomNavigationController.h"
#import "BGQMloginViewController.h"
#import "QDThemeViewController.h"
#import "SDImageCache.h"
#import "BGQMUserHeadTableViewCell.h"
#import "JGUserFeedBackViewController.h"
#import "BGQMFeedBackViewController.h"
#import "CSAboutViewController.h"
#import "BGQMPersonalInfoViewController.h"
//#import "WXApi.h"
#import "BGQMChangeLanguageViewController.h"
#import "BGUIWebViewController.h"

@interface BGQMUserViewController ()<QMUITableViewDelegate,QMUITableViewDataSource>
@property (nonatomic,strong) QMUITableView *tableview;
@property (nonatomic, strong) UIView *headview;
@property (nonatomic,strong) UIImageView *imageHeadPic;
@property (nonatomic,strong) QMUILabel *nameLabel;
@property (nonatomic,strong) QMUILabel *telLabel;
@property (nonatomic,strong) NSArray *tableListArr;

@end

@implementation BGQMUserViewController

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
    // 对 self.view 的操作写在这里
    [self creatView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     self.navigationController.navigationBarHidden = YES;
    //注册通知(接收,监听,一个通知)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification3:) name:@"postSucceed" object:nil];
    [self changeUserViewInfo];
    [self getPersonalInfo];
//    [self getnedataByPid];
//    [];
}

-(void)changeUserViewInfo{
        BGWeakSelf;
//        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [NetService bg_getWithTokenWithPath:BGGetRootMenu params:nil success:^(id respObjc) {
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
            UserManager *user = [UserManager manager];
            NSDictionary *rootData = [respObjc objectForKeyNotNull:kdata];
            if (rootData) {
               NSArray *menuArr = [rootData objectForKeyNotNull:@"rootMenu"];
               if (!menuArr || !menuArr.count) {
                   DefQuickAlert(@"为确保正常显示，请前往网页端配置APP菜单功能，并至少添加一个tab页功能", nil);
                   return ;
               }
            }
            user.rootMenuData = respObjc[kdata];
            NSString *imageSysBaseUrl = respObjc[kdata][@"iconUrl"];
            [DefNSUD setObject:imageSysBaseUrl forKey:@"systemImageUrlstr"];
            DefNSUDSynchronize
            NSArray *array = user.rootMenuData[@"rootMenu"];
            for (NSDictionary *userInfo in array) {
                if ([userInfo[@"fCode"] isEqualToString:BGPersonalPage]) {
                    weakSelf.tableListArr = userInfo[@"nodes"];
                }
            }
            [weakSelf.tableview reloadData];
        } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
        }];
}

//-(void)getnedataByPid{
//    [NetService bg_getWithTokenWithPath:getbgSubinfoVoByPid params:@{@"pid":self.aboutMenuID} success:^(id respObjc) {
//        NSDictionary *dic = respObjc[@"data"];
//        NSArray *arr = dic[@"menuList"];
//        if (arr.count>0) {
//            for (NSDictionary *dic in arr) {
//                NSString *fCode = dic[@"fCode"];
//                if ([fCode isEqualToString:@"appDescribe"]) {
//                    weakSelf.detailText.text = [NSString changgeNonulWithString:dic[@"fExplain"]];
//                } else if([fCode isEqualToString:@"Copyright"]){
//                    weakSelf.banquanBottomText.text = [NSString changgeNonulWithString:dic[@"fExplain"]];
//                }
//            }
//        }
//    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
//
//    }];
//}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    self.title = DefLocalizedString(@"About");
}

- (void)creatView{
    self.tableview = [[QMUITableView alloc] qmui_initWithSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT-BGHeight_TabBar)];
    if (@available(iOS 11.0, *)) {
        self.tableview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
        // Fallback on earlier versions
    }
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.backgroundColor = [UIColor whiteColor];
    //遮盖状态栏层
//    UIWindow *wind = [[UIWindow alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
//    wind.windowLevel = UIWindowLevelStatusBar;
//    wind.backgroundColor = UIColorTheme4;
//    wind.userInteractionEnabled = NO;
//    wind.hidden = NO;
//    [[UIApplication sharedApplication].keyWindow addSubview:wind];
    //247
//    self.tableview.backgroundColor = COLOR_BACKGROUND;
    [self.view addSubview:self.tableview];
    [self.tableview registerNib:[UINib nibWithNibName:@"BGRedSpotCell" bundle:nil] forCellReuseIdentifier:@"BGUserRedSpotCell"];
//    [self.tableview registerNib:[UINib nibWithNibName:@"BGHeadTableViewCell" bundle:nil] forCellReuseIdentifier:@"BGHeadTableViewCell"];
    [self.tableview registerNib:[UINib nibWithNibName:@"BGQMUserHeadTableViewCell" bundle:nil] forCellReuseIdentifier:@"BGQMUserHeadTableViewCell"];
    self.headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 250)];
    [self.headview setBackgroundColor:UIColorTheme4];
    //背景图
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ownbgPic"]];
    imageView.frame =CGRectMake(0, 0, SCREEN_WIDTH, 250);
    //头像
    UserManager *user = [UserManager manager];
    NSArray *uiArray = user.rootMenuData[@"rootMenu"];
    //    homeList = [NSArray new];
    for (NSDictionary *userDic in uiArray) {
        NSString *fCode = [NSString changgeNonulWithString:userDic[@"fCode"]];
        if ([fCode isEqualToString:@"userPage"]) {
            
            NSString *imageStr = [NSString changgeNonulWithString:userDic[@"fIconurl"]];
                    
            //        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(insideImageOpionX, 8, insideHeight/5*3-15, insideHeight/5*3-15)];
                    
            DefLog(@"%@",[getSystemIconADS stringByAppendingString:imageStr]);
            if (!imageStr.length) {
                imageView.image = [UIImage imageNamed:@"ownbgPic"];
            }else{
                 [imageView sd_setImageWithURL:[NSURL URLWithString:[getSystemIconADS stringByAppendingString:imageStr]] placeholderImage:[UIImage imageNamed:@" bghomeheadpic"]];
            }
        }
    }
    
    self.imageHeadPic = [[UIImageView alloc] initWithFrame:CGRectMake(15, 110, 80, 80)];
    if (user.imageUrl) {
         [self.imageHeadPic sd_setImageWithURL:[NSURL URLWithString:[getImageIconADS stringByAppendingString:user.imageUrl]] placeholderImage:[UIImage imageNamed:@"touxiang"]];
        self.imageHeadPic.layer.masksToBounds = YES;
        self.imageHeadPic.layer.cornerRadius = 40.f;
    }else{
        [self.imageHeadPic setImage:[UIImage imageNamed:@"touxiang"]];
    }
    self.imageHeadPic.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImageViewClick)];
    [self.imageHeadPic addGestureRecognizer:tapGesture];
//    [self.imageHeadPic setBackgroundImage:[UIImage imageNamed:@"touxiang"] forState:UIControlStateNormal];
//    [self.imageHeadPic addTarget:self action:@selector(headImageViewClick:) forControlEvents:UIControlEventTouchUpInside];
    //昵称
    self.nameLabel = [[QMUILabel alloc] initWithFrame:CGRectMake(18, 186, 200, 30)];
    self.nameLabel.text = @"";
    self.nameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];//加粗
    
    //电话号码
    self.telLabel = [[QMUILabel alloc] initWithFrame:CGRectMake(18, 216, 200, 30)];
    self.telLabel.text = @"";
    self.telLabel.font = [UIFont systemFontOfSize:14.f];
    
    [self.headview addSubview:imageView];
    [self.headview addSubview:self.imageHeadPic];
    [self.headview addSubview:self.nameLabel];
    [self.headview addSubview:self.telLabel];
    
    self.tableview.tableHeaderView = self.headview;
}

-(void)getPersonalInfo{
    UserManager *user = [UserManager manager];
    if (!user.bguserId.length) {
        return;
    }
    __weak __typeof(self)weakSelf = self;
    [NetService bg_getWithTokenWithPath:@"/getUserInfo" params:@{@"fUserid":user.bguserId} success:^(id respObjc) {
        DefLog(@"personInfo:%@",user.bguserId);
        NSString *imageBaseUrl = respObjc[@"data"][@"userIconUrl"];
        NSDictionary *userInfo = respObjc[@"data"][@"userInfo"];
        NSString *nameStr = [NSString changgeNonulWithString:userInfo[@"fUsername"]];
        NSString *apppicturename = [NSString changgeNonulWithString:userInfo[@"fApppicturename"]];
        NSString *phone = [NSString changgeNonulWithString:userInfo[@"fUserphone"]];
        NSString *email = [NSString changgeNonulWithString:userInfo[@"fUseremail"]];
        UserManager *user = [UserManager manager];
        user.bgnickName = nameStr;
        user.bgaddress = email;
        user.bgtelphone = phone;
        user.imageUrl = apppicturename;
        [DefNSUD setObject:imageBaseUrl forKey:@"imageUrlString"];
        DefNSUDSynchronize
        [weakSelf reloadPersonalData];
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
        
    }];
}

-(void)reloadPersonalData{
    UserManager *personaldata = [UserManager manager];
    self.nameLabel.text = personaldata.bgnickName;
    self.telLabel.text = personaldata.bgtelphone;
//    self.nameLabel.text = @"";
//    self.telLabel.text = @"";
    if (personaldata.imageUrl.length>0) {
        [self.imageHeadPic sd_setImageWithURL:[NSURL URLWithString:[getImageIconADS stringByAppendingString:personaldata.imageUrl]] placeholderImage:[UIImage imageNamed:@"touxiang"]];
        self.imageHeadPic.layer.masksToBounds = YES;
        self.imageHeadPic.layer.cornerRadius = 40.f;
    }
}

#pragma mark - <QMUITableViewDataSource, QMUITableViewDelegate>

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return self.tableListArr.count;
    }else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row == 0 && indexPath.section == 0) {
//        BGHeadTableViewCell *headCell = [tableView dequeueReusableCellWithIdentifier:@"BGHeadTableViewCell"];
//        headCell.selectionStyle = UITableViewCellSelectionStyleNone;
//        headCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        return headCell;
//    }else
    if(indexPath.section == 0){
        BGRedSpotCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGUserRedSpotCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        if (!cell) {
//            cell = [[QMUITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"qmuiCell"];
//
////            userOwnPIc0
////            cell.imageView.image = [UIImage qmui_imageWithShape:QMUIImageShapeOval size:CGSizeMake(16, 16) lineWidth:2 tintColor:[QDCommonUI randomThemeColor]];
////            if (indexPath.row == 1) {
////                cell.detailTextLabel.text = [self folderSize];
////            }
//        }
        // reset
//        cell.imageEdgeInsets = UIEdgeInsetsZero;
//        cell.textLabelEdgeInsets = UIEdgeInsetsZero;
//        cell.detailTextLabelEdgeInsets = UIEdgeInsetsZero;
//        cell.accessoryEdgeInsets = UIEdgeInsetsZero;
        
        
        NSString *textName = [NSString changgeNonulWithString:self.tableListArr[indexPath.row][@"fMenuname"]];
        cell.redSpotBTN.hidden = YES;
        cell.rightLB.text = @"";
        if (textName.length>0) {
            cell.leftLB.text = textName;
        }
        NSString *code = [NSString changgeNonulWithString:self.tableListArr[indexPath.row][@"fCode"]];
        NSString *imageName;
        if ([code isEqualToString:@"personInfo"]) {
            imageName = @"userOwnPic0";
        }else if ([code isEqualToString:@"feedback"]){
            imageName = @"userOwnPic1";
        }else if ([code isEqualToString:@"clearCache"]){
            imageName = @"userOwnPic2";
//            NSString *sizeStr = [self folderSize];
//            cell.rightLB.text = sizeStr;
//            cell.rightLB.textAlignment = NSTextAlignmentRight;
            
        }else if ([code isEqualToString:@"versionInfo"]){
            imageName = @"userOwnPic3";
        }else if ([code isEqualToString:@"shareApp"]){
            imageName = @"userOwnPic4";
        }else if ([code isEqualToString:@"switchLanguage"]){
            imageName = @"userOwnPic5";
        }else if ([code isEqualToString:@"MsgNotification"]){
            imageName = @"userOwnPic6";
        }else {
            imageName = [NSString stringWithFormat:@"userOwnPic%ld",(long)indexPath.row];
        }
        cell.iconIV.image = [UIImage imageNamed:imageName];
        
//        switch (indexPath.row) {
//            case 0:
//                cell.textLabel.text = DefLocalizedString(@"PersonalInfo");
//                break;
//            case 1:
//                cell.textLabel.text = DefLocalizedString(@"Feedback");
//                break;
//            case 2:
//                cell.textLabel.text = DefLocalizedString(@"ClearCache");
//                break;
//            case 3:
//                cell.textLabel.text = DefLocalizedString(@"VersionInfo");
//                break;
//            case 4:
//                cell.textLabel.text = DefLocalizedString(@"ShareApp");
//                break;
////            case 5:
////                cell.textLabel.text = @"系统设置";
////                break;
//            default:
//                break;
//        }
        return cell;
    }else{
        BGQMUserHeadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGQMUserHeadTableViewCell"];
//        [cell.quitOutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
//        if (!cell) {
//            cell = [[BGQMUserHeadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"quitCell"];
////            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
////            cell.imageView.image = [UIImage qmui_imageWithShape:QMUIImageShapeOval size:CGSizeMake(16, 16) lineWidth:2 tintColor:[QDCommonUI randomThemeColor]];
//            // reset
////            cell.imageEdgeInsets = UIEdgeInsetsZero;
////            cell.textLabelEdgeInsets = UIEdgeInsetsZero;
////            cell.detailTextLabelEdgeInsets = UIEdgeInsetsZero;
////            cell.accessoryEdgeInsets = UIEdgeInsetsZero;
////            cell.textLabel.text = @"退出登录";
////            cell.textLabel.textColor = [UIColor redColor];
//        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     [tableView deselectRowAtIndexPath:indexPath animated:NO];
//    if (indexPath.section == 0) {
//
//    }else
    if(indexPath.section == 0){
         NSString *code = [NSString changgeNonulWithString:self.tableListArr[indexPath.row][@"fCode"]];
//        if (indexPath.row == 6) {
//            QDThemeViewController *themeVC = [[QDThemeViewController alloc] init];
//            [self.navigationController pushViewController:themeVC animated:YES];
//        }else{
//            BGQMloginViewController *web = [[BGQMloginViewController alloc] init];
//            [self.navigationController pushViewController:web animated:YES];
//        }
        if ([code isEqualToString:@"personInfo"]) {
            BGQMPersonalInfoViewController *themeVC = [[BGQMPersonalInfoViewController alloc] init];
            [self.navigationController pushViewController:themeVC animated:YES];
        }else if([code isEqualToString:@"feedback"]){
            BGQMFeedBackViewController *feedBackVC = [[BGQMFeedBackViewController alloc] init];
            [self.navigationController pushViewController:feedBackVC animated:YES];
//            JGUserFeedBackViewController *feedBackVC = [[JGUserFeedBackViewController alloc] init];
//            feedBackVC.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:feedBackVC animated:YES];
        }else if ([code isEqualToString:@"clearCache"]){
             [self getfolderSize];
        }else if ([code isEqualToString:@"versionInfo"]){
            CSAboutViewController *aboutVC = [[CSAboutViewController alloc] initWithNibName:@"CSAboutViewController" bundle:nil];
            NSString *menuID = [NSString changgeNonulWithString:self.tableListArr[indexPath.row][@"fMenuid"]];
            aboutVC.aboutMenuID = menuID;
            [self.navigationController pushViewController:aboutVC animated:YES];
        }else if ([code isEqualToString:@"shareApp"]){
            [self shareAPP];
        }else if ([code isEqualToString:@"switchLanguage"]){
            [self changeLanguage];
        }
        else if ([code isEqualToString:@"MsgNotification"]){
            [self setMessageNotification];
        }
    }else{

    }
}

//头部间隙
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0 || section == 2) {
        return 0.1f;
    }
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    view.tintColor = [UIColor whiteColor];
    view.backgroundColor = [UIColor whiteColor];
}

-(void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    view.tintColor = [UIColor whiteColor];
}

//cellheight
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return DefCellHeight;
    }else{
        return 56.f;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 2) {
        return 0.1f;
    }else{
        return 0.1f;
    }
}

#pragma mark - 点击了头像
-(void)headImageViewClick{
    DefLog(@"点击了头像");
    BGHeadPortraitViewController *hpvc = [[BGHeadPortraitViewController alloc] initWithNibName:@"BGHeadPortraitViewController" bundle:nil];
    hpvc.headerImage = self.imageHeadPic.image;
    [self.navigationController pushViewController:hpvc animated:YES];
}

#pragma mark - 清除缓存
-(void)getfolderSize{
    
//    CGFloat totalSize = [self folderSize];
    NSString *sizeStr = [self folderSize];
    if ([sizeStr isEqualToString:@"0.0KB"]) {
            NSString *messae = [NSString stringWithFormat:DefLocalizedString(@"nownoClearCache")];
        BGWeakSelf;
            QMUIAlertAction *action2 = [QMUIAlertAction actionWithTitle:DefLocalizedString(@"Sure") style:QMUIAlertActionStyleCancel handler:^(__kindof QMUIAlertController * _Nonnull aAlertController, QMUIAlertAction * _Nonnull action) {
                [weakSelf.tableview reloadData];
            }];
            QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:DefLocalizedString(@"ClearCache") message:messae preferredStyle:QMUIAlertControllerStyleAlert];
            [alertController addAction:action2];
            
            QMUIVisualEffectView *visualEffectView = [[QMUIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
            visualEffectView.foregroundColor = UIColorMakeWithRGBA(255, 255, 255, .7);// 一般用默认值就行，不用主动去改，这里只是为了展示用法
            alertController.mainVisualEffectView = visualEffectView;
            alertController.alertHeaderBackgroundColor = nil;// 当你需要磨砂的时候请自行去掉这几个背景色，不然这些背景色会盖住磨砂
            alertController.alertButtonBackgroundColor = nil;
            [alertController showWithAnimated:YES];
            return;
    }
    
//    NSString *messae = [NSString stringWithFormat:@"缓存大小为%@，是否清理？",sizeStr];
    NSString *message = [NSString stringWithFormat:@"%@%@,%@?",DefLocalizedString(@"Thecachesizeis"),sizeStr,DefLocalizedString(@"Wasitcleanedup")];
    __weak __typeof(self)weakSelf = self;
    QMUIAlertAction *action = [QMUIAlertAction actionWithTitle:DefLocalizedString(@"Sure") style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController * _Nonnull aAlertController, QMUIAlertAction * _Nonnull action) {
        [MBProgressHUD showSuccess:@"清除成功"];
        [weakSelf clearCache];
    }];
    QMUIAlertAction *action2 = [QMUIAlertAction actionWithTitle:DefLocalizedString(@"Cancel") style:QMUIAlertActionStyleCancel handler:^(__kindof QMUIAlertController * _Nonnull aAlertController, QMUIAlertAction * _Nonnull action) {
       
    }];
    QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:DefLocalizedString(@"ClearCache")  message:message preferredStyle:QMUIAlertControllerStyleAlert];
    [alertController addAction:action];
    [alertController addAction:action2];
    
    QMUIVisualEffectView *visualEffectView = [[QMUIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    visualEffectView.foregroundColor = UIColorMakeWithRGBA(255, 255, 255, .7);// 一般用默认值就行，不用主动去改，这里只是为了展示用法
    alertController.mainVisualEffectView = visualEffectView;
    alertController.alertHeaderBackgroundColor = nil;// 当你需要磨砂的时候请自行去掉这几个背景色，不然这些背景色会盖住磨砂
    alertController.alertButtonBackgroundColor = nil;
    [alertController showWithAnimated:YES];
}


-(void)clearCache{
    //===============清除缓存==============
    //获取路径
    NSString*cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES)objectAtIndex:0];
    
    //返回路径中的文件数组
    NSArray*files = [[NSFileManager defaultManager]subpathsAtPath:cachePath];
    
    DefLog(@"文件数：%ld",[files count]);
    for(NSString *p in files){
        NSError*error;
        
        NSString*path = [cachePath stringByAppendingString:[NSString stringWithFormat:@"/%@",p]];
        
        if([[NSFileManager defaultManager]fileExistsAtPath:path])
        {
            BOOL isRemove = [[NSFileManager defaultManager]removeItemAtPath:path error:&error];
            if(isRemove) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"postSucceed" object:nil userInfo:nil];
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    // 需要在主线程执行的代码
//                    [MBProgressHUD showSuccess:@"清除成功"];
//                });
                
                //这里发送一个通知给外界，外界接收通知，可以做一些操作（比如UIAlertViewController）
            }else{
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    // 需要在主线程执行的代码
//                    [MBProgressHUD showError:@"清除失败"];
//                });
               
            }
        }
    }
}

// 缓存大小
- (NSString *)folderSize{
    CGFloat folderSize = 0.0;
    //获取路径
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES)firstObject];
    
    //获取所有文件的数组
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachePath];
    
    DefLog(@"文件数：%ld",files.count);
    
    for(NSString *path in files) {
        
        NSString*filePath = [cachePath stringByAppendingString:[NSString stringWithFormat:@"/%@",path]];
        
        //累加
        folderSize += [[NSFileManager defaultManager]attributesOfItemAtPath:filePath error:nil].fileSize;
    }
    NSString *sizeStr;
    CGFloat size = folderSize / (1024 *1024);
    if (size<1) {
        CGFloat kbSize = folderSize/1024;
        if (kbSize < 0.2) {
            sizeStr = @"0.0KB";
        }else{
            sizeStr = [NSString stringWithFormat:@"%.1fKB",kbSize];
        }
    }else{
        sizeStr = [NSString stringWithFormat:@"%.1fMB",size];
    }
    return sizeStr;
}


//实现方法
-(void)notification3:(NSNotification *)noti{
    [MBProgressHUD showSuccess:@"清除成功"];
    //使用userInfo处理消
//    [MBProgressHUD showSuccess:@"清除成功"];
}

//
-(void)dealloc{
    
    //移除观察者
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 分享APP
-(void)shareAPP{
    QMUIMoreOperationController *moreOperationController = [[QMUIMoreOperationController alloc] init];
    //下载链接
    NSString *shareString = [NSString stringWithFormat:@"http://itunes.apple.com/app/id%@",kAppleId];
    moreOperationController.items = @[
                                      // 第一行
                                      @[
//                                          [QMUIMoreOperationItemView itemViewWithImage:UIImageMake(@"icon_moreOperation_shareFriend") title:DefLocalizedString(@"ShareWechatFriends") handler:^(QMUIMoreOperationController *moreOperationController, QMUIMoreOperationItemView *itemView) {
//                                              if([WXApi isWXAppInstalled]){//判断当前设备是否安装微信客户端
//
//                                                  //创建多媒体消息结构体
//                                                  WXMediaMessage *message = [WXMediaMessage message];
//                                                  message.title = @"变电所运维";//标题
//                                                  message.description = @"上海安科瑞股份有限公司";//描述
//                                                  [message setThumbImage:[UIImage imageNamed:@"app-vision.png"]];//设置预览图
//
//                                                  //创建网页数据对象
//                                                  WXWebpageObject *webObj = [WXWebpageObject object];
//                                                  webObj.webpageUrl = shareString;//链接
//                                                  message.mediaObject = webObj;
//
//                                                  SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
//                                                  sendReq.bText = NO;//不使用文本信息
//                                                  sendReq.message = message;
//                                                  sendReq.scene = WXSceneSession;//分享到好友会话
//
//                                                  [WXApi sendReq:sendReq];//发送对象实例
//                                              }else{
//
//                                                  //未安装微信应用或版本过低
//                                              }
//                                              [moreOperationController hideToBottom];// 如果嫌每次都在 handler 里写 hideToBottom 烦，也可以直接把这句写到 moreOperationController:didSelectItemView: 里，它可与 handler 共存
//                                          }],
//                                          [QMUIMoreOperationItemView itemViewWithImage:UIImageMake(@"icon_moreOperation_shareMoment") title:DefLocalizedString(@"ShareWechatFriendCircle") handler:^(QMUIMoreOperationController *moreOperationController, QMUIMoreOperationItemView *itemView) {
//                                              if([WXApi isWXAppInstalled]){//判断当前设备是否安装微信客户端
//
//                                                  //创建多媒体消息结构体
//                                                  WXMediaMessage *message = [WXMediaMessage message];
//                                                  message.title = @"变电所运维";//标题
//                                                  message.description = @"上海安科瑞股份有限公司";//描述
//                                                  [message setThumbImage:[UIImage imageNamed:@"app-vision.png"]];//设置预览图
//
//                                                  //创建网页数据对象
//                                                  WXWebpageObject *webObj = [WXWebpageObject object];
//                                                  webObj.webpageUrl = shareString;//链接
//                                                  message.mediaObject = webObj;
//
//                                                  SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
//                                                  sendReq.bText = NO;//不使用文本信息
//                                                  sendReq.message = message;
//                                                  sendReq.scene = WXSceneTimeline;//分享到好友会话
//
//                                                  [WXApi sendReq:sendReq];//发送对象实例
//                                              }else{
//
//                                                  //未安装微信应用或版本过低
//                                              }
//                                              [moreOperationController hideToBottom];
//                                          }],
                                          [QMUIMoreOperationItemView itemViewWithImage:UIImageMake(@"icon_link") title:DefLocalizedString(@"Copylinks")  handler:^(QMUIMoreOperationController *moreOperationController, QMUIMoreOperationItemView *itemView) {
                                              UIPasteboard *pab = [UIPasteboard generalPasteboard];
                                              [pab setString:shareString];
                                              if (pab == nil) {
                                                  [MBProgressHUD showError:@"复制失败"];
                                              }else
                                              {
                                                  [MBProgressHUD showSuccess:@"已复制"];
                                              }
                                              [moreOperationController hideToBottom];
                                          }]
                                          ],
                                      ];
    [moreOperationController.cancelButton setTitle:DefLocalizedString(@"Cancel") forState:UIControlStateNormal];
    [moreOperationController showFromBottom];
}

#pragma mark - 切换语言
-(void)changeLanguage{
    BGQMChangeLanguageViewController *changeLVC = [[BGQMChangeLanguageViewController alloc] init];
    [self.navigationController pushViewController:changeLVC animated:YES];
}

#pragma mark - 设置消息通知开关
-(void)setMessageNotification{
    BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"msgNotifSetting" ofType:@"html" inDirectory:@"aDevices"];
    nomWebView.isUseOnline = NO;
    nomWebView.localUrlString = filePath;
    nomWebView.showWebType = showWebFromMsgNotif;
//    nomWebView.urlParams = url;
    nomWebView.titleName = @"消息通知设置";
    [self.navigationController pushViewController:nomWebView animated:YES];
}

@end
