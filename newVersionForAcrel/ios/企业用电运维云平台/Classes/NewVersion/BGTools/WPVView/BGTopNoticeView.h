//
//  BGTopNoticeView.h
//  BusinessGo
//
//  Created by leo on 2019/1/18.
//  Copyright © 2019 com.Ideal. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^didConfirm)(UIButton * button,NSDictionary *data);

@interface BGTopNoticeView : UIWindow
{
    didConfirm _confirm;
    
}

/**标题*/
@property (nonatomic, copy) NSString * titleText;
/**标题Label*/
@property (nonatomic, strong) UILabel * titleTextLabel;


/**c创建者*/
@property (nonatomic, copy) NSString * creatorText;
/**Label*/
@property (nonatomic, strong) UILabel * creatorTextLabel;

/**内容*/
@property (nonatomic, copy) NSString * messageText;
/**内容Label*/
@property (nonatomic, strong) UILabel * messageTextLabel;

/**确认按钮*/
@property (nonatomic, strong) UIButton * confirmBtn;
/**确认按钮文字*/
@property (nonatomic, copy) NSString * conformBtnTitle;
/**取消按钮*/
@property (nonatomic, strong) UIButton * cancelBtn;
/**取消按钮文字*/
@property (nonatomic, copy) NSString * cancelBtnTitle;

@property (nonatomic, copy) NSMutableArray * dataArray;

@property (nonatomic, copy) NSDictionary * data;

@property (nonatomic, assign)BOOL isShowing;

+ (instancetype)share;

// 显示
- (void)show;
// 消失
- (void)dismiss;
//点击确认按钮
-(void)didConfirm:(void (^)(UIButton * button,NSDictionary *data))didConfirm;

@end
