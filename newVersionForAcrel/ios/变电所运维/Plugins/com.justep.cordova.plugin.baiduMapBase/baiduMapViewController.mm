//
//  baiduMapViewController.mm
//  baiduMap
//
//  Created by LiangQiangkun on 16/5/20.
//
//

#import "baiduMapViewController.h"

#define DEFAULT_VOID_COLOR [UIColor blackColor]
@interface baiduMapViewController ()
@property (nonatomic, strong) BMKUserLocation *userLocation; //当前位置对象
@end

@implementation baiduMapViewController
{
    BMKMapView *_mapView;
    BMKLocationManager *_locationManager;
    NSNotificationCenter *_defaultCenter;
    NSNumber *_colorNumber;
    BOOL _draggable;
    NSString *_bgImagePath;
    CGFloat _lineWidth;
    NSString *_borderColorStr;
    NSString *_fillColorStr;
    NSNumber *_alpha;
    NSInteger _tag;
    NSMutableArray *_overlayArray;
    NSDictionary *_locationDic;
    BOOL _isExist;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _defaultCenter = [NSNotificationCenter defaultCenter];
    //添加观察者
    [_defaultCenter addObserver:self selector:@selector(didReceiveFromCDVBaiduMap:) name:@"sendToMapVC" object:nil];
    [self openMapView:self.mapSettings];
    _mapView.delegate = self;
    self.view = _mapView;
    //启动LocationService
    //显示定位图层
    _overlayArray = [[NSMutableArray alloc]init];
    //初始化BMKLocationService
    _locationManager = [[BMKLocationManager alloc]init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.allowsBackgroundLocationUpdates = YES;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    [_locationManager startUpdatingHeading];
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = BMKUserTrackingModeNone;
}

-(void)openMapView:(NSDictionary *)mapSettings{
    if (!_mapView) {
        _mapView = [[BMKMapView alloc]init];
    }
    //创建地图视图
    //设置地图的frame
    CGRect rect;
    NSDictionary *rectDic = [mapSettings objectForKey:@"position"];
    if (rectDic) {
        CGFloat x = [[rectDic objectForKey:@"x"] floatValue];
        CGFloat y = [[rectDic objectForKey:@"y"] floatValue];
        CGFloat w = [[rectDic objectForKey:@"w"] floatValue];
        CGFloat h = [[rectDic objectForKey:@"h"] floatValue];
        rect = CGRectMake(x, y, w, h);
    }else{
        //默认设置为满屏显示
        rect = [[UIScreen mainScreen] bounds];
        [_defaultCenter postNotificationName:@"mapOpenWithFullScreen" object:nil];
    }
    _mapView.frame = rect;
    //设置地图中心的经纬度
    NSDictionary *centerDic = [mapSettings objectForKey:@"center"];
    if (centerDic) {
        CLLocationCoordinate2D center;
        center.latitude = [[centerDic objectForKey:@"lat"] floatValue];
        center.longitude = [[centerDic objectForKey:@"lon"] floatValue];
        _mapView.centerCoordinate = center;
    }else{
      if(_userLocation.location != nil){
        _mapView.centerCoordinate = _userLocation.location.coordinate;
      }
    }
    //设置缩放等级
    NSNumber *zoomLevel = [mapSettings objectForKey:@"zoomLevel"];
    if(!zoomLevel){
        _mapView.zoomLevel = 10;
    }else{
        _mapView.zoomLevel = [zoomLevel floatValue];
    }
}

//接收到来自CDVMap的通知
-(void)didReceiveFromCDVBaiduMap:(NSNotification *)notification{
    NSDictionary *args = notification.userInfo;
    NSDictionary *params = [args objectForKey:@"params"];
    NSString *action = [args objectForKey:@"action"];
    [self performSelector:NSSelectorFromString(action) withObject:params];
}

//重新设置百度地图的显示区域及位置
-(void)setPosition:(NSDictionary *)params{
    CGFloat x = [[params objectForKey:@"x"] floatValue];
    CGFloat y = [[params objectForKey:@"y"] floatValue];
    CGFloat w = [[params objectForKey:@"w"] floatValue];
    CGFloat h = [[params objectForKey:@"h"] floatValue];
    [_mapView setFrame:CGRectMake(x, y, w, h)];
}

//获取当前位置的经纬度
-(void)getCurrentLocation:(NSDictionary *)params{
    [_defaultCenter postNotificationName:@"successCallBack" object:nil userInfo:_locationDic];
}

//停止定位
-(void)stopLocation{
  //关闭定位服务
  [_locationManager stopUpdatingLocation];
  [_locationManager stopUpdatingHeading];
  //不显示定位图层
  _mapView.showsUserLocation = NO;
}

//显示用户的位置
-(void)showCurrentLocation:(NSDictionary *)params{
    BOOL isShow = [[params objectForKey:@"isShow"] boolValue];
    [_mapView setShowsUserLocation:isShow];
    NSString *modeStr = [params objectForKey:@"trackingMode"];
    if (isShow) {
        //显示用户位置，设置显示方式
        if ([modeStr isEqualToString:@"none"]) {
            [_mapView setUserTrackingMode:BMKUserTrackingModeNone];
        }else if ([modeStr isEqualToString:@"follow"]){
            [_mapView setUserTrackingMode:BMKUserTrackingModeFollow];
        }else if ([modeStr isEqualToString:@"compass"]){
            [_mapView setUserTrackingMode:BMKUserTrackingModeFollowWithHeading];
        }else{
            [_mapView setUserTrackingMode:BMKUserTrackingModeNone];
        }
        _mapView.centerCoordinate = _userLocation.location.coordinate;
    }
}
//设置地图的中心点的经纬度
-(void)setCenter:(NSDictionary *)params{
    CLLocationCoordinate2D center;
    center.latitude = [[params objectForKey:@"lat"] floatValue];
    center.longitude = [[params objectForKey:@"lon"] floatValue];
    if (center.longitude && center.latitude) {
        _mapView.centerCoordinate = center;
    }
}

//获取地图中心的经纬度
-(void)getCenter{
    CLLocationCoordinate2D center = _mapView.centerCoordinate;
    NSDictionary *dic = @{@"lon" : [NSNumber numberWithDouble:center.longitude],@"lat" :[NSNumber numberWithDouble:center.latitude]};
    [_defaultCenter postNotificationName:@"successCallBack" object:nil userInfo:dic];
}

//设置地图的缩放等级
-(void)setZoomLevel:(NSDictionary *)params{
    NSNumber *zoomLevel = [params objectForKey:@"zoomLevel"];
    [_mapView setZoomLevel:[zoomLevel floatValue]];
}
//设置地图相关属性
-(void)setMapAttr:(NSDictionary *)params{
    NSString *typeStr = [params objectForKey:@"type"];
    if ([typeStr isEqualToString:@"none"]) {
        [_mapView setMapType:BMKMapTypeNone];
    }else if ([typeStr isEqualToString:@"standard"]){
        [_mapView setMapType:BMKMapTypeStandard];
    }else if ([typeStr isEqualToString:@"satellite"]){
        [_mapView setMapType:BMKMapTypeSatellite];
    }
    BOOL zoomEnable = [[params objectForKey:@"zoomEnable"] boolValue];
    [_mapView setZoomEnabled:zoomEnable];
    BOOL scrollEnable = [[params objectForKey:@"scrollEnable"] boolValue];
    [_mapView setScrollEnabled:scrollEnable];
}
//设置地图的旋转角度
-(void)setRotation:(NSDictionary *)params{
    NSNumber *rotation = [params objectForKey:@"rotation"];
    [_mapView setRotateEnabled:YES];
    [_mapView setRotation:[rotation intValue]];
}
//设置地图的俯视角度
-(void)setOverlook:(NSDictionary *)params{
    NSNumber *overlook = [params objectForKey:@"overlook"];
    [_mapView setOverlookEnabled:YES];
    [_mapView setOverlooking:[overlook intValue]];
}
//设置地图的比例尺
-(void)setScaleBar:(NSDictionary *)params{
    NSNumber *number = [params objectForKey:@"isShow"];
    BOOL isShow = [number boolValue];
    [_mapView setShowMapScaleBar:isShow];
    NSDictionary *postion = [params objectForKey:@"position"];
    CGPoint point = CGPointMake([[postion objectForKey:@"x"] floatValue], [[postion objectForKey:@"y"] floatValue]);
    [_mapView setMapScaleBarPosition:point];
}
//设置地图的指南针的位置
-(void)setCompass:(NSDictionary *)params{
    if (params) {
        [_mapView setCompassPosition:CGPointMake([[params objectForKey:@"x"] floatValue], [[params objectForKey:@"y"]floatValue])];
    }else{
        [_mapView setCompassPosition:CGPointMake(0,0)];
    }
}
//设置是否显示交通情况
-(void)setTraffic:(NSDictionary *)params{
    NSNumber *number = [params objectForKey:@"isShow"];
    BOOL isShow = [number boolValue];
    [_mapView setTrafficEnabled:isShow];
}
//设置是否显示热力图层
-(void)setHeatMap:(NSDictionary *)params{
    NSNumber *number = [params objectForKey:@"isShow"];
    BOOL isShow = [number boolValue];
    [_mapView setBaiduHeatMapEnabled:isShow];
}
//设置是否显示3D楼块
-(void)setBuilding:(NSDictionary *)params{
    NSNumber *number = [params objectForKey:@"isShow"];
    BOOL isShow = [number boolValue];
    [_mapView setBuildingsEnabled:isShow];
}
//设置地图显示矩形区域
-(void)setRegion:(NSDictionary *)params{
    BMKCoordinateRegion region;
    if ([params objectForKey:@"center"]) {
        //此时传入中心点+经纬度差
        NSNumber *lonDelta = [params objectForKey:@"lonDelta"];
        NSNumber *latDelta = [params objectForKey:@"latDelta"];
        BMKCoordinateSpan span;
        span.latitudeDelta = [latDelta floatValue];
        span.longitudeDelta = [lonDelta floatValue];
        NSDictionary *center = [params objectForKey:@"center"];
        region.span = span;
        region.center = CLLocationCoordinate2DMake([[center objectForKey:@"lat"] floatValue], [[center objectForKey:@"lon"] floatValue]);
        
    } else {
        NSDictionary *southwest = [params objectForKey:@"southwest"];
        NSDictionary *northeast = [params objectForKey:@"northeast"];
        if (southwest && northeast) {
            double swLat = [[southwest objectForKey:@"lat"] doubleValue];
            double swLon = [[southwest objectForKey:@"lon"]doubleValue];
            double neLat = [[northeast objectForKey:@"lat"]doubleValue];
            double neLon = [[northeast objectForKey:@"lon"]doubleValue];
            double cLat = (swLat + neLat)/2;
            double cLon = (swLon + neLon)/2;
            double lonDelta = fabs(swLon - neLon);
            double latDelta = fabs(swLat - neLat);
            region.center = CLLocationCoordinate2DMake(cLat, cLon);
            BMKCoordinateSpan span;
            span.latitudeDelta = latDelta;
            span.longitudeDelta = lonDelta;
            region.span = span;
        }
    }
    BOOL animated = [[params objectForKey:@"animation"] boolValue];
    [_mapView setRegion:region animated:animated];
    
}
//获取地图显示的矩形区域
-(void)getRegion{
    CLLocationCoordinate2D regionCenter = _mapView.region.center;
    NSNumber *lon = [NSNumber numberWithFloat:regionCenter.longitude];
    NSNumber *lat = [NSNumber numberWithFloat:regionCenter.latitude];
    NSDictionary *center = @{@"lon":lon,@"lat":lat};
    NSNumber *latDelta = [NSNumber numberWithFloat:_mapView.region.span.latitudeDelta];
    NSNumber *lonDelta = [NSNumber numberWithFloat:_mapView.region.span.longitudeDelta];
    NSDictionary *dic = @{@"lonDelta":lonDelta,@"latDelta":latDelta,@"center":center};
    if (latDelta && lonDelta && center) {
        [_defaultCenter postNotificationName:@"successCallBack" object:nil userInfo:dic];
    }else{
        [_defaultCenter postNotificationName:@"errorCallBack" object:nil userInfo:nil];
    }
}
//缩小地图，放大视角，放大一级比例尺，此接口自带动画效果
-(void)zoomIn{
    [_mapView zoomIn];
}
////放大地图，缩小视角，缩小一级比例尺，此接口自带动画效果
-(void)zoomOut{
    [_mapView zoomOut];
}
//在地图上添加大头针视图
-(void)addAnnotations:(NSDictionary *)params{
    //标注的数组
    NSArray *annotationsArray = [params objectForKey:@"annotationsArray"];
    //添加标注
    for (int i = 0; i < [annotationsArray count]; i++) {
        NSDictionary *tempDic = annotationsArray[i];
        _tag = [[tempDic objectForKey:@"id"] intValue];
        NSString *tempTitle = [tempDic objectForKey:@"title"];
        NSString *tSubTitle = [tempDic objectForKey:@"subTitle"];
        NSNumber *tempLon = [tempDic objectForKey:@"lon"];
        NSNumber *tempLat = [tempDic objectForKey:@"lat"];
        NSNumber *temColor = [tempDic objectForKey:@"color"];
        NSString *bgImagePath = [tempDic objectForKey:@"bgImgPath"];
        BOOL tempDraggable = [[tempDic objectForKey:@"draggable"] boolValue];
        if (_tag && tempLon && tempLat) {
            BMKPointAnnotation *pointAnnotation = [[BMKPointAnnotation alloc]init];
            CLLocationCoordinate2D coor;
            coor.latitude = [tempLat floatValue];
            coor.longitude = [tempLon floatValue];
            pointAnnotation.coordinate = coor;
            pointAnnotation.title = tempTitle;
            pointAnnotation.subtitle = tSubTitle;
            if (temColor) {
                _colorNumber = temColor;
            }else{
                _colorNumber = 0;
            }
            
            _draggable = tempDraggable;
            _bgImagePath = bgImagePath;
            [_mapView addAnnotation:pointAnnotation];
        }
    }
}
//根据ID移除某些大头针视图
-(void)removeAnnotations:(NSDictionary *)params{
    NSArray *args = [params objectForKey:@"IDArray"];
    for (NSNumber *ID in args) {
        for (BMKPointAnnotation *point in [_mapView annotations]) {
            BMKAnnotationView *annoView = [_mapView viewForAnnotation:point];
            if (annoView.tag == [ID intValue]) {
                [_mapView removeAnnotation:point];
            }
        }
    }
}
//移除所有的大头针视图
-(void)removeAllAnno{
    [_mapView removeAnnotations:_mapView.annotations];
}
//根据标注的ID获取标注的经纬度
-(void)getAnnotationCoords:(NSDictionary *)params{
    NSNumber *ID = [params objectForKey:@"ID"];
    if (ID) {
        for (BMKPointAnnotation *point in [_mapView annotations]) {
            BMKAnnotationView *pointView = [_mapView viewForAnnotation:point];
            if (pointView.tag == [ID intValue]) {
                NSNumber *lon = [NSNumber numberWithFloat:point.coordinate.longitude];
                NSNumber *lat = [NSNumber numberWithFloat:point.coordinate.latitude];
                NSDictionary *dic = @{@"lon":lon,@"lat":lat};
                [_defaultCenter postNotificationName:@"successCallBack" object:nil userInfo:dic];
            } else {
                [_defaultCenter postNotificationName:@"errorCallBack" object:nil userInfo:@{@"error":@"未找到与ID相对应的标注"}];
            }
        }
    } else {
        [_defaultCenter postNotificationName:@"errorCallBack" object:nil userInfo:@{@"error":@"传入的ID参数有误"}];
    }
}
//设置某个已添加标注的经纬度
-(void)updateAnnotationCoords:(NSDictionary *)params{
    NSNumber *ID = [params objectForKey:@"id"];
    NSNumber *lonNum = [params objectForKey:@"lon"];
    NSNumber *latNum = [params objectForKey:@"lat"];
    if (ID && lonNum && latNum) {
        for (BMKPointAnnotation *point in [_mapView annotations]) {
            BMKAnnotationView *pointView = [_mapView viewForAnnotation:point];
            if (pointView.tag == [ID intValue]) {
                point.coordinate = CLLocationCoordinate2DMake([latNum floatValue], [lonNum floatValue]);
            }
        }
    }
}
//根据ID判断某个标注是否存在
-(void)annotationExist:(NSDictionary *)params{
    _isExist = false;
    NSNumber *ID = [params objectForKey:@"ID"];
    if ([[_mapView annotations] count] > 0) {
        for (BMKPointAnnotation *point in [_mapView annotations]) {
            BMKAnnotationView *pointView = [_mapView viewForAnnotation:point];
            if (pointView.tag == [ID intValue]) {
                _isExist = true;
            }
        }
    }
    if (_isExist) {
        [_defaultCenter postNotificationName:@"successCallBack" object:nil userInfo:nil];
    }else{
        [_defaultCenter postNotificationName:@"errorCallBack" object:nil userInfo:nil];
    }
}
//在地图上添加折线
-(void)addLine:(NSDictionary *)params{
    NSArray *pointArray = [params objectForKey:@"points"];
    NSDictionary *styles = [params objectForKey:@"styles"];
    NSUInteger count = pointArray.count;
    CLLocationCoordinate2D coors[count];
    for (int i = 0; i < count; i ++) {
        NSNumber *tempLon = [pointArray[i] objectForKey:@"lon"];
        NSNumber *tempLat = [pointArray[i] objectForKey:@"lat"];
        coors[i].latitude = [tempLat floatValue];
        coors[i].longitude = [tempLon floatValue];
    }
    BMKPolyline *line = [BMKPolyline polylineWithCoordinates:coors count:count];
    _lineWidth = [[styles objectForKey:@"borderWidth"] floatValue];
    _borderColorStr = [styles objectForKey:@"borderColor"];
    [_mapView addOverlay:line];
    NSDictionary *overlayDic = @{@"id":[params objectForKey:@"id"],@"overlay":line};
    [_overlayArray addObject:overlayDic];
}
//在地图上添加多边形
-(void)addPolygon:(NSDictionary *)params{
    NSArray *pointArray = [params objectForKey:@"points"];
    NSDictionary *styles = [params objectForKey:@"styles"];
    NSUInteger count = [pointArray count];
    CLLocationCoordinate2D coors[count];
    for (int i = 0; i<count; i++) {
        NSNumber *tempLon = [pointArray[i] objectForKey:@"lon"];
        NSNumber *tempLat = [pointArray[i] objectForKey:@"lat"];
        coors[i].latitude = [tempLat floatValue];
        coors[i].longitude = [tempLon floatValue];
    }
    BMKPolygon *polygon = [BMKPolygon polygonWithCoordinates:coors count:count];
    _lineWidth = [[styles objectForKey:@"borderWidth"] floatValue];
    _borderColorStr = [styles objectForKey:@"borderColor"];
    _fillColorStr = [styles objectForKey:@"fillColor"];
    _alpha = [styles objectForKey:@"alpha"];
    [_mapView addOverlay:polygon];
    NSDictionary *overlayDic = @{@"id":[params objectForKey:@"id"],@"overlay":polygon};
    [_overlayArray addObject:overlayDic];
}
//在地图上添加弧形
-(void)addArc:(NSDictionary *)params{
    NSArray *pointArray = [params objectForKey:@"points"];
    NSDictionary *styles = [params objectForKey:@"styles"];
    NSUInteger count = [pointArray count];
    CLLocationCoordinate2D coors[count];
    for (int i = 0; i<count; i++) {
        NSNumber *tempLon = [pointArray[i] objectForKey:@"lon"];
        NSNumber *tempLat = [pointArray[i] objectForKey:@"lat"];
        coors[i].latitude = [tempLat floatValue];
        coors[i].longitude = [tempLon floatValue];
    }
    BMKArcline *arcline = [BMKArcline arclineWithCoordinates:coors];
    _lineWidth = [[styles objectForKey:@"borderWidth"] floatValue];
    _borderColorStr = [styles objectForKey:@"borderColor"];
    [_mapView addOverlay:arcline];
    NSDictionary *overlayDic = @{@"id":[params objectForKey:@"id"],@"overlay":arcline};
    [_overlayArray addObject:overlayDic];
}
//在地图上添加圆
-(void)addCircle:(NSDictionary *)params{
    NSNumber *radius = [params objectForKey:@"radius"];
    NSDictionary *centerDic = [params objectForKey:@"center"];
    NSDictionary *styles = [params objectForKey:@"styles"];
    CLLocationCoordinate2D center;
    center.latitude = [[centerDic objectForKey:@"lat"] floatValue];
    center.longitude = [[centerDic objectForKey:@"lon"] floatValue];
    BMKCircle *circle = [BMKCircle circleWithCenterCoordinate:center radius:[radius floatValue]];
    _lineWidth = [[styles objectForKey:@"borderWidth"] floatValue];
    _borderColorStr = [styles objectForKey:@"borderColor"];
    _fillColorStr = [styles objectForKey:@"fillColor"];
    _alpha = [styles objectForKey:@"alpha"];
    [_mapView addOverlay:circle];
    NSDictionary *overlayDic = @{@"id":[params objectForKey:@"id"],@"overlay":circle};
    [_overlayArray addObject:overlayDic];
}
//移除指定id的覆盖物(addLine/addPolygon/addArc/addCircle添加的覆盖物）
-(void)removeOverlay:(NSDictionary *)params{
    NSArray *idArray = [params objectForKey:@"id"];
    for (NSDictionary *dic in _overlayArray) {
        for (int i = 0; i<[idArray count]; i++) {
            if ([[dic objectForKey:@"id"] intValue] == [idArray[i] intValue]) {
                [_mapView removeOverlay:[dic objectForKey:@"overlay"]];
            }
        }
    }
}
#pragma mark--BMKMapViewDelegate
//当地图加载完毕后会调用此方法
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView{
    [_defaultCenter postNotificationName:@"mapDidLoad" object:nil userInfo:nil];
}
//生成标注视图
-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation{
    BMKPinAnnotationView *annotationView = [[BMKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
    annotationView.animatesDrop = YES;
    annotationView.pinColor = [_colorNumber intValue];
    [annotation setCoordinate:annotation.coordinate];
    annotationView.draggable = _draggable;
    annotationView.annotation = annotation;
    UIImage *image = [UIImage imageWithContentsOfFile:_bgImagePath];
    if (image) {
        annotationView.image = image;
    }
    annotationView.tag = _tag;
    return annotationView;
}
//点中地图空白处会调用此方法
-(void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate{
    NSDictionary *infoDic = @{@"action":@"click",@"lat":[NSNumber numberWithDouble:coordinate.latitude],@"lon":[NSNumber numberWithDouble:coordinate.longitude],@"zoom":[NSNumber numberWithFloat:_mapView.zoomLevel],@"overlook":[NSNumber numberWithInt:_mapView.overlooking],@"rotate":[NSNumber numberWithInt:_mapView.rotation]};
    [_defaultCenter postNotificationName:@"eventOccur" object:nil userInfo:infoDic];
}
//双击地图会调用此方法
-(void)mapview:(BMKMapView *)mapView onDoubleClick:(CLLocationCoordinate2D)coordinate{
    NSDictionary *infoDic = @{@"action":@"dbClick",@"lat":[NSNumber numberWithDouble:coordinate.latitude],@"lon":[NSNumber numberWithDouble:coordinate.longitude],@"zoom":[NSNumber numberWithFloat:_mapView.zoomLevel],@"overlook":[NSNumber numberWithInt:_mapView.overlooking],@"rotate":[NSNumber numberWithInt:_mapView.rotation]};
    [_defaultCenter postNotificationName:@"eventOccur" object:nil userInfo:infoDic];
}
//长按地图会调用此方法
-(void)mapview:(BMKMapView *)mapView onLongClick:(CLLocationCoordinate2D)coordinate{
    NSDictionary *infoDic = @{@"action":@"longPress",@"lat":[NSNumber numberWithDouble:coordinate.latitude],@"lon":[NSNumber numberWithDouble:coordinate.longitude],@"zoom":[NSNumber numberWithFloat:_mapView.zoomLevel],@"overlook":[NSNumber numberWithInt:_mapView.overlooking],@"rotate":[NSNumber numberWithInt:_mapView.rotation]};
    [_defaultCenter postNotificationName:@"eventOccur" object:nil userInfo:infoDic];
}
//地图的区域发生变化会调用此方法
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    CLLocationCoordinate2D center = _mapView.centerCoordinate;
    NSDictionary *infoDic = @{@"action":@"viewChange",@"lat":[NSNumber numberWithDouble:center.latitude],@"lon":[NSNumber numberWithDouble:center.longitude],@"zoom":[NSNumber numberWithFloat:_mapView.zoomLevel],@"overlook":[NSNumber numberWithInt:_mapView.overlooking],@"rotate":[NSNumber numberWithInt:_mapView.rotation]};
    [_defaultCenter postNotificationName:@"eventOccur" object:nil userInfo:infoDic];
}

//生成折线/多边形/弧形/圆
-(BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay{
    if ([overlay isKindOfClass:[BMKPolyline class]]){
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        //        polylineView.strokeColor = [[UIColor purpleColor] colorWithAlphaComponent:1];
        polylineView.lineWidth = _lineWidth;
        UIColor *borderColor = [self hexStringToColor:_borderColorStr];
        polylineView.strokeColor = borderColor;
        return polylineView;
    }
    if ([overlay isKindOfClass:[BMKPolygon class]]){
        BMKPolygonView* polygonView = [[BMKPolygonView alloc] initWithOverlay:overlay];
        polygonView.lineWidth = _lineWidth;
        UIColor *borderColor = [self hexStringToColor:_borderColorStr];
        polygonView.strokeColor = borderColor;
        UIColor *fillColor = [self hexStringToColor:_fillColorStr alpha:_alpha];
        polygonView.fillColor = fillColor;
        return polygonView;
    }
    if ([overlay isKindOfClass:[BMKArcline class]]) {
        BMKArclineView *arclineView = [[BMKArclineView alloc]initWithOverlay:overlay];
        arclineView.lineWidth = _lineWidth;
        UIColor *borderColor = [self hexStringToColor:_borderColorStr];
        arclineView.strokeColor = borderColor;
        return arclineView;
    }
    if ([overlay isKindOfClass:[BMKCircle class]]) {
        BMKCircleView *circleView = [[BMKCircleView alloc]initWithOverlay:overlay];
        circleView.lineWidth = _lineWidth;
        UIColor *borderColor = [self hexStringToColor:_borderColorStr];
        circleView.strokeColor = borderColor;
        UIColor *fillColor = [self hexStringToColor:_fillColorStr alpha:_alpha];
        circleView.fillColor = fillColor;
        return circleView;
    }
    return nil;
}

#pragma mark - BMKLocationManagerDelegate
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didFailWithError:(NSError * _Nullable)error {
  NSLog(@"定位失败");
  NSDictionary *dic = @{@"error":[NSNumber numberWithInteger:error.code]};
  _locationDic = dic;
}

- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateHeading:(CLHeading *)heading {
  if (!heading) {
    return;
  }
  NSLog(@"用户方向更新");
  
  self.userLocation.heading = heading;
  [_mapView updateLocationData:self.userLocation];
}

- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateLocation:(BMKLocation *)location orError:(NSError *)error {
  if (error) {
    NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
  }
  
  if (!location) {
    return;
  }
  
  self.userLocation.location = location.location;
  [_mapView updateLocationData:self.userLocation];
  //此时已经定位成功,返回经纬度，时间戳
  NSNumber *lat = [NSNumber numberWithDouble:self.userLocation.location.coordinate.latitude];
  NSNumber *lon = [NSNumber numberWithDouble:self.userLocation.location.coordinate.longitude];
  NSTimeInterval interval = [[NSDate date] timeIntervalSince1970]*1000;
  NSNumber *timeInterval = [NSNumber numberWithDouble:interval];
  NSDictionary *dic = @{@"lat":lat,@"lon":lon,@"timestamp":timeInterval};
  _locationDic = dic;
}

//将十六进制转换为UIColor
- (UIColor *) hexStringToColor: (NSString *) hexColor{
    NSString *cString = [[hexColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    
    if ([cString length] < 6)
        return DEFAULT_VOID_COLOR;
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return DEFAULT_VOID_COLOR;
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}
- (UIColor *) hexStringToColor: (NSString *) stringToConvert alpha:(NSNumber *)alpha{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 charactersif ([cString length] < 6) return [UIColor blackColor];
    // strip 0X if it appearsif ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return [UIColor blackColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:[alpha floatValue]];
}

-(void)viewWillDisappear:(BOOL)animated{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil;
    _locationManager.delegate = nil;
    if (_mapView) {
        _mapView = nil;
    }
}

+(baiduMapViewController *)sharedVC{
    static baiduMapViewController *sharedVC = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedVC = [[self alloc]init];
    });
    return sharedVC;
}

- (BMKUserLocation *)userLocation {
  if (!_userLocation) {
    _userLocation = [[BMKUserLocation alloc] init];
  }
  return _userLocation;
}
@end
