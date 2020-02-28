//
//  YYHistoryTrackViewController.m
//  YYObjCDemo
//
//  Created by Daniel Bey on 2017年06月16日.
//  Copyright © 2017 百度鹰眼. All rights reserved.
//

#import "YYHistoryTrackViewController.h"
#import "YYHistoryTrackParamSetTableViewController.h"
#import "YYHistoryViewModel.h"
#import "YYHistoryTrackPoint.h"
#import "YYArrowAnnotationView.h"
#import "YYMultiColorPolyline.h"
#import "WSDatePickerView.h"

@interface YYHistoryTrackViewController ()

/**
 播放轨迹动画时的箭头图标
 */
@property (nonatomic, strong) BMKPointAnnotation *arrowAnnotation;

/**
 播放轨迹动画时的箭头View
 */
@property (nonatomic, strong) YYArrowAnnotationView *arrowAnnotationView;

/**
 地图底图
 */
@property (nonatomic, strong) BMKMapView *mapView;

/**
 点击此按钮进入历史轨迹查询的参数设置页面
 */
@property (nonatomic, strong) UIBarButtonItem *paramSetButton;

/**
 点击此按钮手动发起一次历史轨迹查询
 */
@property (nonatomic, strong) UIBarButtonItem *refreshButton;

/**
 点击此按钮播放轨迹动画
 */
@property (nonatomic, strong) UIBarButtonItem *playButton;

/**
 切换是否使用不同颜色代表不同的速度
 */
@property (nonatomic, strong) UISegmentedControl *wormSegmentControl;

@property (nonatomic, strong) YYHistoryTrackParam *param;
@property (nonatomic, copy) NSArray *historyPoints;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong) dispatch_queue_t pointsQueue;

@property(nonatomic, strong) QMUIFillButton *searchBtn;
@end

static double const EPSILON = 0.0001;
static NSString * const kStartPositionTitle = @"起点";
static NSString * const kEndPositionTitle = @"终点";
static NSString * const kArrowTitle = @"箭头";

@implementation YYHistoryTrackViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     self.navigationController.navigationBarHidden = NO;
    [self.mapView viewWillAppear];
    self.mapView.delegate = self;
    // 每次显示页面时默认用单色图
    self.wormSegmentControl.selectedSegmentIndex = 0;
    //开始时间按钮
    UIView *selectTimeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    selectTimeView.backgroundColor = DefColorFromRGB(181,223,228,1);
    
    QMUIButton *selectStartBtn = [[QMUIButton alloc] init];
    selectStartBtn.frame = CGRectMake(5, 5, SCREEN_WIDTH/3-5, 40);
    selectStartBtn.layer.cornerRadius = 5;
    selectStartBtn.backgroundColor = [UIColor whiteColor];
    selectStartBtn.titleLabel.font = UIFontMake(14);
    [selectStartBtn setTitle:@"开始时间" forState:UIControlStateNormal];
    [selectStartBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [selectStartBtn addTarget:self action:@selector(selectStartTime:) forControlEvents:UIControlEventTouchUpInside];
    [selectTimeView addSubview:selectStartBtn];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5+SCREEN_WIDTH/3+5, 5, 15, 40)];
    label.text = @"至";
    [selectTimeView addSubview:label];
    
    //结束时间按钮
    QMUIButton *selectEndBtn =  [[QMUIButton alloc] init];
    selectEndBtn.frame = CGRectMake(5+SCREEN_WIDTH/3+38, 5, SCREEN_WIDTH/3-5, 40);
    selectEndBtn.layer.cornerRadius = 5;
    selectEndBtn.titleLabel.font = UIFontMake(14);
    selectEndBtn.backgroundColor = [UIColor whiteColor];
    [selectEndBtn setTitle:@"结束时间" forState:UIControlStateNormal];
    [selectEndBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    selectStartBtn.titleLabel.textColor = [UIColor blackColor];
    [selectEndBtn addTarget:self action:@selector(selectEndTime:) forControlEvents:UIControlEventTouchUpInside];
    [selectTimeView addSubview:selectEndBtn];
    
    //搜索按钮
    self.searchBtn = [[QMUIFillButton alloc] initWithFillType:QMUIFillButtonColorGreen];
    self.searchBtn.titleLabel.font = UIFontMake(14);
    self.searchBtn.frame = CGRectMake(SCREEN_WIDTH-85, 10, 80, 30);
    [self.searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [self.searchBtn setImage:[UIImage imageNamed:@"searchImg"] forState:UIControlStateNormal];
    self.searchBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 6);
    self.searchBtn.adjustsImageWithTitleTextColor = YES;
    [self.searchBtn addTarget:self action:@selector(clickSearchBtn:) forControlEvents:UIControlEventTouchUpInside];
    [selectTimeView addSubview:self.searchBtn];
    
    [self.view addSubview:selectTimeView];
}

