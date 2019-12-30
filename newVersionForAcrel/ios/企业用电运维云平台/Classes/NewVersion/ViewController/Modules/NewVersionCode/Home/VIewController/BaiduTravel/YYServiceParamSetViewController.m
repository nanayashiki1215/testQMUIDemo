//
//  YYServiceParamSetViewController.m
//  YYObjCDemo
//
//  Created by Daniel Bey on 2017年06月16日.
//  Copyright © 2017 百度鹰眼. All rights reserved.
//


#import "YYServiceParamSetViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface YYServiceParamSetViewController ()

/**
 保存按钮，参数设置完成后，点击此按钮
 */
@property (nonatomic, strong) UIBarButtonItem *saveParamButton;
@property (nonatomic, strong) YYServiceParam *paramInfo;
@property (nonatomic, copy) NSArray * sectionTitles;
@property (nonatomic, strong) UIPickerView *gatherIntervalPicker;
@property (nonatomic, strong) UIPickerView *packIntervalPicker;
@property (nonatomic, strong) UITextField *entityNameTextField;
@property (nonatomic, strong) UIPickerView *activityTypePicker;
@property (nonatomic, strong) UIPickerView *desiredAccuracyPicker;
@property (nonatomic, strong) UITextField *distanceFilterTextField;
@property (nonatomic, strong) UISwitch *keepAliveSwitch;
@property (nonatomic, strong) UIPickerView *distanceFilterPicker;

@property (nonatomic, copy) NSArray *gatherIntervalDataSource;
@property (nonatomic, copy) NSArray *packIntervalDataSource;
@property (nonatomic, copy) NSArray *activityTypeDataSource;
@property (nonatomic, copy) NSArray *desiredAccuracyDataSource;
@property (nonatomic, copy) NSArray *distanceFilterDataSource;

-(void)showGatherIntervalPickerCell;
-(void)hideGatherIntervalPickerCell;
-(void)showPackIntervalPickerCell;
-(void)hidePackIntervalPickerCell;
-(void)showActivityTypePickerCell;
-(void)hideActivityTypePickerCell;
-(void)showDesiredAccuracyPickerCell;
-(void)hideDesiredAccuracyPickerCell;
-(void)showDistanceFilterCell;
-(void)hideDistanceFilterCell;


@end


static NSString * const kServiceParamPickerViewCellIdentifier = @"kServiceParamPickerViewCellIdentifier";
static NSString * const kServiceParamDefaultCellIdentifier = @"kServiceParamDefaultCellIdentifier";
static NSString * const kServiceParamTextFieldCellIdentifier = @"kServiceParamTextFieldCellIdentifier";
static NSString * const kServiceParamUISwitchCellIdentifier = @"kServiceParamUISwitchCellIdentifier";

@implementation YYServiceParamSetViewController

