//
//  YYHistoryTrackParamSetTableViewController.m
//  YYObjCDemo
//
//  Created by Daniel Bey on 2017年06月16日.
//  Copyright © 2017 百度鹰眼. All rights reserved.
//

#import "YYHistoryTrackParamSetTableViewController.h"

@interface YYHistoryTrackParamSetTableViewController ()

@property (nonatomic, strong) UIBarButtonItem *saveParamButton;
@property (nonatomic, strong) YYHistoryTrackParam *paramInfo;
@property (nonatomic, copy) NSArray *sectionTitles;
@property (nonatomic, strong) UITextField *entityNameTextField;
@property (nonatomic, strong) UIDatePicker *startTimePicker;
@property (nonatomic, strong) UIDatePicker *endTimePicker;
@property (nonatomic, strong) UIPickerView *radiusThresholdPicker;
@property (nonatomic, strong) UIPickerView *transportModePicker;
@property (nonatomic, strong) UIPickerView *supplementModePicker;
@property (nonatomic, strong) UISwitch *isProcessSwitch;
@property (nonatomic, strong) UISwitch *denoiseSwitch;
@property (nonatomic, strong) UISwitch *vacuateSwitch;
@property (nonatomic, strong) UISwitch *mapMatchSwitch;
@property (nonatomic, strong) NSArray *radiusThresholdPickerDataSource;
@property (nonatomic, strong) NSArray *transportModePickerDataSource;
@property (nonatomic, strong) NSArray *supplementModePickerDataSource;
@end

static NSString * const kHistoryTrackParamPickerViewCellIdentifier = @"kHistoryTrackParamPickerViewCellIdentifier";
static NSString * const kHistoryTrackParamDefaultCellIdentifier = @"kHistoryTrackParamDefaultCellIdentifier";
static NSString * const kHistoryTrackParamTextFieldCellIdentifier = @"kHistoryTrackParamTextFieldCellIdentifier";
static NSString * const kHistoryTrackParamUISwitchCellIdentifier = @"kHistoryTrackParamUISwitchCellIdentifier";


@implementation YYHistoryTrackParamSetTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(instancetype)init {
    return [super initWithStyle:UITableViewStyleGrouped];
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}

#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionTitles.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kHeightForHeaderInSection;
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
                    rowHeight = self.startTimePicker.hidden ? 0 : kTableViewCellPickerViewHeight;
                    break;
                case 3:
                    rowHeight = self.endTimePicker.hidden ? 0 : kTableViewCellPickerViewHeight;
                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 1:
                case 2:
                case 3:
                case 4:
                case 6:
                    rowHeight = self.isProcessSwitch.on ? rowHeight : 0;
                    break;
                case 5:
                    rowHeight = self.isProcessSwitch.on && !self.radiusThresholdPicker.hidden ? kTableViewCellPickerViewHeight : 0;
                    break;
                case 7:
                    rowHeight = self.isProcessSwitch.on && !self.transportModePicker.hidden ? kTableViewCellPickerViewHeight : 0;
                    break;
                default:
                    break;
            }
            break;
        case 3:
            if (indexPath.row == 1) {
                rowHeight = self.supplementModePicker.hidden ? 0 : kTableViewCellPickerViewHeight;
            }
            break;
        default:
            break;
    }
    return rowHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
//        case 0:
//            return 1;
        case 0:
            return 4;
//        case 2:
//            return 8;
//        case 3:
//            return 2;
//        default:
//            return 1;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
//    if (section == 0) {
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kHistoryTrackParamTextFieldCellIdentifier];
//        if (nil == cell) {
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kHistoryTrackParamTextFieldCellIdentifier];
//        }
//        [cell.contentView addSubview:self.entityNameTextField];
//        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.entityNameTextField
//                                                                     attribute:NSLayoutAttributeCenterY
//                                                                     relatedBy:NSLayoutRelationEqual
//                                                                        toItem:cell.contentView
//                                                                     attribute:NSLayoutAttributeCenterY
//                                                                    multiplier:1.0
//                                                                      constant:0]
//         ];
//        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.entityNameTextField
//                                                                     attribute:NSLayoutAttributeLeft
//                                                                     relatedBy:NSLayoutRelationEqual
//                                                                        toItem:cell.contentView
//                                                                     attribute:NSLayoutAttributeLeft
//                                                                    multiplier:1.0
//                                                                      constant:20]
//         ];
//        return cell;
//    } else
        if (section == 0) {
        if (row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kHistoryTrackParamDefaultCellIdentifier];
            if (nil == cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kHistoryTrackParamDefaultCellIdentifier];
            }
            cell.textLabel.text = @"点击设置起始时间";
            return cell;
        } else if (row == 1) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kHistoryTrackParamPickerViewCellIdentifier];
            if (nil == cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kHistoryTrackParamPickerViewCellIdentifier];
            }
            [cell addSubview:self.startTimePicker];
            return cell;
        } else if (row == 2) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kHistoryTrackParamDefaultCellIdentifier];
            if (nil == cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kHistoryTrackParamDefaultCellIdentifier];
            }
            cell.textLabel.text = @"点击设置截止时间";
            return cell;
        } else if (row == 3) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kHistoryTrackParamPickerViewCellIdentifier];
            if (nil == cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kHistoryTrackParamPickerViewCellIdentifier];
            }
            [cell addSubview:self.endTimePicker];
            return cell;
        } else {
            return nil;
        }
    }
