//
//  CDVBaiduMap.h
//  baiduMap
//  Created by LiangQiangkun on 16/5/20.
//
//

#import <Cordova/CDVPlugin.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BMKLocationKit/BMKLocationComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
@interface CDVBaiduMap : CDVPlugin <BMKGeneralDelegate,BMKLocationManagerDelegate,BMKMapViewDelegate,BMKOfflineMapDelegate, BMKLocationAuthDelegate>
@property(nonatomic,copy)NSString *baiduKey;
@property(nonatomic,copy)NSString *mcode;

- (void)open:(CDVInvokedUrlCommand *)command;
- (void)close:(CDVInvokedUrlCommand *)command;
- (void)setPosition:(CDVInvokedUrlCommand *)command;
- (void)getCurrentLocation:(CDVInvokedUrlCommand *)command;
- (void)getLocationFromName:(CDVInvokedUrlCommand *)command;
- (void)getNameFromLocation:(CDVInvokedUrlCommand *)command;
- (void)showCurrentLocation:(CDVInvokedUrlCommand *)command;
- (void)setCenter:(CDVInvokedUrlCommand *)command;
- (void)getCenter:(CDVInvokedUrlCommand *)command;
- (void)setZoomLevel:(CDVInvokedUrlCommand *)command;
- (void)setMapAttr:(CDVInvokedUrlCommand *)command;
- (void)setRotation:(CDVInvokedUrlCommand *)command;
- (void)setOverlook:(CDVInvokedUrlCommand *)command;
- (void)setScaleBar:(CDVInvokedUrlCommand *)command;
- (void)setCompass:(CDVInvokedUrlCommand *)command;
- (void)setTraffic:(CDVInvokedUrlCommand *)command;
- (void)setHeatMap:(CDVInvokedUrlCommand *)command;
- (void)setBuilding:(CDVInvokedUrlCommand *)command;
- (void)setRegion:(CDVInvokedUrlCommand *)command;
- (void)getRegion:(CDVInvokedUrlCommand *)command;
- (void)zoomIn:(CDVInvokedUrlCommand *)command;
- (void)zoomOut:(CDVInvokedUrlCommand *)command;
- (void)addAnnotations:(CDVInvokedUrlCommand *)command;
- (void)removeAnnotations:(CDVInvokedUrlCommand *)command;
- (void)removeAllAnno:(CDVInvokedUrlCommand *)command;
- (void)getAnnotationCoords:(CDVInvokedUrlCommand *)command;
- (void)updateAnnotationCoords:(CDVInvokedUrlCommand *)command;
- (void)annotationExist:(CDVInvokedUrlCommand *)command;
- (void)addLine:(CDVInvokedUrlCommand *)command;
- (void)addPolygon:(CDVInvokedUrlCommand *)command;
- (void)addArc:(CDVInvokedUrlCommand *)command;
- (void)addCircle:(CDVInvokedUrlCommand *)command;
- (void)removeOverlay:(CDVInvokedUrlCommand *)command;
//- (void)offLineMapInit:(CDVInvokedUrlCommand *)command;
- (void)addOfflineListener:(CDVInvokedUrlCommand *)command;
- (void)removeOfflineListener:(CDVInvokedUrlCommand *)command;
- (void)getHotCityList:(CDVInvokedUrlCommand *)command;
- (void)getOfflineCityList:(CDVInvokedUrlCommand *)command;
- (void)searchCityByName:(CDVInvokedUrlCommand *)command;
- (void)getUpdateInfo:(CDVInvokedUrlCommand *)command;
- (void)getAllUpdateInfo:(CDVInvokedUrlCommand *)command;
- (void)downLoad:(CDVInvokedUrlCommand *)command;
- (void)update:(CDVInvokedUrlCommand *)command;
- (void)pause:(CDVInvokedUrlCommand *)command;
- (void)remove:(CDVInvokedUrlCommand *)command;
- (void)getDistance:(CDVInvokedUrlCommand *)command;
- (void)transCoords:(CDVInvokedUrlCommand *)command;
@end