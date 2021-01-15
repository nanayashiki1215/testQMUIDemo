//
//  HintViewController.m
//  LCOpenSDKDemo
//
//  Created by chenjian on 16/7/11.
//  Copyright (c) 2016年 lechange. All rights reserved.
//

//#import "LCOpenSDK_Prefix.h"
#import "AddDeviceViewController.h"
#import "DeviceOperationViewController.h"
#import "DeviceViewController.h"
#import "LiveVideoViewController.h"
#import "MessageViewController.h"
#import "RecordViewController.h"
#import <Foundation/Foundation.h>

@interface DeviceViewController ()
{
    NSInteger m_devKeyIndex;
    NSInteger m_chnKeyIndex;
    LCOpenSDK_Utils* m_util;
}

@end

@implementation DeviceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    m_util = [[LCOpenSDK_Utils alloc] init];
    // Do any additional setup after loading the view, typically from a nib.
    UINavigationItem* item = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(DEVICE_TITLE_TXT, nil)];
    super.m_navigationBar.tintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];

    UIButton* right = [UIButton buttonWithType:UIButtonTypeCustom];
    [right setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 5 - 40, 0, 50, 30)];
    [right setBackgroundImage:[UIImage leChangeImageNamed:AddDevice_Png] forState:UIControlStateNormal];
    [right addTarget:self action:@selector(onAddDevice:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* rightBtn = [[UIBarButtonItem alloc] initWithCustomView:right];
    [item setRightBarButtonItem:rightBtn animated:NO];
    //[bar pushNavigationItem:item animated:NO];

    UIButton* left = [UIButton buttonWithType:UIButtonTypeCustom];
    [left setFrame:CGRectMake(0, 0, 50, 30)];
    UIImage* imgLeft = [UIImage leChangeImageNamed:Back_Btn_Png];

    [left setBackgroundImage:imgLeft forState:UIControlStateNormal];
    [left addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* leftBtn = [[UIBarButtonItem alloc] initWithCustomView:left];
    [item setLeftBarButtonItem:leftBtn animated:NO];
    [super.m_navigationBar pushNavigationItem:item animated:NO];

    [self.view addSubview:super.m_navigationBar];
    m_devListView = [[UITableView alloc] initWithFrame:CGRectMake(0, super.m_yOffset, self.view.frame.size.width, self.view.frame.size.height - super.m_yOffset - 10)];
    [self.view addSubview:m_devListView];
    m_devListView.delegate = self;
    m_devListView.dataSource = self;

    m_devListView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    m_devListView.separatorColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    m_devListView.allowsSelection = YES;

    m_progressInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    m_progressInd.transform = CGAffineTransformMakeScale(2.0, 2.0);
    m_progressInd.center = CGPointMake(self.view.center.x, self.view.center.y);
    [self.view addSubview:m_progressInd];

    m_toastLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
    m_toastLab.center = self.view.center;
    m_toastLab.backgroundColor = [UIColor whiteColor];
    m_toastLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:m_toastLab];

    [self.view bringSubviewToFront:m_toastLab];
    [self.view bringSubviewToFront:m_progressInd];
    NSString* cerPath=@"";
    /*if ([NSLocalizedString(LANGUAGE_TXT, nil) isEqualToString:@"zh"]) {
        cerPath = [[NSBundle mainBundle] pathForResource:@"cert" ofType:@"pem"];
    } else {
        cerPath = [[NSBundle mainBundle] pathForResource:@"cert_en" ofType:@"pem"];
    }*/
    self.m_hc = [[LCOpenSDK_Api shareMyInstance] initOpenApi:80 == m_iPort ? PROCOTOL_TYPE_HTTP : PROCOTOL_TYPE_HTTPS addr:m_strSvr port:m_iPort CA_PATH:cerPath];

    RestApiService* restApiService = [RestApiService shareMyInstance];
    m_devList = [[NSMutableArray alloc] init];
    if (nil != self.m_hc && nil != self.m_accessToken) {
        [restApiService initComponent:self.m_hc Token:self.m_accessToken];
    }
    else {
        DefLog(@"DeviceViewController, m_hc or m_accessToken is nil");
    }

    for (int i = 0; i < DEV_CHANNEL_MAX * DEV_NUM_MAX; i++) {
        m_downloadPicture[i] = [[DownloadPicture alloc] init];
    }

    m_iPos = 0;
    m_downloadingPos = -1;

    m_downStatusLock = [[NSLock alloc] init];
    m_devLock = [[NSLock alloc] init];
    m_looping = YES;
    m_conn = nil;
    self.m_imgDeviceNULL.hidden = YES;
    m_toastLab.hidden = YES;

    [self showLoading];
    dispatch_queue_t get_devlist = dispatch_queue_create("get_devlist", nil);
    dispatch_async(get_devlist, ^{
        NSString* errMsg;
        NSString* errMsgB, *errMsgS, *errMsgG;
        if ([NSLocalizedString(LANGUAGE_TXT, nil) isEqualToString:@"zh"]) {
            [restApiService beAuthDeviceList:m_devList Begin:DEV_BEGIN End:DEV_END Msg:&errMsgB];
            if (![errMsgB isEqualToString:[MSG_SUCCESS mutableCopy]]) {
                errMsg = @"get auth";
            }
            [restApiService shareDeviceList:m_devList Begin:DEV_BEGIN End:DEV_END Msg:&errMsgS];
            if (![errMsgS isEqualToString:[MSG_SUCCESS mutableCopy]]) {
                if (errMsg) {
                    errMsg = [errMsg stringByAppendingString:@",shared"];
                }else{
                    errMsg = @"get shared";
                }
            }
        }
        
        [restApiService getDevList:m_devList Begin:DEV_BEGIN End:DEV_END Msg:&errMsgG];
        
        if(m_devList.count==0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                m_toastLab.text = @"NO DEVICES";
                m_toastLab.hidden = NO;
                m_progressInd.hidden = YES;
            });

            return;
        }
        
        if (![errMsgG isEqualToString:[MSG_SUCCESS mutableCopy]]) {
            if (errMsg) {
                errMsg = [errMsg stringByAppendingString:@",own"];
            }else{
                errMsg = @"get own";
            }
        }
        if ([errMsg isEqualToString:@"get auth,shared,own"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideLoading];
                m_toastLab.text = [errMsg stringByAppendingString:@" device failed"];
                m_toastLab.hidden = NO;
            });
            return;
        }
        if (errMsg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                m_toastLab.text = [errMsg stringByAppendingString:@" device failed"];
                m_toastLab.hidden = NO;
            });
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            
            if (0 == m_devList.count) {
                DefLog(@"DeviceViewController getDevList NULL");
                m_toastLab.hidden = YES;
                self.m_imgDeviceNULL.hidden = NO;
            }
            else {
                [self performSelector:@selector(hideToastDelay) withObject:nil afterDelay:2.0f];
                [m_devListView reloadData];
                [self.view bringSubviewToFront:m_progressInd];
            }
        });
    });

    dispatch_queue_t downQueue = dispatch_queue_create("thumbnailDown", nil);
    dispatch_async(downQueue, ^{
        [self downloadThread];
    });
}