//        else if (section == 2) {
//        if (row == 0) {
//            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kHistoryTrackParamUISwitchCellIdentifier];
//            if (nil == cell) {
//                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kHistoryTrackParamUISwitchCellIdentifier];
//            }
//            cell.textLabel.text = @"是否返回纠偏后的轨迹";
//            [cell.contentView addSubview:self.isProcessSwitch];
//            [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.isProcessSwitch
//                                                                         attribute:NSLayoutAttributeCenterY
//                                                                         relatedBy:NSLayoutRelationEqual
//                                                                            toItem:cell.contentView
//                                                                         attribute:NSLayoutAttributeCenterY
//                                                                        multiplier:1.0
//                                                                          constant:0]
//             ];
//            [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.isProcessSwitch
//                                                                         attribute:NSLayoutAttributeRight
//                                                                         relatedBy:NSLayoutRelationEqual
//                                                                            toItem:cell.contentView
//                                                                         attribute:NSLayoutAttributeRight
//                                                                        multiplier:1.0
//                                                                          constant:-20]
//             ];
//            return cell;
//        } else if (row == 1) {
//            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kHistoryTrackParamUISwitchCellIdentifier];
//            if (nil == cell) {
//                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kHistoryTrackParamUISwitchCellIdentifier];
//            }
//            if (self.isProcessSwitch.on) {
//                cell.textLabel.text = @"是否去除明显的定位偏移点";
//                [cell.contentView addSubview:self.denoiseSwitch];
//                [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.denoiseSwitch
//                                                                             attribute:NSLayoutAttributeCenterY
//                                                                             relatedBy:NSLayoutRelationEqual
//                                                                                toItem:cell.contentView
//                                                                             attribute:NSLayoutAttributeCenterY
//                                                                            multiplier:1.0
//                                                                              constant:0]
//                 ];
//                [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.denoiseSwitch
//                                                                             attribute:NSLayoutAttributeRight
//                                                                             relatedBy:NSLayoutRelationEqual
//                                                                                toItem:cell.contentView
//                                                                             attribute:NSLayoutAttributeRight
//                                                                            multiplier:1.0
//                                                                              constant:-20]
//                 ];
//                cell.textLabel.hidden = FALSE;
//                for (UIView *view in cell.contentView.subviews) {
//                    view.hidden = FALSE;
//                }
//            } else {
//                for (UIView *view in cell.contentView.subviews) {
//                    view.hidden = TRUE;
//                }
//                cell.textLabel.hidden = TRUE;
//            }
//            return cell;
//        } else if (row == 2) {
//            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kHistoryTrackParamUISwitchCellIdentifier];
//            if (nil == cell) {
//                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kHistoryTrackParamUISwitchCellIdentifier];
//            }
//            if (self.isProcessSwitch.on) {
//                cell.textLabel.text = @"是否去处冗余的轨迹点";
//                [cell.contentView addSubview:self.vacuateSwitch];
//                [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.vacuateSwitch
//                                                                             attribute:NSLayoutAttributeCenterY
//                                                                             relatedBy:NSLayoutRelationEqual
//                                                                                toItem:cell.contentView
//                                                                             attribute:NSLayoutAttributeCenterY
//                                                                            multiplier:1.0
//                                                                              constant:0]
//                 ];
//                [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.vacuateSwitch
//                                                                             attribute:NSLayoutAttributeRight
//                                                                             relatedBy:NSLayoutRelationEqual
//                                                                                toItem:cell.contentView
//                                                                             attribute:NSLayoutAttributeRight
//                                                                            multiplier:1.0
//                                                                              constant:-20]
//                 ];
//                cell.textLabel.hidden = FALSE;
//                for (UIView *view in cell.contentView.subviews) {
//                    view.hidden = FALSE;
//                }
//            } else {
//                for (UIView *view in cell.contentView.subviews) {
//                    view.hidden = TRUE;
//                }
//                cell.textLabel.hidden = TRUE;
//            }
//            return cell;
//        } else if (row == 3) {
//            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kHistoryTrackParamUISwitchCellIdentifier];
//            if (nil == cell) {
//                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kHistoryTrackParamUISwitchCellIdentifier];
//
//            }
//            if (self.isProcessSwitch.on) {
//                cell.textLabel.text = @"是否将轨迹点绑定至道路";
//                [cell.contentView addSubview:self.mapMatchSwitch];
//                [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.mapMatchSwitch
//                                                                             attribute:NSLayoutAttributeCenterY
//                                                                             relatedBy:NSLayoutRelationEqual
//                                                                                toItem:cell.contentView
//                                                                             attribute:NSLayoutAttributeCenterY
//                                                                            multiplier:1.0
//                                                                              constant:0]
//                 ];
//                [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.mapMatchSwitch
//                                                                             attribute:NSLayoutAttributeRight
//                                                                             relatedBy:NSLayoutRelationEqual
//                                                                                toItem:cell.contentView
//                                                                             attribute:NSLayoutAttributeRight
//                                                                            multiplier:1.0
//                                                                              constant:-20]
//                 ];
//                cell.textLabel.hidden = FALSE;
//                for (UIView *view in cell.contentView.subviews) {
//                    view.hidden = FALSE;
//                }
//            } else {
//                for (UIView *view in cell.contentView.subviews) {
//                    view.hidden = TRUE;
//                }
//                cell.textLabel.hidden = TRUE;
//            }
//
//            return cell;
//        }  else if (row == 4) {
//            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kHistoryTrackParamDefaultCellIdentifier];
//            if (nil == cell) {
//                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kHistoryTrackParamDefaultCellIdentifier];
//            }
//            if (self.isProcessSwitch.on) {
//                cell.textLabel.hidden = FALSE;
//                cell.textLabel.text = @"点击设置定位精度过滤阀值";
//                for (UIView *view in cell.contentView.subviews) {
//                    view.hidden = FALSE;
//                }
//            } else {
//                for (UIView *view in cell.contentView.subviews) {
//                    view.hidden = TRUE;
//                }
//                cell.textLabel.hidden = TRUE;
//            }
//            return cell;
//        } else if (row == 5) {
//            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kHistoryTrackParamPickerViewCellIdentifier];
//            if (nil == cell) {
//                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kHistoryTrackParamPickerViewCellIdentifier];
//            }
//            [cell addSubview:self.radiusThresholdPicker];
//            return cell;
//        } else if (row == 6) {
//            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kHistoryTrackParamDefaultCellIdentifier];
//            if (nil == cell) {
//                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kHistoryTrackParamDefaultCellIdentifier];
//            }
//            if (self.isProcessSwitch.on) {
//                cell.textLabel.hidden = FALSE;
//                cell.textLabel.text = @"点击设置交通方式";
//                for (UIView *view in cell.contentView.subviews) {
//                    view.hidden = FALSE;
//                }
//            } else {
//                for (UIView *view in cell.contentView.subviews) {
//                    view.hidden = TRUE;
//                }
//                cell.textLabel.hidden = TRUE;
//            }
//            return cell;
//        } else if (row == 7) {
//            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kHistoryTrackParamPickerViewCellIdentifier];
//            if (nil == cell) {
//                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kHistoryTrackParamPickerViewCellIdentifier];
//            }
//            [cell addSubview:self.transportModePicker];
//            return cell;
//        } else {
//            return nil;
//        }
//    } else if (section == 3) {
//        if (row == 0) {
//            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kHistoryTrackParamDefaultCellIdentifier];
//            if (nil == cell) {
//                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kHistoryTrackParamDefaultCellIdentifier];
//            }
//            cell.textLabel.text = @"点击设置里程补偿方式";
//            return cell;
//        } else if (row == 1) {
//            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kHistoryTrackParamPickerViewCellIdentifier];
//            if (nil == cell) {
//                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kHistoryTrackParamPickerViewCellIdentifier];
//            }
//            [cell addSubview:self.supplementModePicker];
//            return cell;
//        } else {
//            return nil;
//        }
//    } else {
//        return nil;
//    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    self.startTimePicker.hidden ? [self showStartTimePickerCell] : [self hideStartTimePickerCell];
                    break;
                case 2:
                    self.endTimePicker.hidden ? [self showEndTimePickerCell] : [self hideEndTimePickerCell];
                    break;
                default:
                    break;
            }
            break;
