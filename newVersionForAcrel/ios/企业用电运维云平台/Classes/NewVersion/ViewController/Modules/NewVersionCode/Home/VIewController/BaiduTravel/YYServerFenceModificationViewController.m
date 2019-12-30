//
//  YYServerFenceModificationViewController.m
//  YYObjCDemo
//
//  Created by Daniel Bey on 2017年06月16日.
//  Copyright © 2017 百度鹰眼. All rights reserved.
//

#import "YYServerFenceModificationViewController.h"

@interface YYServerFenceModificationViewController ()

// 围栏名称
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UITextField *nameTextField;
// 圆形半径
@property (nonatomic, strong) UILabel *radiusLabel;
@property (nonatomic, strong) UITextField *radiusTextField;
// 去噪精度
@property (nonatomic, strong) UILabel *denoiseLabel;
@property (nonatomic, strong) UITextField *denoiseTextField;
// 圆形圆形
@property (nonatomic, strong) UILabel *centerLabel;
@property (nonatomic, strong) BMKMapView *mapView;
// 点击后创建圆形围栏
@property (nonatomic, strong) UIBarButtonItem *doneButton;

@property (nonatomic, assign) CLLocationCoordinate2D circleCenter;

@property (nonatomic, assign) ServerFenceModificationType modificatioinType;

@property (nonatomic, copy) BTKServerCircleFence *originalFence;
/**
 更新围栏的时候，需要指定fenceID
 */
@property (nonatomic, assign) NSUInteger fenceID;
@end

@implementation YYServerFenceModificationViewController

#pragma mark - life cycle
-(instancetype)initWithModificationType:(ServerFenceModificationType)type fenceID:(NSUInteger)fenceID fenceObject:(BTKServerCircleFence *)fence {
    self = [self initWithModificationType:type];
    if (self) {
        _originalFence = fence;
        _fenceID = fenceID;
    }
    return self;
}

-(instancetype)initWithModificationType:(ServerFenceModificationType)type {
    self = [super init];
    if (self) {
        _modificatioinType = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.mapView viewWillAppear];
    self.mapView.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.mapView viewWillDisappear];
    self.mapView.delegate = nil;
}

-(void)dealloc {
    self.mapView = nil;
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}

#pragma mark - BTKFenceDelegate
-(void)onCreateServerFence:(NSData *)response {
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:nil];
    if (nil == dict) {
        NSLog(@"Server Fence Create 格式转换出错");
        return;
    }
    if (0 != [dict[@"status"] intValue]) {
        NSLog(@"Server Fence Create 返回错误");
        dispatch_async(MAIN_QUEUE, ^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"创建服务端围栏失败" message:dict[@"message"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:defaultAction];
            [self presentViewController:alertController animated:YES completion:nil];
        });
        return;
    }
    // 创建成功则返回上一级页面
    dispatch_async(MAIN_QUEUE, ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

-(void)onUpdateServerFence:(NSData *)response {
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:nil];
    if (nil == dict) {
        NSLog(@"Server Fence Update 格式转换出错");
        return;
    }
    if (0 != [dict[@"status"] intValue]) {
        NSLog(@"Server Fence Update 返回错误");
        dispatch_async(MAIN_QUEUE, ^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"更新服务端围栏失败" message:dict[@"message"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:defaultAction];
            [self presentViewController:alertController animated:YES completion:nil];
        });
        return;
    }
    // 更新成功则返回上一级页面
    dispatch_async(MAIN_QUEUE, ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

#pragma mark - BMKMapViewDelegate
/// 一般来说应该点击空白处，然而在地图缩放级别不够高的时候，很容易点到POI上，所以我们也实现地图SDK中的这个回调方法
-(void)mapView:(BMKMapView *)mapView onClickedMapPoi:(BMKMapPoi *)mapPoi {
    CLLocationCoordinate2D coordinate = mapPoi.pt;
    self.circleCenter = coordinate;
    BMKPointAnnotation *centerAnnotation = [[BMKPointAnnotation alloc] init];
    centerAnnotation.coordinate = coordinate;
    centerAnnotation.title = @"圆心";
    BMKCircle *radiusCircle = [[BMKCircle alloc] init];
    radiusCircle.coordinate = coordinate;
    double radius = [self.radiusTextField.text doubleValue];
    if (fabs(radius) > DBL_EPSILON) {
        radiusCircle.radius = radius;
    } else {
        radiusCircle.radius = 50.0;
    }
    dispatch_async(MAIN_QUEUE, ^{
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView removeOverlays:self.mapView.overlays];
        [self.mapView addAnnotation:centerAnnotation];
        [self.mapView addOverlay:radiusCircle];
        [self.mapView setCenterCoordinate:coordinate animated:YES];
    });
}

