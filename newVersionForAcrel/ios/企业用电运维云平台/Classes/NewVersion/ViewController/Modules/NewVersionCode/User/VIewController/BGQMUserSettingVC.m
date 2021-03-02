//
//  BGQMUserSettingVC.m
//  企业用电运维云平台
//
//  Created by Acrel on 2020/4/23.
//

#import "BGQMUserSettingVC.h"
#import "BGHeadTableViewCell.h"
#import "BGRedSpotCell.h"
#import "BGHeadPortraitViewController.h"

#import "BGLoginViewController.h"
#import "CustomNavigationController.h"
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
#import "BGOnlyAuthWkViewController.h"
#import "BGChangePasswordVC.h"
#import "BGQMSafeViewController.h"

@interface BGQMUserSettingVC ()<QMUITableViewDelegate,QMUITableViewDataSource>
@property (nonatomic,strong) QMUITableView *tableview;
@property (nonatomic,strong) NSArray *tableListArr;

@end

@implementation BGQMUserSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     [self creatView];
     [self getAboutNetData];
}

- (void)creatView{
    self.title = DefLocalizedString(@"Settings");
//    self.tableview = [[QMUITableView alloc] qmui_initWithSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.tableview = [[QMUITableView alloc] initWithFrame:CGRectMake(0, NavigationContentTop, SCREEN_WIDTH, SCREEN_HEIGHT)];
  
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
 
    //头像
    UserManager *user = [UserManager manager];
    NSArray *uiArray = user.rootMenuData[@"rootMenu"];
    //    homeList = [NSArray new];
    for (NSDictionary *userDic in uiArray) {
        NSString *fCode = [NSString changgeNonulWithString:userDic[@"fCode"]];
        if ([fCode isEqualToString:@"userPage"]) {
            
            NSString *imageStr = [NSString changgeNonulWithString:userDic[@"fIconurl"]];
           
        }
    }
    
}

-(void)changeUserViewInfo{
        BGWeakSelf;
//        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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
        [NetService bg_getWithTokenWithPath:BGGetRootMenu params:@{@"english":language,
                                                                   @"projectType":BGProjectType} success:^(id respObjc) {
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

-(void)getAboutNetData{
    if (self.aboutMenuID.length>0) {
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
        [NetService bg_getWithTokenWithPath:getbgSubinfoVoByPid params:@{@"pid":self.aboutMenuID,@"english":language} success:^(id respObjc) {
            NSDictionary *dic = respObjc[@"data"];
            NSArray *arr = dic[@"menuList"];
            if (arr.count>0) {
//                for (NSDictionary *userInfo in arr) {
//                    if ([userInfo[@"fCode"] isEqualToString:BGPersonalPage]) {
                        weakSelf.tableListArr = arr;
//                    }
//                }
                  [weakSelf.tableview reloadData];
            }else{
                
            }
           
        } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
            
        }];
    }
}
#pragma mark - <QMUITableViewDataSource, QMUITableViewDelegate>

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.tableListArr.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

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
        NSString *iconUrl = [NSString changgeNonulWithString:self.tableListArr[indexPath.row][@"fIconurl"]];
        NSString *imageName;
        if ([code isEqualToString:@"personInfo"]) {
            imageName = @"userOwnPic0";
        }else if ([code isEqualToString:@"feedbackLower"]){
            imageName = @"userOwnPic1";
        }else if ([code isEqualToString:@"clearCache"]){
            imageName = @"userOwnPic2";
//            NSString *sizeStr = [self folderSize];
//            cell.rightLB.text = sizeStr;
//            cell.rightLB.textAlignment = NSTextAlignmentRight;
        }else if ([code isEqualToString:@"versionInfoLower"]){
            imageName = @"userOwnPic3";
        }else if ([code isEqualToString:@"shareAppLower"]){
            imageName = @"userOwnPic4";
        }else if ([code isEqualToString:@"switchLanguageLower"]){
            imageName = @"userOwnPic5";
        }else if ([code isEqualToString:@"MsgNotificationLower"]){
            imageName = @"userOwnPic6";
        }else if ([code isEqualToString:@"pushRecord"]){
            imageName = @"userOwnPic6";
        }else if ([code isEqualToString:@"settings"]){
            imageName = @"userOwnPic6";
        }else if ([code isEqualToString:@"accountSecurity"]){
            imageName = @"userOwnPic9";
        }else if ([code isEqualToString:@"EZAuth"]){
            imageName = @"userOwnPic10";
        }else if ([code isEqualToString:@"UploadPosition"]){
            imageName = @"userOwnPic11";
        }else {
            imageName = [NSString stringWithFormat:@"userOwnPic%ld",(long)indexPath.row];
        }
        if (iconUrl && iconUrl.length>0) {
             cell.iconIV.image = [UIImage imageNamed:imageName];
//            [cell.iconIV sd_setImageWithURL:[NSURL URLWithString:[getSystemIconADS stringByAppendingString:iconUrl]] placeholderImage:[UIImage imageNamed:imageName]];
        }else{
            cell.iconIV.image = [UIImage imageNamed:imageName];
        }
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
    
}

//点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     [tableView deselectRowAtIndexPath:indexPath animated:NO];

         NSString *code = [NSString changgeNonulWithString:self.tableListArr[indexPath.row][@"fCode"]];

        if ([code isEqualToString:@"personInfo"]) {
            BGQMPersonalInfoViewController *themeVC = [[BGQMPersonalInfoViewController alloc] init];
            [self.navigationController pushViewController:themeVC animated:YES];
        }else if([code isEqualToString:@"feedbackLower"]){
            BGQMFeedBackViewController *feedBackVC = [[BGQMFeedBackViewController alloc] init];
            [self.navigationController pushViewController:feedBackVC animated:YES];
//            JGUserFeedBackViewController *feedBackVC = [[JGUserFeedBackViewController alloc] init];
//            feedBackVC.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:feedBackVC animated:YES];
        }else if ([code isEqualToString:@"clearCache"]){
             [self getfolderSize];
        }else if ([code isEqualToString:@"versionInfoLower"]){
            CSAboutViewController *aboutVC = [[CSAboutViewController alloc] initWithNibName:@"CSAboutViewController" bundle:nil];
            NSString *menuID = [NSString changgeNonulWithString:self.tableListArr[indexPath.row][@"fMenuid"]];
            aboutVC.aboutMenuID = menuID;
            [self.navigationController pushViewController:aboutVC animated:YES];
        }else if ([code isEqualToString:@"shareAppLower"]){
            [self shareAPP];
        }else if ([code isEqualToString:@"switchLanguageLower"]){
            [self changeLanguage];
        }
        else if ([code isEqualToString:@"MsgNotificationLower"]){
            [self setMessageNotification];
        }
        //推送记录
        else if ([code isEqualToString:@"pushRecord"]){
                   [self setMessageNotification];
        }else if ([code isEqualToString:@"accountSecurity"]){
            //账户与安全
            BGQMSafeViewController *themeVC = [[BGQMSafeViewController alloc] init];
            NSString *menuID = [NSString changgeNonulWithString:self.tableListArr[indexPath.row][@"fMenuid"]];
            themeVC.aboutMenuID = menuID;
            [self.navigationController pushViewController:themeVC animated:YES];
        }
        //设置
        else if ([code isEqualToString:@"settings"]){
                BGQMUserSettingVC *themeVC = [[BGQMUserSettingVC alloc] init];
                [self.navigationController pushViewController:themeVC animated:YES];
        }else if ([code isEqualToString:@"EZAuth"]){
            [self pushAuthorization];
        }else if ([code isEqualToString:@"UploadPosition"]){
            [self uploadPositioning];
        }
}


