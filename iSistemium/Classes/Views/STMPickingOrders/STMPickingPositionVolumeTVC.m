//
//  STMPickingPositionVolumeTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 19/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMPickingPositionVolumeTVC.h"


@interface STMPickingPositionVolumeTVC () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) NSString *positionNameCellIdentifier;
@property (nonatomic, strong) NSString *volumeCellIdentifier;
//@property (nonatomic, strong) NSString *volumeControlsCellIdentifier;

@property (nonatomic, strong) UIPickerView *volumePicker;

@property (nonatomic) NSInteger volume;
@property (nonatomic) NSInteger packageRel;
@property (nonatomic) NSString *name;


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
    return [self.position nonPickedVolume];
}

- (NSInteger)packageRel {
    return self.position.article.packageRel.integerValue;
}

- (NSString *)name {
    return self.position.article.name;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    switch (section) {
        case 0:
            return 1;
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
            return @"Количество:";
            break;
            
        default:
            return nil;
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
            return [super tableView:tableView heightForRowAtIndexPath:indexPath];
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
            
            cell = [tableView dequeueReusableCellWithIdentifier:self.positionNameCellIdentifier forIndexPath:indexPath];
            [self fillPositionNameCell:cell];
            
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

- (void)fillPositionNameCell:(UITableViewCell *)cell {
    
    if ([cell isKindOfClass:[STMCustom7TVCell class]]) {
        
        STMCustom7TVCell *customCell = (STMCustom7TVCell *)cell;
        
        customCell.titleLabel.text = self.name;
        customCell.detailLabel.text = nil;
        
    }
    
}

- (void)fillVolumeCell:(UITableViewCell *)cell {
    [cell.contentView addSubview:self.volumePicker];
}

- (void)fillButtonCell:(UITableViewCell *)cell {

    cell.textLabel.text = @"NEXT BUTTON";
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = ACTIVE_BLUE_COLOR;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
}

- (void)nextButtonPressed {
    NSLogMethodName;
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


#pragma mark - view lifecycle

- (void)customInit {
    
    self.tableView.scrollEnabled = NO;

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:self.cellIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:self.volumeCellIdentifier];

    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([STMCustom7TVCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.positionNameCellIdentifier];

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
