//
//  CDVBaiduMap.m
//  baiduMap
//  Created by LiangQiangkun on 16/5/20.
//
//
#import <Cordova/CDV.h>
#import "CDVBaiduMap.h"
#import "baiduMapViewController.h"
@implementation CDVBaiduMap
{
    BMKMapManager *_mapManager;
    baiduMapViewController *_baiduMapVC;
    BMKMapView *_mapView;
    BMKOfflineMap *offLineMap;
    NSString *_callBackId;
    NSDictionary *_args;//发送到，mapVC的参数
    NSNotificationCenter *_defaultCenter;
    NSString *_eventCBId;
    BMKOfflineMap *_offLineMap;
    NSArray* _arrayHotCityData;//热门城市
    NSArray* _arrayOfflineCityData;//全国支持离线地图的城市
    NSMutableArray * _arraylocalDownLoadMapInfo;//本地下载的离线地图
    NSString *_offMapEventCB;
    BOOL _isOpen;
    int _cityID;
    NSString *_onLoadCBID;
    BOOL _isFullScreen;
    UIView *_closeView;
}
//插件初始化方法
- (void)pluginInitialize{
    _isFullScreen = NO;
    _mapManager = [[BMKMapManager alloc]init];
    CDVViewController *viewController = (CDVViewController *)self.viewController;
    //获取百度AK
    self.baiduKey = [viewController.settings objectForKey:@"baidumapkey"];
    self.mcode = [viewController.settings objectForKey:@"mcode"];
    _defaultCenter = [NSNotificationCenter defaultCenter];
  
    [[BMKLocationAuth sharedInstance] checkPermisionWithKey:self.baiduKey authDelegate:self];
  
    //添加普通监听
    [_defaultCenter addObserver:self selector:@selector(errorCallBack:) name:@"errorCallBack" object:nil];
    [_defaultCenter addObserver:self selector:@selector(successCallBack:) name:@"successCallBack" object:nil];
    [_defaultCenter addObserver:self selector:@selector(mapDidLoad:) name:@"mapDidLoad" object:nil];
    [_defaultCenter addObserver:self selector:@selector(mapViewOpenFullScreen) name:@"mapOpenWithFullScreen" object:nil];
    //添加地图事件的回调监听
    _eventCBId = @"navigator.baiduMap.base.eventOccur";
    [_defaultCenter addObserver:self selector:@selector(eventOccur:) name:@"eventOccur" object:nil];
    _isOpen = NO;
    //首次打开百度地图
    BOOL ret = [_mapManager start:self.baiduKey generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    //初始化离线地图服务
    _offLineMap = [[BMKOfflineMap alloc]init];
    _offLineMap.delegate = self;
}
//全屏显示地图时添加关闭地图的按钮
-(void)mapViewOpenFullScreen{
    _isFullScreen = YES;
}
-(void)closeBtnClicked{
    [_closeView removeFromSuperview];
    _closeView = nil;
    _isOpen = false;
    [_mapView removeFromSuperview];
    [_baiduMapVC removeFromParentViewController];
    _baiduMapVC.view = nil;
    _mapView = nil;
    _baiduMapVC = nil;
}
-(void)addCloseView{
    CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
    _closeView = [[UIView alloc]initWithFrame:CGRectMake(0, rectStatus.size.height, 40, 25)];
    _closeView.backgroundColor = [UIColor clearColor];
    [self.viewController.view addSubview:_closeView];
    //创建关闭按钮
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(10, 5, 20, 20);
    [closeBtn setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [_closeView addSubview:closeBtn];
}
//失败的回调
-(void)errorCallBack:(NSNotification *)notification{
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:notification.userInfo];
    [self.commandDelegate sendPluginResult:result callbackId:_callBackId];
}
//成功的回调
-(void)successCallBack:(NSNotification *)notification{
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:notification.userInfo];
    [self.commandDelegate sendPluginResult:result callbackId:_callBackId];

}
-(void)mapDidLoad:(NSNotification *)notification{
    if (_isFullScreen) {
        _isFullScreen = NO;
        [self addCloseView];
    }

    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:_onLoadCBID];
}
//地图事件监听的回调
-(void)eventOccur:(NSNotification *)notification{
    NSDictionary *info = notification.userInfo;
    NSMutableString *jsonStr = [NSMutableString stringWithString:@"{"];
    [self parseDictionary:info intoJSON:jsonStr];
    [jsonStr appendString:@"}"];
    NSString * jsCallBack = [NSString stringWithFormat:@"%@(%@);", _eventCBId, jsonStr];
    //[self.webView stringByEvaluatingJavaScriptFromString:jsCallBack];
    [self.webViewEngine evaluateJavaScript:jsCallBack completionHandler:nil];
}
-(void)parseDictionary:(NSDictionary *)inDictionary intoJSON:(NSMutableString *)jsonString
{
    NSArray         *keys = [inDictionary allKeys];
    NSString        *key;
    for (key in keys)
    {
        id thisObject = [inDictionary objectForKey:key];

        if ([thisObject isKindOfClass:[NSDictionary class]])
            [self parseDictionary:thisObject intoJSON:jsonString];
        else if ([thisObject isKindOfClass:[NSString class]])
            [jsonString appendFormat:@"\"%@\":\"%@\",",
             key,
             [[[[inDictionary objectForKey:key]
                stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"]
               stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]
              stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"]];
        else {
            [jsonString appendFormat:@"\"%@\":\"%@\",", key, [inDictionary objectForKey:key]];
        }
    }
}
//打开百度地图
- (void)open:(CDVInvokedUrlCommand *)command{
    _onLoadCBID = command.callbackId;
    //首先判断当前地图是否打开
    if (_isOpen) {
        //此时已经打开过百度地图，则此时调用open接口只是调整视图的position及center等属性
        NSDictionary *args = [command argumentAtIndex:0];
        //设置地图的frame
        CGRect rect;
        NSDictionary *rectDic = [args objectForKey:@"position"];
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
        NSDictionary *centerDic = [args objectForKey:@"center"];
        if (centerDic) {
            CLLocationCoordinate2D center;
            center.latitude = [[centerDic objectForKey:@"lat"] floatValue];
            center.longitude = [[centerDic objectForKey:@"lon"] floatValue];
            _mapView.centerCoordinate = center;
        }
        //设置缩放等级
        NSNumber *zoomLevel = [args objectForKey:@"zoomLevel"];
        if(!zoomLevel){
            _mapView.zoomLevel = 10;
        }else{
            _mapView.zoomLevel = [zoomLevel floatValue];
        }
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }else{
        _isOpen = YES;
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        [def setObject:self.baiduKey forKey:@"baiduMapKey"];
        //获取百度地图打开时的参数
        NSDictionary *args = [command argumentAtIndex:0];
        _baiduMapVC = [baiduMapViewController sharedVC];
        _baiduMapVC.mapSettings = args;
        //添加百度地图视图
        [self.viewController addChildViewController:_baiduMapVC];
        [self.viewController.view addSubview:_baiduMapVC.view];
        _mapView = (BMKMapView *)_baiduMapVC.view;
        //        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        //        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

//关闭百度地图
- (void)close:(CDVInvokedUrlCommand *)command{
    _isOpen = false;
    [_mapView removeFromSuperview];
    [_baiduMapVC removeFromParentViewController];
    _baiduMapVC.view = nil;
    _mapView = nil;
    _baiduMapVC = nil;
}
//重新设置百度地图的显示区域
- (void)setPosition:(CDVInvokedUrlCommand *)command{
    NSDictionary *params = [command argumentAtIndex:0];
    _args = @{@"action":@"setPosition:",@"params":params};
    [_defaultCenter postNotificationName:@"sendToMapVC" object:nil userInfo:_args];
}
//开始定位
- (void)getCurrentLocation:(CDVInvokedUrlCommand *)command{
    _callBackId = command.callbackId;
    _args = @{@"action":@"getCurrentLocation:"};
    [_defaultCenter postNotificationName:@"sendToMapVC" object:nil userInfo:_args];
}
//根据地址名称获取经纬度
- (void)getLocationFromName:(CDVInvokedUrlCommand *)command{
    //http://api.map.baidu.com/geocoder/v2/?address=北京市海淀区上地十街10号&output=json&ak=E4805d16520de693a3fe707cdc962045&callback=showLocation
    NSDictionary *params = [command argumentAtIndex:0];
    NSString *city = [params objectForKey:@"city"];
    NSString *address = [params objectForKey:@"address"];
    NSString *mcode = self.mcode;
    NSString *URLStr = [NSString stringWithFormat:@"http://api.map.baidu.com/geocoder/v2/?address=%@&city=%@&output=json&ak=%@&mcode=%@",address,city,self.baiduKey,mcode];
    URLStr = [URLStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [[NSURL alloc]initWithString:URLStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (error) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"发送请求失败，请检查传入参数"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }else{
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"------------dic:%@",dic);
        NSDictionary *resultDic = @{@"lat":[[[dic objectForKey:@"result"] objectForKey:@"location"] objectForKey:@"lat"],@"lon":[[[dic objectForKey:@"result"] objectForKey:@"location"] objectForKey:@"lng"]};
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}
//根据经纬度获取地址名称
- (void)getNameFromLocation:(CDVInvokedUrlCommand *)command{
    //http://api.map.baidu.com/geocoder/v2/?ak=E4805d16520de693a3fe707cdc962045&callback=renderReverse&location=39.983424,116.322987&output=json&pois=1
    NSDictionary *params = [command argumentAtIndex:0];
    NSString *mcode = self.mcode;
    NSString *lon = [params objectForKey:@"lon"];
    NSString *lat = [params objectForKey:@"lat"];
    NSString *URLStr = [NSString stringWithFormat:@"http://api.map.baidu.com/geocoder/v2/?ak=%@&location=%@,%@&output=json&mcode=%@",self.baiduKey,lat,lon,mcode];
    URLStr = [URLStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [[NSURL alloc]initWithString:URLStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (error) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"发送请求失败，请检查传入参数"];
        [self.commandDelegate  sendPluginResult:result callbackId:command.callbackId];
    }else{
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"------------dic:%@",dic);
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}
//显示用户的位置
- (void)showCurrentLocation:(CDVInvokedUrlCommand *)command{
    NSDictionary *params = [command argumentAtIndex:0];
    _args = @{@"action":@"showCurrentLocation:",@"params":params};
    [_defaultCenter postNotificationName:@"sendToMapVC" object:nil userInfo:_args];
}
//设置百度地图的中心点
- (void)setCenter:(CDVInvokedUrlCommand *)command{
    NSDictionary *params = [command argumentAtIndex:0];
    _args = @{@"action":@"setCenter:",@"params":params};
    [_defaultCenter postNotificationName:@"sendToMapVC" object:nil userInfo:_args];

}
//获取百度地图的中心点
- (void)getCenter:(CDVInvokedUrlCommand *)command{
    _callBackId = command.callbackId;
    _args = @{@"action":@"getCenter"};
    [_defaultCenter postNotificationName:@"sendToMapVC" object:nil userInfo:_args];
}
//设置地图的缩放等级
- (void)setZoomLevel:(CDVInvokedUrlCommand *)command{
    NSNumber *level = [command argumentAtIndex:0];
    NSDictionary *dic = @{@"zoomLevel":level};
    _args = @{@"action":@"setZoomLevel:",@"params":dic};
    [_defaultCenter postNotificationName:@"sendToMapVC" object:nil userInfo:_args];
}
//设置地图相关属性
- (void)setMapAttr:(CDVInvokedUrlCommand *)command{
    _callBackId = command.callbackId;
    NSDictionary *params = [command argumentAtIndex:0];
    _args = @{@"action":@"setMapAttr:",@"params":params};
    [_defaultCenter postNotificationName:@"sendToMapVC" object:nil userInfo:_args];
}
//设置百度地图的旋转角度
- (void)setRotation:(CDVInvokedUrlCommand *)command{
    NSNumber *rotation = [command argumentAtIndex:0];
    NSDictionary *dic = @{@"rotation":rotation};
    _args = @{@"action":@"setRotation:",@"params":dic};
    [_defaultCenter postNotificationName:@"sendToMapVC" object:nil userInfo:_args];

}
//设置百度地图的俯视角度
- (void)setOverlook:(CDVInvokedUrlCommand *)command{
    NSNumber *overlook = [command argumentAtIndex:0];
    NSDictionary *dic = @{@"overlook":overlook};
    _args = @{@"action":@"setOverlook:",@"params":dic};
    [_defaultCenter postNotificationName:@"sendToMapVC" object:nil userInfo:_args];
}
//设置百度地图的比例尺
- (void)setScaleBar:(CDVInvokedUrlCommand *)command{
    NSDictionary *params = [command argumentAtIndex:0];
    _args = @{@"action":@"setScaleBar:",@"params":params};
    [_defaultCenter postNotificationName:@"sendToMapVC" object:nil userInfo:_args];

}
//设置指南针的位置
- (void)setCompass:(CDVInvokedUrlCommand *)command{
    NSDictionary *params = [command argumentAtIndex:0];
    _args = @{@"action":@"setCompass:",@"params":params};
    [_defaultCenter postNotificationName:@"sendToMapVC" object:nil userInfo:_args];

}
//设置交通状况
- (void)setTraffic:(CDVInvokedUrlCommand *)command{
    NSNumber *number = [command argumentAtIndex:0];
    NSDictionary *params = @{@"isShow":number};
    _args = @{@"action":@"setTraffic:",@"params":params};
    [_defaultCenter postNotificationName:@"sendToMapVC" object:nil userInfo:_args];
}
//设置热力图
- (void)setHeatMap:(CDVInvokedUrlCommand *)command{
    NSNumber *number = [command argumentAtIndex:0];
    NSDictionary *params = @{@"isShow":number};
    _args = @{@"action":@"setHeatMap:",@"params":params};
    [_defaultCenter postNotificationName:@"sendToMapVC" object:nil userInfo:_args];
}
//设置3D楼块
- (void)setBuilding:(CDVInvokedUrlCommand *)command{
    NSNumber *number = [command argumentAtIndex:0];
    NSDictionary *params = @{@"isShow":number};
    _args = @{@"action":@"setBuilding:",@"params":params};
    [_defaultCenter postNotificationName:@"sendToMapVC" object:nil userInfo:_args];
}
//设置地图的显示范围
- (void)setRegion:(CDVInvokedUrlCommand *)command{
    NSDictionary *params = [command argumentAtIndex:0];
    _args = @{@"action":@"setRegion:",@"params":params};
    [_defaultCenter postNotificationName:@"sendToMapVC" object:nil userInfo:_args];
}
//获取地图显示范围(矩形区域)
- (void)getRegion:(CDVInvokedUrlCommand *)command{
    _callBackId = command.callbackId;
    _args = @{@"action":@"getRegion"};
    [_defaultCenter postNotificationName:@"sendToMapVC" object:nil userInfo:_args];
}
//缩小地图，放大视角，放大一级比例尺，此接口自带动画效果
- (void)zoomIn:(CDVInvokedUrlCommand *)command{
    _args = @{@"action":@"zoomIn"};
    [_defaultCenter postNotificationName:@"sendToMapVC" object:nil userInfo:_args];
}
//放大地图，缩小视角，缩小一级比例尺，此接口自带动画效果
- (void)zoomOut:(CDVInvokedUrlCommand *)command{
    _args = @{@"action":@"zoomOut"};
    [_defaultCenter postNotificationName:@"sendToMapVC" object:nil userInfo:_args];
}
//在地图上添加大头针
- (void)addAnnotations:(CDVInvokedUrlCommand *)command{
    //标注的数组
    NSArray *annotationsArray = [command argumentAtIndex:0];
    NSDictionary *params = @{@"annotationsArray":annotationsArray};
    _args = @{@"action":@"addAnnotations:",@"params":params};
    [_defaultCenter postNotificationName:@"sendToMapVC" object:nil userInfo:_args];
}
//移除指定大头针
- (void)removeAnnotations:(CDVInvokedUrlCommand *)command{
    NSArray *IDArray = [command argumentAtIndex:0];
    NSDictionary *params = @{@"IDArray":IDArray};
    _args = @{@"action":@"removeAnnotations:",@"params":params};
    [_defaultCenter postNotificationName:@"sendToMapVC" object:nil userInfo:_args];
}
//移除所有的大头针视图
- (void)removeAllAnno:(CDVInvokedUrlCommand *)command{
    _args = @{@"action":@"removeAllAnno"};
    [_defaultCenter postNotificationName:@"sendToMapVC" object:nil userInfo:_args];
}
//获取指定标注的经纬度
- (void)getAnnotationCoords:(CDVInvokedUrlCommand *)command{
    _callBackId = command.callbackId;
    NSNumber *ID = [command argumentAtIndex:0];
    NSDictionary *params = @{@"ID":ID};
    _args = @{@"action":@"getAnnotationCoords:",@"params":params};
    [_defaultCenter postNotificationName:@"sendToMapVC" object:nil userInfo:_args];
}
//设置某个已添加标注的经纬度
- (void)updateAnnotationCoords:(CDVInvokedUrlCommand *)command{
    NSDictionary *params = [command argumentAtIndex:0];
    _args = @{@"action":@"updateAnnotationCoords:",@"params":params};
    [_defaultCenter postNotificationName:@"sendToMapVC" object:nil userInfo:_args];
}
//判断某个标注是否存在
- (void)annotationExist:(CDVInvokedUrlCommand *)command{
    _callBackId = command.callbackId;
    NSNumber *ID = [command argumentAtIndex:0];
    NSDictionary *params = @{@"ID":ID};
    _args = @{@"action":@"annotationExist:",@"params":params};
    [_defaultCenter postNotificationName:@"sendToMapVC" object:nil userInfo:_args];
}
//设置点击标注时候弹出的气泡信息
- (void)setBubble:(CDVInvokedUrlCommand *)command{
    //    NSDictionary *args = [command argumentAtIndex:0];
    //    NSString *bgImgPath = [args objectForKey:@"bgImgPath"];
    //    UIImage *bgImage = [UIImage imageWithContentsOfFile:bgImgPath];
    //    NSDictionary *contentDic = [args objectForKey:@"content"];
    //    NSString *title = [contentDic objectForKey:@"title"];
    //    NSString *subTitle = [contentDic objectForKey:@"subTitle"];
    //    NSString *illusStr = [contentDic objectForKey:@"illus"];
    //    NSDictionary *stylesDic = [args objectForKey:@"styles"];
    //    NSNumber *titleSize = [stylesDic objectForKey:@"titleSize"];
    //    NSNumber *subTitleSize = [stylesDic objectForKey:@"subTitleSize"];
    //    NSNumber *ID = [args objectForKey:@"id"];
    //    for (BMKPointAnnotation *point in [_mapView annotations]) {
    //        if (point.ID == ID) {
    //            point.annotationView.canShowCallout = YES;
    //            point.title = title;
    //            point.subtitle = subTitle;
    //            if (bgImage) {
    //                point.annotationView.image = bgImage;
    //            }
    //            UIImage *illImg = [[UIImage alloc]init];
    //            if ([illusStr hasPrefix:@"http://"] || [illusStr hasPrefix:@"https://"]) {
    //                illImg = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:illusStr]]];
    //
    //            }else{
    //                illImg = [UIImage imageWithContentsOfFile:illusStr];
    //            }
    //            //自定义弹出视图
    //            UIView *popView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 120, 60)];
    //            //设置弹出气泡的图片
    //            UIImageView *imageView = [[UIImageView alloc]initWithImage:illImg];
    //            imageView.frame = CGRectMake(0, 0, 60, 60);
    //            [popView addSubview:imageView];
    //            //自定义显示的内容
    //            //主标题
    //            UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(63, 3,57, 20)];
    //            lable.text = title;
    //            lable.font = [UIFont systemFontOfSize:[titleSize floatValue]];
    //            lable.textAlignment = NSTextAlignmentCenter;
    //            [popView addSubview:lable];
    //            //副标题
    //            UILabel *subLable = [[UILabel alloc]initWithFrame:CGRectMake(63, 33, 57, 20)];
    //            subLable.text = subTitle;
    //            subLable.font = [UIFont systemFontOfSize:[subTitleSize floatValue]];
    //            subLable.textAlignment = NSTextAlignmentCenter;
    //            [popView addSubview:subLable];
    //            BMKActionPaopaoView *paoPaoView = [[BMKActionPaopaoView alloc]initWithCustomView:popView];
    //            paoPaoView.frame = CGRectMake(0, 0, 120, 60);
    //        }
    //    }

}
//弹出指定标注的气泡
- (void)popupBubble:(CDVInvokedUrlCommand *)command{
    // NSNumber *IDNum = [command argumentAtIndex:0];
    // for (BMKPointAnnotation *point in [_mapView annotations]) {
    //     if (point.ID == IDNum) {
    //         //设置标注视图被选中并强制刷新地图
    //         [point.annotationView setSelected:YES animated:YES];
    //         [_mapView mapForceRefresh];
    //     }
    // }
}
//添加折线
- (void)addLine:(CDVInvokedUrlCommand *)command{
    NSDictionary *params = [command argumentAtIndex:0];
    _args = @{@"action":@"addLine:",@"params":params};
    [_defaultCenter postNotificationName:@"sendToMapVC" object:nil userInfo:_args];
}
//添加多边形
- (void)addPolygon:(CDVInvokedUrlCommand *)command{
    NSDictionary *params = [command argumentAtIndex:0];
    _args = @{@"action":@"addPolygon:",@"params":params};
    [_defaultCenter postNotificationName:@"sendToMapVC" object:nil userInfo:_args];
}
//添加弧形
- (void)addArc:(CDVInvokedUrlCommand *)command{
    NSDictionary *params = [command argumentAtIndex:0];
    _args = @{@"action":@"addArc:",@"params":params};
    [_defaultCenter postNotificationName:@"sendToMapVC" object:nil userInfo:_args];
}
//添加圆
- (void)addCircle:(CDVInvokedUrlCommand *)command{
    NSDictionary *params = [command argumentAtIndex:0];
    _args = @{@"action":@"addCircle:",@"params":params};
    [_defaultCenter postNotificationName:@"sendToMapVC" object:nil userInfo:_args];
}
//移除指定id的覆盖物(addLine/addPolygon/addArc/addCircle添加的覆盖物）
- (void)removeOverlay:(CDVInvokedUrlCommand *)command{
    NSArray *idArray = [command argumentAtIndex:0];
    NSDictionary *params = @{@"id":idArray};
    _args = @{@"action":@"removeOverlay:",@"params":params};
    [_defaultCenter postNotificationName:@"sendToMapVC" object:nil userInfo:_args];
}
////离线地图初始化
//- (void)offLineMapInit:(CDVInvokedUrlCommand *)command{
//    //初始化离线地图服务
//    _offLineMap = [[BMKOfflineMap alloc]init];
//    _offLineMap.delegate = self;
//}
//添加离线地图事件的监听
- (void)addOfflineListener:(CDVInvokedUrlCommand *)command{
    _offMapEventCB = command.callbackId;
    [_defaultCenter addObserver:self selector:@selector(offLineMapEventOccur:) name:@"offLineMapEventOccur" object:nil];
}
//移除离线地图事件的监听
- (void)removeOfflineListener:(CDVInvokedUrlCommand *)command{
    [_defaultCenter removeObserver:self name:@"offLineMapEventOccur" object:nil];
}

//离线地图事件触发的回调
-(void)offLineMapEventOccur:(NSNotification *)notification{
    NSDictionary *dic = notification.userInfo;
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:_offMapEventCB];
}

//获取热门城市列表
- (void)getHotCityList:(CDVInvokedUrlCommand *)command{
    _arrayHotCityData = [_offLineMap getHotCityList];
    NSMutableArray *cityArray = [[NSMutableArray alloc]init];
    for (BMKOLSearchRecord *record in _arrayHotCityData) {
        NSString *cityName = record.cityName;
        int size = record.size;
        int cityID = record.cityID;
        int cityType = record.cityType;
        NSDictionary *cityInfo = @{@"cityName":cityName,@"size":[NSNumber numberWithInt:size],@"cityID":[NSNumber numberWithInt:cityID],@"cityType":[NSNumber numberWithInt:cityType],@"childCities":@[]};
        [cityArray addObject:cityInfo];
    }
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:cityArray];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}
//获取支持离线下载的城市列表
- (void)getOfflineCityList:(CDVInvokedUrlCommand *)command{
    _arrayOfflineCityData = [_offLineMap getOfflineCityList];
    NSMutableArray *cityArray = [[NSMutableArray alloc]init];
    NSMutableArray *childCityArray = [[NSMutableArray alloc]init];
    for (BMKOLSearchRecord *record in _arrayOfflineCityData) {
        NSString *cityName = record.cityName;
        int size = record.size;
        int cityID = record.cityID;
        int cityType = record.cityType;
        if (cityType == 1) {
            [childCityArray removeAllObjects];
            for (BMKOLSearchRecord *childRecord in record.childCities) {
                NSString *cName = childRecord.cityName;
                int cID = childRecord.cityID;
                int cSize = childRecord.size;
                int cType = childRecord.cityType;
                NSArray *cArray = @[];
                NSDictionary *childCity = @{@"cityName":cName,@"size":[NSNumber numberWithInt:cSize],@"cityID":[NSNumber numberWithInt:cID],@"cityType":[NSNumber numberWithInt:cType],@"childCities":cArray};
                [childCityArray addObject:childCity];
            }
        }
        NSDictionary *cityInfo = @{@"cityName":cityName,@"size":[NSNumber numberWithInt:size],@"cityID":[NSNumber numberWithInt:cityID],@"cityType":[NSNumber numberWithInt:cityType],@"childCities":[childCityArray mutableCopy]};
        [cityArray addObject:cityInfo];
    }
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:cityArray];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}
//根据城市名搜索该城市离线地图记录
- (void)searchCityByName:(CDVInvokedUrlCommand *)command{
    NSString *cityName = [command argumentAtIndex:0];
    NSArray *cityInfoArray = [_offLineMap searchCity:cityName];
    if (cityInfoArray) {
        BMKOLSearchRecord *record = cityInfoArray[0];
        NSMutableArray *childCityArray = [[NSMutableArray alloc]init];
        NSString *cityName = record.cityName;
        int size = record.size;
        int cityID = record.cityID;
        int cityType = record.cityType;
        if (cityType == 1) {
            for (BMKOLSearchRecord *childRecord in record.childCities) {
                NSString *cName = childRecord.cityName;
                int cID = childRecord.cityID;
                int cSize = childRecord.size;
                int cType = childRecord.cityType;
                NSArray *cArray = @[];
                NSDictionary *childCity = @{@"cityName":cName,@"size":[NSNumber numberWithInt:cSize],@"cityID":[NSNumber numberWithInt:cID],@"cityType":[NSNumber numberWithInt:cType],@"childCities":cArray};
                [childCityArray addObject:childCity];
            }

        }
        NSDictionary *cityInfo = @{@"cityName":cityName,@"size":[NSNumber numberWithInt:size],@"cityID":[NSNumber numberWithInt:cityID],@"cityType":[NSNumber numberWithInt:cityType],@"childCities":[childCityArray mutableCopy]};
        NSArray *array = @[cityInfo];
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:array];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }else{
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:@{@"error":@"未搜索到结果"}];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}
//根据城市id获取更新信息
- (void)getUpdateInfo:(CDVInvokedUrlCommand *)command{
    NSNumber *cityID = [command argumentAtIndex:0];
    //此时下载或者更新
    NSDictionary *updateInfo = [[NSDictionary alloc]init];
    BMKOLUpdateElement *info = [_offLineMap getUpdateInfo:[cityID intValue]];
    if (info) {
        NSString *cityName = info.cityName;
        int cityId = info.cityID;
        int size = info.size;
        int serversize = info.serversize;
        BOOL update = info.update;
        int ratio = info.ratio;
        int status = info.status;
        NSNumber *lat = [NSNumber numberWithDouble:info.pt.latitude];
        NSNumber *lon = [NSNumber numberWithDouble:info.pt.longitude];
        NSDictionary *pt = @{@"lat":lat,@"lon":lon};
        updateInfo = @{@"cityName":cityName,@"cityID":[NSNumber numberWithInt:cityId],@"size":[NSNumber numberWithInt:size],@"serversize":[NSNumber numberWithInt:serversize],@"update":[NSNumber numberWithBool:update],@"ratio":[NSNumber numberWithInt:ratio],@"status":[NSNumber numberWithInt:status],@"pt":pt};
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"error":@"获取更新信息失败"}];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    } else {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:updateInfo];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }

}

