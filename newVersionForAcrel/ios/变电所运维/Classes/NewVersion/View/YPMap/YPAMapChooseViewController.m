//
//  YPAMapChooseViewController.m
//  linphone
//
//  Created by feitian on 2016/11/28.
//
//

#import "YPAMapChooseViewController.h"
#import <MAMapKit/MAMapKit.h>

#import <AMapSearchKit/AMapSearchKit.h>
#import "YPAMapSearchPointViewController.h"
#import "YPAMapChooseCell.h"
#import "UIBarButtonItem+SXCreate.h"

@interface YPAMapChooseViewController ()<MAMapViewDelegate,AMapSearchDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) UIButton *gpsButton;
@property (nonatomic, strong) MAPointAnnotation *poiAnnotation;
@property (strong, nonatomic) IBOutlet UIView *topV;

@property (strong, nonatomic) IBOutlet UITableView *tableV;
@property (strong,nonatomic) NSMutableArray *dataArray;
@property (nonatomic, strong) AMapSearchAPI *search;


@end

@implementation YPAMapChooseViewController

-(void)setChooseLocationBlock:(void (^)(NSDictionary *))chooseLocationBlock{
    _chooseLocationBlock = [chooseLocationBlock copy];
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"选择位置";    
    
    UIBarButtonItem *seachItem = [[UIBarButtonItem alloc] initWithTitle:@"搜索"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(searchAction)];
    UIBarButtonItem *sendItem = [[UIBarButtonItem alloc] initWithTitle:@"上传"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(sendAction)];
    // 字体大小
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spacer.width = 15;
    [self.navigationItem setRightBarButtonItems:@[spacer,sendItem,seachItem]];
    
    self.mapView = [[MAMapView alloc] initWithFrame:self.topV.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    [self.topV addSubview:self.mapView];
    
    UIView *zoomPannelView = [self makeZoomPannelView];
    zoomPannelView.center = CGPointMake(self.mapView.bounds.size.width -  CGRectGetMidX(zoomPannelView.bounds) - 10,
                                        self.mapView.bounds.size.height -  CGRectGetMidY(zoomPannelView.bounds) - 10);
    
    zoomPannelView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.mapView addSubview:zoomPannelView];
    
    self.gpsButton = [self makeGPSButtonView];
    self.gpsButton.center = CGPointMake(CGRectGetMidX(self.gpsButton.bounds) + 10,
                                        self.mapView.bounds.size.height -  CGRectGetMidY(self.gpsButton.bounds) - 20);
    [self.mapView addSubview:self.gpsButton];
    self.gpsButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    
    self.dataArray = [NSMutableArray array];
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self.tableV registerNib:[UINib nibWithNibName:@"YPAMapChooseCell" bundle:nil] forCellReuseIdentifier:@"YPAMapChooseCell"];
    self.tableV.bounces = NO;
    self.tableV.delegate = self;
    self.tableV.dataSource = self;
    self.tableV.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableV.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.tableV];
    [self.tableV setFooterCellLineHidden];
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
}

- (void)initNavigationBarButtonItems {
    [super initNavigationBarButtonItems];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (UIButton *)makeGPSButtonView {
    UIButton *ret = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    ret.backgroundColor = [UIColor whiteColor];
    ret.layer.cornerRadius = 4;
    
    [ret setImage:[UIImage imageNamed:@"gpsStat1"] forState:UIControlStateNormal];
    [ret addTarget:self action:@selector(gpsAction) forControlEvents:UIControlEventTouchUpInside];
    
    return ret;
}

- (UIView *)makeZoomPannelView
{
    UIView *ret = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 53, 98)];
    
    UIButton *incBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 53, 49)];
    [incBtn setImage:[UIImage imageNamed:@"increase"] forState:UIControlStateNormal];
    [incBtn sizeToFit];
    [incBtn addTarget:self action:@selector(zoomPlusAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *decBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 49, 53, 49)];
    [decBtn setImage:[UIImage imageNamed:@"decrease"] forState:UIControlStateNormal];
    [decBtn sizeToFit];
    [decBtn addTarget:self action:@selector(zoomMinusAction) forControlEvents:UIControlEventTouchUpInside];
    
    
    [ret addSubview:incBtn];
    [ret addSubview:decBtn];
    
    return ret;
}

