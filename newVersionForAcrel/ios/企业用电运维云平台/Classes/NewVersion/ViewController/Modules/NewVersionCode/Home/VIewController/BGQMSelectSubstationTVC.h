//
//  BGQMSelectSubstationTVC.h
//  变电所运维
//
//  Created by Acrel on 2019/6/10.
//  
//

#import <QMUIKit/QMUIKit.h>
#import "BGQMSubstationModel.h"

@protocol BGQMSelectSubstationTVCDelegate

- (void)sendSubModel:(BGQMSubstationModel *)subModel;

@end

@interface BGQMSelectSubstationTVC : QMUICommonTableViewController

@property (nonatomic,weak) id<BGQMSelectSubstationTVCDelegate> subTVCdelegate;

@end
