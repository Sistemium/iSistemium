//
//  STMPickingPositionVolumeTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 19/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMPickingPositionVolumeTVC.h"


@interface STMPickingPositionVolumeTVC ()

@property (nonatomic, strong) NSString *positionNameCellIdentifier;
@property (nonatomic, strong) NSString *volumeCellIdentifier;
@property (nonatomic, strong) NSString *volumeControlsCellIdentifier;


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

- (NSString *)volumeControlsCellIdentifier {
    
    if (!_volumeControlsCellIdentifier) {
        _volumeControlsCellIdentifier = [self.cellIdentifier stringByAppendingString:@"_volumeControlsCellIdentifier"];
    }
    return _volumeControlsCellIdentifier;
    
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
            return 2;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0:
            
            cell = [tableView dequeueReusableCellWithIdentifier:self.positionNameCellIdentifier forIndexPath:indexPath];
            [self fillPositionNameCell:cell];
            
            break;

        case 1:
            
            switch (indexPath.row) {
                case 0:
                    cell = [tableView dequeueReusableCellWithIdentifier:self.volumeCellIdentifier forIndexPath:indexPath];
                    break;

                case 1:
                    cell = [tableView dequeueReusableCellWithIdentifier:self.volumeControlsCellIdentifier forIndexPath:indexPath];
                    break;

                default:
                    break;
            }
            
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
        
        customCell.titleLabel.text = self.position.article.name;
        
        
    }
    
}

- (void)fillButtonCell:(UITableViewCell *)cell {
    
    UIButton *nextButton = [[UIButton alloc] initWithFrame:cell.contentView.frame];
    
    nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    nextButton.titleLabel.text = @"NEXT BUTTON";
    [nextButton addTarget:self action:@selector(nextButtonPressed) forControlEvents:UIControlEventTouchUpInside];

    [cell.contentView addSubview:nextButton];
    
}

- (void)nextButtonPressed {
    NSLogMethodName;
}

#pragma mark - view lifecycle

- (void)customInit {
    
    self.tableView.scrollEnabled = NO;

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:self.cellIdentifier];

    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([STMVolumeTVCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.volumeCellIdentifier];

    cellNib = [UINib nibWithNibName:NSStringFromClass([STMVolumeControlsTVCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.volumeControlsCellIdentifier];

    cellNib = [UINib nibWithNibName:NSStringFromClass([STMCustom7TVCell class]) bundle:nil];
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