//获取各城市离线地图更新信息，无需调用 open 接口即可搜索
- (void)getAllUpdateInfo:(CDVInvokedUrlCommand *)command{
    NSArray *cityInfo = [_offLineMap getAllUpdateInfo];
    if (cityInfo) {
        NSMutableArray *cityInfoArray = [[NSMutableArray alloc]init];
        for (BMKOLUpdateElement *element in cityInfo) {
            NSString *cityName = element.cityName;
            int cityID = element.cityID;
            int size = element.size;
            int serversize = element.serversize;
            BOOL update = element.update;
            int ratio = element.ratio;
            int status = element.status;
            CLLocationCoordinate2D pt = element.pt;
            NSDictionary *ptDic = @{@"latitude":[NSNumber numberWithDouble:pt.latitude],@"longitude":[NSNumber numberWithDouble:pt.longitude]};
            NSDictionary *elementDic = @{@"cityName":cityName,@"cityID":[NSNumber numberWithInt:cityID],@"size":[NSNumber numberWithInt:size],@"serversize":[NSNumber numberWithInt:serversize],@"update":[NSNumber numberWithBool:update],@"ratio":[NSNumber numberWithInt:ratio],@"status":[NSNumber numberWithInt:status],@"pt":ptDic};
            [cityInfoArray addObject:elementDic];
        }
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:cityInfoArray];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    } else {
        //未获取到数据
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

    }

}
//启动下载指定城市 id 的离线地图
- (void)downLoad:(CDVInvokedUrlCommand *)command{
    NSNumber *ID = [command argumentAtIndex:0];
    BOOL status = [_offLineMap start:[ID intValue]];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"status":[NSNumber numberWithBool:status]}];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}