//跳转萤石云授权
-(void)pushAuthorization{
//    NSInteger subid;
//    if (self.pushSubid) {
//        subid = [self.pushSubid integerValue];
//    } else {
//        subid = [[UserManager manager].fsubID integerValue];
//    }
    BGOnlyAuthWkViewController *webview = [[BGOnlyAuthWkViewController alloc] init];
    webview.isUseOnline = YES;
    webview.onlineUrlString =   [NSString stringWithFormat:@"https://openauth.ys7.com/trust/device?client_id=cec0dca73dfc4782bc84375a57cd8170&response_type=code&state=test"];
//    if (self.pushSubid) {
        [self.navigationController pushViewController:webview animated:YES];
//    }else{
//        [self.ownNaviController pushViewController:webview animated:YES];
//    }
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

#pragma mark - 上传定位
//上传定位
-(void)uploadPositioning{
    UserManager *user = [UserManager manager];
    NSString *versionURL = [user.rootMenuData objectForKeyNotNull:@"H5_2"];
    NSString *fAction;
         NSString *fFunctionurl;
         for (NSDictionary *nodeDic in self.tableListArr) {
             if ([nodeDic[@"fCode"] isEqualToString:@"MsgNotificationLower"]) {
                 fAction = [NSString changgeNonulWithString:nodeDic[@"fActionurl"]];
                 fFunctionurl = [NSString changgeNonulWithString:nodeDic[@"fFunctionfield"]];
             }
         }
         if (fFunctionurl.length>0) {
            BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"UploadPosition" ofType:@"html" inDirectory:@"aDevices"];
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
}

#pragma mark - 设置消息通知开关
-(void)setMessageNotification{
//    BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"notifySetting" ofType:@"html" inDirectory:@"aDevices"];
//
//    nomWebView.isUseOnline = NO;
//    nomWebView.localUrlString = filePath;
//    nomWebView.showWebType = showWebTypeDevice;
////    nomWebView.urlParams = url;
////    nomWebView.titleName = DefLocalizedString(@"MsgNoticeSettings");
//    [self.navigationController pushViewController:nomWebView animated:YES];
    UserManager *user = [UserManager manager];
    NSString *versionURL = [user.rootMenuData objectForKeyNotNull:@"H5_2"];
    NSString *fAction;
         NSString *fFunctionurl;
         for (NSDictionary *nodeDic in self.tableListArr) {
             if ([nodeDic[@"fCode"] isEqualToString:@"MsgNotificationLower"]) {
                 fAction = [NSString changgeNonulWithString:nodeDic[@"fActionurl"]];
                 fFunctionurl = [NSString changgeNonulWithString:nodeDic[@"fFunctionfield"]];
             }
         }
         if (fFunctionurl.length>0) {
            BGUIWebViewController *nomWebView = [[BGUIWebViewController alloc] init];
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"notifySetting" ofType:@"html" inDirectory:@"aDevices"];
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
}



@end
