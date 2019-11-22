//
//  BGFileDownLoadTableViewCell.m
//  BusinessGo
//
//  Created by NanayaSSD on 2017/4/11.
//  Copyright © 2017年 com.Ideal. All rights reserved.
//

#import "BGFileDownLoadTableViewCell.h"

@implementation BGFileDownLoadTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.downLoadingLabel.hidden = YES;
    [self setup];
}

- (void)setup{
    
    UILongPressGestureRecognizer *longPressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGes.numberOfTouchesRequired = 1;
    longPressGes.minimumPressDuration = 1.0f;
    [self.contentView addGestureRecognizer:longPressGes];
    
//    self.selectionStyle = UITableViewCellSelectionStyleNone;
}


- (IBAction)clickDownloadBtnEvent:(UIButton *)sender {
    [self.delegate didClickDownloadButton:sender];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

#pragma mark - UIMenuController 需要的方法
//以下两个方法必须有
/*
 *  让UIView成为第一responser
 */
- (BOOL)canBecomeFirstResponder{
    return YES;
}

/*
 *  根据action,判断UIMenuController是否显示对应aciton的title
 */
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(selectDeleteItem)) {
        return YES;
    }
    return NO;
}

-(void)setMenuControllerMenuItems{
    //    [self resignFirstResponder];
    
    UIMenuItem *dItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(selectDeleteItem)];
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    
    [menuController setMenuItems:@[dItem]];
    
    [menuController setArrowDirection:UIMenuControllerArrowDefault];
    [menuController setTargetRect:self.frame inView:self.superview];
    [menuController setMenuVisible:YES animated:YES];
}


-(void)selectDeleteItem{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickDeleteFileWithName:)]) {
        [self.delegate didClickDeleteFileWithName:self.fileName.text];
    }
}

//长按对话框功能
- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressGes{
    if (longPressGes.state == UIGestureRecognizerStateBegan) {
        //首先自己成为第一responser
        [self becomeFirstResponder];
        [self setMenuControllerMenuItems];
        
    }
}

@end