//        case 2:
//            switch (indexPath.row) {
//                case 4:
//                    self.radiusThresholdPicker.hidden ? [self showRadiusThresholdPickerCell] : [self hideRadiusThresholdPickerCell];
//                    break;
//                case 6:
//                    self.transportModePicker.hidden ? [self showTransportModePickerCell] : [self hideTransportModePickerCell];
//                default:
//                    break;
//            }
//        case 3:
//            if (indexPath.row == 0) {
//                self.supplementModePicker.hidden ? [self showSupplementModePickerCell] : [self hideSupplementModePickerCell];
//            }
//            break;
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}


#pragma mark - UIPickerViewDelegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger num = 1;
    switch (pickerView.tag) {
        case YY_HISTORY_TRACK_PARAM_RADIUS_THRESHOLD_PICKER:
            num = self.radiusThresholdPickerDataSource.count;
            break;
        case YY_HISTORY_TRACK_PARAM_TRANSPORT_MODE_PICKER:
            num = self.transportModePickerDataSource.count;
            break;
        case YY_HISTORY_TRACK_PARAM_SUPPLEMENT_MODE_PICKER:
            num = self.supplementModePickerDataSource.count;
            break;
        default:
            break;
    }
    return num;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (pickerView.tag) {
        case YY_HISTORY_TRACK_PARAM_RADIUS_THRESHOLD_PICKER:
            if (row == 0) {
                return @"保留所有定位点";
            } else if (row == 1) {
                return @"仅保留GPS定位点";
            } else if (row == 2) {
                return @"保留GPS和Wi-Fi定位点";
            } else {
                return @"";
            }
            break;
        case YY_HISTORY_TRACK_PARAM_TRANSPORT_MODE_PICKER:
            if (row == 0) {
                return @"步行";
            } else if (row == 1) {
                return @"骑行";
            } else if (row == 2){
                return @"驾车";
            } else {
                return @"";
            }
            break;
        case YY_HISTORY_TRACK_PARAM_SUPPLEMENT_MODE_PICKER:
            if (row == 0) {
                return @"不进行里程补偿";
            } else if (row == 1) {
                return @"使用直线距离补充";
            } else if (row == 2){
                return @"使用最短步行路线距离补充";
            } else if (row == 3) {
                return @"使用最短骑行路线距离补充";
            } else if (row == 4) {
                return @"使用最短驾车路线距离补充";
            } else {
                return @"";
            }
            break;
        default:
            return @"";
            break;
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (pickerView.tag) {
        case YY_HISTORY_TRACK_PARAM_RADIUS_THRESHOLD_PICKER:
            if (row < self.radiusThresholdPickerDataSource.count) {
                self.paramInfo.processOption.radiusThreshold = [self.radiusThresholdPickerDataSource[row] intValue];
            }
            break;
        case YY_HISTORY_TRACK_PARAM_TRANSPORT_MODE_PICKER:
            if (row < self.transportModePickerDataSource.count) {
                self.paramInfo.processOption.transportMode = (BTKTrackProcessOptionTransportMode)[self.transportModePickerDataSource[row] unsignedIntValue];
            }
            break;
        case YY_HISTORY_TRACK_PARAM_SUPPLEMENT_MODE_PICKER:
            if (row < self.supplementModePickerDataSource.count) {
                self.paramInfo.supplementMode = (BTKTrackProcessOptionSupplementMode)[self.supplementModePickerDataSource[row] unsignedIntValue];
            }
            break;
        default:
            break;
    }
}