/// 点击地图的空白处以确定圆心
-(void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate {
    self.circleCenter = coordinate;
    BMKPointAnnotation *centerAnnotation = [[BMKPointAnnotation alloc] init];
    centerAnnotation.coordinate = coordinate;
    centerAnnotation.title = @"圆心";
    BMKCircle *radiusCircle = [[BMKCircle alloc] init];
    radiusCircle.coordinate = coordinate;
    double radius = [self.radiusTextField.text doubleValue];
    if (fabs(radius) > DBL_EPSILON) {
        radiusCircle.radius = radius;
    } else {
        radiusCircle.radius = 50.0;
    }
    dispatch_async(MAIN_QUEUE, ^{
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView removeOverlays:self.mapView.overlays];
        [self.mapView addAnnotation:centerAnnotation];
        [self.mapView addOverlay:radiusCircle];
        [self.mapView setCenterCoordinate:coordinate animated:YES];
    });
}

-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation {
    if (FALSE == [annotation isMemberOfClass:[BMKPointAnnotation class]]) {
        return nil;
    }
    static NSString * fenceCenterAnnotationViewID = @"fenceCenterAnnotationViewID";
    BMKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:fenceCenterAnnotationViewID];
    if (nil == annotationView) {
        annotationView = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:fenceCenterAnnotationViewID];
    }
    annotationView.image = [UIImage imageNamed:@"icon_fence_center"];
    [annotationView setSelected:YES animated:YES];
    return annotationView;
}

-(BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay {
    if (FALSE == [overlay isMemberOfClass:[BMKCircle class]]) {
        return nil;
    }
    BMKCircleView *circleView = [[BMKCircleView alloc] initWithOverlay:overlay];
    circleView.fillColor = [[UIColor alloc] initWithRed:0 green:0 blue:1 alpha:0.3];
    circleView.strokeColor = [[UIColor alloc] initWithRed:0 green:0 blue:1 alpha:0];
    return circleView;
}

#pragma mark - event handler
- (void)createCircleServerFence {
    dispatch_async(MAIN_QUEUE, ^{
        // SDK要求围栏的圆心和半径必须设定值
        // 虽然SDK没有要求，这里我们校验fenceName也有值，
        // 因为我们想把fence的name作为annotation的title来展示，以区别不同的围栏，毕竟name比ID对人眼更友好
        NSString *fenceName = self.nameTextField.text;
        double radius = [self.radiusTextField.text doubleValue];
        if (fenceName == nil || fenceName.length == 0) {
            NSLog(@"没有设置服务端围栏的名称");
            dispatch_async(MAIN_QUEUE, ^{
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"name必须设置" message:@"请设置围栏的名称" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:defaultAction];
                [self presentViewController:alertController animated:YES completion:nil];
            });
            return;
        }
        if (fabs(radius) < DBL_EPSILON) {
            NSLog(@"没有设置服务端圆形围栏的半径，我们默认50米");
            radius = 50.0;
            self.radiusTextField.text = @"50";
        }
        if (fabs(self.circleCenter.latitude) < DBL_EPSILON || fabs(self.circleCenter.longitude) < DBL_EPSILON) {
            NSLog(@"没有设置服务端圆形围栏的圆心");
            dispatch_async(MAIN_QUEUE, ^{
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"圆心必须设置" message:@"请点击地图空白处以设置圆形围栏的圆心" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:defaultAction];
                [self presentViewController:alertController animated:YES completion:nil];
            });
            return;
        }
        
        // 去噪精度可以不指定，不指定的时候，我们设置denoise为0，代笔所有轨迹点都参与计算
        NSUInteger denoise = self.denoiseTextField.text == nil ? 0 : [self.denoiseTextField.text integerValue];
        NSString *monitoredObject = [USER_DEFAULTS objectForKey:ENTITY_NAME];
        if (monitoredObject == nil) {
            NSLog(@"没有设置登录的Entity终端名称");
            dispatch_async(MAIN_QUEUE, ^{
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"缺少监控对象" message:@"请进入轨迹追踪设置页面，设置当前登陆的Entity终端名称，DEMO创建的围栏，以该名称作为监控对象" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:defaultAction];
                [self presentViewController:alertController animated:YES completion:nil];
            });
            return;
        }
        BTKServerCircleFence *fence = [[BTKServerCircleFence alloc] initWithCenter:self.circleCenter radius:radius coordType:BTK_COORDTYPE_BD09LL denoiseAccuracy:denoise fenceName:fenceName monitoredObject:monitoredObject];
        BTKCreateServerFenceRequest *request = [[BTKCreateServerFenceRequest alloc] initWithServerCircleFence:fence serviceID:BGSERVICEID tag:1];
        [[BTKFenceAction sharedInstance] createServerFenceWith:request delegate:self];
    });
}

