//
//  EZCustomTableVIew.m
//  EZOpenSDKDemo
//
//  Created by yuqian on 2019/6/27.
//  Copyright © 2019 hikvision. All rights reserved.
//

#import "EZCustomTableView.h"
#import "Masonry.h"


@interface EZCustomTableView() <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *datasources;

@end

static NSString *reuseId = @"UITableViewCell";

@implementation EZCustomTableView

- (instancetype) initTableViewWith:(NSArray *)datasource delegate:(id<EZCustomTableViewDelegate>) delegate {
    
    if (self = [super init]) {
        
        self.tableView = [[UITableView alloc]init];
//        self.tableView.backgroundColor = [UIColor colorWithRed:25/255.0 green:25/255.0 blue:112/255.0 alpha:0.5];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.rowHeight = 30;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseId];
        [self addSubview:_tableView];
        
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        self.delegate = delegate;
        self.datasources = datasource;
        
        [self.tableView reloadData];
    }
    return self;
}

- (void) destroy {
    
    [self removeFromSuperview];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datasources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId forIndexPath:indexPath];
    
    cell.textLabel.text = self.datasources[indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
//    cell.backgroundColor = [UIColor colorWithRed:25/255.0 green:25/255.0 blue:112/255.0 alpha:0.5];
    cell.backgroundColor = [UIColor blackColor];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.textLabel.highlightedTextColor = [UIColor blackColor];
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(EZCustomTableView:didSelectedTableViewCell:)]) {
        [self.delegate EZCustomTableView:self didSelectedTableViewCell:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

@end