#pragma mark - event response
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.entityNameTextField resignFirstResponder];
}

- (void)saveParam {
    // 校验设置的参数
    
    if (self.completionHandler) {
        self.completionHandler(self.paramInfo);
    }
    dispatch_async(MAIN_QUEUE, ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)startTimeSetted:(UIDatePicker *)datePicker {
    NSInteger startTime = datePicker.date.timeIntervalSince1970;
    [USER_DEFAULTS setInteger:startTime forKey:HISTORY_TRACK_START_TIME];
    self.paramInfo.startTime = startTime;
}

- (void)endTimeSetted:(UIDatePicker *)datePicker {
    NSInteger endTime = datePicker.date.timeIntervalSince1970;
    [USER_DEFAULTS setInteger:endTime forKey:HISTORY_TRACK_END_TIME];
    self.paramInfo.endTime = endTime;
}

- (void)isProcessSwitchValueChanged:(UISwitch *)switchButton {
    self.paramInfo.isProcessed = switchButton.on;
    [self.tableView reloadData];
}

- (void)denoiseSwitchValueChanged:(UISwitch *)switchButton {
    self.paramInfo.processOption.denoise = switchButton.on;
}

- (void)vacuateSwitchValueChanged:(UISwitch *)switchButton {
    self.paramInfo.processOption.vacuate = switchButton.on;
}

- (void)mapMatchSwitchValueChanged:(UISwitch *)switchButton {
    self.paramInfo.processOption.mapMatch = switchButton.on;
}

#pragma mark - private function
- (void)setupUI {
    self.navigationItem.title = @"查询参数设置";
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] init];
    backBarButtonItem.title = @"返回";
    self.navigationItem.rightBarButtonItem = self.saveParamButton;
}

