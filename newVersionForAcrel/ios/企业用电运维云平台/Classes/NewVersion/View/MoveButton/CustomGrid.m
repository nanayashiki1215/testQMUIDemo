//
//  CustomGrid.m
//  MoveGrid
//
//  Created by fuzheng on 16-5-26.
//  Copyright © 2016年 付正. All rights reserved.
//

#import "CustomGrid.h"

static NSInteger const pointWidth = 20; //小红点的宽高
static NSInteger const rightRange = pointWidth/2; //距离控件右边的距离

@implementation CustomGrid

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

//创建格子
- (id)initWithFrame:(CGRect)frame
              title:(NSString *)title
        normalImage:(UIImage *)normalImage
   highlightedImage:(UIImage *)highlightedImage
             gridId:(NSInteger)gridId
            atIndex:(NSInteger)index
        isAddDelete:(BOOL)isAddDelete
         deleteIcon:(UIImage *)deleteIcon
      withIconImage:(NSString *)imageString
    withBadgeNumber:(NSString *)number
{
    self = [super initWithFrame:frame];
    if (self) {
        //计算每个格子的X坐标
        CGFloat pointX = (index % PerRowGridCount) * (GridWidth + PaddingX) + PaddingX;
        //计算每个格子的Y坐标
        CGFloat pointY = (index / PerRowGridCount) * (GridHeight + PaddingY) + PaddingY;
        
        [self setFrame:CGRectMake(pointX, pointY, GridWidth+1, GridHeight+1)];
        [self setBackgroundImage:normalImage forState:UIControlStateNormal];
        [self setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [self addTarget:self action:@selector(gridClick:) forControlEvents:UIControlEventTouchUpInside];
        
        if (isPad) {
            // 图片icon
            UIImageView * imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width/2-(GridHeight-85)/2, GridHeight/4-10, GridHeight-85 , GridHeight-85)];
            if ([imageString containsString:@"dsbgl"]) {
                imageIcon.image = [UIImage imageNamed:imageString];
            }else{
                [imageIcon sd_setImageWithURL:[NSURL URLWithString:[getSystemIconADS stringByAppendingString:imageString]] placeholderImage:[UIImage imageNamed:@""]];
            }
            imageIcon.tag = self.gridId;
            [self addSubview:imageIcon];
            // 标题
            UILabel * title_label = [[UILabel alloc]initWithFrame:CGRectMake(0, GridHeight/4 + GridHeight - 45 - 70, GridHeight-80, 20)];
            title_label.text = title;
            title_label.textAlignment = NSTextAlignmentCenter;
            title_label.font = [UIFont systemFontOfSize:18];
            title_label.backgroundColor = [UIColor clearColor];
            title_label.textColor = UIColorFromRGB(0x3c454c);
            [self addSubview:title_label];
            //小红点
           if ([number integerValue]>0) {
               CGRect frame = CGRectMake(GridHeight - 85 + self.frame.size.width/2-(GridHeight - 85)/2 - rightRange, GridHeight/4-10-rightRange, pointWidth, pointWidth);
               self.badgeLabel = [[UILabel alloc] initWithFrame:frame];
               self.badgeLabel.textColor = [UIColor whiteColor];
               self.badgeLabel.font = [UIFont systemFontOfSize:12.f];
               if([number integerValue]>99){
                   number = @"···";
               }
               self.badgeLabel.text = number;
               self.badgeLabel.backgroundColor = [UIColor qmui_colorWithHexString:@"ff5153"];
               self.badgeLabel.textAlignment = NSTextAlignmentCenter;
               //圆角为宽度的一半
               self.badgeLabel.layer.cornerRadius = pointWidth / 2;
               //确保可以有圆角
               self.badgeLabel.layer.masksToBounds = YES;
               [self addSubview:self.badgeLabel];
           }else{
               [self.badgeLabel removeFromSuperview];
           }
        }else{
            // 图片icon
            UIImageView * imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width/2-(GridHeight-35)/2, GridHeight/4-10, GridHeight-35 , GridHeight-35)];
            if ([imageString containsString:@"dsbgl"]) {
                imageIcon.image = [UIImage imageNamed:imageString];
            }else{
                [imageIcon sd_setImageWithURL:[NSURL URLWithString:[getSystemIconADS stringByAppendingString:imageString]] placeholderImage:[UIImage imageNamed:@""]];
            }
            imageIcon.tag = self.gridId;
            [self addSubview:imageIcon];
            // 标题
            UILabel * title_label = [[UILabel alloc]initWithFrame:CGRectMake(0, GridHeight/4 + GridHeight - 45, GridHeight, 20)];
            title_label.text = title;
            title_label.textAlignment = NSTextAlignmentCenter;
            title_label.font = [UIFont systemFontOfSize:14];
            title_label.backgroundColor = [UIColor clearColor];
            title_label.textColor = UIColorFromRGB(0x3c454c);
            [self addSubview:title_label];
            //小红点
            if ([number integerValue]>0) {
                CGRect frame = CGRectMake(GridHeight - 35 + self.frame.size.width/2-(GridHeight-35)/2 - rightRange-1, GridHeight/4-10-rightRange+1, pointWidth, pointWidth);
                self.badgeLabel = [[UILabel alloc] initWithFrame:frame];
                self.badgeLabel.textColor = [UIColor whiteColor];
                self.badgeLabel.font = [UIFont systemFontOfSize:12.f];
                if([number integerValue]>99){
                    number = @"···";
                }
                self.badgeLabel.text = number;
                self.badgeLabel.backgroundColor = [UIColor qmui_colorWithHexString:@"ff5153"];
                self.badgeLabel.textAlignment = NSTextAlignmentCenter;
                //圆角为宽度的一半
                self.badgeLabel.layer.cornerRadius = pointWidth / 2;
                //确保可以有圆角
                self.badgeLabel.layer.masksToBounds = YES;
                [self addSubview:self.badgeLabel];
            }else{
                [self.badgeLabel removeFromSuperview];
            }
        }
        
        //
        [self setGridId:gridId];
        [self setGridIndex:index];
        [self setGridCenterPoint:self.center];
        
        
        //判断是否要添加删除图标
        if (isAddDelete) {
            //当长按时添加删除按钮图标
            UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [deleteBtn setFrame:CGRectMake(self.frame.size.width-30, 10, 20, 20)];
            [deleteBtn setBackgroundColor:[UIColor clearColor]];
            [deleteBtn setBackgroundImage:deleteIcon forState:UIControlStateNormal];
            [deleteBtn addTarget:self action:@selector(deleteGrid:) forControlEvents:UIControlEventTouchUpInside];
            [deleteBtn setHidden:YES];
            
            /////////////
            [deleteBtn setTag:gridId];
            [self addSubview:deleteBtn];
            
            //添加长按手势
            UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gridLongPress:)];
            [self addGestureRecognizer:longPressGesture];
             longPressGesture = nil;
        }
    }
    return self;
}
- (void)layoutSubviews {
    self.backgroundColor = [UIColor clearColor];
    [super layoutSubviews];
    
}


