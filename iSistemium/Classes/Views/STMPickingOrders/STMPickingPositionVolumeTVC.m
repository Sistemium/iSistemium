//
//  STMPickingPositionVolumeTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 19/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMPickingPositionVolumeTVC.h"

#import "STMPickingPositionInfoTVC.h"


@interface STMPickingPositionVolumeTVC () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) NSString *positionNameCellIdentifier;
@property (nonatomic, strong) NSString *volumeCellIdentifier;

@property (nonatomic, strong) UIPickerView *volumePicker;

@property (nonatomic) NSInteger volume;
@property (nonatomic) NSInteger packageRel;
@property (nonatomic) NSString *name;
@property (nonatomic, weak) STMProductionInfoType *productionInfoType;

@property (nonatomic) NSInteger selectedVolume;
@property (nonatomic) NSInteger selectedBoxCount;


@end


@implementation STMPickingPositionVolumeTVC

- (NSString *)positionNameCellIdentifier {
    
    if (!_positionNameCellIdentifier) {
        _positionNameCellIdentifier = [self.cellIdentifier stringByAppendingString:@"_positionNameCellIdentifier"];
    }
    return _positionNameCellIdentifier;
    
}

- (NSString *)volumeCellIdentifier {
    
    if (!_volumeCellIdentifier) {
        _volumeCellIdentifier = [self.cellIdentifier stringByAppendingString:@"_volumeCellIdentifier"];
    }
    return _volumeCellIdentifier;
    
}

- (UIPickerView *)volumePicker {
    
    if (!_volumePicker) {
        
        CGRect pickerFrame = CGRectMake(0, 0, self.view.frame.size.width, 162); // UIPicker height may be 162, 180 and 216 only

        _volumePicker = [[UIPickerView alloc] initWithFrame:pickerFrame];
        _volumePicker.dataSource = self;
        _volumePicker.delegate = self;

    }
    return _volumePicker;
    
}

- (NSInteger)volume {
    return (self.position) ? [self.position nonPickedVolume] : [self.pickedPosition.pickingOrderPosition nonPickedVolume] + self.pickedPosition.volume.integerValue;
}

- (NSInteger)packageRel {
    return (self.position) ? self.position.article.packageRel.integerValue : self.pickedPosition.article.packageRel.integerValue;
}

- (NSString *)name {
    return (self.position) ? self.position.article.name : self.pickedPosition.article.name;
}

- (STMProductionInfoType *)productionInfoType {
    return (self.position) ? self.position.article.productionInfoType : self.pickedPosition.article.productionInfoType;
}

- (void)setSelectedVolume:(NSInteger)selectedVolume {

    if (selectedVolume > self.volume) {
        selectedVolume = self.volume;
    }
    
    _selectedVolume = selectedVolume;
    
    self.selectedBoxCount = (self.packageRel > 0) ? self.selectedVolume / self.packageRel : 0;
    
    [self.volumePicker selectRow:self.selectedBoxCount inComponent:0 animated:YES];
    [self.volumePicker selectRow:self.selectedVolume inComponent:2 animated:YES];

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    switch (section) {
        case 0:
            return (self.pickedPosition) ? 2 : 1;
            break;

        case 1:
            return 1;
            break;

        case 2:
            return 1;
            break;

        default:
            return 0;
        break;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case 1:
            return [NSLocalizedString(@"QVOLUME", nil) stringByAppendingString:@":"];
            break;
            
        default:
            return nil;
            break;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case 2:
            return CGFLOAT_MIN;
            break;
            
        default:
            return [super tableView:tableView heightForHeaderInSection:section];
            break;
    }
    
}

- (UITableViewCell *)cellForHeightCalculationForIndexPath:(NSIndexPath *)indexPath {
    
    static STMCustom7TVCell *cell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    });
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
                    break;
                    
                default:
                    return self.standardCellHeight;
                    break;
            }
            break;
            
        case 1:
            return self.volumePicker.frame.size.height;
            break;
            
        default:
            return self.standardCellHeight;
            break;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0:
            
            switch (indexPath.row) {
                case 0:
                    cell = [tableView dequeueReusableCellWithIdentifier:self.positionNameCellIdentifier forIndexPath:indexPath];
                    [self fillCell:cell atIndexPath:indexPath];
                    break;

                case 1:
                    cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
                    [self fillDeleteCell:cell];
                    break;

                default:
                    break;
            }
            
            break;

        case 1:

            cell = [tableView dequeueReusableCellWithIdentifier:self.volumeCellIdentifier forIndexPath:indexPath];
            [self fillVolumeCell:cell];
            
            break;

        case 2:
            
            cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
            [self fillButtonCell:cell];
            
            break;

        default:
            break;
    }

    return cell;
    
}

