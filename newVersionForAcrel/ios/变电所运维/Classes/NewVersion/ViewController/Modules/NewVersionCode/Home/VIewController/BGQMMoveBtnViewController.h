//
//  BGQMMoveBtnViewController.h
//  变电所运维
//
//  Created by Acrel on 2019/6/4.
//  
//

#import <QMUIKit/QMUIKit.h>

@interface BGQMMoveBtnViewController : QMUICommonViewController
//显示格子的GridId
@property(nonatomic, strong)NSMutableArray *showMoreGridIdArray;
@property(nonatomic, strong)NSMutableArray *showMoreGridTitleArray;
@property(nonatomic, strong)NSMutableArray *showMoreGridImageArray;

@property(nonatomic, strong)NSMutableArray *showGridArray; //title
@property(nonatomic, strong)NSMutableArray *showImageGridArray;//image
@property(nonatomic, strong)NSMutableArray *showGridIDArray;//gridId

//首页显示应用
@property(nonatomic, strong)NSMutableArray *addGridTitleArray;
@property(nonatomic, strong)NSMutableArray *addGridIdArray;
@property(nonatomic, strong)NSMutableArray *addImageGridArray;//image

@end
