//
//  BGImouVideoListVC.h
//  企业用电运维云平台
//
//  Created by Acrel on 2020/7/24.
//

#import <QMUIKit/QMUIKit.h>
#import "JXCategoryListCollectionContainerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface BGImouVideoListVC : QMUICommonTableViewController<JXCategoryListCollectionContentViewDelegate>

@property(nonatomic, strong)NSString *titleFromHomepage;
//透传navi
@property(nonatomic,strong) UINavigationController *ownNaviController;

@property(nonatomic,strong)NSString *pushTitleName;

@property(nonatomic,strong)NSString *pushSubid;

@end

NS_ASSUME_NONNULL_END