-(void)selectStartTime:(QMUIButton *)sender{
    //年-月-日-时-分
//    NSInteger startTime = [USER_DEFAULTS integerForKey:HISTORY_TRACK_START_TIME];
//                   if (startTime != 0) {
//                       _param.startTime = startTime;
//                   } else {
//                       _param.startTime = [[NSDate date] timeIntervalSince1970] - 24 * 60 *60;
//                   }
//                   NSInteger endTime = [USER_DEFAULTS integerForKey:HISTORY_TRACK_END_TIME];
//                   if (endTime != 0) {
//                       _param.endTime = endTime;
//                   } else {
//                         _param.endTime = [[NSDate date] timeIntervalSince1970];
//                   }
    WSDatePickerView *datepicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDayHourMinute CompleteBlock:^(NSDate *selectDate) {
        
        NSString *dateString = [selectDate stringWithFormat:@"yyyy-MM-dd HH:mm"];
        NSLog(@"选择的日期：%@",dateString);
        self.param.startTime = [selectDate timeIntervalSince1970];
        [sender setTitle:dateString forState:UIControlStateNormal];
    }];
    datepicker.dateLabelColor = COLOR_NAVBAR;//年-月-日-时-分 颜色
    datepicker.datePickerColor = [UIColor blackColor];//滚轮日期颜色
    datepicker.doneButtonColor = COLOR_NAVBAR;//确定按钮的颜色
    [datepicker show];
}

-(void)selectEndTime:(QMUIButton *)sender{
    //年-月-日-时-分
    WSDatePickerView *datepicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDayHourMinute CompleteBlock:^(NSDate *selectDate) {
        
        NSString *dateString = [selectDate stringWithFormat:@"yyyy-MM-dd HH:mm"];
        self.param.endTime = [selectDate timeIntervalSince1970];
        NSLog(@"选择的日期：%@",dateString);
        [sender setTitle:dateString forState:UIControlStateNormal];
    }];
    datepicker.dateLabelColor = COLOR_NAVBAR;//年-月-日-时-分 颜色
    datepicker.datePickerColor = [UIColor blackColor];//滚轮日期颜色
    datepicker.doneButtonColor = COLOR_NAVBAR;//确定按钮的颜色
    [datepicker show];
}

-(void)clickSearchBtn:(QMUIFillButton *)sender{
    YYHistoryViewModel *vm = [[YYHistoryViewModel alloc] init];
    vm.completionHandler = ^(NSArray *points) {
        self.historyPoints = points;
        [self drawHistoryTrackWithPoints:points];
    };
    [vm queryHistoryWithParam:self.param];
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.mapView viewWillDisappear];
    self.mapView.delegate = nil;
}

-(void)dealloc {
    self.mapView = nil;
}