//启动更新指定城市 id 的离线地图
- (void)update:(CDVInvokedUrlCommand *)command{
    NSNumber *ID = [command argumentAtIndex:0];
    _cityID = [ID intValue];
    BOOL status = [_offLineMap update:[ID intValue]];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"status":[NSNumber numberWithBool:status]}];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}
//暂停更新指定城市 id 的离线地图
- (void)pause:(CDVInvokedUrlCommand *)command{
    NSNumber *ID = [command argumentAtIndex:0];
    _cityID = [ID intValue];
    [_offLineMap pause:[ID intValue]];
}
//删除下载指定城市 id 的离线地图
- (void)remove:(CDVInvokedUrlCommand *)command{
    NSNumber *ID = [command argumentAtIndex:0];
    BOOL status = [_offLineMap remove:[ID intValue]];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"status":[NSNumber numberWithBool:status]}];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}
//获取地图上两点间的距离
- (void)getDistance:(CDVInvokedUrlCommand *)command{
    NSDictionary *args = [command argumentAtIndex:0];
    NSDictionary *start = [args objectForKey:@"start"];
    NSDictionary *end = [args objectForKey:@"end"];
    NSNumber *startLon = [start objectForKey:@"lon"];
    NSNumber *startLat = [start objectForKey:@"lat"];
    NSNumber *endLon = [end objectForKey:@"lon"];
    NSNumber *endLat = [end objectForKey:@"lat"];
    if (startLon && startLat && endLon && endLat) {
        BMKMapPoint point1 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake([startLat doubleValue], [startLon doubleValue]));
        BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake([endLat doubleValue], [endLon doubleValue]));
        CLLocationDistance distance = BMKMetersBetweenMapPoints(point1, point2);
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:distance];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

    } else {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"参数传入有误"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
};
//将其它类型的地理坐标转换为百度坐标。
- (void)transCoords:(CDVInvokedUrlCommand *)command{
    NSDictionary *args = [command argumentAtIndex:0];
    NSString *type = [args objectForKey:@"type"];
    NSNumber *lonNum = [args objectForKey:@"lon"];
    NSNumber *latNum = [args objectForKey:@"lat"];

    if (type && lonNum && latNum) {
        CLLocationCoordinate2D coor = CLLocationCoordinate2DMake([latNum floatValue], [lonNum floatValue]);
        NSDictionary *coorDic = [[NSDictionary alloc]init];
        if ([type isEqualToString:@"gps"]) {
            //转换GPS设备采集的原始GPS坐标至百度坐标
            coorDic = BMKConvertBaiduCoorFrom(coor, BMK_COORDTYPE_GPS);
        }else if ([type isEqualToString:@"common"]){
            //转换 google地图、soso地图、aliyun地图、mapabc地图和amap地图所用坐标至百度坐标
            coorDic = BMKConvertBaiduCoorFrom(coor, BMK_COORDTYPE_COMMON);
        }
        //解密加密后的坐标字典
        CLLocationCoordinate2D baiduCoor = BMKCoorDictionaryDecode(coorDic);//转换后的百度坐标
        NSNumber *lon = [NSNumber numberWithFloat:baiduCoor.longitude];
        NSNumber *lat = [NSNumber numberWithFloat:baiduCoor.latitude];
        NSDictionary *dic = @{@"lat":lat,@"lon":lon};
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

    }else{
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"参数传入有误"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }


}

