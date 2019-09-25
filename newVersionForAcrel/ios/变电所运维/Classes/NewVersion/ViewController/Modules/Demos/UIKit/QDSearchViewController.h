//
//  QDSearchViewController.h
//  qmuidemo
//
//  Created by QMUI Team on 16/5/25.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "QDCommonTableViewController.h"

@interface QDSearchViewController : QDCommonTableViewController

@end

@interface QDRecentSearchView : UIView

@property(nonatomic, strong) QMUILabel *titleLabel;
@property(nonatomic, strong) QMUIFloatLayoutView *floatLayoutView;

@end