#pragma mark - BMKMapViewDelegate
-(BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay {
    if ([overlay isMemberOfClass:[BMKPolyline class]]) {
        // 普通图使用单一颜色渲染轨迹
        BMKPolylineView *view = [[BMKPolylineView alloc] initWithOverlay:overlay];
        view.strokeColor = [UIColor colorWithRed:1 green:0 blue:0.4 alpha:0.7];
        view.lineWidth = 3;
        return view;
    } else if ([overlay isMemberOfClass:[YYMultiColorPolyline class]]) {
        // 蚯蚓图中每段轨迹使用不同的颜色渲染
        BMKPolylineView *view = [[BMKPolylineView alloc] initWithOverlay:overlay];
        view.strokeColor = ((YYMultiColorPolyline *)overlay).color;
        view.lineWidth = 3;
        return view;
    } else {
        return nil;
    }
}

// 绘制起点、终点
-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation {
    BMKAnnotationView *view = nil;
    if ([annotation.title isEqualToString:kStartPositionTitle]) {
        static NSString *historyTrackStartPositionAnnotationViewID = @"historyTrackStartPositionAnnotationViewID";
        view = [mapView dequeueReusableAnnotationViewWithIdentifier:historyTrackStartPositionAnnotationViewID];
        if (view == nil) {
            view = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:historyTrackStartPositionAnnotationViewID];
            view.image = [UIImage imageNamed:@"icon_start"];
        }
    } else if ([annotation.title isEqualToString:kEndPositionTitle]) {
        static NSString *historyTrackEndPositionAnnotationViewID = @"historyTrackEndPositionAnnotationViewID";
        view = [mapView dequeueReusableAnnotationViewWithIdentifier:historyTrackEndPositionAnnotationViewID];
        if (view == nil) {
            view = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:historyTrackEndPositionAnnotationViewID];
            view.image = [UIImage imageNamed:@"icon_end"];
        }
    } else if ([annotation.title isEqualToString:kArrowTitle]) {
        static NSString *historyTrackArrorAnnotationViewID = @"historyTrackArrorAnnotationViewID";
        view = [mapView dequeueReusableAnnotationViewWithIdentifier:historyTrackArrorAnnotationViewID];
        if (view == nil) {
            self.arrowAnnotationView = [[YYArrowAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:historyTrackArrorAnnotationViewID];
            self.arrowAnnotationView.imageView.transform = CGAffineTransformMakeRotation(((YYHistoryTrackPoint *)[self.historyPoints firstObject]).direction);
            view = self.arrowAnnotationView;
        }
    }
    return view;
}


#pragma mark - event response
- (void)showParamSettings {
    //设置按钮
    YYHistoryTrackParamSetTableViewController *paramVC = [[YYHistoryTrackParamSetTableViewController alloc] init];
    paramVC.completionHandler = ^(YYHistoryTrackParam *paramInfo) {
        self.param = paramInfo;
        self.param.entityName = self.bgEntityName;
        
        [self queryHistoryTrack];
    };
    [self.navigationController pushViewController:paramVC animated:YES];
}

- (void)didClickWormSegmentedControl:(UISegmentedControl *)segmentControl {
    if (self.historyPoints.count == 0) {
        // 如果当前都没有查询出来数据，点击也没用，直接返回
        return;
    }
    NSInteger idx = segmentControl.selectedSegmentIndex;
    if (idx == 0) {
        // 单色图
        [self drawHistoryTrackWithPoints:self.historyPoints];
    } else {
        // 蚯蚓图
        [self drawColoredHistoryTrackWithPoints:self.historyPoints];
    }
}