- (void)showStartTimePickerCell {
    self.startTimePicker.hidden = FALSE;
    self.startTimePicker.alpha = 0;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView animateWithDuration:kTableViewCellAnimationShowDuration animations:^{
        self.startTimePicker.alpha = 1;
    }];
}

- (void)hideStartTimePickerCell {
    self.startTimePicker.alpha = 1;
    [UIView animateWithDuration:kTableViewCellAnimationHideDuration animations:^{
        self.startTimePicker.alpha = 0;
    } completion:^(BOOL finished) {
        self.startTimePicker.hidden = TRUE;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }];
}

- (void)showEndTimePickerCell {
    self.endTimePicker.hidden = FALSE;
    self.endTimePicker.alpha = 0;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView animateWithDuration:kTableViewCellAnimationShowDuration animations:^{
        self.endTimePicker.alpha = 1;
    }];
}

- (void)hideEndTimePickerCell {
    self.endTimePicker.alpha = 1;
    [UIView animateWithDuration:kTableViewCellAnimationHideDuration animations:^{
        self.endTimePicker.alpha = 0;
    } completion:^(BOOL finished) {
        self.endTimePicker.hidden = TRUE;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }];
}

- (void)showRadiusThresholdPickerCell {
    self.radiusThresholdPicker.hidden = FALSE;
    self.radiusThresholdPicker.alpha = 0;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView animateWithDuration:kTableViewCellAnimationShowDuration animations:^{
        self.radiusThresholdPicker.alpha = 1;
    }];
}

- (void)hideRadiusThresholdPickerCell {
    self.radiusThresholdPicker.alpha = 1;
    [UIView animateWithDuration:kTableViewCellAnimationHideDuration animations:^{
        self.radiusThresholdPicker.alpha = 0;
    } completion:^(BOOL finished) {
        self.radiusThresholdPicker.hidden = TRUE;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }];
}

- (void)showTransportModePickerCell {
    self.transportModePicker.hidden = FALSE;
    self.transportModePicker.alpha = 0;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView animateWithDuration:kTableViewCellAnimationShowDuration animations:^{
        self.transportModePicker.alpha = 1;
    }];
}

- (void)hideTransportModePickerCell {
    self.transportModePicker.alpha = 1;
    [UIView animateWithDuration:kTableViewCellAnimationHideDuration animations:^{
        self.transportModePicker.alpha = 0;
    } completion:^(BOOL finished) {
        self.transportModePicker.hidden = TRUE;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }];
}

- (void)showSupplementModePickerCell {
    self.supplementModePicker.hidden = FALSE;
    self.supplementModePicker.alpha = 0;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView animateWithDuration:kTableViewCellAnimationShowDuration animations:^{
        self.supplementModePicker.alpha = 1;
    }];
}

- (void)hideSupplementModePickerCell {
    self.supplementModePicker.alpha = 1;
    [UIView animateWithDuration:kTableViewCellAnimationHideDuration animations:^{
        self.supplementModePicker.alpha = 0;
    } completion:^(BOOL finished) {
        self.supplementModePicker.hidden = TRUE;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }];
}

#pragma mark - getter & setter
-(UIBarButtonItem *)saveParamButton {
    if (_saveParamButton == nil) {
        _saveParamButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveParam)];
    }
    return _saveParamButton;
}