////监听地图的相关事件
//- (void)addOfflineListener:(CDVInvokedUrlCommand *)command{
//    _offMapEventCB = command.callbackId;
//    [_defaultCenter addObserver:self selector:@selector(offLineMapEventOccur:) name:@"offLineMapEventOccur" object:nil];
//}
/**
 *返回网络错误
 *@param iError 错误号
 */
- (void)onGetNetworkState:(int)iError{
    if (0 == iError) {
        NSLog(@"联网成功");
    }
    else{
        NSLog(@"onGetNetworkState %d",iError);
    }

}

#pragma mark--BMKOfflineMapDelegate
-(void)onGetOfflineMapState:(int)type withState:(int)state{
    NSDictionary *updateInfo = [[NSDictionary alloc]init];
    if (type == 0) {
        //此时下载或者更新
        BMKOLUpdateElement *info = [_offLineMap getUpdateInfo:_cityID];
        NSString *cityName = info.cityName;
        int cityID = info.cityID;
        int size = info.size;
        int serversize = info.serversize;
        BOOL update = info.update;
        int ratio = info.ratio;
        int status = info.status;
        NSNumber *lat = [NSNumber numberWithDouble:info.pt.latitude];
        NSNumber *lon = [NSNumber numberWithDouble:info.pt.longitude];
        NSDictionary *pt = @{@"lat":lat,@"lon":lon};
        updateInfo = @{@"cityName":cityName,@"cityID":[NSNumber numberWithInt:cityID],@"size":[NSNumber numberWithInt:size],@"serversize":[NSNumber numberWithInt:serversize],@"update":[NSNumber numberWithBool:update],@"ratio":[NSNumber numberWithInt:ratio],@"status":[NSNumber numberWithInt:status],@"pt":pt};
        NSDictionary *dic = @{@"type":[NSNumber numberWithInt:type],@"state":[NSNumber numberWithInt:state],@"updateInfo":updateInfo};
        [_defaultCenter postNotificationName:@"offLineMapEventOccur" object:nil userInfo:dic];


    }else{
        NSDictionary *dic = @{@"type":[NSNumber numberWithInt:type],@"state":[NSNumber numberWithInt:state]};
        [_defaultCenter postNotificationName:@"offLineMapEventOccur" object:nil userInfo:dic];

    }


}
/**
 *返回授权验证错误
 *@param iError 错误号 : 为0时验证通过，具体参加BMKPermissionCheckResultCode
 */
- (void)onGetPermissionState:(int)iError{
    if (0 == iError) {
        NSLog(@"授权成功");
    }
    else {
        NSLog(@"onGetPermissionState %d",iError);
    }
}

#pragma mark--BMKLocationAuthDelegate
/**
 *@brief 返回授权验证错误
 *@param iError 错误号 : 为0时验证通过，具体参加BMKLocationAuthErrorCode
 */
- (void)onCheckPermissionState:(BMKLocationAuthErrorCode)iError{
  if (0 == iError) {
    NSLog(@"定位授权成功");
  }
  else {
    NSLog(@"onGetPermissionState %d",iError);
  }
}


-(void)dealloc{
    if (_arrayHotCityData) {
        _offLineMap = nil;
    }
    _offLineMap.delegate = nil;
}

@end