#pragma mark - private function
- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    // 设置导航栏
//    NSArray *rightButtons = [NSArray arrayWithObjects:self.playButton, self.paramSetButton, self.refreshButton, nil];
//    NSArray *rightButtons = [NSArray arrayWithObjects:self.paramSetButton, self.refreshButton, nil];
//    [self.navigationItem setRightBarButtonItems:rightButtons];
    self.navigationItem.title = @"查询历史轨迹";
    // 设置控件
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.wormSegmentControl];
    [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.translatesAutoresizingMaskIntoConstraints = FALSE;
    }];
    // 设置约束
    [self setupConstraints];
    
    // 如果有之前的定位点，则将地图中心设置在定位点，如果没有的话，就保持地图中心点在默认的天安门
    NSData *locationData = [USER_DEFAULTS objectForKey:LATEST_LOCATION];
    if (locationData == nil) {
        return;
    }
    CLLocation *position = [NSKeyedUnarchiver unarchiveObjectWithData:locationData];
    dispatch_async(MAIN_QUEUE, ^{
        [self.mapView setCenterCoordinate:position.coordinate];
        self.mapView.zoomLevel = 19;
    });
}

- (void)setupConstraints {
    // segmentedControl的约束
    // 水平居中，下边紧贴view，宽度为屏幕宽度的60%, 高度40
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.wormSegmentControl
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]
    ];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.wormSegmentControl
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0]
    ];
    [self.wormSegmentControl addConstraint:[NSLayoutConstraint constraintWithItem:self.wormSegmentControl
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:1
                                                                constant:SCREEN_WIDTH * 0.6]
    ];
    [self.wormSegmentControl addConstraint:[NSLayoutConstraint constraintWithItem:self.wormSegmentControl
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:1
                                                                         constant:40]
    ];
    // mapView的约束: 上、下、左、右、都紧贴view
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mapView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
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
}

- (void)queryHistoryTrack {
    YYHistoryViewModel *vm = [[YYHistoryViewModel alloc] init];
    vm.completionHandler = ^(NSArray *points) {
        self.historyPoints = points;
        [self drawHistoryTrackWithPoints:points];
    };
    [vm queryHistoryWithParam:self.param];
}


- (void)playHistoryAnnimation {
    if (self.historyPoints.count == 0) {
        dispatch_async(MAIN_QUEUE, ^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"没有轨迹可播放" message:@"请先查询轨迹再播放" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:defaultAction];
            [self presentViewController:alertController animated:YES completion:nil];
        });
        return;
    }
    // 播放轨迹前，先调整当前地图的视野范围
    [self mapViewFitForCoordinates:self.historyPoints];
    // 放置箭头的初始位置
    BMKPointAnnotation *arrowAnnotation = [[BMKPointAnnotation alloc] init];
    arrowAnnotation.coordinate = ((YYHistoryTrackPoint *)[self.historyPoints firstObject]).coordinate;
    arrowAnnotation.title = kArrowTitle;
    [self.mapView addAnnotation:arrowAnnotation];
    // 箭头沿着轨迹移动
    self.index = 0;
    [self moveTheArrow];
}

- (void)moveTheArrow {
    if (self.index == self.historyPoints.count - 1) {
        return;
    }
    YYHistoryTrackPoint *point = [self.historyPoints objectAtIndex:self.index];
    YYHistoryTrackPoint *nextPoint = [self.historyPoints objectAtIndex:(self.index + 1)];
    self.arrowAnnotationView.imageView.transform = CGAffineTransformIdentity;
    self.arrowAnnotationView.imageView.transform = CGAffineTransformMakeRotation(point.direction * M_PI / 180.0 );
    double timeInterval = nextPoint.loctime - point.loctime;
    // 这里的动画耗时可以根据自己的喜好自行选择
    //double duration = 0.5 / averageSpeed;
    double duration = 0.02 * timeInterval;
    [UIView animateWithDuration:duration animations:^{
        self.index++;
        YYHistoryTrackPoint *point = [self.historyPoints objectAtIndex:self.index];
        self.arrowAnnotationView.annotation.coordinate = ((YYHistoryTrackPoint *)point).coordinate;
    } completion:^(BOOL finished) {
        [self moveTheArrow];
    }];
}