-(YYHistoryTrackParam *)paramInfo {
    if (_paramInfo == nil) {
        _paramInfo = [[YYHistoryTrackParam alloc] init];
//        _paramInfo.entityName = @"311";会在YYHistoryTrackViewController中配置
        
                 // 配置默认值
                UserManager *tjuser = [UserManager manager];
                if (tjuser.yytjBaiduDic) {
                    NSDictionary *baiduDic = tjuser.yytjBaiduDic;
                    
                    _paramInfo.endTime = [self.endTimePicker.date timeIntervalSince1970];
                    _paramInfo.startTime = [self.startTimePicker.date timeIntervalSince1970];
                    _paramInfo.isProcessed = FALSE;
                    // 我们设置默认值为步行、保留所有轨迹点、去噪、抽稀、不绑路，可以随便设置
                    BTKQueryTrackProcessOption *processOption = [[BTKQueryTrackProcessOption alloc] init];
                    processOption.denoise = TRUE;
                    processOption.vacuate = TRUE;
                    
                    //是否将轨迹点绑定至道路
                   NSString *isBindTrack =[NSString changgeNonulWithString:baiduDic[@"tjIsBindTrack"]];
                   if ([isBindTrack integerValue] == 0) {
                        processOption.mapMatch = FALSE;
                   }else if ([isBindTrack integerValue] == 1){
                        processOption.mapMatch = TRUE;
                   }
            
                    //若只需保留 GPS 定位点，则建议设为：20；若需保留 GPS 和 Wi-Fi 定位点，去除基站定位点，则建议设为：100
                    NSString *seclectFiltering =[NSString changgeNonulWithString:baiduDic[@"tjSeclectFiltering"]];
                    if ([seclectFiltering integerValue] == 0) {
                        processOption.radiusThreshold = 0;
                    }else if ([seclectFiltering integerValue] == 1){
                        processOption.radiusThreshold = 20;
                    }else{
                        processOption.radiusThreshold = 100;
                    }
                    
                    // @[@"步行、骑行、跑步", @"驾车", @"火车、飞机", @"其他类型"]; 驾车
                    NSString *tjActivityType =[NSString changgeNonulWithString:baiduDic[@"tjActivityType"]];
                    if([tjActivityType integerValue] == 1){
                        processOption.transportMode = BTK_TRACK_PROCESS_OPTION_TRANSPORT_MODE_DRIVING;
                    }else if ([tjActivityType integerValue] == 3){
                        processOption.transportMode = BTK_TRACK_PROCESS_OPTION_TRANSPORT_MODE_AUTO;
                    }else if ([tjActivityType integerValue] == 2){
                        processOption.transportMode = BTK_TRACK_PROCESS_OPTION_TRANSPORT_MODE_RIDING;
                    }else{
                        processOption.transportMode = BTK_TRACK_PROCESS_OPTION_TRANSPORT_MODE_WALKING;
                    }
                  
                    _paramInfo.processOption = processOption;
                    
    //                BTK_TRACK_PROCESS_OPTION_NO_SUPPLEMENT: 不补充，中断两点间距离不记入里程
    //                - BTK_TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_STRAIGHT: 使用直线距离补充
    //                - BTK_TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_DRIVING: 使用最短驾车路线距离补充
    //                - BTK_TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_RIDING: 使用最短骑行路线距离补充
    //                - BTK_TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_WALKING: 使用最短步行路线距离补充
                    NSString *mileageCompensation =[NSString changgeNonulWithString:baiduDic[@"tjMileageCompensation"]];
                    if([mileageCompensation integerValue] == 0){
                        _paramInfo.supplementMode = BTK_TRACK_PROCESS_OPTION_NO_SUPPLEMENT;
                    }else if ([mileageCompensation integerValue] == 1){
                        _paramInfo.supplementMode = BTK_TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_STRAIGHT;
                    }else if ([mileageCompensation integerValue] == 4){
                        _paramInfo.supplementMode = BTK_TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_DRIVING;
                    }else if ([mileageCompensation integerValue] == 3){
                        _paramInfo.supplementMode = BTK_TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_RIDING;
                    }else{
                        _paramInfo.supplementMode = BTK_TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_WALKING;
                    }
                }else{
                   _paramInfo.endTime = [self.endTimePicker.date timeIntervalSince1970];
                    _paramInfo.startTime = [self.startTimePicker.date timeIntervalSince1970];
                    _paramInfo.isProcessed = FALSE;
                    // 我们设置默认值为步行、保留所有轨迹点、去噪、抽稀、不绑路，可以随便设置
                    BTKQueryTrackProcessOption *processOption = [[BTKQueryTrackProcessOption alloc] init];
                    processOption.denoise = TRUE;
                    processOption.vacuate = TRUE;
                    processOption.mapMatch = FALSE;
                    processOption.radiusThreshold = 0;
                    processOption.transportMode = BTK_TRACK_PROCESS_OPTION_TRANSPORT_MODE_WALKING;
                    _paramInfo.processOption = processOption;
                    _paramInfo.supplementMode = BTK_TRACK_PROCESS_OPTION_NO_SUPPLEMENT;
                     
                }
        
    }
    return _paramInfo;
}

