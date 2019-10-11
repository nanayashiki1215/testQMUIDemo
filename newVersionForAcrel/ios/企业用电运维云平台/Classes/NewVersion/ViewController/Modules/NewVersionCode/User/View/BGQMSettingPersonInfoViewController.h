//
//  BGQMSettingPersonInfoViewController.h
//  变电所运维
//
//  Created by Acrel on 2019/8/7.
//

#import <QMUIKit/QMUIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BGQMSettingPersonInfoViewController : QMUICommonViewController
@property (nonatomic,copy) NSString *settingName;
@property (nonatomic,copy) NSString *settingChangeStr;
@property (nonatomic,assign) NSInteger uploadType;
@end

NS_ASSUME_NONNULL_END