// 将YYHistoryTrackPoint数组中的轨迹点绘制在地图上
- (void)drawHistoryTrackWithPoints:(NSArray *)points {
    // line代表轨迹
    CLLocationCoordinate2D coors[points.count];
    NSInteger count = 0;
    for (size_t i = 0; i < points.count; i++) {
        CLLocationCoordinate2D p = ((YYHistoryTrackPoint *)points[i]).coordinate;
        if (fabs(p.latitude) < EPSILON || fabs(p.longitude) < EPSILON) {
            continue;
        }
        count++;
        coors[i] = ((YYHistoryTrackPoint *)points[i]).coordinate;
    }
    BMKPolyline *line = [BMKPolyline polylineWithCoordinates:coors count:count];
    // 起点annotation
    BMKPointAnnotation *startAnnotation = [[BMKPointAnnotation alloc] init];
    startAnnotation.coordinate = coors[0];
    startAnnotation.title = kStartPositionTitle;
    // 终点annotation
    BMKPointAnnotation *endAnnotation = [[BMKPointAnnotation alloc] init];
    endAnnotation.coordinate = coors[count - 1];
    endAnnotation.title = kEndPositionTitle;
    
    dispatch_async(MAIN_QUEUE, ^{
        [self.mapView removeOverlays:self.mapView.overlays];
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self mapViewFitForCoordinates:points];
        [self.mapView addOverlay:line];
        [self.mapView addAnnotation:startAnnotation];
        [self.mapView addAnnotation:endAnnotation];
    });
}