-(NSArray *)sectionTitles {
    if (_sectionTitles == nil) {
        _sectionTitles = @[
//            @"用户终端ID",
                           @"轨迹起止时间设置",
//                           @"纠偏选项设置",
//                           @"里程补偿方式设置"
        ];
    }
    return _sectionTitles;
}

-(UITextField *)entityNameTextField {
    if (_entityNameTextField == nil) {
        _entityNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH / 2, 30)];
        NSString *entityNameStored = [USER_DEFAULTS objectForKey:ENTITY_NAME];
        //临时方案，别浪
        entityNameStored = [UserManager manager].bguserId;
        if (nil == entityNameStored || entityNameStored.length == 0) {
            _entityNameTextField.placeholder = @"开启轨迹追踪后自动获取";
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

-(UIDatePicker *)startTimePicker {
    if (_startTimePicker == nil) {
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, kTableViewCellPickerViewHeight);
        _startTimePicker = [[UIDatePicker alloc] initWithFrame:rect];
        _startTimePicker.locale = CURRENT_LOCALE;
        _startTimePicker.datePickerMode = UIDatePickerModeDateAndTime;
        _startTimePicker.translatesAutoresizingMaskIntoConstraints = FALSE;
        _startTimePicker.hidden = YES;
        _startTimePicker.minuteInterval = 10;
        NSInteger startTime = [USER_DEFAULTS integerForKey:HISTORY_TRACK_START_TIME];
        // 如果之前设置过startTime就用上一次设置过的值，否则默认的startTime为12小时之前
        if (startTime != 0) {
            _startTimePicker.date = [NSDate dateWithTimeIntervalSince1970:startTime];
        } else {
            NSInteger defaultStartTime = [[NSDate date] timeIntervalSince1970] - 12 * 60 *60;
            _startTimePicker.date = [NSDate dateWithTimeIntervalSince1970:defaultStartTime];
        }
        [_startTimePicker addTarget:self action:@selector(startTimeSetted:) forControlEvents:UIControlEventValueChanged];
    }
    return _startTimePicker;
}

-(UIDatePicker *)endTimePicker {
    if (_endTimePicker == nil) {
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, kTableViewCellPickerViewHeight);
        _endTimePicker = [[UIDatePicker alloc] initWithFrame:rect];
        _endTimePicker.locale = CURRENT_LOCALE;
        _endTimePicker.datePickerMode = UIDatePickerModeDateAndTime;
        _endTimePicker.translatesAutoresizingMaskIntoConstraints = FALSE;
        _endTimePicker.hidden = YES;
        _endTimePicker.minuteInterval = 10;
        NSInteger endTime = [USER_DEFAULTS integerForKey:HISTORY_TRACK_END_TIME];
        // 如果之前设置过endTime就用上一次设置过的值，否则默认的endTime为当前时刻
        if (endTime != 0) {
            _endTimePicker.date = [NSDate dateWithTimeIntervalSince1970:endTime];
        } else {
            NSInteger defaultEndTime = [[NSDate date] timeIntervalSince1970];
            _endTimePicker.date = [NSDate dateWithTimeIntervalSince1970:defaultEndTime];
        }
        [_endTimePicker addTarget:self action:@selector(endTimeSetted:) forControlEvents:UIControlEventValueChanged];
    }
    return _endTimePicker;
}

