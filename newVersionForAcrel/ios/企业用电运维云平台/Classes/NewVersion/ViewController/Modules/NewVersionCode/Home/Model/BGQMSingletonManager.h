//
//  BGQMSingletonManager.h
//  变电所运维
//
//  Created by Acrel on 2019/6/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BGQMSingletonManager : NSObject
// 主页 按钮 数组
@property (strong,nonatomic) NSMutableArray * showGridArray; // 标题
@property (strong,nonatomic) NSMutableArray * showImageGridArray; // 图片
@property (strong,nonatomic) NSMutableArray * showBadgeArray; // 红点数
@property (strong,nonatomic) NSMutableArray * showGridIDArray;  //button的ID

// 主页 更多 按钮 数组
@property (strong,nonatomic) NSMutableArray * moreshowGridArray; // 标题
@property (strong,nonatomic) NSMutableArray * moreshowImageGridArray; // 图片
@property (strong,nonatomic) NSMutableArray * moreshowBadgeArray; // 红点数
@property (strong,nonatomic) NSMutableArray * moreshowGridIDArray;  //button的ID

+(BGQMSingletonManager *)shareInstance;

@end

NS_ASSUME_NONNULL_END
