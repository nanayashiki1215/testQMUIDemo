//
//  BGQMCategoryListConViewController.h
//  变电所运维
//
//  Created by Acrel on 2019/6/4.
//  
//

#import <QMUIKit/QMUIKit.h>

@interface BGQMCategoryListConViewController : QMUICommonViewController
- (NSArray <NSString *> *)getRandomTitles;
@property (nonatomic,strong) NSArray *titleArr;
@property (nonatomic,strong) NSArray *allDataArr;
@property (nonatomic,assign) NSInteger clickIndex;//点击了Cell中的第几个
@property (nonatomic,assign) NSInteger clickIndexOfSelectedCell;//点击了tableview中的第几个

@end