- (void)fillCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    [self fillPositionNameCell:cell];
    [super fillCell:cell atIndexPath:indexPath];
    
}

- (void)fillPositionNameCell:(UITableViewCell *)cell {
    
    if ([cell isKindOfClass:[STMCustom7TVCell class]]) {
        
        STMCustom7TVCell *customCell = (STMCustom7TVCell *)cell;
        
        customCell.titleLabel.text = self.name;
        customCell.detailLabel.text = nil;
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
}

- (void)fillDeleteCell:(UITableViewCell *)cell {
    
    if (self.pickedPosition) {
        
        cell.textLabel.text = NSLocalizedString(@"DELETE", nil);
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor redColor];
    
    }
    
}

- (void)fillVolumeCell:(UITableViewCell *)cell {
    [cell.contentView addSubview:self.volumePicker];
}

- (void)fillButtonCell:(UITableViewCell *)cell {

    if (self.productionInfoType) {

        cell.textLabel.text = NSLocalizedString(@"NEXT", nil);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    } else {

        cell.textLabel.text = NSLocalizedString(@"DONE", nil);
        cell.accessoryType = UITableViewCellAccessoryNone;

    }
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = ACTIVE_BLUE_COLOR;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            
            switch (indexPath.row) {
                case 1:
                    if (self.pickedPosition) {
                        
                        [self.pickedPositionsTVC deletePickedPosition:self.pickedPosition];
                        [self.navigationController popViewControllerAnimated:YES];
                        
                    }
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        case 2:
            if (self.productionInfoType) {
                [self performSegueWithIdentifier:@"showPositionInfo" sender:nil];
            } else {
                [self doneButtonPressed];
            }
            break;
            
        default:
            break;
    }
    
}

- (void)doneButtonPressed {
    
    if (self.position) {
        [self.positionsTVC position:self.position wasPickedWithVolume:self.selectedVolume andProductionInfo:nil];
    } else {
        [self.pickedPositionsTVC pickedPosition:self.pickedPosition newVolume:self.selectedVolume andProductionInfo:nil];
    }
    
}


#pragma mark - UIPickerViewDataSource, UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 4;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {

    switch (component) {
        case 0:
            return (self.packageRel > 0) ? (self.volume / self.packageRel) + 1 : 1;
            break;

        case 1:
            return 1;
            break;

        case 2:
            return self.volume + 1;
            break;

        case 3:
            return 1;
            break;

        default:
            return 0;
            break;
    }
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {

    switch (component) {
        case 0:
            return @(row).stringValue;
            break;

        case 1:
            return NSLocalizedString(@"VOLUME UNIT1", nil);
            break;

        case 2:
            return (self.packageRel > 0) ? @(row % self.packageRel).stringValue : @(row).stringValue;
            break;

        case 3: {
            
            NSDictionary *appSettings = [[STMSessionManager sharedManager].currentSession.settingsController currentSettingsForGroup:@"appSettings"];
            BOOL enableShowBottles = [appSettings[@"enableShowBottles"] boolValue];
            
            return (enableShowBottles) ? NSLocalizedString(@"VOLUME UNIT2", nil) : NSLocalizedString(@"VOLUME UNIT3", nil);

        }
            break;

        default:
            return nil;
            break;
    }
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return self.standardCellHeight;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    switch (component) {
        case 0:
            self.selectedVolume = self.selectedVolume + (row - self.selectedBoxCount) * self.packageRel;
            break;

        case 2:
            self.selectedVolume = row;
            break;

        default:
            break;
    }
    
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"showPositionInfo"] &&
        [segue.destinationViewController isKindOfClass:[STMPickingPositionInfoTVC class]]) {
        
        STMPickingPositionInfoTVC *infoTVC = (STMPickingPositionInfoTVC *)segue.destinationViewController;

        infoTVC.position = self.position;
        infoTVC.selectedVolume = self.selectedVolume;
        infoTVC.positionsTVC = self.positionsTVC;
        
        infoTVC.pickedPosition = self.pickedPosition;
        infoTVC.pickedPositionsTVC = self.pickedPositionsTVC;
        
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    self.tableView.scrollEnabled = NO;

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:self.cellIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:self.volumeCellIdentifier];

    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([STMCustom7TVCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.positionNameCellIdentifier];

    self.selectedVolume = (self.position) ? [self.position nonPickedVolume] : self.pickedPosition.volume.integerValue;;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