-(instancetype)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {

    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void)setupUI {
    self.navigationItem.title = @"服务基础信息设置";
    self.navigationItem.rightBarButtonItem = self.saveParamButton;
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionTitles.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 24;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionTitles[section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight = tableView.rowHeight;
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 1:
                    rowHeight = self.gatherIntervalPicker.hidden ? 0 : kTableViewCellPickerViewHeight;
                    break;
                case 3:
                    rowHeight = self.packIntervalPicker.hidden ? 0 : kTableViewCellPickerViewHeight;
                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 1:
                    rowHeight = self.activityTypePicker.hidden ? 0 : kTableViewCellPickerViewHeight;
                    break;
                case 3:
                    rowHeight = self.desiredAccuracyPicker.hidden ? 0 : kTableViewCellPickerViewHeight;
                    break;
                case 5:
                    rowHeight = self.distanceFilterPicker.hidden ? 0 : kTableViewCellPickerViewHeight;
                    break;
                default:
                    break;
            }
        default:
            break;
    }
    return rowHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 4;
        case 1:
            return 1;
        case 2:
            return 6;
        case 3:
            return 1;
        default:
            return 1;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kServiceParamDefaultCellIdentifier];
            if (nil == cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kServiceParamDefaultCellIdentifier];
            }
            cell.textLabel.text = @"点击设置采集周期";
            return cell;
        } else if (row == 1) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kServiceParamPickerViewCellIdentifier];
            if (nil == cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kServiceParamPickerViewCellIdentifier];
            }
            [cell addSubview:self.gatherIntervalPicker];
            return cell;
        } else if (row == 2) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kServiceParamDefaultCellIdentifier];
            if (nil == cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kServiceParamDefaultCellIdentifier];
            }
            cell.textLabel.text = @"点击设置上传周期";
            return cell;
        } else if (row == 3) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kServiceParamPickerViewCellIdentifier];
            if (nil == cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kServiceParamPickerViewCellIdentifier];
            }
            [cell addSubview:self.packIntervalPicker];
            return cell;
        } else {
            return nil;
        }
    } else if (section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kServiceParamTextFieldCellIdentifier];
        if (nil == cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kServiceParamTextFieldCellIdentifier];
        }
        [cell.contentView addSubview:self.entityNameTextField];
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.entityNameTextField
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:cell.contentView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1.0
                                                                      constant:0]
         ];
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.entityNameTextField
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:cell.contentView
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1.0
                                                                      constant:20]
         ];
        return cell;
    } else if (section == 2) {
        if (row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kServiceParamDefaultCellIdentifier];
            if (nil == cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kServiceParamDefaultCellIdentifier];
            }
            cell.textLabel.text = @"点击设置活动类型";
            return cell;
        } else if (row == 1) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kServiceParamPickerViewCellIdentifier];
            if (nil == cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kServiceParamPickerViewCellIdentifier];
            }
            [cell.contentView addSubview:self.activityTypePicker];
            return cell;
        } else if (row == 2) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kServiceParamDefaultCellIdentifier];
            if (nil == cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kServiceParamDefaultCellIdentifier];
            }
            cell.textLabel.text = @"点击设置定位精度";
            return cell;
        } else if (row == 3) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kServiceParamPickerViewCellIdentifier];
            if (nil == cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kServiceParamPickerViewCellIdentifier];
            }
            [cell.contentView addSubview:self.desiredAccuracyPicker];
            return cell;
        } else if (row == 4) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kServiceParamDefaultCellIdentifier];
            if (nil == cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kServiceParamDefaultCellIdentifier];
            }
            cell.textLabel.text = @"点击设置触发定位的距离阀值";
            return cell;
        } else if (row == 5) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kServiceParamPickerViewCellIdentifier];
            if (nil == cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kServiceParamPickerViewCellIdentifier];
            }
            [cell.contentView addSubview:self.distanceFilterPicker];
            return cell;
        } else {
            return nil;
        }
    } else if (section == 3) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kServiceParamUISwitchCellIdentifier];
        if (nil == cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kServiceParamUISwitchCellIdentifier];
        }
        cell.textLabel.text = @"开启保活后，将始终访问位置";
        [cell.contentView addSubview:self.keepAliveSwitch];
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.keepAliveSwitch
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:cell.contentView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1.0
                                                                      constant:0]
         ];
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.keepAliveSwitch
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:cell.contentView
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1.0
                                                                      constant:-20]
         ];
        return cell;
    } else {
        return nil;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    self.gatherIntervalPicker.hidden ? [self showGatherIntervalPickerCell] : [self hideGatherIntervalPickerCell];
                    break;
                case 2:
                    self.packIntervalPicker.hidden ? [self showPackIntervalPickerCell] : [self hidePackIntervalPickerCell];
                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    self.activityTypePicker.hidden ? [self showActivityTypePickerCell] : [self hideActivityTypePickerCell];
                    break;
                case 2:
                    self.desiredAccuracyPicker.hidden ? [self showDesiredAccuracyPickerCell] : [self hideDesiredAccuracyPickerCell];
                    break;
                case 4:
                    self.distanceFilterPicker.hidden ? [self showDistanceFilterCell] : [self hideDistanceFilterCell];
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}



