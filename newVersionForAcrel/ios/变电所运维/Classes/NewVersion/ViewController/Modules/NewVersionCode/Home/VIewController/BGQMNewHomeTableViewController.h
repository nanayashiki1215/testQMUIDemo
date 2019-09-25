//
//  BGQMNewHomeTableViewController.h
//  变电所运维
//
//  Created by Acrel on 2019/6/12.
//  
//

#import <QMUIKit/QMUIKit.h>
#import "BGQMHomeHeadView.h"
#import "BGQMSubstationModel.h"

@interface BGQMNewHomeTableViewController : QMUICommonTableViewController

@property (nonatomic,strong) BGQMSubstationModel *subModel;
@property (nonatomic,strong) NSString *fMenuid;

@end