- (void)updateCircleServerFence {
    // 更新围栏的时候，不需要校验任何字段，完全可以什么字段都不更新，虽然这样没有意义。
    BTKServerCircleFence *newFence = [[BTKServerCircleFence alloc] initWithCenter:self.originalFence.center radius:self.originalFence.radius coordType:BTK_COORDTYPE_BD09LL denoiseAccuracy:self.originalFence.denoiseAccuracy fenceName:self.originalFence.fenceName monitoredObject:self.originalFence.monitoredObject];
    
    NSString *fenceName = self.nameTextField.text;
    if (fenceName != nil && fenceName.length > 0) {
        newFence.fenceName = fenceName;
    }
    double radius = [self.radiusTextField.text doubleValue];
    if (fabs(radius) > DBL_EPSILON) {
        newFence.radius = radius;
    }
    NSUInteger denoise = [self.denoiseTextField.text intValue];
    newFence.denoiseAccuracy = denoise;
    
    if (fabs(self.circleCenter.latitude) > DBL_EPSILON && fabs(self.circleCenter.longitude) > DBL_EPSILON) {
        newFence.center = self.circleCenter;
    }
    
    dispatch_async(GLOBAL_QUEUE, ^{
        BTKUpdateServerFenceRequest *request = [[BTKUpdateServerFenceRequest alloc] initWithServerCircleFence:newFence fenceID:self.fenceID serviceID:BGSERVICEID tag:1];
        [[BTKFenceAction sharedInstance] updateServerFenceWith:request delegate:self];
    });
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.nameTextField resignFirstResponder];
    [self.denoiseTextField resignFirstResponder];
    [self.radiusTextField resignFirstResponder];
}

#pragma mark - private function
- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    if (self.modificatioinType == YY_SERVER_FENCE_MODIFICATION_TYPE_CREATE) {
        self.navigationItem.title = @"新建圆形围栏";
    } else {
        self.navigationItem.title = @"修改圆形围栏";
    }
    
    [self.view addSubview:self.nameLabel];
    [self.view addSubview:self.denoiseLabel];
    [self.view addSubview:self.radiusLabel];
    [self.view addSubview:self.centerLabel];
    [self.view addSubview:self.nameTextField];
    [self.view addSubview:self.denoiseTextField];
    [self.view addSubview:self.radiusTextField];
    [self.view addSubview:self.mapView];
    [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.translatesAutoresizingMaskIntoConstraints = FALSE;
    }];
    [self setupConstraints];
    self.navigationItem.rightBarButtonItem = self.doneButton;
    CLLocationCoordinate2D mapCenter;
    if (fabs(self.mapCenter.latitude) < DBL_EPSILON || fabs(self.mapCenter.longitude) < DBL_EPSILON) {
        // 没有设置地图中心点的话，就用上一次定位的位置
        NSData *locationData = [USER_DEFAULTS objectForKey:LATEST_LOCATION];
        CLLocation *position = [NSKeyedUnarchiver unarchiveObjectWithData:locationData];
        mapCenter = position.coordinate;
    } else {
        mapCenter = self.mapCenter;
    }
    dispatch_async(MAIN_QUEUE, ^{
        [self.mapView setCenterCoordinate:mapCenter];
        self.mapView.zoomLevel = 19;
    });
}

