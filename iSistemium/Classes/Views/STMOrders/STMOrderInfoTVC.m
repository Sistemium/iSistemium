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
//        NSSortDescriptor *volumeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"volume" ascending:YES selector:@selector(compare:)];
        
        _saleOrderPositions = [self.saleOrder.saleOrderPositions sortedArrayUsingDescriptors:@[nameDescriptor]];

    }
    return _saleOrderPositions;
    
}


- (void)closeButtonPressed {
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
    NSString *positionsCountString = [NSString stringWithFormat:@"%lu %@", (unsigned long)positionsCount, NSLocalizedString(pluralTypeString, nil)];
    
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
    
    static NSString *infoCellIdentifier = @"orderInfoCell";
    static NSString *positionCellIdentifier = @"orderPositionCell";
    
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:infoCellIdentifier forIndexPath:indexPath];
            [self fillOrderInfoCell:cell forRow:indexPath.row];
            break;

        case 1:
            cell = [[STMInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:positionCellIdentifier];
            [self fillOrderPositionCell:(STMInfoTableViewCell *)cell forRow:indexPath.row];
            break;

        default:
            break;
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell = nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    if (indexPath.section == 1) {
//        
//        STMSaleOrderPosition *saleOrderPosition = self.saleOrderPositions[indexPath.row];
//        STMArticle *article = saleOrderPosition.article;
//        
//        NSLog(@"saleOrderPosition %@", saleOrderPosition);
//        NSLog(@"article %@", article);
//        
//    }
    
    return indexPath;
    
}

- (void)fillOrderInfoCell:(UITableViewCell *)cell forRow:(NSUInteger)row {
    
    switch (row) {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"OUTLET", nil);
            cell.detailTextLabel.text = self.saleOrder.outlet.name;
            break;

        case 1:
            cell.textLabel.text = NSLocalizedString(@"SALESMAN", nil);
            cell.detailTextLabel.text = self.saleOrder.salesman.name;
            break;

        case 2:
            cell.textLabel.text = NSLocalizedString(@"DISPATCH DATE", nil);
            cell.detailTextLabel.text = [STMFunctions dayWithDayOfWeekFromDate:self.saleOrder.date];
            break;

        case 3:
            cell.textLabel.text = NSLocalizedString(@"COST", nil);
            cell.detailTextLabel.text = [[STMFunctions currencyFormatter] stringFromNumber:self.saleOrder.totalCost];
            break;

        case 4:
            cell.textLabel.text = NSLocalizedString(@"STATUS", nil);
            cell.detailTextLabel.text = [STMSaleOrderController labelForProcessing:self.saleOrder.processing];
            if ([STMSaleOrderController colorForProcessing:self.saleOrder.processing]) {
                cell.detailTextLabel.textColor =  [STMSaleOrderController colorForProcessing:self.saleOrder.processing];
            }
            break;

        case 5:
            cell.textLabel.text = NSLocalizedString(@"COMMENT", nil);
            cell.detailTextLabel.text = self.saleOrder.commentText;
            break;

        default:
            break;
    }
    
}

- (void)fillOrderPositionCell:(STMInfoTableViewCell *)cell forRow:(NSUInteger)row {
    
    STMSaleOrderPosition *saleOrderPosition = self.saleOrderPositions[row];
    
    cell.textLabel.text = saleOrderPosition.article.name;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
    cell.detailTextLabel.text = [self detailedTextForSaleOrderPosition:saleOrderPosition];
    
    NSString *volumeUnitString = nil;
    
    int volume = [saleOrderPosition.volume intValue];
    int packageRel = [saleOrderPosition.article.packageRel intValue];
    
    if (packageRel != 0 && volume >= packageRel) {

        int package = floor(volume / packageRel);
        
        volumeUnitString = NSLocalizedString(@"VOLUME UNIT1", nil);
        NSString *packageString = [NSString stringWithFormat:@"%d %@", package, volumeUnitString];

        int bottle = volume % packageRel;
        
        if (bottle > 0) {
            
            volumeUnitString = NSLocalizedString(@"VOLUME UNIT2", nil);
            NSString *bottleString = [NSString stringWithFormat:@" %d %@", bottle, volumeUnitString];
            
            packageString = [packageString stringByAppendingString:bottleString];
            
        }
        
        cell.infoLabel.text = packageString;
        
    } else {
     
        volumeUnitString = NSLocalizedString(@"VOLUME UNIT2", nil);
        cell.infoLabel.text = [NSString stringWithFormat:@"%@ %@", saleOrderPosition.volume, volumeUnitString];

    }
        
}

- (NSString *)detailedTextForSaleOrderPosition:(STMSaleOrderPosition *)saleOrderPosition {
    
    NSDecimalNumber *price0 = saleOrderPosition.price0;
    NSDecimalNumber *price1 = saleOrderPosition.price1;
    NSDecimalNumber *priceOrigin = saleOrderPosition.priceOrigin;
    
    NSString *detailedText = @"";
    NSString *appendString = @"";
    
    NSString *volumeUnitString = NSLocalizedString(@"VOLUME UNIT", nil);
    appendString = [NSString stringWithFormat:@"%@%@", saleOrderPosition.article.pieceVolume, volumeUnitString];
    detailedText = [detailedText stringByAppendingString:appendString];
    
    NSNumberFormatter *numberFormatter = [STMFunctions currencyFormatter];
    
    appendString = [NSString stringWithFormat:@", %@", NSLocalizedString(@"PRICE0", nil)];
    detailedText = [detailedText stringByAppendingString:appendString];
    
    appendString = [NSString stringWithFormat:@": %@", [numberFormatter stringFromNumber:price0]];
    detailedText = [detailedText stringByAppendingString:appendString];
    
    if ([price0 compare:price1] != NSOrderedSame) {
        
        appendString = [NSString stringWithFormat:@", %@", NSLocalizedString(@"PRICE1", nil)];
        detailedText = [detailedText stringByAppendingString:appendString];
        
        appendString = [NSString stringWithFormat:@": %@", [numberFormatter stringFromNumber:price1]];
        detailedText = [detailedText stringByAppendingString:appendString];
        
    }
    
    if ([price0 compare:priceOrigin] != NSOrderedSame) {
        
        appendString = [NSString stringWithFormat:@", %@", NSLocalizedString(@"PRICE ORIGIN", nil)];
        detailedText = [detailedText stringByAppendingString:appendString];
        
        appendString = [NSString stringWithFormat:@": %@", [numberFormatter stringFromNumber:priceOrigin]];
        detailedText = [detailedText stringByAppendingString:appendString];
        
        NSDecimalNumber *result = [price0 decimalNumberBySubtracting:priceOrigin];
        result = [result decimalNumberByDividingBy:priceOrigin];
        
        NSDecimalNumberHandler *behavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:3 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];

        NSDecimalNumber *discount = [result decimalNumberByRoundingAccordingToBehavior:behavior];
        
        numberFormatter = [STMFunctions percentFormatter];

        NSString *discountString = [numberFormatter stringFromNumber:discount];
        
        appendString = [NSString stringWithFormat:@", %@", discountString];
        detailedText = [detailedText stringByAppendingString:appendString];
        
    }

    return detailedText;
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CLOSE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonPressed)];

    [self setToolbarItems:@[flexibleSpace, closeButton]];

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
