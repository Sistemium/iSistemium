//
//  STMOrderInfoTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMOrderInfoTVC.h"
#import "STMOrderInfoNC.h"
#import "STMSaleOrderController.h"


@interface STMOrderInfoTVC ()

@property (nonatomic, weak) STMOrderInfoNC *parentNC;
@property (nonatomic, strong) STMSaleOrder *saleOrder;
@property (nonatomic, strong) NSArray *saleOrderPositions;


@end


@implementation STMOrderInfoTVC

- (STMOrderInfoNC *)parentNC {
    
    if (!_parentNC) {
        
        if ([self.navigationController isKindOfClass:[STMOrderInfoNC class]]) {
            _parentNC = (STMOrderInfoNC *)self.navigationController;
        }
        
    }
    return _parentNC;
    
}

- (STMSaleOrder *)saleOrder {
    
    if (!_saleOrder) {
        
        _saleOrder = self.parentNC.saleOrder;
        
    }
    return _saleOrder;
    
}

- (NSArray *)saleOrderPositions {
    
    if (!_saleOrderPositions) {
        
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"article.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        NSSortDescriptor *volumeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"volume" ascending:YES selector:@selector(compare:)];
        
        _saleOrderPositions = [self.saleOrder.saleOrderPositions sortedArrayUsingDescriptors:@[nameDescriptor, volumeDescriptor]];

    }
    return _saleOrderPositions;
    
}


- (void)cancelButtonPressed {
    [self.parentNC cancelButtonPressed];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    switch (section) {
        case 0:
            
            if (self.saleOrder.commentText) {
                return 6;
            } else {
                return 5;
            }
            
            break;
            
        case 1:
            return self.saleOrder.saleOrderPositions.count;
            break;
            
        default:
            return 0;
            break;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSUInteger positionsCount = self.saleOrder.saleOrderPositions.count;
    NSString *pluralTypeString = [[STMFunctions pluralTypeForCount:positionsCount] stringByAppendingString:@"POSITIONS"];
    NSString *positionsCountString = [NSString stringWithFormat:@"%lu %@:", (unsigned long)positionsCount, NSLocalizedString(pluralTypeString, nil)];
    
    switch (section) {
        case 0:
            return NSLocalizedString(@"ORDER INFO", nil);
            break;
            
        case 1:
//            return NSLocalizedString(@"ORDER POSITIONS", nil);
            return positionsCountString;
            break;
            
        default:
            return @"";
            break;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"orderInfoCell";
    
    STMUIInfoTableViewCell *cell = [[STMUIInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    switch (indexPath.section) {
        case 0:
            [self fillOrderInfoCell:cell forRow:indexPath.row];
            break;

        case 1:
            [self fillOrderPositionCell:cell forRow:indexPath.row];
            break;

        default:
            break;
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell = nil;
}

- (void)fillOrderInfoCell:(STMUIInfoTableViewCell *)cell forRow:(NSUInteger)row {
    
    switch (row) {
        case 0:
            cell.textLabel.text = self.saleOrder.outlet.partner.name;
            cell.detailTextLabel.text = self.saleOrder.outlet.shortName;
            break;

        case 1:
            cell.textLabel.text = self.saleOrder.salesman.name;
            cell.detailTextLabel.text = @"";
            break;

        case 2:
            cell.textLabel.text = [STMFunctions dayWithDayOfWeekFromDate:self.saleOrder.date];
            cell.detailTextLabel.text = @"";
            break;

        case 3:
            cell.textLabel.text = [[STMFunctions currencyFormatter] stringFromNumber:self.saleOrder.totalCost];
            cell.detailTextLabel.text = @"";
            break;

        case 4:
            cell.textLabel.text = [STMSaleOrderController labelForProcessing:self.saleOrder.processing];
            if ([STMSaleOrderController colorForProcessing:self.saleOrder.processing]) {
                cell.textLabel.textColor =  [STMSaleOrderController colorForProcessing:self.saleOrder.processing];
            }
            cell.detailTextLabel.text = @"";
            break;

        case 5:
            cell.textLabel.text = self.saleOrder.commentText;
            cell.detailTextLabel.text = @"";
            break;

        default:
            break;
    }
    
}

- (void)fillOrderPositionCell:(STMUIInfoTableViewCell *)cell forRow:(NSUInteger)row {
    
    STMSaleOrderPosition *saleOrderPosition = self.saleOrderPositions[row];
    
    cell.textLabel.text = saleOrderPosition.article.name;
    
    NSString *detailedText = @"";
    NSString *appendString = @"";
    
//    NSNumberFormatter *numberFormatter = [STMFunctions currencyFormatter];
//    appendString = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:article.price]];
//    detailedText = [detailedText stringByAppendingString:appendString];
//    
//    if (article.extraLabel) {
//        
//        appendString = [NSString stringWithFormat:@", %@", article.extraLabel];
//        detailedText = [detailedText stringByAppendingString:appendString];
//        
//    }
    
    cell.detailTextLabel.text = detailedText;
    
    NSString *volumeUnitString = NSLocalizedString(@"VOLUME UNIT", nil);
    cell.infoLabel.text = [NSString stringWithFormat:@"%@%@", saleOrderPosition.volume, volumeUnitString];
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];

    [self setToolbarItems:@[flexibleSpace, cancelButton]];

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
