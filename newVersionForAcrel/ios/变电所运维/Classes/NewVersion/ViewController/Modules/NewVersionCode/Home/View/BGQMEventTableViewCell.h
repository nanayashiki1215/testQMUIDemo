//
//  BGQMEventTableViewCell.h
//  变电所运维
//
//  Created by Acrel on 2019/6/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BGQMEventTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) UILabel *textInLabel;

@end

NS_ASSUME_NONNULL_END
