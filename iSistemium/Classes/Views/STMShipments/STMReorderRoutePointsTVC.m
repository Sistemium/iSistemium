//
//  STMReorderRoutePointsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMReorderRoutePointsTVC.h"
#import "STMUI.h"
#import "STMDataModel.h"


@interface STMReorderRoutePointsTVC ()


@end


@implementation STMReorderRoutePointsTVC

- (NSString *)cellIdentifier {
    return @"reorderPointCell";
}


#pragma mark - tableView data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.points.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMCustom7TVCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    [self fillCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

- (void)fillCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[STMCustom7TVCell class]]) {
        
        STMCustom7TVCell *customCell = (STMCustom7TVCell *)cell;
        
        STMShipmentRoutePoint *point = self.points[indexPath.row];
        
        customCell.titleLabel.text = point.name;
        
        UIColor *titleColor = [UIColor blackColor];
        
        if (point.isReached.boolValue) {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isShipped.boolValue != YES"];
            NSUInteger unprocessedShipmentsCount = [point.shipments filteredSetUsingPredicate:predicate].count;
            
            titleColor = (unprocessedShipmentsCount > 0) ? [UIColor redColor] : [UIColor lightGrayColor];
            
        }
        
        customCell.titleLabel.textColor = titleColor;
        
        customCell.detailLabel.text = [point shortInfo];
        customCell.detailLabel.textColor = titleColor;
        
        customCell.accessoryType = UITableViewCellAccessoryNone;
        
    }
    
}

#pragma mark - view lifecycle

- (void)customInit {
    [self.tableView registerNib:[UINib nibWithNibName:@"STMCustom7TVCell" bundle:nil] forCellReuseIdentifier:self.cellIdentifier];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