-(UISwitch *)isProcessSwitch {
    if (_isProcessSwitch == nil) {
        _isProcessSwitch = [[UISwitch alloc] init];
        _isProcessSwitch.on = NO;
        _isProcessSwitch.translatesAutoresizingMaskIntoConstraints = FALSE;
        [_isProcessSwitch addTarget:self action:@selector(isProcessSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _isProcessSwitch;
}

-(UISwitch *)denoiseSwitch {
    if (_denoiseSwitch == nil) {
        _denoiseSwitch = [[UISwitch alloc] init];
        _denoiseSwitch.on = YES;
        _denoiseSwitch.translatesAutoresizingMaskIntoConstraints = FALSE;
        [_denoiseSwitch addTarget:self action:@selector(denoiseSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _denoiseSwitch;
}

-(UISwitch *)vacuateSwitch {
    if (_vacuateSwitch == nil) {
        _vacuateSwitch = [[UISwitch alloc] init];
        _vacuateSwitch.on = YES;
        _vacuateSwitch.translatesAutoresizingMaskIntoConstraints = FALSE;
        [_vacuateSwitch addTarget:self action:@selector(vacuateSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _vacuateSwitch;
}

-(UISwitch *)mapMatchSwitch {
    if (_mapMatchSwitch == nil) {
        _mapMatchSwitch = [[UISwitch alloc] init];
        _mapMatchSwitch.on = NO;
        _mapMatchSwitch.translatesAutoresizingMaskIntoConstraints = FALSE;
        [_mapMatchSwitch addTarget:self action:@selector(mapMatchSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _mapMatchSwitch;
}

-(UIPickerView *)radiusThresholdPicker {
    if (_radiusThresholdPicker == nil) {
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, kTableViewCellPickerViewHeight);
        _radiusThresholdPicker = [[UIPickerView alloc] initWithFrame:rect];
        _radiusThresholdPicker.translatesAutoresizingMaskIntoConstraints = FALSE;
        _radiusThresholdPicker.tag = YY_HISTORY_TRACK_PARAM_RADIUS_THRESHOLD_PICKER;
        _radiusThresholdPicker.hidden = TRUE;
        _radiusThresholdPicker.delegate = self;
        _radiusThresholdPicker.dataSource = self;
        [_radiusThresholdPicker selectRow:0 inComponent:0 animated:TRUE];
    }
    return _radiusThresholdPicker;
}

-(UIPickerView *)transportModePicker {
    if (_transportModePicker == nil) {
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, kTableViewCellPickerViewHeight);
        _transportModePicker = [[UIPickerView alloc] initWithFrame:rect];
        _transportModePicker.translatesAutoresizingMaskIntoConstraints = FALSE;
        _transportModePicker.tag = YY_HISTORY_TRACK_PARAM_TRANSPORT_MODE_PICKER;
        _transportModePicker.hidden = TRUE;
        _transportModePicker.delegate = self;
        _transportModePicker.dataSource = self;
        [_transportModePicker selectRow:0 inComponent:0 animated:TRUE];
    }
    return _transportModePicker;
}

-(UIPickerView *)supplementModePicker {
    if (_supplementModePicker == nil) {
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, kTableViewCellPickerViewHeight);
        _supplementModePicker = [[UIPickerView alloc] initWithFrame:rect];
        _supplementModePicker.translatesAutoresizingMaskIntoConstraints = FALSE;
        _supplementModePicker.tag = YY_HISTORY_TRACK_PARAM_SUPPLEMENT_MODE_PICKER;
        _supplementModePicker.hidden = TRUE;
        _supplementModePicker.delegate = self;
        _supplementModePicker.dataSource = self;
        [_supplementModePicker selectRow:0 inComponent:0 animated:TRUE];
    }
    return _supplementModePicker;
}

-(NSArray *)radiusThresholdPickerDataSource {
    if (_radiusThresholdPickerDataSource == nil) {
        _radiusThresholdPickerDataSource = @[@0, @20, @100];
    }
    return _radiusThresholdPickerDataSource;
}

-(NSArray *)transportModePickerDataSource {
    if (_transportModePickerDataSource == nil) {
        _transportModePickerDataSource = @[@(BTK_TRACK_PROCESS_OPTION_TRANSPORT_MODE_WALKING),
                                           @(BTK_TRACK_PROCESS_OPTION_TRANSPORT_MODE_RIDING),
                                           @(BTK_TRACK_PROCESS_OPTION_TRANSPORT_MODE_DRIVING)
                                           ];
    }
    return _transportModePickerDataSource;
}

-(NSArray *)supplementModePickerDataSource {
    if (_supplementModePickerDataSource == nil) {
        _supplementModePickerDataSource = @[@(BTK_TRACK_PROCESS_OPTION_NO_SUPPLEMENT),
                                            @(BTK_TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_STRAIGHT),
                                            @(BTK_TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_WALKING),
                                            @(BTK_TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_RIDING),
                                            @(BTK_TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_DRIVING)
                                            ];
    }
    return _supplementModePickerDataSource;
}

@end
