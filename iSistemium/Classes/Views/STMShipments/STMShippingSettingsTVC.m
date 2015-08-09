//
//  STMShippingSettingsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 09/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShippingSettingsTVC.h"

@interface STMShippingSettingsTVC ()

@property (weak, nonatomic) IBOutlet UITableViewCell *nameSortCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *timestampSortCell;

@property (nonatomic) STMShipmentPositionSort sortOrder;


@end


@implementation STMShippingSettingsTVC

- (void)setSortOrder:(STMShipmentPositionSort)sortOrder {
    
    _sortOrder = sortOrder;

    self.nameSortCell.accessoryType = UITableViewCellAccessoryNone;
    self.timestampSortCell.accessoryType = UITableViewCellAccessoryNone;
    self.nameSortCell.textLabel.text = @"Наименование";
    self.timestampSortCell.textLabel.text = @"Время обработки";

    switch (sortOrder) {
        case STMShipmentPositionSortNameAsc:
            self.nameSortCell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.nameSortCell.textLabel.text = @"Наименование (А-Я)";
            break;
            
        case STMShipmentPositionSortNameDesc:
            self.nameSortCell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.nameSortCell.textLabel.text = @"Наименование (Я-А)";
            break;

        case STMShipmentPositionSortTsAsc:
            self.timestampSortCell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.timestampSortCell.textLabel.text = @"Время обработки (новые сверху)";
            break;

        case STMShipmentPositionSortTsDesc:
            self.timestampSortCell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.timestampSortCell.textLabel.text = @"Время обработки (старые сверху)";
            break;

        default:
            break;
    }
    
}


#pragma mark - Table view data source


#pragma mark - view lifecycle

- (void)customInit {
    self.sortOrder = self.parentVC.sortOrder;
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