- (void)drawColoredHistoryTrackWithPoints:(NSArray *)points {
    // 定义最低速对应的颜色
    UIColor *slowestColor = [UIColor colorWithRed:1.0 green:20.0 / 255.0 blue:44.0/255.0 alpha:1];
    // 定义中速对应的颜色
    UIColor *medialColor = [UIColor colorWithRed:1.0 green:215.0 / 255.0 blue:0 alpha:1];
    // 定义最高速对应的颜色
    UIColor *fastestColor = [UIColor colorWithRed:0 green:146.0 / 255.0 blue:78.0/255.0 alpha:1];
    // 计算相邻两点之间的平均速度、整段行程的最大速度、最小速度
    NSMutableArray *speedInSegment = [NSMutableArray arrayWithCapacity:points.count - 1];
    NSMutableArray *locations = [NSMutableArray arrayWithCapacity:points.count - 1];
    [locations addObject:(YYHistoryTrackPoint *)[points firstObject]];
    double minSpeed = DBL_MAX;
    double maxSpeed = 0;
    double stickyDistance = 0;
    for (size_t i = 1; i < points.count; i++) {
        YYHistoryTrackPoint *point1 = (YYHistoryTrackPoint *)points[i - 1];
        YYHistoryTrackPoint *point2 = (YYHistoryTrackPoint *)points[i];
        CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:point1.coordinate.latitude longitude:point1.coordinate.longitude];
        CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:point2.coordinate.latitude longitude:point2.coordinate.longitude];
        double distance = [loc1 distanceFromLocation:loc2] + stickyDistance;
        if (fabs(distance) < DBL_EPSILON) {
            // 如果两点间距离几乎为0，就不用构造线段了
            continue;
        }
        double duration = (double)point2.loctime - (double)point1.loctime;
        if (fabs(duration) < DBL_EPSILON) {
            // 如果两点的loctime相等，证明其中至少有一个点是绑路服务补充的道路形状点
            stickyDistance += distance;
            continue;
        } else {
            stickyDistance = 0;
        }
        double speed = distance / fabs(duration);
        minSpeed = fmin(minSpeed, speed);
        maxSpeed = fmax(maxSpeed, speed);
        [speedInSegment addObject:@(speed)];
        [locations addObject:point2];
    }

    double meanSpeed = (minSpeed + maxSpeed) / 2;
    // 构造蚯蚓线段
    // 根据每段的速度，决定其颜色
    NSMutableArray *polylines = [NSMutableArray arrayWithCapacity:speedInSegment.count - 1];
    for (size_t i = 1; i < locations.count; i++) {
        // 构造线段的端点
        CLLocationCoordinate2D coors[2];
        coors[0] = ((YYHistoryTrackPoint *)locations[i - 1]).coordinate;
        coors[1] = ((YYHistoryTrackPoint *)locations[i]).coordinate;
        // 计算线段的颜色
        double speed = [speedInSegment[i - 1] doubleValue];
        UIColor *color = nil;
        if (speed < meanSpeed) {
            double ratio = (speed - minSpeed) / (meanSpeed - minSpeed);
            CGFloat r = CGColorGetComponents(slowestColor.CGColor)[0] + ratio * (CGColorGetComponents(medialColor.CGColor)[0] - CGColorGetComponents(slowestColor.CGColor)[0]);
            CGFloat g = CGColorGetComponents(slowestColor.CGColor)[1] + ratio * (CGColorGetComponents(medialColor.CGColor)[1] - CGColorGetComponents(slowestColor.CGColor)[1]);
            CGFloat b = CGColorGetComponents(slowestColor.CGColor)[2] + ratio * (CGColorGetComponents(medialColor.CGColor)[2] - CGColorGetComponents(slowestColor.CGColor)[2]);
            color = [UIColor colorWithRed:r green:g blue:b alpha:1];
        } else {
            double ratio = (speed - meanSpeed) / (maxSpeed - meanSpeed);
            CGFloat r = CGColorGetComponents(medialColor.CGColor)[0] + ratio * (CGColorGetComponents(fastestColor.CGColor)[0] - CGColorGetComponents(medialColor.CGColor)[0]);
            CGFloat g = CGColorGetComponents(medialColor.CGColor)[1] + ratio * (CGColorGetComponents(fastestColor.CGColor)[1] - CGColorGetComponents(medialColor.CGColor)[1]);
            CGFloat b = CGColorGetComponents(medialColor.CGColor)[2] + ratio * (CGColorGetComponents(fastestColor.CGColor)[2] - CGColorGetComponents(medialColor.CGColor)[2]);
            color = [UIColor colorWithRed:r green:g blue:b alpha:1];
        }
        YYMultiColorPolyline *coloredLine = [[YYMultiColorPolyline alloc] initWithCoordinates:coors color:color];
        [polylines addObject:coloredLine];
    }
    // 起点annotation
    BMKPointAnnotation *startAnnotation = [[BMKPointAnnotation alloc] init];
    startAnnotation.coordinate = ((YYHistoryTrackPoint *)[locations firstObject]).coordinate;
    startAnnotation.title = kStartPositionTitle;
    // 终点annotation
    BMKPointAnnotation *endAnnotation = [[BMKPointAnnotation alloc] init];
    endAnnotation.coordinate = ((YYHistoryTrackPoint *)[locations lastObject]).coordinate;
    endAnnotation.title = kEndPositionTitle;
    
    dispatch_async(MAIN_QUEUE, ^{
        [self.mapView removeOverlays:self.mapView.overlays];
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self mapViewFitForCoordinates:locations];
        [self.mapView addOverlays:polylines];
        [self.mapView addAnnotation:startAnnotation];
        [self.mapView addAnnotation:endAnnotation];
    });
}

-(void)mapViewFitForCoordinates:(NSArray *)points {
    double minLat = 90.0;
    double maxLat = -90.0;
    double minLon = 180.0;
    double maxLon = -180.0;
    for (size_t i = 0; i < points.count; i++) {
        minLat = fmin(minLat, ((YYHistoryTrackPoint *)points[i]).coordinate.latitude);
        maxLat = fmax(maxLat, ((YYHistoryTrackPoint *)points[i]).coordinate.latitude);
        minLon = fmin(minLon, ((YYHistoryTrackPoint *)points[i]).coordinate.longitude);
        maxLon = fmax(maxLon, ((YYHistoryTrackPoint *)points[i]).coordinate.longitude);
    }
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((minLat + maxLat) * 0.5, (minLon + maxLon) * 0.5);
    BMKCoordinateSpan span;
    span.latitudeDelta = (maxLat - minLat) + 0.01;
    span.longitudeDelta = (maxLon - minLon) + 0.01;
    BMKCoordinateRegion region;
    region.center = center;
    region.span = span;
    [self.mapView setRegion:region animated:YES];
}