//响应格子点击事件
- (void)gridClick:(CustomGrid *)clickItem
{
    [self.delegate gridItemDidClicked:clickItem];
}

//响应格子删除事件
- (void)deleteGrid:(UIButton *)deleteButton
{
    [self.delegate gridItemDidDeleteClicked:deleteButton];
}

//响应格子的长安手势事件
- (void)gridLongPress:(UILongPressGestureRecognizer *)longPressGesture
{
    switch (longPressGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self.delegate pressGestureStateBegan:longPressGesture withGridItem:self];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            //应用移动后的新坐标
            CGPoint newPoint = [longPressGesture locationInView:longPressGesture.view];
            [self.delegate pressGestureStateChangedWithPoint:newPoint gridItem:self];
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            [self.delegate pressGestureStateEnded:self];
            break;
        }
        default:
            break;
    }
}

//根据格子的坐标计算格子的索引位置
+ (NSInteger)indexOfPoint:(CGPoint)point
               withButton:(UIButton *)btn
                gridArray:(NSMutableArray *)gridListArray
{
    for (NSInteger i = 0;i< gridListArray.count;i++)
    {
        UIButton *appButton = gridListArray[i];
        if (appButton != btn)
        {
            if (CGRectContainsPoint(appButton.frame, point))
            {
                return i;
            }
        }
    }
    return -1;
}

@end
