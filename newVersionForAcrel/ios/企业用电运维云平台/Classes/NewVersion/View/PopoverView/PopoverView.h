//
//  PopoverView.h
//  86SB
//
//  Created by 李智慧 on 16/4/20.
//  Copyright © 2016年 尚标. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopoverView : UIView
-(id)initWithPoint:(CGPoint)point titleAndImageInfoArray:(NSArray *)infoArray;
-(void)show;
-(void)dismiss;
-(void)dismiss:(BOOL)animated;

@property (nonatomic, copy) UIColor *borderColor;
@property (nonatomic, copy) void (^selectRowAtIndex)(NSInteger index,id objc);
@end