#pragma mark - UIPickerViewDelegate & UIPickerViewDataSource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger num = 1;
    switch (pickerView.tag) {
        case YY_SERVICE_PARAM_GATHER_INTEVAL_PICKER:
            num = self.gatherIntervalDataSource.count;
            break;
        case YY_SERVICE_PARAM_PACK_INTEVAL_PICKER:
            num = self.packIntervalDataSource.count;
            break;
        case YY_SERVICE_PARAM_ACTIVITY_TYPE_PICKER:
            num = self.activityTypeDataSource.count;
            break;
        case YY_SERVICE_PARAM_DESIRED_ACCURACY_PICKER:
            num = self.desiredAccuracyDataSource.count;
            break;
        case YY_SERVICE_PARAM_DISTANCE_FILTER_PICKER:
            num = self.distanceFilterDataSource.count;
            break;
        default:
            break;
    }
    return num;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (pickerView.tag) {
        case YY_SERVICE_PARAM_GATHER_INTEVAL_PICKER:
            return [NSString stringWithFormat:@"%@秒", self.gatherIntervalDataSource[row]];
        case YY_SERVICE_PARAM_PACK_INTEVAL_PICKER:
            return [NSString stringWithFormat:@"%@秒", self.packIntervalDataSource[row]];
        case YY_SERVICE_PARAM_ACTIVITY_TYPE_PICKER:
            return [NSString stringWithString:self.activityTypeDataSource[row]];
        case YY_SERVICE_PARAM_DESIRED_ACCURACY_PICKER:
            return self.desiredAccuracyDataSource[row];
        case YY_SERVICE_PARAM_DISTANCE_FILTER_PICKER:
            return [NSString stringWithFormat:@"%@秒", self.distanceFilterDataSource[row]];
        default:
            return @"";
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (pickerView.tag) {
        case YY_SERVICE_PARAM_GATHER_INTEVAL_PICKER:
            if (row < self.gatherIntervalDataSource.count) {
                self.paramInfo.gatherInterval = [self.gatherIntervalDataSource[row] unsignedIntValue];
            }
            break;
        case YY_SERVICE_PARAM_PACK_INTEVAL_PICKER:
            if (row < self.packIntervalDataSource.count) {
                self.paramInfo.packInterval = [self.packIntervalDataSource[row] unsignedIntValue];
            }
            break;
        case YY_SERVICE_PARAM_ACTIVITY_TYPE_PICKER:
            switch (row) {
                case 0:
                    self.paramInfo.activityType = CLActivityTypeFitness;
                    break;
                case 1:
                    self.paramInfo.activityType = CLActivityTypeAutomotiveNavigation;
                    break;
                case 2:
                    self.paramInfo.activityType = CLActivityTypeOtherNavigation;
                    break;
                case 3:
                    self.paramInfo.activityType = CLActivityTypeOther;
                    break;
                default:
                    break;
            }
            break;
        case YY_SERVICE_PARAM_DESIRED_ACCURACY_PICKER:
            switch (row) {
                case 0:
                    self.paramInfo.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
                    break;
                case 1:
                    self.paramInfo.desiredAccuracy = kCLLocationAccuracyBest;
                    break;
                case 2:
                    self.paramInfo.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
                    break;
                case 3:
                    self.paramInfo.desiredAccuracy = kCLLocationAccuracyHundredMeters;
                    break;
                case 4:
                    self.paramInfo.desiredAccuracy = kCLLocationAccuracyKilometer;
                    break;
                case 5:
                    self.paramInfo.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
                    break;
                default:
                    break;
            }
            break;
        case YY_SERVICE_PARAM_DISTANCE_FILTER_PICKER:
            if (row < self.distanceFilterDataSource.count) {
                self.paramInfo.distanceFilter = [self.distanceFilterDataSource[row] doubleValue];
            }
            break;
        default:
            break;
    }
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    self.paramInfo.entityName = textField.text;
    [USER_DEFAULTS setObject:textField.text forKey:ENTITY_NAME];
    [USER_DEFAULTS synchronize];
}

