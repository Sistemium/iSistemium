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

@interface STMOrdersDetailTVC () <UIPopoverControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) STMOrdersSVC *splitVC;
@property (nonatomic, strong) UIPopoverController *orderInfoPopover;
@property (nonatomic) BOOL orderInfoPopoverWasVisible;
@property (nonatomic, strong) STMSaleOrder *selectedOrder;
@property (nonatomic, strong) STMSaleOrder *processingOrder;
@property (nonatomic ,strong) NSArray *processingRoutes;
@property (nonatomic, strong) UIActionSheet *routesActionSheet;
@property (nonatomic) BOOL routesActionSheetWasVisible;
@property (nonatomic) BOOL filterProcessed;


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

- (BOOL)filterProcessed {
    
    if (!_filterProcessed) {
        _filterProcessed = NO;
    }
    return _filterProcessed;
    
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
    
    if (self.filterProcessed) {
        
        NSPredicate *processedPredicate = [NSPredicate predicateWithFormat:@"processing != %@", @"processed"];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, processedPredicate]];

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
    
    NSString *outlet = NSLocalizedString(@"ALL OUTLETS", nil);
    NSString *date = NSLocalizedString(@"ALL DATES", nil);
    NSString *salesman = NSLocalizedString(@"ALL SALESMANS", nil);
    
    if (self.splitVC.selectedOutlet) {
        outlet = self.splitVC.selectedOutlet.name;
    }

    if (self.splitVC.selectedDate) {
        
        NSDateFormatter *dateFormatter = [STMFunctions dateShortNoTimeFormatter];
        date = [dateFormatter stringFromDate:self.splitVC.selectedDate];
        
    }

    if (self.splitVC.selectedSalesman) {
        
        NSArray *salesmanNames = [self.splitVC.selectedSalesman.name componentsSeparatedByString:@" "];
        salesman = salesmanNames[0];
        
    }

    self.navigationItem.title = [NSString stringWithFormat:@"%@ / %@ / %@", date, salesman, outlet];
    
}

- (void)infoLabelTapped:(id)sender {
    
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        
        UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
        
        STMInfoTableViewCell *cell = [self cellForView:tap.view];
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        STMSaleOrder *saleOrder = [self.resultsController objectAtIndexPath:indexPath];
        
        self.processingRoutes = [STMSaleOrderController availableRoutesForProcessing:saleOrder.processing];

        if (self.processingRoutes.count > 0) {
            
            self.processingOrder = saleOrder;
            [self showRoutesActionSheet];
            
        } else {
            
            [self tableView:self.tableView willSelectRowAtIndexPath:indexPath];
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            
        }

    }
    
}

- (STMInfoTableViewCell *)cellForView:(UIView *)view {
    
    UIView *superView = view.superview;
    
    if (superView) {
        
        if ([superView isKindOfClass:[STMInfoTableViewCell class]]) {
            return (STMInfoTableViewCell *)superView;
        } else {
            return [self cellForView:superView];
        }

    } else {
        return nil;
    }
    
}

- (void)filterProcessedButtonPressed {
    
    self.filterProcessed = !self.filterProcessed;
    [self refreshTable];
    
}

#pragma mark - routesActionSheet

- (UIActionSheet *)routesActionSheet {
    
    if (!_routesActionSheet) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
        for (NSString *processing in self.processingRoutes) {
            [actionSheet addButtonWithTitle:[STMSaleOrderController labelForProcessing:processing]];
        }

        _routesActionSheet = actionSheet;
        
    }
    return _routesActionSheet;
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex >= 0 && buttonIndex < self.processingRoutes.count) {
        
        self.processingOrder.processing = self.processingRoutes[buttonIndex];
        
        NSIndexPath *indexPath = [self.resultsController indexPathForObject:self.processingOrder];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    self.routesActionSheet = nil;
}

- (void)showRoutesActionSheet {
    
    if (!self.routesActionSheet.isVisible) {
        
        NSIndexPath *indexPath = [self.resultsController indexPathForObject:self.processingOrder];
        STMInfoTableViewCell *cell = (STMInfoTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        [self.routesActionSheet showFromRect:cell.infoLabel.frame inView:cell.contentView animated:YES];
        
    }
    
}

- (void)hideRoutesActionSheet {
    
    [self.routesActionSheet dismissWithClickedButtonIndex:-1 animated:YES];
    self.routesActionSheet = nil;
    
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
    
    if (self.orderInfoPopoverWasVisible) {
        
        [self showOrderInfoPopover];
        self.orderInfoPopoverWasVisible = NO;
        
    }
    
    if (self.routesActionSheetWasVisible) {
        
        [self showRoutesActionSheet];
        self.routesActionSheetWasVisible = NO;
        
    }
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    if (self.orderInfoPopover.popoverVisible) {
        
        self.orderInfoPopoverWasVisible = YES;
        [self dismissOrderInfoPopover];
        
    }
    
    if (self.routesActionSheet.visible) {
        
        self.routesActionSheetWasVisible = YES;
        [self hideRoutesActionSheet];
        
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
        
        NSString *dateString = [STMFunctions dayWithDayOfWeekFromDate:saleOrder.date];
        
        return dateString;
        
    } else {
        
        return nil;
        
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"orderCell";
    
    STMInfoTableViewCell *cell = [[STMInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];

    STMSaleOrder *saleOrder = [self.resultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = saleOrder.outlet.name;
    
    NSNumberFormatter *currencyFormatter = [STMFunctions currencyFormatter];
    NSString *totalCostString = [currencyFormatter stringFromNumber:saleOrder.totalCost];
    
    NSUInteger positionsCount = saleOrder.saleOrderPositions.count;
    NSString *pluralTypeString = [[STMFunctions pluralTypeForCount:positionsCount] stringByAppendingString:@"POSITIONS"];
    
    NSString *positionsCountString = nil;
    
    if (positionsCount == 0) {
        positionsCountString = [NSString stringWithFormat:@"%@",NSLocalizedString(pluralTypeString, nil)];
    } else {
        positionsCountString = [NSString stringWithFormat:@"%lu %@", (unsigned long)positionsCount, NSLocalizedString(pluralTypeString, nil)];
    }
    
    NSString *detailText = [NSString stringWithFormat:@"%@, %@, %@", totalCostString, positionsCountString, saleOrder.salesman.name];

    cell.detailTextLabel.text = detailText;

    NSString *processingLabel = [STMSaleOrderController labelForProcessing:saleOrder.processing];
    
    cell.infoLabel.text = processingLabel;

    for (UIGestureRecognizer *gestures in cell.infoLabel.gestureRecognizers) {
        [cell.infoLabel removeGestureRecognizer:gestures];
    }
    
    cell.infoLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(infoLabelTapped:)];
    [cell.infoLabel addGestureRecognizer:tap];
    
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

- (void)setupToolbar {
    
    STMBarButtonItem *flexibleSpace = [STMBarButtonItem flexibleSpace];
    
    NSString *filterProcessedLabel = [STMSaleOrderController labelForProcessing:@"processed"];
    
    STMBarButtonItem *filterProcessedButton = [[STMBarButtonItem alloc] initWithTitle:filterProcessedLabel style:UIBarButtonItemStylePlain target:self action:@selector(filterProcessedButtonPressed)];
    
    [self setToolbarItems:@[flexibleSpace, filterProcessedButton, flexibleSpace]];
    
}

- (void)customInit {
    
    [self setupToolbar];
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
