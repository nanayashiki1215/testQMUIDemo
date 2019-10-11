//
//  YPAMapChooseViewController.h
//  linphone
//
//  Created by feitian on 2016/11/28.
//
//

#import <UIKit/UIKit.h>

@interface YPAMapChooseViewController : BaseViewController

@property (nonatomic,strong)NSString *citycode;/**< 当前定位的城市编码 */
@property (copy, nonatomic) void (^chooseLocationBlock)( NSDictionary*data);
-(void)setChooseLocationBlock:(void (^)(NSDictionary *))chooseLocationBlock;

@end