#pragma mark - setter & getter
-(YYHistoryTrackParam *)param {
    if (_param == nil) {
        _param = [[YYHistoryTrackParam alloc] init];
        //配置查询人的entityName 用userid记录
        _param.entityName = self.bgEntityName;
//        _param.entityName = @"116-236-149-165_8090-315";
         // 配置默认值
            UserManager *tjuser = [UserManager manager];
            if (tjuser.yytjBaiduDic) {
                NSDictionary *baiduDic = tjuser.yytjBaiduDic;
                
//                NSInteger startTime = [USER_DEFAULTS integerForKey:HISTORY_TRACK_START_TIME];
//                if (startTime != 0) {
//                    _param.startTime = startTime;
//                } else {
//                    _param.startTime = [[NSDate date] timeIntervalSince1970] - 24 * 60 *60;
//                }
//                NSInteger endTime = [USER_DEFAULTS integerForKey:HISTORY_TRACK_END_TIME];
//                if (endTime != 0) {
//                    _param.endTime = endTime;
//                } else {
//                      _param.endTime = [[NSDate date] timeIntervalSince1970];
//                }
                _param.isProcessed = NO;
                BTKQueryTrackProcessOption *option = [[BTKQueryTrackProcessOption alloc] init];
                option.denoise = TRUE;
                option.vacuate = TRUE;
                  
                //是否将轨迹点绑定至道路
               NSString *isBindTrack =[NSString changgeNonulWithString:baiduDic[@"tjIsBindTrack"]];
               if ([isBindTrack integerValue] == 0) {
                    option.mapMatch = FALSE;
               }else if ([isBindTrack integerValue] == 1){
                    option.mapMatch = TRUE;
               }
        
                //若只需保留 GPS 定位点，则建议设为：20；若需保留 GPS 和 Wi-Fi 定位点，去除基站定位点，则建议设为：100
                NSString *seclectFiltering =[NSString changgeNonulWithString:baiduDic[@"tjSeclectFiltering"]];
                if ([seclectFiltering integerValue] == 0) {
                    option.radiusThreshold = 0;
                }else if ([seclectFiltering integerValue] == 1){
                    option.radiusThreshold = 20;
                }else{
                    option.radiusThreshold = 100;
                }
                
                // @[@"步行、骑行、跑步", @"驾车", @"火车、飞机", @"其他类型"]; 驾车
                NSString *tjActivityType =[NSString changgeNonulWithString:baiduDic[@"tjActivityType"]];
                if([tjActivityType integerValue] == 1){
                    option.transportMode = BTK_TRACK_PROCESS_OPTION_TRANSPORT_MODE_DRIVING;
                }else if ([tjActivityType integerValue] == 3){
                    option.transportMode = BTK_TRACK_PROCESS_OPTION_TRANSPORT_MODE_AUTO;
                }else if ([tjActivityType integerValue] == 2){
                    option.transportMode = BTK_TRACK_PROCESS_OPTION_TRANSPORT_MODE_RIDING;
                }else{
                    option.transportMode = BTK_TRACK_PROCESS_OPTION_TRANSPORT_MODE_WALKING;
                }
              
                _param.processOption = option;
                
//                BTK_TRACK_PROCESS_OPTION_NO_SUPPLEMENT: 不补充，中断两点间距离不记入里程
//                - BTK_TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_STRAIGHT: 使用直线距离补充
//                - BTK_TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_DRIVING: 使用最短驾车路线距离补充
//                - BTK_TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_RIDING: 使用最短骑行路线距离补充
//                - BTK_TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_WALKING: 使用最短步行路线距离补充
                NSString *mileageCompensation =[NSString changgeNonulWithString:baiduDic[@"tjMileageCompensation"]];
                if([mileageCompensation integerValue] == 0){
                    _param.supplementMode = BTK_TRACK_PROCESS_OPTION_NO_SUPPLEMENT;
                }else if ([mileageCompensation integerValue] == 1){
                    _param.supplementMode = BTK_TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_STRAIGHT;
                }else if ([mileageCompensation integerValue] == 4){
                    _param.supplementMode = BTK_TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_DRIVING;
                }else if ([mileageCompensation integerValue] == 3){
                    _param.supplementMode = BTK_TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_RIDING;
                }else{
                    _param.supplementMode = BTK_TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_WALKING;
                }
            }else{
//                NSInteger startTime = [USER_DEFAULTS integerForKey:HISTORY_TRACK_START_TIME];
//                      if (startTime != 0) {
//                          _param.startTime = startTime;
//                      } else {
//                          _param.startTime = [[NSDate date] timeIntervalSince1970] - 24 * 60 *60;
//                      }
//                      NSInteger endTime = [USER_DEFAULTS integerForKey:HISTORY_TRACK_END_TIME];
//                      if (endTime != 0) {
//                          _param.endTime = endTime;
//                      } else {
//                          _param.endTime = [[NSDate date] timeIntervalSince1970];
//                      }
                      _param.isProcessed = NO;
                      BTKQueryTrackProcessOption *option = [[BTKQueryTrackProcessOption alloc] init];
                      option.denoise = TRUE;
                      option.vacuate = TRUE;
                      option.mapMatch = FALSE;
                      option.radiusThreshold = 0;
                      option.transportMode = BTK_TRACK_PROCESS_OPTION_TRANSPORT_MODE_WALKING;
                      _param.processOption = option;
                      _param.supplementMode = BTK_TRACK_PROCESS_OPTION_NO_SUPPLEMENT;
            }
    }
    return _param;
}

