//
//  YPAMapSearchPointViewController.h
//  linphone
//
//  Created by feitian on 2016/11/28.
//
//

#import <UIKit/UIKit.h>

@interface YPAMapSearchPointViewController : BaseViewController

@property (nonatomic,strong)NSString *citycode;/**< 当前定位的城市编码 */
@property (copy, nonatomic) void (^chooseBlock)( NSArray*data,NSIndexPath *indexPath);
-(void)setChooseBlock:(void (^)(NSArray *, NSIndexPath *))chooseBlock;

@end