#pragma mark - event response
-(void)saveParam {
    self.paramInfo.entityName = self.entityNameTextField.text;
    //entityName必须设置，因为鹰眼SDK会以此entityName的名义登录到鹰眼服务端，本设备采集到的轨迹信息也都算在此entityName的名下
    if (self.paramInfo.entityName == nil || self.paramInfo.entityName.length == 0) {
        dispatch_async(MAIN_QUEUE, ^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"entityName必须设置" message:@"鹰眼SDK以此entityName的名义登录到服务端，SDK采集到的轨迹信息也算在此entityName的名下" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:defaultAction];
            [self presentViewController:alertController animated:YES completion:nil];
        });
        return;
    } else {
        [USER_DEFAULTS setObject:self.entityNameTextField.text forKey:ENTITY_NAME];
        [USER_DEFAULTS synchronize];
        [[[UIApplication sharedApplication] keyWindow] endEditing:TRUE];
    }
    
    if (self.block) {
        self.block(self.paramInfo);
    }
    dispatch_async(MAIN_QUEUE, ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

-(void)keepAliveSwitchValueChanged:(UISwitch *)switchButton {
    self.paramInfo.keepAlive = switchButton.on;
}


#pragma mark - private functions

-(void)showGatherIntervalPickerCell {
    self.gatherIntervalPicker.hidden = FALSE;
    self.gatherIntervalPicker.alpha = 0;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView animateWithDuration:kTableViewCellAnimationShowDuration animations:^{
        self.gatherIntervalPicker.alpha = 1;
    }];
}

-(void)hideGatherIntervalPickerCell {
    self.gatherIntervalPicker.alpha = 1;
    [UIView animateWithDuration:kTableViewCellAnimationHideDuration animations:^{
        self.gatherIntervalPicker.alpha = 0;
    } completion:^(BOOL finished) {
        self.gatherIntervalPicker.hidden = TRUE;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }];
}

-(void)showPackIntervalPickerCell {
    self.packIntervalPicker.hidden = FALSE;
    self.packIntervalPicker.alpha = 0;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView animateWithDuration:kTableViewCellAnimationShowDuration animations:^{
        self.packIntervalPicker.alpha = 1;
    }];
}

-(void)hidePackIntervalPickerCell {
    self.packIntervalPicker.alpha = 1;
    [UIView animateWithDuration:kTableViewCellAnimationHideDuration animations:^{
        self.packIntervalPicker.alpha = 0;
    } completion:^(BOOL finished) {
        self.packIntervalPicker.hidden = TRUE;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }];
}

-(void)showActivityTypePickerCell {
    self.activityTypePicker.hidden = FALSE;
    self.activityTypePicker.alpha = 0;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView animateWithDuration:kTableViewCellAnimationShowDuration animations:^{
        self.activityTypePicker.alpha = 1;
    }];
}

-(void)hideActivityTypePickerCell {
    self.activityTypePicker.alpha = 1;
    [UIView animateWithDuration:kTableViewCellAnimationHideDuration animations:^{
        self.activityTypePicker.alpha = 0;
    } completion:^(BOOL finished) {
        self.activityTypePicker.hidden = TRUE;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }];
}

-(void)showDesiredAccuracyPickerCell {
    self.desiredAccuracyPicker.hidden = FALSE;
    self.desiredAccuracyPicker.alpha = 0;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView animateWithDuration:kTableViewCellAnimationShowDuration animations:^{
        self.desiredAccuracyPicker.alpha = 1;
    }];
}

-(void)hideDesiredAccuracyPickerCell {
    self.desiredAccuracyPicker.alpha = 1;
    [UIView animateWithDuration:kTableViewCellAnimationHideDuration animations:^{
        self.desiredAccuracyPicker.alpha = 0;
    } completion:^(BOOL finished) {
        self.desiredAccuracyPicker.hidden = TRUE;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }];
}

