//
//  BGCrearTrendsBaseTableViewCell.h
//  BusinessGo
//
//  Created by per on 16/10/17.
//  Copyright © 2016年 com.Ideal. All rights reserved.
//

#import <UIKit/UIKit.h>
extern NSString *const sendImageInfo;
extern NSString *const sayInfo;
@interface BGCrearTrendsBaseTableViewCell : UITableViewCell
@property(nonatomic,assign)UIViewController *curentVC;
@property (nonatomic, copy) void (^addImagesFinishdBlock)(NSDictionary *sendDic);
-(NSDictionary*)gettingSendDic;
-(void)settingSendDic:(NSDictionary *)dic;
-(void)settingSendHiddenImage:(BOOL)isHidden;
@end
