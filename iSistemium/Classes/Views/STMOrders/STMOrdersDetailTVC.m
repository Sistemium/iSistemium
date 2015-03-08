//
//  STMOrdersDetailTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMOrdersDetailTVC.h"
#import "STMOrdersSVC.h"
#import "STMSaleOrderController.h"
#import "STMOrderInfoNC.h"

@interface STMOrdersDetailTVC () <UIPopoverControllerDelegate>

@property (nonatomic, weak) STMOrdersSVC *splitVC;
@property (nonatomic, strong) UIPopoverController *orderInfoPopover;
@property (nonatomic) BOOL orderInfoPopoverIsVisible;
@property (nonatomic, strong) STMSaleOrder *selectedOrder;


@end


@implementation STMOrdersDetailTVC

@synthesize resultsController = _resultsController;

- (STMOrdersSVC *)splitVC {
    
    if (!_splitVC) {
        
        if ([self.splitViewController isKindOfClass:[STMOrdersSVC class]]) {
            _splitVC = (STMOrdersSVC *)self.splitViewController;
        }
        
    }
    return _splitVC;
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMSaleOrder class])];
        
        NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO selector:@selector(compare:)];
        NSSortDescriptor *salesmanDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"salesman.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        
        request.sortDescriptors = @[dateDescriptor, salesmanDescriptor];
        
        NSCompoundPredicate *predicate = [self requestPredicate];
        if (predicate.subpredicates.count > 0) request.predicate = predicate;
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:@"date" cacheName:nil];
        
        _resultsController.delegate = self;
        
    }
    
    return _resultsController;
    
}

- (NSCompoundPredicate *)requestPredicate {
    
    NSCompoundPredicate *predicate = [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:@[]];
    
    if (self.splitVC.selectedDate) {
        
        NSPredicate *datePredicate = [NSPredicate predicateWithFormat:@"date == %@", self.splitVC.selectedDate];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, datePredicate]];
        
    }
    
    if (self.splitVC.selectedOutlet) {
        
        NSPredicate *outletPredicate = [NSPredicate predicateWithFormat:@"outlet == %@", self.splitVC.selectedOutlet];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, outletPredicate]];
        
    }

    if (self.splitVC.selectedSalesman) {
        
        NSPredicate *salesmanPredicate = [NSPredicate predicateWithFormat:@"salesman == %@", self.splitVC.selectedSalesman];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, salesmanPredicate]];
        
    }

    return predicate;
    
}

- (void)performFetch {
    
    self.resultsController = nil;
    
    NSError *error;
    if (![self.resultsController performFetch:&error]) {
        
        NSLog(@"performFetch error %@", error);
        
    } else {
        
        [self.tableView reloadData];
        [self updateTitle];
        
    }
    
}

- (void)refreshTable {
    [self performFetch];
}

- (void)updateTitle {
    
    NSString *date = NSLocalizedString(@"ALL DATES", nil);
    NSString *salesman = NSLocalizedString(@"ALL SALESMANS", nil);
    NSString *outlet = NSLocalizedString(@"ALL OUTLETS", nil);
    
    if (self.splitVC.selectedSalesman) {
        
        NSArray *salesmanNames = [self.splitVC.selectedSalesman.name componentsSeparatedByString:@" "];
        salesman = salesmanNames[0];
        
    }

    if (self.splitVC.selectedDate) {
        
        NSDateFormatter *dateFormatter = [STMFunctions dateShortNoTimeFormatter];
        date = [dateFormatter stringFromDate:self.splitVC.selectedDate];
        
    }

    if (self.splitVC.selectedOutlet) {
        outlet = self.splitVC.selectedOutlet.name;
    }

    self.navigationItem.title = [NSString stringWithFormat:@"%@ / %@ / %@", salesman, date, outlet];
    
}


#pragma mark - articleInfo popover

- (UIPopoverController *)orderInfoPopover {
    
    if (!_orderInfoPopover) {
        
        STMOrderInfoNC *orderInfoNC = [self.storyboard instantiateViewControllerWithIdentifier:@"orderInfoNC"];
        orderInfoNC.parentVC = self;
        orderInfoNC.saleOrder = self.selectedOrder;
        
        _orderInfoPopover = [[UIPopoverController alloc] initWithContentViewController:orderInfoNC];
        _orderInfoPopover.delegate = self;
        
    }
    return _orderInfoPopover;
    
}

- (void)showOrderInfoPopover {
    
    CGRect rect = CGRectMake(self.splitVC.view.frame.size.width/2, self.splitVC.view.frame.size.height/2, 1, 1);
    [self.orderInfoPopover presentPopoverFromRect:rect inView:self.splitVC.view permittedArrowDirections:0 animated:YES];
    
}

- (void)dismissOrderInfoPopover {
    
    [self.orderInfoPopover dismissPopoverAnimated:YES];
    self.orderInfoPopover = nil;
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    if (self.orderInfoPopoverIsVisible) {
        
        [self showOrderInfoPopover];
        self.orderInfoPopoverIsVisible = NO;
        
    }
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    if (self.orderInfoPopover.popoverVisible) {
        
        self.orderInfoPopoverIsVisible = YES;
        [self dismissOrderInfoPopover];
        
    }
    
}


#pragma mark - UIPopoverControllerDelegate

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    return YES;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.orderInfoPopover = nil;
}


#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (self.resultsController.sections.count > 0) {
        
        id <NSFetchedResultsSectionInfo> sectionInfo = self.resultsController.sections[section];
        
        STMSaleOrder *saleOrder = [[sectionInfo objects] lastObject];
        
        NSDate *date = saleOrder.date;
        
        NSString *dateString = [STMFunctions dayWithDayOfWeekFromDate:date];
        
        return dateString;
        
    } else {
        
        return nil;
        
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"orderCell";
    
    STMUIInfoTableViewCell *cell = [[STMUIInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];

    STMSaleOrder *saleOrder = [self.resultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = saleOrder.outlet.name;
    
    NSNumberFormatter *currencyFormatter = [STMFunctions currencyFormatter];
    NSString *totalCostString = [currencyFormatter stringFromNumber:saleOrder.totalCost];
    
    NSUInteger positionsCount = saleOrder.saleOrderPositions.count;
    NSString *pluralTypeString = [[STMFunctions pluralTypeForCount:positionsCount] stringByAppendingString:@"POSITIONS"];
    NSString *positionsCountString = [NSString stringWithFormat:@"%lu %@", (unsigned long)positionsCount, NSLocalizedString(pluralTypeString, nil)];
    
//    NSString *detailText = [NSString stringWithFormat:@"%@, %@, %@", totalCostString, positionsCountString, saleOrder.outlet.shortName];
    NSString *detailText = [NSString stringWithFormat:@"%@, %@", totalCostString, positionsCountString];

    cell.detailTextLabel.text = detailText;

    NSString *processingLabel = [STMSaleOrderController labelForProcessing:saleOrder.processing];
    
    cell.infoLabel.text = processingLabel;
    
    UIColor *processingColor = [STMSaleOrderController colorForProcessing:saleOrder.processing];
    
    if (processingColor) {
        cell.infoLabel.textColor = processingColor;
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell = nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedOrder = [self.resultsController objectAtIndexPath:indexPath];

    [self showOrderInfoPopover];
    
    return indexPath;
    
}

#pragma mark - view lifecycle

- (void)customInit {
    [self performFetch];
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