- (void)onBack:(id)sender
{
    [self destroyThread];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    [m_devLock lock];
    int iChCount = 0;
    for (DeviceInfo* dev in m_devList) {
        if (nil == dev->ID) {
            break;
        }
        iChCount += dev->channelSize;
    }
    [m_devLock unlock];
    return iChCount;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* cellIdentifier = @"Cell";
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];

    [m_devLock lock];
    NSInteger devKeyIndex = [self locateDevKeyIndex:[indexPath row]];
    NSInteger chnKeyIndex = [self locateDevChannelKeyIndex:[indexPath row]];
    if (devKeyIndex < 0 || chnKeyIndex < 0) {
        DefLog(@"cellForRowAtIndexPath devKeyIndex[%ld],chnKeyIndex[%ld]", (long)devKeyIndex, (long)chnKeyIndex);
        [m_devLock unlock];
        return cell;
    }

    UIImage* imgPic = nil;
    if (nil != m_downloadPicture[[indexPath row]].picData) {
        imgPic = [UIImage imageWithData:m_downloadPicture[[indexPath row]].picData];
    }
    else {
        DefLog(@"test cell image default");
        imgPic = [UIImage leChangeImageNamed:DefaultCover_Png];
    }

    UIImageView* imgPicView = [[UIImageView alloc] initWithFrame:CGRectMake(0, Device_Cell_Separate, Device_Cell_Width, Device_Cell_Height - Device_Cell_Separate)];
    [imgPicView setImage:imgPic];
    [cell addSubview:imgPicView];

    UILabel* lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, Device_Cell_Width, Device_Cell_Separate)];
    lblTitle.text = ((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->channelName[chnKeyIndex];
    [lblTitle setFont:[UIFont systemFontOfSize:14.0f]];
    lblTitle.textColor = [UIColor colorWithRed:159.0 / 255 green:159.0 / 255 blue:166 / 255 alpha:1];
    lblTitle.backgroundColor = [UIColor whiteColor];
    [cell addSubview:lblTitle];

    UIButton* btnDelDev = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDelDev.frame = CGRectMake(Device_Cell_Width - 40 - 5, 0, 40, Device_Cell_Separate);
    UIImage* imgDelDev = [UIImage leChangeImageNamed:Trash_Png];
    [btnDelDev setImage:imgDelDev forState:UIControlStateNormal];
    [cell addSubview:btnDelDev];
    btnDelDev.tag = [indexPath row];
    [btnDelDev addTarget:self action:@selector(onDelete:) forControlEvents:UIControlEventTouchUpInside];

    UIImage* imgBottom = [UIImage leChangeImageNamed:Toast_Png];
    UIImageView* imgBottomView = [[UIImageView alloc] initWithFrame:CGRectMake(-50, Device_Cell_Height - 60, Device_Cell_Width + 100, 60)];
    imgBottomView.layer.masksToBounds = YES;
    imgBottomView.contentMode = UIViewContentModeScaleAspectFill;

    [imgBottomView setImage:imgBottom];
    [cell addSubview:imgBottomView];

    UIImage* imgLive = [UIImage leChangeImageNamed:LiveVideo_Png];
    UIButton* btnLive = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLive.frame = CGRectMake(5, Device_Cell_Height - 50, 50, 40);
    CGFloat step = (Device_Cell_Width - 2 * 5 - 5 * 50) / 4;
    [btnLive setImage:imgLive forState:UIControlStateNormal];
    [cell addSubview:btnLive];
    btnLive.tag = [indexPath row];
    [btnLive addTarget:self action:@selector(onLive:) forControlEvents:UIControlEventTouchUpInside];

    UIImage* imgVideo = [UIImage leChangeImageNamed:Video_Png];
    UIButton* btnVideo = [UIButton buttonWithType:UIButtonTypeCustom];
    btnVideo.frame = CGRectMake(btnLive.frame.origin.x + btnLive.frame.size.width + step, Device_Cell_Height - 50, 50, 40);
    [btnVideo setImage:imgVideo forState:UIControlStateNormal];
    [cell addSubview:btnVideo];
    btnVideo.tag = [indexPath row];
    [btnVideo addTarget:self action:@selector(onVideo:) forControlEvents:UIControlEventTouchUpInside];

    UIImage* imgCloud = [UIImage leChangeImageNamed:CloudVideo_Png];
    UIButton* btnCloud = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCloud.frame = CGRectMake(btnVideo.frame.origin.x + btnVideo.frame.size.width + step, Device_Cell_Height - 50, 50, 40);
    [btnCloud setImage:imgCloud forState:UIControlStateNormal];
    [cell addSubview:btnCloud];
    btnCloud.tag = [indexPath row];
    [btnCloud addTarget:self action:@selector(onCloud:) forControlEvents:UIControlEventTouchUpInside];

    UIImage* imgMessage = [UIImage leChangeImageNamed:Message_Png];
    UIButton* btnMessage = [UIButton buttonWithType:UIButtonTypeCustom];
    btnMessage.frame = CGRectMake(btnCloud.frame.origin.x + btnCloud.frame.size.width + step, Device_Cell_Height - 50, 50, 40);
    [btnMessage setImage:imgMessage forState:UIControlStateNormal];
    [cell addSubview:btnMessage];
    btnMessage.tag = [indexPath row];
    [btnMessage addTarget:self action:@selector(onMessage:) forControlEvents:UIControlEventTouchUpInside];

    UIImage* imgSetting = [UIImage leChangeImageNamed:Setting_Png];
    UIButton* btnSetting = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSetting.frame = CGRectMake(btnMessage.frame.origin.x + btnMessage.frame.size.width + step, Device_Cell_Height - 50, 50, 40);
    [btnSetting setImage:imgSetting forState:UIControlStateNormal];
    [cell addSubview:btnSetting];
    btnSetting.tag = [indexPath row];
    [btnSetting addTarget:self action:@selector(onSetting:) forControlEvents:UIControlEventTouchUpInside];
    if ([NSLocalizedString(LANGUAGE_TXT, nil) isEqualToString:@"en"]) {
    //    btnSetting.enabled = NO;
    }
    
    if (((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->channelSize > 1){
       /* NVR设备逐个通道展示区分是否离线 */
        if( ((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->isOnline[chnKeyIndex] == NO ){
            UIImage* imgOffline = [UIImage leChangeImageNamed:Offline_Png];
            UIImageView* imgOfflineView = [[UIImageView alloc] initWithFrame:CGRectMake(Device_Cell_Width / 2 - 50, (Device_Cell_Height - Device_Cell_Separate) / 2 + Device_Cell_Separate - 50, 100, 100)];
            [imgOfflineView setImage:imgOffline];
            
            UILabel* lblCover = [[UILabel alloc] initWithFrame:CGRectMake(0, Device_Cell_Separate, Device_Cell_Width, Device_Cell_Height - Device_Cell_Separate)];
            lblCover.text = @"";
            lblCover.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
            [cell addSubview:lblCover];
            [cell addSubview:imgOfflineView];
            
            btnLive.enabled = NO;
            btnCloud.enabled = NO;
            btnMessage.enabled = NO;
            btnSetting.enabled = NO;
            btnVideo.enabled = NO;;
        }
    }
    else if( (((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->devOnline == 0)
        &&  (((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->channelSize <= 1) ){
        /* 非NVR设备按devOnline字段区分是否离线 */
        UIImage* imgOffline = [UIImage leChangeImageNamed:Offline_Png];
        UIImageView* imgOfflineView = [[UIImageView alloc] initWithFrame:CGRectMake(Device_Cell_Width / 2 - 50, (Device_Cell_Height - Device_Cell_Separate) / 2 + Device_Cell_Separate - 50, 100, 100)];
        [imgOfflineView setImage:imgOffline];
        
        UILabel* lblCover = [[UILabel alloc] initWithFrame:CGRectMake(0, Device_Cell_Separate, Device_Cell_Width, Device_Cell_Height - Device_Cell_Separate)];
        lblCover.text = @"";
        lblCover.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [cell addSubview:lblCover];
        [cell addSubview:imgOfflineView];
        
        btnLive.enabled = NO;
        btnCloud.enabled = NO;
        btnMessage.enabled = NO;
        btnSetting.enabled = NO;
        btnVideo.enabled = NO;
    }
    else if ((1 == ((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->encryptMode) && 0 == (((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->encryptKey[chnKeyIndex]).length && ![((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->ability containsString:@"TCM"]) {
        UILabel* lblCover = [[UILabel alloc] initWithFrame:CGRectMake(0, Device_Cell_Separate, Device_Cell_Width, Device_Cell_Height - Device_Cell_Separate)];
        lblCover.text = NSLocalizedString(ENTER_ENCRYPTED_KEY_TXT, nil);
        [lblCover setFont:[UIFont systemFontOfSize:24.0f]];
        [lblCover setTextColor:[UIColor whiteColor]];
        lblCover.textAlignment = NSTextAlignmentCenter;
        lblCover.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [cell addSubview:lblCover];
        
        btnLive.enabled = NO;
        btnCloud.enabled = NO;
        btnMessage.enabled = NO;
        btnSetting.enabled = NO;
        btnVideo.enabled = NO;
    }

    cell.textLabel.font = [UIFont systemFontOfSize:12.0f];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    [m_devLock unlock];
    return cell;
}
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [m_devLock lock];
    NSInteger devKeyIndex = [self locateDevKeyIndex:[indexPath row]];
    NSInteger chnKeyIndex = [self locateDevChannelKeyIndex:[indexPath row]];
    if (!((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->isOnline[chnKeyIndex])
    {
        [m_devLock unlock];
        return;
    }
    if (0 != (((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->encryptKey[chnKeyIndex]).length) {
        [m_devLock unlock];
        return;
    }
    if (1 == ((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->encryptMode && ![((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->ability containsString:@"TCM"]) {
        alertDecryptView = [[UIAlertView alloc] initWithTitle:@"Encrypt Key" message:@"please input correct key" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        alertDecryptView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertDecryptView show];
        m_devKeyIndex = devKeyIndex;
        m_chnKeyIndex = chnKeyIndex;
        [m_devLock unlock];
    }
    [m_devLock unlock];

}
- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return Device_Cell_Height;
}
#pragma mark - 定位设备通道
- (NSInteger)locateDevKeyIndex:(NSInteger)index
{
    int iChCount = 0;
    int i = 0;
    for (DeviceInfo* dev in m_devList) {
        if (nil == dev->ID) {
            break;
        }
        iChCount += dev->channelSize;
        if (iChCount >= index + 1) {
            break;
        }
        i++;
    }
     /* 返回当前的通道所在的NVR是第几个设备 */
    return (iChCount >= index + 1) ? i : -1;
}

- (NSInteger)locateDevChannelKeyIndex:(NSInteger)index
{
    int iChCount = 0;
    int i = 0;
    for (DeviceInfo* dev in m_devList) {

        if (nil == dev->ID) {
            break;
        }
        iChCount += dev->channelSize;
        if (iChCount >= index + 1) {
            break;
        }
        i++;
    }
    
    /* 返回当前的通道是NVR内的第几个通道 */
    return (iChCount >= index + 1) ? (index - iChCount + ((DeviceInfo*)[m_devList objectAtIndex:i])->channelSize) : -1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 设置管理员账号信息
- (void)setAdminInfo:(NSString*)token protocol:(NSInteger)protocol address:(NSString*)addr port:(NSInteger)port
{
    self.m_accessToken = [token mutableCopy];
    m_strSvr = [addr mutableCopy];
    m_iPort = port;
    m_iProtocol = protocol;
}
#pragma mark - 实时播放
- (void)onLive:(id)sender
{
    UIButton* btnLive = (UIButton*)sender;

    NSInteger devKeyIndex = [self locateDevKeyIndex:btnLive.tag];
    NSInteger chnKeyIndex = [self locateDevChannelKeyIndex:btnLive.tag];

    self.m_strDevSelected = ((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->ID;
    self.m_devAbilitySelected = [NSString stringWithFormat:@"%@,%@", ((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->ability, ((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->channelAbility[chnKeyIndex]];
    self.m_devChnSelected = ((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->channelId[chnKeyIndex];
    self.m_imgPicSelected = [UIImage imageWithData:m_downloadPicture[btnLive.tag].picData];
    self.m_encryptKey = ((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->encryptKey[chnKeyIndex];
    
    DefLog(@"onLive device[%@],channel[%ld]", self.m_strDevSelected, (long)self.m_devChnSelected);

    UIStoryboard* currentBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LiveVideoViewController* liveVideoView = [currentBoard instantiateViewControllerWithIdentifier:@"LiveVideo"];
    [self.navigationController pushViewController:liveVideoView animated:NO];
    [liveVideoView setInfo:self.m_accessToken Dev:self.m_strDevSelected Key:self.m_encryptKey Chn:self.m_devChnSelected Img:self.m_imgPicSelected Abl:self.m_devAbilitySelected];
}
#pragma mark - 设备录像
- (void)onVideo:(id)sender
{
    UIButton* btnVideo = (UIButton*)sender;

    NSInteger devKeyIndex = [self locateDevKeyIndex:btnVideo.tag];
    NSInteger chnKeyIndex = [self locateDevChannelKeyIndex:btnVideo.tag];
    self.m_strDevSelected = ((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->ID;
    // TODO
    self.m_devChnSelected = ((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->channelId[chnKeyIndex];
    self.m_encryptKey = ((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->encryptKey[chnKeyIndex];
    DefLog(@"onLive device[%@],channel[%ld]", self.m_strDevSelected, (long)self.m_devChnSelected);

    UIStoryboard* currentBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RecordViewController* recordView = [currentBoard instantiateViewControllerWithIdentifier:@"Record"];
    [recordView setInfo:self.m_accessToken Dev:self.m_strDevSelected Key:self.m_encryptKey Chn:self.m_devChnSelected Type:DeviceRecord];
    [self.navigationController pushViewController:recordView animated:NO];
}
#pragma mark - 云录像
- (void)onCloud:(id)sender
{
    UIButton* btnCloudVideo = (UIButton*)sender;

    NSInteger devKeyIndex = [self locateDevKeyIndex:btnCloudVideo.tag];
    NSInteger chnKeyIndex = [self locateDevChannelKeyIndex:btnCloudVideo.tag];
    self.m_strDevSelected = ((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->ID;
    self.m_devChnSelected = ((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->channelId[chnKeyIndex];
    self.m_encryptKey = ((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->encryptKey[chnKeyIndex];
    DefLog(@"onCloud device[%@],channel[%ld]", self.m_strDevSelected, (long)self.m_devChnSelected);

    UIStoryboard* currentBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RecordViewController* recordView = [currentBoard instantiateViewControllerWithIdentifier:@"Record"];
    [recordView setInfo:self.m_accessToken Dev:self.m_strDevSelected Key:self.m_encryptKey Chn:self.m_devChnSelected Type:CloudRecord];
    [self.navigationController pushViewController:recordView animated:NO];
}
#pragma mark - 报警消息
- (void)onMessage:(id)sender
{
    UIButton* btnMessage = (UIButton*)sender;

    NSInteger devKeyIndex = [self locateDevKeyIndex:btnMessage.tag];
    NSInteger chnKeyIndex = [self locateDevChannelKeyIndex:btnMessage.tag];
    self.m_strDevSelected = ((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->ID;
    self.m_devChnSelected = ((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->channelId[chnKeyIndex];
    self.m_encryptKey = ((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->encryptKey[chnKeyIndex];
    UIStoryboard* currentBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    MessageViewController* msgView = [currentBoard instantiateViewControllerWithIdentifier:@"MessageView"];
    [self.navigationController pushViewController:msgView animated:NO];
    [msgView setInfo:self.m_accessToken Dev:self.m_strDevSelected Key:self.m_encryptKey Chn:self.m_devChnSelected];
}
#pragma mark - 设备设置
- (void)onSetting:(id)sender
{
    UIButton* btnSetting = (UIButton*)sender;
    NSInteger devKeyIndex = [self locateDevKeyIndex:btnSetting.tag];
    NSInteger chnKeyIndex = [self locateDevChannelKeyIndex:btnSetting.tag];
    self.m_strDevSelected = ((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->ID;
    ;
    self.m_devChnSelected = ((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->channelId[chnKeyIndex];
    
    UIStoryboard* currentBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DeviceOperationViewController* deviceOperationView = [currentBoard instantiateViewControllerWithIdentifier:@"DeviceOperation"];
    [deviceOperationView setInfo:self.m_hc Token:self.m_accessToken Dev:self.m_strDevSelected Chn:self.m_devChnSelected];
    [self.navigationController pushViewController:deviceOperationView animated:NO];
}
#pragma mark - 删除设备
- (void)onDelete:(id)sender
{
    UIButton* btnDetelte = (UIButton*)sender;

    NSInteger devKeyIndex = [self locateDevKeyIndex:btnDetelte.tag];
    NSInteger chnKeyIndex = [self locateDevChannelKeyIndex:btnDetelte.tag];

    [m_devLock lock];
    self.m_strDevSelected = ((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->ID;
    self.m_devChnSelected = ((DeviceInfo*)[m_devList objectAtIndex:devKeyIndex])->channelId[chnKeyIndex];
    [m_devLock unlock];

    alertDelView = [[UIAlertView alloc] initWithTitle:@"alarm" message:@"confirm to delete?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [alertDelView show];

    return;
}
#pragma mark - 添加设备
- (void)onAddDevice:(id)sender
{
    UIStoryboard* currentBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    AddDeviceViewController* addDevView = [currentBoard instantiateViewControllerWithIdentifier:@"AddDeviceView"];
    [self.navigationController pushViewController:addDevView animated:NO];
    [addDevView setInfo:self.m_hc token:self.m_accessToken devView:self];
}
#pragma mark - 对话框
- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == alertDelView) {
        if (0 == buttonIndex) {
            DefLog(@"cancel delete[%@]", self.m_strDevSelected);
            return;
        }
        else if (1 == buttonIndex) {
            [self showLoading];
            m_devListView.hidden = YES;
            dispatch_queue_t unbind_device = dispatch_queue_create("unbind_device", nil);
            dispatch_async(unbind_device, ^{
                NSString* errMsg;
                RestApiService* restApiService = [RestApiService shareMyInstance];
                [restApiService unBindDevice:self.m_strDevSelected Msg:&errMsg];
                if (![errMsg isEqualToString:[MSG_SUCCESS mutableCopy]]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self hideLoading];
                        m_devListView.hidden = NO;
                        m_toastLab.text = errMsg;
                        m_toastLab.hidden = NO;
                        [self performSelector:@selector(hideToastDelay) withObject:nil afterDelay:2.0f];
                    });
                    return;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self refreshDevList];
                });
            });
        }
    }
    if (alertView == alertDecryptView) {
        if (0 == buttonIndex) {
            return;
        }
        if (1 == buttonIndex) {
            (((DeviceInfo*)[m_devList objectAtIndex:m_devKeyIndex])->encryptKey[m_chnKeyIndex]) = [[alertView textFieldAtIndex: 0] text];
            [m_devLock unlock];
            [m_devListView reloadData];
            m_devListView.hidden = NO;
            return;
        }
    }
}
#pragma mark - 刷新设备列表
- (void)refreshDevList
{
    [m_devLock lock];
    [m_devList removeAllObjects];
    [m_devLock unlock];

    [m_downStatusLock lock];
    m_iPos = 0;
    m_downloadingPos = -1;
    m_conn = nil;
    for (int i = 0; i < DEV_CHANNEL_MAX * DEV_NUM_MAX; i++) {
        [m_downloadPicture[i] clearData];
    }
    [m_downStatusLock unlock];

    [self showLoading];
    m_devListView.hidden = YES;
    m_toastLab.hidden = YES;
    dispatch_queue_t get_devList = dispatch_queue_create("get_devList", nil);
    dispatch_async(get_devList, ^{
        RestApiService* restApiService = [RestApiService shareMyInstance];
        NSString* errMsg;
        NSString* errMsgB, *errMsgS, *errMsgG;
        if ([NSLocalizedString(LANGUAGE_TXT, nil) isEqualToString:@"ch"]) {
            [restApiService beAuthDeviceList:m_devList Begin:DEV_BEGIN End:DEV_END Msg:&errMsgB];
            if (![errMsgB isEqualToString:[MSG_SUCCESS mutableCopy]]) {
                errMsg = @"get auth";
            }
            [restApiService shareDeviceList:m_devList Begin:DEV_BEGIN End:DEV_END Msg:&errMsgS];
            if (![errMsgS isEqualToString:[MSG_SUCCESS mutableCopy]]) {
                if (errMsg) {
                    errMsg = [errMsg stringByAppendingString:@",shared"];
                }else{
                    errMsg = @"get shared";
                }
            }
        }
        [restApiService getDevList:m_devList Begin:DEV_BEGIN End:DEV_END Msg:&errMsgG];
        if (![errMsgG isEqualToString:[MSG_SUCCESS mutableCopy]]) {
            if (errMsg) {
                errMsg = [errMsg stringByAppendingString:@",own"];
            }else{
                errMsg = @"get own";
            }
        }
        if ([errMsg isEqualToString:@"get auth,shared,own"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideLoading];
                m_toastLab.text = [errMsg stringByAppendingString:@" device failed"];
                m_toastLab.hidden = NO;
            });
            return;
        }
        if (errMsg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                m_toastLab.text = [errMsg stringByAppendingString:@" device failed"];
                m_toastLab.hidden = NO;
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            [m_devLock lock];
            if (0 == m_devList.count) {
                [m_devLock unlock];
                DefLog(@"refreshDevList hasn't got any device\n");
                m_toastLab.hidden = YES;
                self.m_imgDeviceNULL.hidden = NO;
                return;
            }
            else {
                [self performSelector:@selector(hideToastDelay) withObject:nil afterDelay:2.0f];
                self.m_imgDeviceNULL.hidden = YES;
                [m_devLock unlock];
                [m_devListView reloadData];
                m_devListView.hidden = NO;
            }
        });
    });
}
#pragma mark - 延时隐藏toast
- (void)hideToastDelay
{
    m_toastLab.hidden = YES;
}
#pragma mark - 封面图片下载线程
- (void)downloadThread
{
    m_iPos = 0;
    m_downloadingPos = -1;
    int j;
    while (m_looping) {
        //        DefLog(@"retain count = %ld\n", CFGetRetainCount((__bridge CFTypeRef)(self)));
        usleep(20 * 1000);
        BOOL bNeedDown = YES;
        NSString* picUrl;

        [m_devLock lock];
        [m_downStatusLock lock];
        NSInteger iDevKey = [self locateDevKeyIndex:m_iPos];
        NSInteger iChnKey = [self locateDevChannelKeyIndex:m_iPos];
        do {
            picUrl = nil;
            if (iDevKey < 0 || iChnKey < 0) {
                bNeedDown = NO;
                m_iPos = (m_iPos + 1) % (DEV_CHANNEL_MAX * DEV_NUM_MAX);
                break;
            }

            for (j = 0; j < DEV_CHANNEL_MAX * DEV_NUM_MAX; j++) {
                if (DOWNLOADING == m_downloadPicture[j].downStatus) {
                    break;
                }
            }
            if (j < DEV_CHANNEL_MAX * DEV_NUM_MAX) {
                bNeedDown = NO;
                break;
            }
            if (NONE != m_downloadPicture[m_iPos].downStatus) {
                bNeedDown = NO;
                m_iPos = (m_iPos + 1) % (DEV_CHANNEL_MAX * DEV_NUM_MAX);
                break;
            }
            
            if([m_devList count]>0){
                picUrl = [((DeviceInfo*)[m_devList objectAtIndex:iDevKey])->channelPic[iChnKey] mutableCopy];
            }
        } while (0);

        [m_devLock unlock];
        if (!bNeedDown || !picUrl) {
            [m_downStatusLock unlock];
            continue;
        }

        //download
        m_httpUrl = [NSURL URLWithString:picUrl];

        //[m_downStatusLock lock];
        m_downloadPicture[m_iPos].downStatus = DOWNLOADING;
        //[m_downStatusLock unlock];
        m_downloadingPos = m_iPos;
        m_iPos = (m_iPos + 1) % (DEV_CHANNEL_MAX * DEV_NUM_MAX);
        
        [m_devLock unlock];

        NSURLRequest* request = [NSMutableURLRequest requestWithURL:m_httpUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
        NSHTTPURLResponse* response = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];

        if (m_downloadingPos < 0) {
            DefLog(@"connectionDidFinishLoading m_downloadingPos[%ld]", (long)m_downloadingPos);
            return;
        }
        if (response == nil) {
            DefLog(@"download failed");
            m_downloadPicture[m_downloadingPos].downStatus = DOWNLOAD_FAILED;
        }
        else {
            if([m_devList count]>0){
                if (((DeviceInfo*)[m_devList objectAtIndex:iDevKey])->platForm == 4) {
                    NSData* dataOut = [[NSData alloc] init];
                    NSInteger iret = [m_util decryptPic:data deviceID:((DeviceInfo*)[m_devList objectAtIndex:iDevKey])->ID key:((DeviceInfo*)[m_devList objectAtIndex:iDevKey])->encryptKey[iChnKey] token:_m_accessToken  bufOut:&dataOut];
                    if (0 == iret) {
                        [m_downloadPicture[m_downloadingPos] setData:dataOut status:DOWNLOAD_FINISHED];
                    }
                } else {
                    [m_downloadPicture[m_downloadingPos] setData:data status:DOWNLOAD_FINISHED];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [m_devListView reloadData];
            });
        }
        [m_downStatusLock unlock];

        //end
    }
    //    DefLog(@"retain count = %ld\n", CFGetRetainCount((__bridge CFTypeRef)(self)));
}
#pragma mark - 结束图片下载线程
- (void)destroyThread
{
    m_looping = NO;
}
#pragma mark - 滚动轮指示器
// 显示滚动轮指示器
- (void)showLoading
{
    [m_progressInd startAnimating];
}
// 消除滚动轮指示器
- (void)hideLoading
{
    if ([m_progressInd isAnimating]) {
        [m_progressInd stopAnimating];
    }
}

- (void)dealloc
{
    //    DefLog(@"retain count = %ld\n", CFGetRetainCount((__bridge CFTypeRef)(self)));
    //    DefLog(@"DeviceViewController dealloc");
}

@end
