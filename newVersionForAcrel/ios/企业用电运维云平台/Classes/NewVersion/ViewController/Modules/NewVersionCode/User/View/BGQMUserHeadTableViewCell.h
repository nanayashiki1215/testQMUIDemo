//
//  BGQMTableViewCell.h
//  变电所运维
//
//  Created by Acrel on 2019/7/31.
//

#import <QMUIKit/QMUIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <BMKLocationKit/BMKLocationComponent.h>
#import "SKControllerTools.h"

NS_ASSUME_NONNULL_BEGIN

@interface BGQMUserHeadTableViewCell : QMUITableViewCell<BMKLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *quitOutBtn;
@property (weak, nonatomic) IBOutlet UILabel *signoutlabel;
@property (nonatomic, strong) BMKLocationManager *locationManager; //定位对象


@end

NS_ASSUME_NONNULL_END