- (void)setupConstraints {
    // nameLabel的约束
    CGFloat navigationBarHeight = self.navigationController.navigationBar.bounds.size.height;
    CGFloat space = 20;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1
                                                           constant:0.05 * SCREEN_WIDTH]
     ];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:navigationBarHeight + space + BGTopBarHeight]
     ];
    // denoiseLabel的约束
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.denoiseLabel
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.nameLabel
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:0]
     ];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.denoiseLabel
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.nameLabel
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:space]
     ];
    // radiusLabel的约束
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.radiusLabel
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.denoiseLabel
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:0]
     ];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.radiusLabel
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.denoiseLabel
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:space]
     ];
    // centerLabel的约束
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.centerLabel
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.radiusLabel
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1
                                                           constant:0]
     ];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.centerLabel
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.radiusLabel
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:space]
     ];
    
    // nameTextField的约束
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.nameTextField
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.nameLabel
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:20]
     ];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.nameTextField
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.nameLabel
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1
                                                           constant:0]
     ];
    [self.nameTextField addConstraint:[NSLayoutConstraint constraintWithItem:self.nameTextField
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1
                                                                    constant:SCREEN_WIDTH * 0.6]
     ];
    
    // denoiseTextField的约束
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.denoiseTextField
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.denoiseLabel
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:20]
     ];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.denoiseTextField
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.denoiseLabel
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1
                                                           constant:0]
     ];
    [self.denoiseTextField addConstraint:[NSLayoutConstraint constraintWithItem:self.denoiseTextField
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1
                                                                       constant:SCREEN_WIDTH * 0.6]
     ];
    
    // radiusTextField的约束
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.radiusTextField
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.radiusLabel
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:20]
     ];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.radiusTextField
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.radiusLabel
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1
                                                           constant:0]
     ];
    [self.radiusTextField addConstraint:[NSLayoutConstraint constraintWithItem:self.radiusTextField
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1
                                                                      constant:SCREEN_WIDTH * 0.6]
     ];
    
    // mapView的约束
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mapView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1
                                                           constant:0]
     ];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mapView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:0]
     ];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mapView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0]
     ];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mapView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.centerLabel
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:space]
     ];
}


#pragma mark - setter & getter
-(BMKMapView *)mapView {
    if (_mapView == nil) {
        _mapView = [[BMKMapView alloc] init];
        _mapView.zoomLevel = 19;
    }
    return _mapView;
}

-(UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.text = @"围栏名称";
        [_nameLabel sizeToFit];
    }
    return _nameLabel;
}

-(UILabel *)radiusLabel {
    if (_radiusLabel == nil) {
        _radiusLabel = [[UILabel alloc] init];
        _radiusLabel.textAlignment = NSTextAlignmentCenter;
        _radiusLabel.text = @"圆形半径";
        [_radiusLabel sizeToFit];
    }
    return _radiusLabel;
}

-(UILabel *)denoiseLabel {
    if (_denoiseLabel == nil) {
        _denoiseLabel = [[UILabel alloc] init];
        _denoiseLabel.textAlignment = NSTextAlignmentCenter;
        _denoiseLabel.text = @"去噪精度";
        [_denoiseLabel sizeToFit];
    }
    return _denoiseLabel;
}

-(UILabel *)centerLabel {
    if (_centerLabel == nil) {
        _centerLabel = [[UILabel alloc] init];
        _centerLabel.textAlignment = NSTextAlignmentCenter;
        _centerLabel.text = @"在地图空白处戳点，以确定圆形圆心位置";
        [_centerLabel sizeToFit];
    }
    return _centerLabel;
}

-(UITextField *)nameTextField {
    if (_nameTextField == nil) {
        _nameTextField = [[UITextField alloc] init];
        _nameTextField.borderStyle = UITextBorderStyleRoundedRect;
        _nameTextField.layer.borderColor = [[UIColor blackColor] CGColor];
        _nameTextField.placeholder = @"字母数字汉字下划线的组合";
        _nameTextField.returnKeyType = UIReturnKeyDone;
        _nameTextField.delegate = self;
    }
    return _nameTextField;
}

-(UITextField *)radiusTextField {
    if (_radiusTextField == nil) {
        _radiusTextField = [[UITextField alloc] init];
        _radiusTextField.borderStyle = UITextBorderStyleRoundedRect;
        _radiusTextField.layer.borderColor = [[UIColor blackColor] CGColor];
        _radiusTextField.placeholder = @"默认50米";
        _radiusTextField.keyboardType = UIKeyboardTypeNumberPad;
        _radiusTextField.returnKeyType = UIReturnKeyDone;
        _radiusTextField.delegate = self;
    }
    return _radiusTextField;
}

-(UITextField *)denoiseTextField {
    if (_denoiseTextField == nil) {
        _denoiseTextField = [[UITextField alloc] init];
        _denoiseTextField.borderStyle = UITextBorderStyleRoundedRect;
        _denoiseTextField.layer.borderColor = [[UIColor blackColor] CGColor];
        _denoiseTextField.placeholder = @"默认0米";
        _denoiseTextField.keyboardType = UIKeyboardTypeNumberPad;
        _denoiseTextField.returnKeyType = UIReturnKeyDone;
        _denoiseTextField.delegate = self;
    }
    return _denoiseTextField;
}

-(UIBarButtonItem *)doneButton {
    if (_doneButton == nil) {
        if (self.modificatioinType == YY_SERVER_FENCE_MODIFICATION_TYPE_CREATE) {
            _doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(createCircleServerFence)];
        } else {
            _doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(updateCircleServerFence)];
        }
        
    }
    return _doneButton;
}

@end
