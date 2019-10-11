//
//  BGQMPersonalInfoViewController.m
//  变电所运维
//
//  Created by Acrel on 2019/8/5.
//

#import "BGQMPersonalInfoViewController.h"
#import "BGRedSpotCell.h"
#import "BGQMSettingPersonInfoViewController.h"

@interface BGQMPersonalInfoViewController ()

@end

@implementation BGQMPersonalInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView registerNib:[UINib nibWithNibName:@"BGRedSpotCell" bundle:nil] forCellReuseIdentifier:@"BGRedSpotCell"];
    self.title =  DefLocalizedString(@"PersonalInfo");;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - <QMUITableViewDataSource, QMUITableViewDelegate>

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        BGRedSpotCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGRedSpotCell"];
        UserManager *user = [UserManager manager];
        switch (indexPath.row) {
            case 0:
                cell.leftLB.text = DefLocalizedString(@"nickname");
                [cell.iconIV setImage:[UIImage imageNamed:@"userOwnPic0"]];
                cell.rightLB.text = user.bgnickName;
                break;
            case 1:
                cell.leftLB.text = DefLocalizedString(@"tel");
                [cell.iconIV setImage:[UIImage imageNamed:@"userOwnPic1"]];
                cell.rightLB.text = user.bgtelphone;
                break;
            case 2:
                cell.leftLB.text = DefLocalizedString(@"address");
                [cell.iconIV setImage:[UIImage imageNamed:@"userOwnPic2"]];
                cell.rightLB.text = user.bgaddress;
                break;
        
                //                cell.textLabel.text = @"系统设置";
                //                break;
                //            case 6:
                //                cell.textLabel.text = @"更换主题";
                //                break;
            default:
                break;
        }
    cell.redSpotBTN.hidden =YES;
        return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BGRedSpotCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    BGQMSettingPersonInfoViewController *settingVC = [[BGQMSettingPersonInfoViewController alloc] init];
    settingVC.uploadType = indexPath.row;
    settingVC.settingName = cell.leftLB.text;
    settingVC.settingChangeStr = cell.rightLB.text;
    [self.navigationController pushViewController:settingVC animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
