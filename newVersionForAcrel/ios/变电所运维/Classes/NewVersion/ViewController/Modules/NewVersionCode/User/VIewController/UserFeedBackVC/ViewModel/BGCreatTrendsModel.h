//
//  BGCreatTrendsModel.h
//  BusinessGo
//
//  Created by per on 16/10/31.
//  Copyright © 2016年 com.Ideal. All rights reserved.
//

#import "BGCreatTrendsModel.h"

@interface BGCreatTrendsModel : NSObject
//@{kcustomerId:@"1",ktitle:@"1123",kmsgType:@0,ktextContent:@"33124"}
@property(nonatomic,copy)NSString *customerId;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSNumber *msgType;
@property(nonatomic,copy)NSString *textContent;
@property(nonatomic,copy)NSArray *imgList;
/**
 *  通过定义键值返回向后台发送的数据
 *
 *  @return 向后台发送的数据
 */
-(NSMutableDictionary*)postDictionary;

@end