-(void)showDistanceFilterCell {
    self.distanceFilterPicker.hidden = FALSE;
    self.distanceFilterPicker.alpha = 0;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView animateWithDuration:kTableViewCellAnimationShowDuration animations:^{
        self.distanceFilterPicker.alpha = 1;
    }];
}

-(void)hideDistanceFilterCell {
    self.distanceFilterPicker.alpha = 1;
    [UIView animateWithDuration:kTableViewCellAnimationHideDuration animations:^{
        self.distanceFilterPicker.alpha = 0;
    } completion:^(BOOL finished) {
        self.distanceFilterPicker.hidden = TRUE;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }];
}


#pragma mark - setter & getter
-(UIBarButtonItem *)saveParamButton {
    if (_saveParamButton == nil) {
        _saveParamButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveParam)];
    }
    return _saveParamButton;
}

-(YYServiceParam *)paramInfo {
    if (_paramInfo == nil) {
        _paramInfo = [[YYServiceParam alloc] init];
        //设置默认值
        _paramInfo.gatherInterval = 5;
        _paramInfo.packInterval = 30;
        _paramInfo.activityType = CLActivityTypeAutomotiveNavigation;
        _paramInfo.desiredAccuracy = kCLLocationAccuracyBest;
        _paramInfo.distanceFilter = kCLDistanceFilterNone;
    }
    return _paramInfo;
}

-(NSArray *)sectionTitles {
    if (_sectionTitles == nil) {
        _sectionTitles = @[@"间隔设置",
                           @"Entity设置",
                           @"定位选项",
                           @"保活"];
    }
    return _sectionTitles;
}

-(UIPickerView *)gatherIntervalPicker {
    if (_gatherIntervalPicker == nil) {
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, kTableViewCellPickerViewHeight);
        _gatherIntervalPicker = [[UIPickerView alloc] initWithFrame:rect];
        _gatherIntervalPicker.translatesAutoresizingMaskIntoConstraints = FALSE;
        _gatherIntervalPicker.tag = YY_SERVICE_PARAM_GATHER_INTEVAL_PICKER;
        _gatherIntervalPicker.hidden = TRUE;
        _gatherIntervalPicker.delegate = self;
        _gatherIntervalPicker.dataSource = self;
        [_gatherIntervalPicker selectRow:1 inComponent:0 animated:TRUE];
    }
    return _gatherIntervalPicker;
}

-(UIPickerView *)packIntervalPicker {
    if (_packIntervalPicker == nil) {
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, kTableViewCellPickerViewHeight);
        _packIntervalPicker = [[UIPickerView alloc] initWithFrame:rect];
        _packIntervalPicker.translatesAutoresizingMaskIntoConstraints = FALSE;
        _packIntervalPicker.tag = YY_SERVICE_PARAM_PACK_INTEVAL_PICKER;
        _packIntervalPicker.hidden = TRUE;
        _packIntervalPicker.delegate = self;
        _packIntervalPicker.dataSource = self;
        [_packIntervalPicker selectRow:1 inComponent:0 animated:TRUE];
    }
    return _packIntervalPicker;
}

-(UITextField *)entityNameTextField {
    if (_entityNameTextField == nil) {
        _entityNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH / 2, 30)];
        NSString *entityNameStored = [USER_DEFAULTS objectForKey:ENTITY_NAME];
        if (nil == entityNameStored || entityNameStored.length == 0) {
            _entityNameTextField.placeholder = @"输入entityName";
        } else {
            _entityNameTextField.placeholder = entityNameStored;
            _entityNameTextField.text = entityNameStored;
        }
        _entityNameTextField.layer.borderColor = [[UIColor blackColor] CGColor];
        _entityNameTextField.translatesAutoresizingMaskIntoConstraints = FALSE;
        _entityNameTextField.delegate = self;
        _entityNameTextField.returnKeyType = UIReturnKeyDone;
    }
    return _entityNameTextField;
}

