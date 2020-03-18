//
//  EZLocationAlertVCViewController.m
//  EZOpenSDKDemo
//
//  Created by yuqian on 2019/9/19.
//  Copyright © 2019 hikvision. All rights reserved.
//

#import "EZLocationAlertVCViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "EZWifiInfoViewController.h"
#import "Masonry.h"


@interface EZLocationAlertVCViewController ()<CLLocationManagerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *connectLabel;
@property (nonatomic, strong) IBOutlet UIButton *btn;
@property (nonatomic, strong) IBOutlet UIButton *exceptionButton;
@property (nonatomic, strong) CLLocationManager *locationmanager;

@end

@implementation EZLocationAlertVCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self layoutSubView];
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        _locationmanager = [[CLLocationManager alloc]init];
        _locationmanager.delegate = self;
        [_locationmanager requestWhenInUseAuthorization];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onClick
{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] canOpenURL:url])
    {
        //TODO:版本适配
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)appDidBecomeActive
{
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusRestricted)
    {
         [self performSegueWithIdentifier:@"go2WifiInfo" sender:nil];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        [self performSegueWithIdentifier:@"go2WifiInfo" sender:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue destinationViewController] isKindOfClass:[EZWifiInfoViewController class]]) {
        EZWifiInfoViewController *vc = (EZWifiInfoViewController *)[segue destinationViewController];
        vc.supportApMode = self.supportApMode;
        vc.supportSmartMode = self.supportSmartMode;
        vc.supportSoundMode = self.supportSoundMode;
    }
}

- (void)exceptionButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) setupUI {
    
    self.title = NSLocalizedString(@"请开启定位服务", );
    
    _imageView.image = [UIImage imageNamed:@"icn_location"];
    _imageView.contentMode = UIViewContentModeScaleToFill;
    
    _connectLabel.text = NSLocalizedString(@"定位服务未开启，请进入系统［设置］> [隐私] > [定位服务]中打开开关，并允许使用定位服务",);
    _connectLabel.numberOfLines = 0;
    _connectLabel.textColor = [UIColor blackColor];
    _connectLabel.textAlignment = NSTextAlignmentCenter;
    _connectLabel.font = [UIFont systemFontOfSize:13.0];
    
    [_btn setTitle:NSLocalizedString(@"立即开启",) forState:UIControlStateNormal];
    [_btn setTintColor:[UIColor whiteColor]];
    [_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btn.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [_btn addTarget:self action:@selector(onClick) forControlEvents:UIControlEventTouchUpInside];
    _btn.backgroundColor = [UIColor orangeColor];
    _btn.layer.cornerRadius = 22;
    _btn.clipsToBounds = YES;
    
    [_exceptionButton addTarget:self action:@selector(exceptionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 2;
    [_exceptionButton addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_exceptionButton);
    }];
    
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"暂不",)];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(0, attributeStr.length)];
    [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15.f] range:NSMakeRange(0, attributeStr.length)];
    [attributeStr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, attributeStr.length)];
    label.attributedText = attributeStr;
}

- (void)layoutSubView
{
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(100);
    }];
    
    [_connectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(_imageView.mas_bottom).offset(50);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width-40);
    }];
    
    [_btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(_connectLabel.mas_bottom).offset(40);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width-40);
        make.height.mas_equalTo(44);
    }];
    
    [_exceptionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(_btn.mas_bottom).offset(15);
    }];
}

@end