#pragma mark - Action Handlers
-(void)backButtonAction:(UIButton *)backBtn
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)searchAction {
    YPAMapSearchPointViewController *vc = [[YPAMapSearchPointViewController alloc] initWithNibName:@"YPAMapSearchPointViewController" bundle:nil];
    vc.citycode = self.citycode;
    [vc setChooseBlock:^(NSArray *data, NSIndexPath *indexPath) {
        AMapPOI *model = data[indexPath.row];
        self.mapView.centerCoordinate = CLLocationCoordinate2DMake(model.location.latitude, model.location.longitude);
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:data];
        [self.tableV reloadData];
        [self.tableV selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        [self tableView:self.tableV didSelectRowAtIndexPath:indexPath];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)sendAction{
    if (_chooseLocationBlock) {
        if (self.dataArray.count<1) {
            DefQuickAlert(@"网络异常，请检查网络设置", nil);
            return;
        }
        NSIndexPath *indexPath = [self.tableV indexPathForSelectedRow];
        AMapPOI *model = self.dataArray[indexPath.row];
        if (!model) {
            DefQuickAlert(@"网络异常，请检查网络设置", nil);
            return;
        }
        
        NSLog(@"%@,%@,%lf,%lf",model.name,model.address,model.location.longitude,model.location.latitude);
        NSString *longitude = [NSString stringWithFormat:@"%lf",model.location.longitude];
        NSString *latitude = [NSString stringWithFormat:@"%lf",model.location.latitude];
        NSString *name = [NSString stringWithFormat:@"%@",model.name];
        NSString *address = [NSString stringWithFormat:@"%@",model.address];
        self.mapView.showsUserLocation = NO;
        UIImage * image = [self.mapView takeSnapshotInRect:self.mapView.bounds];
        NSString *stringPin = [NSString stringWithFormat:@"/getLocation.do?lat=%@&lon=%@",latitude,longitude];
        NSString *realURL =[BASE_URL stringByAppendingString:stringPin];
        [NetService bg_postWithPath:realURL params:@{@"lat":latitude,@"lon":longitude} success:^(id respObjc) {
            DefLog(@"成功上传定位：%@",respObjc);
            [MBProgressHUD showSuccess:[NSString stringWithFormat:@"上传位置成功"]];
        } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
            
        }];
//        NSString *localImagePath = [BGChatUtils saveImageToLocal:image];
        
//        NSDictionary *data = @{@"longitude":longitude,
//                               @"latitude":latitude,
//                               kaddressName:name,
//                               @"address":address,
//                               @"image":image,
//                               klocalImgPath:localImagePath
//                               };
//        _chooseLocationBlock(data);
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)zoomPlusAction
{
    CGFloat oldZoom = self.mapView.zoomLevel;
    [self.mapView setZoomLevel:(oldZoom + 1) animated:YES];
}

- (void)zoomMinusAction
{
    CGFloat oldZoom = self.mapView.zoomLevel;
    [self.mapView setZoomLevel:(oldZoom - 1) animated:YES];
}

- (void)gpsAction {
    if(self.mapView.userLocation.updating && self.mapView.userLocation.location) {
        [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
        [self.gpsButton setSelected:YES];
        [self searchPoiByCenterCoordinate];
    }
}

- (void)initAnnotation
{
    self.poiAnnotation = [[MAPointAnnotation alloc] init];
    self.poiAnnotation.coordinate = self.mapView.userLocation.location.coordinate;
    self.poiAnnotation.title      = [NSString stringWithFormat:@"anno:"];
    self.poiAnnotation.lockedToScreen = YES;
    self.poiAnnotation.lockedScreenPoint = self.mapView.center;
    [self.mapView addAnnotation:self.poiAnnotation];
    [self.mapView selectAnnotation:self.poiAnnotation animated:YES];
    
    
}

#pragma mark - Map Delegate

/*!
 @brief 根据anntation生成对应的View
 @param mapView 地图View
 @param annotation 指定的标注
 @return 生成的标注View
 */
- (MAAnnotationView*)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
        }
        
        //        annotationView.canShowCallout               = YES;
        annotationView.animatesDrop                 = YES;
        //        annotationView.draggable                    = YES;
        //        annotationView.rightCalloutAccessoryView    = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        annotationView.pinColor                     = 0;
        
        return annotationView;
    }
    
    return nil;
}

-(void)mapViewWillStartLocatingUser:(MAMapView *)mapView{
    
}
-(void)mapViewDidStopLocatingUser:(MAMapView *)mapView{
    
}
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    if (updatingLocation && self.poiAnnotation == nil) {
        self.mapView.centerCoordinate = self.mapView.userLocation.location.coordinate;
        self.mapView.zoomLevel = 14;
        [self initAnnotation];
        [self searchPoiByCenterCoordinate];
    }
    
}
-(void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction{
    if (wasUserAction) {
        NSLog(@"%lf,%lf",mapView.centerCoordinate.longitude,mapView.centerCoordinate.latitude);
        [self searchPoiByCoordinate:mapView.centerCoordinate];
    }
}

#pragma mark - AMapSearchDelegate
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
}

/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if (response.pois.count == 0)
    {
        return;
    }
    [self.dataArray removeAllObjects];
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        if (self.citycode == nil && obj.citycode ) {
            self.citycode = obj.citycode;
        }
        [self.dataArray addObject:obj];
        
    }];
    [self.tableV reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableV selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self tableView:self.tableV didSelectRowAtIndexPath:indexPath];
}

#pragma mark - Utility

/* 根据中心点坐标来搜周边的POI. */
- (void)searchPoiByCoordinate:(CLLocationCoordinate2D )coordinate
{
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    
    request.location            = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    request.keywords            = @"";
    /* 按照距离排序. */
    request.sortrule            = 0;
    request.requireExtension    = YES;
    
    [self.search AMapPOIAroundSearch:request];
}

/* 根据中心点坐标来搜周边的POI. */
- (void)searchPoiByCenterCoordinate
{
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    
    request.location            = [AMapGeoPoint locationWithLatitude:self.mapView.userLocation.location.coordinate.latitude longitude:self.mapView.userLocation.location.coordinate.longitude];
    request.keywords            = @"";
    /* 按照距离排序. */
    request.sortrule            = 0;
    request.requireExtension    = YES;
    
    [self.search AMapPOIAroundSearch:request];
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
    cell.rightIV.hidden = YES;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    YPAMapChooseCell *cell =[tableView cellForRowAtIndexPath:indexPath];
    cell.rightIV.hidden = NO;
    AMapPOI *model = self.dataArray[indexPath.row];
    NSLog(@"%@,%lf,%lf",model.name,model.location.longitude,model.location.latitude);
    self.mapView.centerCoordinate = CLLocationCoordinate2DMake(model.location.latitude, model.location.longitude);
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    YPAMapChooseCell *cell =[tableView cellForRowAtIndexPath:indexPath];
    cell.rightIV.hidden = YES;
}

@end
