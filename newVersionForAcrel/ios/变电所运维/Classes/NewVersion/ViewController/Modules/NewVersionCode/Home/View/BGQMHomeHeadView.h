//
//  BGQMHomeHeadView.h
//  变电所运维
//
//  Created by Acrel on 2019/6/12.
//  
//

#import <UIKit/UIKit.h>

@interface BGQMHomeHeadView : UIView

@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UILabel *addressLabel;
@property (nonatomic,strong) UILabel *contactLabel;
@property (nonatomic,strong) UILabel *phoneLabel;
@property (nonatomic,strong) QMUIGridView *gridView;
@property (nonatomic,strong) UIButton *PhoneBtn;
@property (nonatomic,strong) UIButton *addressBtn;

@property (nonatomic,strong) NSArray *strArray;
@property (nonatomic,strong) NSString *fLatitude;
@property (nonatomic,strong) NSString *fLongitude;

- (instancetype)initHomeHeadViewWithFrame:(CGRect)frame andHeadData:(NSDictionary *)paramDic andDataArray:(NSArray *)paramArr;

@end
