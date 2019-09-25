//
//  BGQMFeedBackViewController.m
//  变电所运维
//
//  Created by Acrel on 2019/8/1.
//

#import "BGQMFeedBackViewController.h"
#import "BGCreatTrendsModel.h"
#import "BGCrearTrendsBaseTableViewCell.h"
#import "SKControllerTools.h"

@interface BGQMFeedBackViewController ()
@property(nonatomic,strong)NSArray *tableArr;
@property(nonatomic,strong)NSMutableArray *imageArr;
@property(nonatomic,strong)NSDictionary *headInfoDic;
@property(nonatomic,strong)BGCreatTrendsModel *uploadModel;

@end

@implementation BGQMFeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView registerNib:[UINib nibWithNibName:@"BGCrearTrendsBaseTableViewCell" bundle:nil] forCellReuseIdentifier:@"BGCrearTrendsBaseTableViewCell"];
    self.title = DefLocalizedString(@"Feedback");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:DefLocalizedString(@"submit") style:UIBarButtonItemStylePlain target:self action:@selector(clickSuggestSend)];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//推荐该方法
    self.tableView.backgroundColor = COLOR_BACKGROUND;
}

#pragma mark - <QMUITableViewDataSource, QMUITableViewDelegate>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    BGCrearTrendsBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([BGCrearTrendsBaseTableViewCell class]) forIndexPath:indexPath];
   
    __weak typeof(self) weakSelf = self;
    if (!cell.addImagesFinishdBlock) {
        [cell setAddImagesFinishdBlock:^(NSDictionary *dic) {
            weakSelf.headInfoDic = dic;
            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }];
    }
    
    [cell settingSendDic:_headInfoDic];
//    NSDictionary *dic = [cell gettingSendDic];
    [cell settingSendHiddenImage:(_sendMsgType==SendMegTypeTextAndUrl)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.curentVC = self;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *imagArr = (NSArray *)_headInfoDic[sendImageInfo];
    if (!imagArr) {
        imagArr = [NSArray array];
    }
    NSDictionary *tempDic = _tableArr[indexPath.section][indexPath.row];
    return ((imagArr.count/4+1) * 98 + (_sendMsgType==SendMegTypeTextAndUrl?0:260));
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(void)clickSuggestSend{
    BGCrearTrendsBaseTableViewCell *cell = (BGCrearTrendsBaseTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    BGCreatTrendsModel *model = [[BGCreatTrendsModel alloc]init];
    NSDictionary *dic = [cell gettingSendDic];
    [model setValuesForKeysWithDictionary:dic];
    NSArray *imageArr = dic[@"imgList"];
    if (imageArr.count>0&&model.textContent.length!=0) {
        model.msgType = @2;
    }else if(imageArr.count==0&&model.textContent.length!=0){
        model.msgType = @0;
    }else if(imageArr.count!=0&&model.textContent.length==0){
        model.msgType = @1;
    }else{
        NSLog(@"必须有内容才能发送");
        [MBProgressHUD showError:@"必须有内容才能发送"];
        return;
    }
    self.uploadModel = model;
    NSString *textContent = dic[@"textContent"];
    //TODO 掉接口传值
    DefLog(@"textContent:%@",textContent);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak __typeof(self)weakSelf = self;
    [NetService bg_postWithTokenWithPath:@"/insertAdvice" params:@{@"fContent":textContent} success:^(id respObjc) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        DefLog(@"%@",respObjc);
        [MBProgressHUD showSuccess:DefLocalizedString(@"Successfulsubmission")];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(id respObjc, NSString *errorCode, NSString *errorMsg) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        [MBProgressHUD showError:@"提交失败，请检查网络"];
    }];
}
@end
