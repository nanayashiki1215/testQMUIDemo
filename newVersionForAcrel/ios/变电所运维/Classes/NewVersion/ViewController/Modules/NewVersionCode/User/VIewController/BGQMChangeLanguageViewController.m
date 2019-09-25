//
//  BGQMChangeLanguageViewController.m
//  变电所运维
//
//  Created by Acrel on 2019/8/22.
//

#import "BGQMChangeLanguageViewController.h"
#import "NSBundle+Language.h"
#import "QDTabBarViewController.h"
#import "BGQMUserViewController.h"

@interface BGQMChangeLanguageViewController ()
@property(nonatomic, copy) NSArray *dataSource;

@end

@implementation BGQMChangeLanguageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UserManager *user = [UserManager manager];
    if (!user.selectlanageArr.count) {
        user.selectlanageArr = @[@{@"name":@"简体中文",@"click":@"1",@"id":@"1"},
                                 @{@"name":@"English",@"click":@"0",@"id":@"2"}];
    }
    self.dataSource = user.selectlanageArr;
    self.title = DefLocalizedString(@"ChangeLanguage");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:DefLocalizedString(@"Save") style:UIBarButtonItemStylePlain target:self action:@selector(saveLanguage)];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"languageCell";
    QMUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[QMUITableViewCell alloc] initForTableView:tableView withReuseIdentifier:identifier];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }
    NSString *nameStr;
    if ([self.dataSource[indexPath.row][@"id"] integerValue] == 1) {
        nameStr = DefLocalizedString(@"Chinese-simple");
        cell.textLabel.text = nameStr;
    }else{
        cell.textLabel.text = self.dataSource[indexPath.row][@"name"];
    }
    NSString *clickStr = self.dataSource[indexPath.row][@"click"];
    if ([clickStr integerValue] == 1) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [cell updateCellAppearanceWithIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    QMUITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSMutableArray *array = [NSMutableArray new];
    for (int clickNum = 0; clickNum < self.dataSource.count; clickNum++) {
        NSMutableDictionary *mutDic = [self.dataSource[clickNum] mutableCopy];
        mutDic[@"click"] = @"0";
        [array addObject:mutDic];
    }
    array[indexPath.row][@"click"] = @"1";
    self.dataSource = [array copy];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [QMUITips showWithText:[NSString stringWithFormat:@"点击了第 %@ 行的按钮", @(indexPath.row)] inView:self.view hideAfterDelay:1.2];
}

-(void)saveLanguage{
    UserManager *user = [UserManager manager];
    user.selectlanageArr = self.dataSource;
    NSString *languageId;
    for (NSDictionary *dic in self.dataSource) {
        if ([dic[@"click"] integerValue] == 1) {
            languageId = dic[@"id"];
        }
    }
    if ([languageId integerValue] == 1) {
        [self changeLanguageTo:@"zh-Hans"];
    } else {
        [self changeLanguageTo:@"en"];
//        [self changeLanguageTo:@"English"];
    }
}

- (void)changeLanguageTo:(NSString *)language {
    // 设置语言
    [NSBundle setLanguage:language];
    
    // 然后将设置好的语言存储好，下次进来直接加载
    [[NSUserDefaults standardUserDefaults] setObject:language forKey:@"myLanguage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 我们要把系统windown的rootViewController替换掉
    QDTabBarViewController *tab = [[QDTabBarViewController alloc] init];
    [UIApplication sharedApplication].keyWindow.rootViewController = tab;
    // 跳转到设置页
    NSInteger selectCount = 0;
    for (int count = 0; count<tab.viewControllers.count; count++) {
        UINavigationController *vc = tab.viewControllers[count];
        if ([vc.topViewController isKindOfClass:[BGQMUserViewController class]]) {
            selectCount = count;
        }
    }
    tab.selectedIndex = selectCount;
    BGQMChangeLanguageViewController *changLangeVC = [[BGQMChangeLanguageViewController alloc] init];
    [tab.navigationController pushViewController:changLangeVC animated:YES];
    
}

@end