-(UIPickerView *)activityTypePicker {
    if (_activityTypePicker == nil) {
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, kTableViewCellPickerViewHeight);
        _activityTypePicker = [[UIPickerView alloc] initWithFrame:rect];
        _activityTypePicker.translatesAutoresizingMaskIntoConstraints = FALSE;
        _activityTypePicker.tag = YY_SERVICE_PARAM_ACTIVITY_TYPE_PICKER;
        _activityTypePicker.hidden = TRUE;
        _activityTypePicker.delegate = self;
        _activityTypePicker.dataSource = self;
        [_activityTypePicker selectRow:1 inComponent:0 animated:TRUE];
    }
    return _activityTypePicker;
}

-(UIPickerView *)desiredAccuracyPicker {
    if (_desiredAccuracyPicker == nil) {
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, kTableViewCellPickerViewHeight);
        _desiredAccuracyPicker = [[UIPickerView alloc] initWithFrame:rect];
        _desiredAccuracyPicker.translatesAutoresizingMaskIntoConstraints = FALSE;
        _desiredAccuracyPicker.tag = YY_SERVICE_PARAM_DESIRED_ACCURACY_PICKER;
        _desiredAccuracyPicker.hidden = TRUE;
        _desiredAccuracyPicker.delegate = self;
        _desiredAccuracyPicker.dataSource = self;
        [_desiredAccuracyPicker selectRow:0 inComponent:0 animated:TRUE];
    }
    return _desiredAccuracyPicker;
}

-(UIPickerView *)distanceFilterPicker {
    if (_distanceFilterPicker == nil) {
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, kTableViewCellPickerViewHeight);
        _distanceFilterPicker = [[UIPickerView alloc] initWithFrame:rect];
        _distanceFilterPicker.translatesAutoresizingMaskIntoConstraints = FALSE;
        _distanceFilterPicker.tag = YY_SERVICE_PARAM_DISTANCE_FILTER_PICKER;
        _distanceFilterPicker.hidden = TRUE;
        _distanceFilterPicker.delegate = self;
        _distanceFilterPicker.dataSource = self;
        [_distanceFilterPicker selectRow:0 inComponent:0 animated:TRUE];
    }
    return _distanceFilterPicker;
}

-(UISwitch *)keepAliveSwitch {
    if (_keepAliveSwitch == nil) {
        _keepAliveSwitch = [[UISwitch alloc] init];
        _keepAliveSwitch.on = FALSE;
        _keepAliveSwitch.translatesAutoresizingMaskIntoConstraints = FALSE;
        [_keepAliveSwitch addTarget:self action:@selector(keepAliveSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _keepAliveSwitch;
}

-(NSArray *)gatherIntervalDataSource {
    if (_gatherIntervalDataSource == nil) {
        // 采集周期值域为[2,300]
        _gatherIntervalDataSource = @[@2, @5, @10];
    }
    return _gatherIntervalDataSource;
}

-(NSArray *)packIntervalDataSource {
    if (_packIntervalDataSource == nil) {
        // 上传周期值域为[2,300]，且必须是采集周期的整数倍
        _packIntervalDataSource = @[@10, @30, @60, @100];
    }
    return _packIntervalDataSource;
}


-(NSArray *)activityTypeDataSource {
    if (_activityTypeDataSource == nil) {
        _activityTypeDataSource = @[@"步行、骑行、跑步", @"驾车", @"火车、飞机", @"其他类型"];
    }
    return _activityTypeDataSource;
}

-(NSArray *)desiredAccuracyDataSource {
    if (_desiredAccuracyDataSource == nil) {
        _desiredAccuracyDataSource = @[@"最高精度（插电才有效）", @"米级", @"十米级别", @"百米级别", @"公里级别", @"最低精度"];
    }
    return _desiredAccuracyDataSource;
}

-(NSArray *)distanceFilterDataSource {
    if (_distanceFilterDataSource == nil) {
        _distanceFilterDataSource = @[@1, @10, @100, @500];
    }
    return _distanceFilterDataSource;
}

@end
