//
//  PopoverView.m
//  86SB
//
//  Created by 李智慧 on 16/4/20.
//  Copyright © 2016年 尚标. All rights reserved.
//

#import "PopoverView.h"
#import "PopoverCell.h"

#define kArrowHeight 8.f
#define kArrowCurvature 5.f
//#define SPACE 2.f
#define SPACE 0.f
#define ROW_HEIGHT 40.f
#define TITLE_FONT [UIFont systemFontOfSize:16]
#define RGB(r, g, b)    [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:1.f]
static NSString *PopoverViewCellRI = @"PopoverViewCellRI";

@interface PopoverView ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *infoArray;
@property (nonatomic) CGPoint showPoint;
@property (nonatomic, strong) UIButton *handerView;

@end

@implementation PopoverView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.borderColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

-(id)initWithPoint:(CGPoint)point titleAndImageInfoArray:(NSArray *)infoArray
{
    self = [super init];
    if (self) {
        
        self.showPoint = point;
        self.infoArray = infoArray;        
        self.frame = [self getViewFrame];
        
        [self addSubview:self.tableView];
    }
    return self;
}

-(CGRect)getViewFrame
{
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    CGRect frame = CGRectZero;
    
    frame.size.height = [self.infoArray count] * ROW_HEIGHT + SPACE + kArrowHeight;
    
    for (NSDictionary *muneItem in self.infoArray) {
        NSString *title = [muneItem objectForKey:@"title"];
       CGFloat width = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:TITLE_FONT} context:nil].size.width;
        
        frame.size.width = MAX(width, frame.size.width);
    }
    
    if ([self.infoArray count]) {
        frame.size.width = 55 + frame.size.width;
    }else{
        frame.size.width = 10 + frame.size.width + 40;
    }
    
    frame.origin.x = self.showPoint.x - frame.size.width/2;
    frame.origin.y = self.showPoint.y;
    
    //左间隔最小5x
    if (frame.origin.x < 5) {
        frame.origin.x = 5;
    }
    double length;
    if (window.bounds.size.width > 0) {
        length = window.bounds.size.width - 5;
    }
    
    DefLog(@"%f",length);
    //右间隔最小5x
    if ((frame.origin.x + frame.size.width) > length) {
        frame.origin.x = length - frame.size.width;
    }
    
    
    return frame;
}


-(void)show
{
    self.handerView = [UIButton buttonWithType:UIButtonTypeCustom];
    [_handerView setFrame:[UIScreen mainScreen].bounds];
//    [_handerView setBackgroundColor:[UIColor clearColor]];
    
    [_handerView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.3]];
    
    [_handerView addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [_handerView addSubview:self];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [window addSubview:_handerView];
    
    CGPoint arrowPoint = [self convertPoint:self.showPoint fromView:_handerView];
    self.layer.anchorPoint = CGPointMake(arrowPoint.x / self.frame.size.width, arrowPoint.y / self.frame.size.height);
    self.frame = [self getViewFrame];
    
    self.alpha = 0.f;
    self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
        self.alpha = 1.f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.08f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
}

-(void)dismiss
{
    [self dismiss:YES];
}

-(void)dismiss:(BOOL)animate
{
    if (!animate) {
        [_handerView removeFromSuperview];
        return;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [_handerView removeFromSuperview];
    }];
    
}


#pragma mark - UITableView

-(UITableView *)tableView
{
    if (_tableView != nil) {
        return _tableView;
    }
    
    CGRect rect = self.frame;
    rect.origin.x = SPACE;
    rect.origin.y = kArrowHeight + SPACE;
    rect.size.width -= SPACE * 2;
    rect.size.height -= (SPACE + kArrowHeight);
    
    
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.alwaysBounceHorizontal = NO;
    _tableView.alwaysBounceVertical = NO;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.scrollEnabled = NO;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.layer.cornerRadius = 4;
    _tableView.layer.masksToBounds = YES;
    [_tableView registerClass:[PopoverCell class] forCellReuseIdentifier:PopoverViewCellRI];
    
    return _tableView;
}

#pragma mark - UITableView DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_infoArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PopoverCell *cell = [tableView dequeueReusableCellWithIdentifier:PopoverViewCellRI];
    cell.separatorInset = UIEdgeInsetsMake(0, 40, 0, 0);
    cell.layoutMargins = UIEdgeInsetsMake(0, 40, 0, 0);
    if ([_infoArray count] ) {
        cell.dic = [_infoArray objectAtIndex:indexPath.row];
    }
    return cell;
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.selectRowAtIndex) {
        self.selectRowAtIndex(indexPath.row,[_infoArray objectAtIndex:indexPath.row]);
    }
    [self dismiss:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT;
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [self.borderColor set]; //设置线条颜色
    
    CGRect frame = CGRectMake(0, kArrowHeight, self.bounds.size.width, self.bounds.size.height - kArrowHeight);
    
    float xMin = CGRectGetMinX(frame);
    float yMin = CGRectGetMinY(frame);
    
    float xMax = CGRectGetMaxX(frame);
    float yMax = CGRectGetMaxY(frame);
    
    CGPoint arrowPoint = [self convertPoint:self.showPoint fromView:_handerView];
    
    UIBezierPath *popoverPath = [UIBezierPath bezierPath];
//    [popoverPath moveToPoint:CGPointMake(xMin, yMin)];//左上角
    
    /********************向上的箭头**********************/
//    [popoverPath addLineToPoint:CGPointMake(arrowPoint.x - kArrowHeight, yMin)];//left side
    
    [popoverPath moveToPoint:CGPointMake(arrowPoint.x - kArrowHeight, yMin)];//left side
    
    [popoverPath addCurveToPoint:arrowPoint
                   controlPoint1:CGPointMake(arrowPoint.x - kArrowHeight + kArrowCurvature, yMin)
                   controlPoint2:arrowPoint];//actual arrow point
    
    [popoverPath addCurveToPoint:CGPointMake(arrowPoint.x + kArrowHeight, yMin)
                   controlPoint1:arrowPoint
                   controlPoint2:CGPointMake(arrowPoint.x + kArrowHeight - kArrowCurvature, yMin)];//right side
    /********************向上的箭头**********************/
    
    
//    [popoverPath addLineToPoint:CGPointMake(xMax, yMin)];//右上角
//
//    [popoverPath addLineToPoint:CGPointMake(xMax, yMax)];//右下角
//
//    [popoverPath addLineToPoint:CGPointMake(xMin, yMax)];//左下角
    
    //填充颜色
//    [[UIColor colorWithHexString:@"#333333"] setFill];

    [[UIColor whiteColor] setFill];

    [popoverPath fill];
    
    [popoverPath closePath];
    [popoverPath stroke];
}


@end