-(BMKMapView *)mapView {
    if (_mapView == nil) {
        _mapView = [[BMKMapView alloc] init];
        _mapView.zoomLevel = 19;
    }
    return _mapView;
}

-(UIBarButtonItem *)paramSetButton {
    if (_paramSetButton == nil) {
        UIImage *setupIcon = [UIImage imageNamed:@"icon_settings"];
        _paramSetButton = [[UIBarButtonItem alloc] initWithImage:setupIcon style:UIBarButtonItemStylePlain target:self action:@selector(showParamSettings)];
    }
    return _paramSetButton;
}

-(UIBarButtonItem *)refreshButton {
    if (_refreshButton == nil) {
        _refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(queryHistoryTrack)];
    }
    return _refreshButton;
}

-(UIBarButtonItem *)playButton {
    if (_playButton == nil) {
        _playButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playHistoryAnnimation)];
    }
    return _playButton;
}

-(UISegmentedControl *)wormSegmentControl {
    if (_wormSegmentControl == nil) {
        NSArray *segmentArray = @[@"单色图", @"蚯蚓图"];
        _wormSegmentControl = [[UISegmentedControl alloc] initWithItems:segmentArray];
        // 默认选择单色图
        _wormSegmentControl.selectedSegmentIndex = 0;
        [_wormSegmentControl addTarget:self action:@selector(didClickWormSegmentedControl:) forControlEvents:UIControlEventValueChanged];
    }
    return _wormSegmentControl;
}

-(dispatch_queue_t)pointsQueue {
    if (_pointsQueue == nil) {
        const char *queueName = [@"com.baidu.yingyan.demo.historyPointsQueue" UTF8String];
        _pointsQueue = dispatch_queue_create(queueName, DISPATCH_QUEUE_CONCURRENT);
    }
    return _pointsQueue;
}

@end
