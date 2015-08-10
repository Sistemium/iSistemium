//
//  STMShippingSettingsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 09/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShippingSettingsTVC.h"

@interface STMShippingSettingsTVC ()


@property (weak, nonatomic) IBOutlet UITableViewCell *ordAscCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *ordDescCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *nameAscCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *nameDescCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *timestampAscCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *timestampDescCell;

@property (nonatomic, strong) NSArray *sortOrderCells;


@property (nonatomic) STMShipmentPositionSort sortOrder;


@end


@implementation STMShippingSettingsTVC

- (NSArray *)sortOrderCells {
    
    if (!_sortOrderCells) {
        _sortOrderCells = @[self.ordAscCell,
                            self.ordDescCell,
                            self.nameAscCell,
                            self.nameDescCell,
                            self.timestampAscCell,
                            self.timestampDescCell];
    }
    return _sortOrderCells;
    
}

- (void)setSortOrder:(STMShipmentPositionSort)sortOrder {

    UITableViewCell *cell = self.sortOrderCells[_sortOrder];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    cell = self.sortOrderCells[sortOrder];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    _sortOrder = sortOrder;

    self.parentVC.sortOrder = sortOrder;
    
}


#pragma mark - Table view data source & delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.sortOrder = (STMShipmentPositionSort)indexPath.row;
}


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
