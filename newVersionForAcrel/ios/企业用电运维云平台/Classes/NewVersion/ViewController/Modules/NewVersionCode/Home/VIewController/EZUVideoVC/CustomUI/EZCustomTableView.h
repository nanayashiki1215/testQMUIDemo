//
//  EZCustomTableVIew.h
//  EZOpenSDKDemo
//
//  Created by yuqian on 2019/6/27.
//  Copyright © 2019 hikvision. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class EZCustomTableView;

@protocol EZCustomTableViewDelegate <NSObject>

@optional
- (void) EZCustomTableView:(EZCustomTableView *)customTableView didSelectedTableViewCell:(NSIndexPath *)indexPath;

@end

@interface EZCustomTableView : UIView

@property (nonatomic, weak) id<EZCustomTableViewDelegate> delegate;

- (instancetype) initTableViewWith:(NSArray *)datasource delegate:(id<EZCustomTableViewDelegate>)delegate;
- (void) destroy;

@end

NS_ASSUME_NONNULL_END

