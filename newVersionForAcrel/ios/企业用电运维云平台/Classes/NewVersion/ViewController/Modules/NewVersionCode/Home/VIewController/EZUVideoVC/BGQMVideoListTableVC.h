//
//  BGQMVideoListTableVC.h
//  变电所运维
//
//  Created by Acrel on 2019/6/6.
//  
//

#import <QMUIKit/QMUIKit.h>
#import "JXCategoryListCollectionContainerView.h"

@interface BGQMVideoListTableVC : QMUICommonTableViewController<JXCategoryListCollectionContentViewDelegate>

@property(nonatomic, strong)NSString *titleFromHomepage;
//透传navi
@property(nonatomic,strong) UINavigationController *ownNaviController;


@end
