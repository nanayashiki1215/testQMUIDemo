//
//  BGQMHomeViewController.h
//  变电所运维
//
//  Created by Acrel on 2019/6/3.
//  
//

#import <QMUIKit/QMUIKit.h>
#import "BGQMHomeHeadView.h"

@interface BGQMHomeViewController : QMUICommonViewController

@property(nonatomic, strong)NSMutableArray *addGridTitleArray;//接收更多标签页面传过来的值
@property(nonatomic, strong)NSMutableArray *addGridImageArray;//image
@property(nonatomic, strong)NSMutableArray *addGridIDArray;//gridId

@property(nonatomic, strong)NSMutableArray *gridListArray;

@property(nonatomic, strong)NSMutableArray *showGridArray; //title
@property(nonatomic, strong)NSMutableArray *showGridImageArray;//image
@property(nonatomic, strong)NSMutableArray *showGridIDArray;//gridId

//更多页面显示应用
@property(nonatomic, strong)NSMutableArray *moreGridTitleArray;
@property(nonatomic, strong)NSMutableArray *moreGridIdArray;
@property(nonatomic, strong)NSMutableArray *moreGridImageArray;//image

@property(nonatomic, strong)UIView  *gridListView;
@property(nonatomic, strong)UIImageView *imageView;
@property(nonatomic, strong) BGQMHomeHeadView *headView;

@end
