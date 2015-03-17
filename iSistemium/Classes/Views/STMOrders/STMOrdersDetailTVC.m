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
#import "STMOrderInfoTVC.h"
#import "STMOrderEditablesVC.h"


@interface STMOrdersDetailTVC () <UIPopoverControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) STMOrdersSVC *splitVC;

@property (nonatomic, strong) STMSaleOrder *selectedOrder;
@property (nonatomic, strong) STMSaleOrder *processingOrder;

@property (nonatomic ,strong) NSArray *processingRoutes;

@property (nonatomic, strong) UIActionSheet *routesActionSheet;
@property (nonatomic) BOOL routesActionSheetWasVisible;

@property (nonatomic, strong) NSMutableArray *currentFilterProcessings;
@property (nonatomic, strong) NSMutableDictionary *filterButtons;

@property (nonatomic, strong) NSString *nextProcessing;
@property (nonatomic, strong) NSArray *editableProperties;
@property (nonatomic, strong) UIPopoverController *editablesPopover;
@property (nonatomic) BOOL editablesPopoverWasVisible;

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

- (STMBarButtonItem *)filterButtonForProcessing:(NSString *)processing {
    
    NSString *filterProcessedLabel = [STMSaleOrderController labelForProcessing:processing];
    
    STMSegmentedControl *filterProcessedSegmentedControl = [[STMSegmentedControl alloc] initWithItems:@[filterProcessedLabel]];
    filterProcessedSegmentedControl.selectedSegmentIndex = 0;
        
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterButtonPressed:)];
    [filterProcessedSegmentedControl addGestureRecognizer:tap];

    STMBarButtonItem *filterButton = [[STMBarButtonItem alloc] initWithCustomView:filterProcessedSegmentedControl];
    return filterButton;
    
}

- (NSMutableDictionary *)filterButtons {
    
    if (!_filterButtons) {
        _filterButtons = [NSMutableDictionary dictionary];
    }
    return _filterButtons;
    
}

- (NSMutableArray *)currentFilterProcessings {
    
    if (!_currentFilterProcessings) {
        _currentFilterProcessings = [NSMutableArray array];
    }
    return _currentFilterProcessings;
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
    
    for (NSString *processing in self.currentFilterProcessings) {
        
        NSPredicate *processedPredicate = [NSPredicate predicateWithFormat:@"processing != %@", processing];
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

- (void)filterButtonPressed:(id)sender {
    
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        
        STMSegmentedControl *segmentedControl = (STMSegmentedControl *)[(UITapGestureRecognizer *)sender view];
        NSString *title = [segmentedControl titleForSegmentAtIndex:0];
        NSString *processing = [STMSaleOrderController processingForLabel:title];
        
        if (segmentedControl.selectedSegmentIndex == 0) {
            
            segmentedControl.selectedSegmentIndex = -1;
            [self.currentFilterProcessings addObject:processing];
            
        } else {
            
            segmentedControl.selectedSegmentIndex = 0;
            [self.currentFilterProcessings removeObject:processing];
            
        }
        
        [self refreshTable];

    }
    
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
        
        self.nextProcessing = self.processingRoutes[buttonIndex];
        
        self.editableProperties = [STMSaleOrderController editablesPropertiesForProcessing:self.nextProcessing];

        if (self.editableProperties) {
            
            [self showEditablesPopover];
            
        } else {
            
            [STMSaleOrderController setProcessing:self.nextProcessing forSaleOrder:self.processingOrder];

        }

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


#pragma mark - editables popover

- (UIPopoverController *)editablesPopover {
    
    if (!_editablesPopover) {
        
        STMOrderEditablesVC *vc = [[STMOrderEditablesVC alloc] init];
        
        vc.fromProcessing = self.processingOrder.processing;
        vc.toProcessing = self.nextProcessing;
        vc.editableFields = self.editableProperties;
        vc.saleOrder = self.processingOrder;
        
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:vc];
        popover.delegate = self;
        popover.popoverContentSize = CGSizeMake(vc.view.frame.size.width, vc.view.frame.size.height);
        
        vc.popover = popover;
        
        _editablesPopover = popover;

    }
    return _editablesPopover;
    
}

- (void)showEditablesPopover {
    
    NSIndexPath *indexPath = [self.resultsController indexPathForObject:self.processingOrder];
    STMInfoTableViewCell *cell = (STMInfoTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    [self.editablesPopover presentPopoverFromRect:cell.infoLabel.frame inView:cell.contentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

- (void)hideEditablesPopover {
    
    [self.editablesPopover dismissPopoverAnimated:YES];
    self.editablesPopover = nil;
    
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
    self.editablesPopover = nil;
    
}


#pragma mark - rotate

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    if (self.routesActionSheet.isVisible) {
        
        self.routesActionSheetWasVisible = YES;
        [self hideRoutesActionSheet];
        
    }
    
    if (self.editablesPopover.isPopoverVisible) {
        
        self.editablesPopoverWasVisible = YES;
        [self hideEditablesPopover];
        
    }
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    if (self.routesActionSheetWasVisible) {
        
        self.routesActionSheetWasVisible = NO;
        [self showRoutesActionSheet];
        
    }
    
    if (self.editablesPopoverWasVisible) {
        
        self.editablesPopoverWasVisible = NO;
        [self showEditablesPopover];
        
    }
    
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
    
    STMInfoButtonTableViewCell *cell = [[STMInfoButtonTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];

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

    [self setupInfoLabelForCell:cell andSaleOrder:saleOrder];
    
    return cell;
    
}

- (void)setupInfoLabelForCell:(STMInfoTableViewCell *)cell andSaleOrder:(STMSaleOrder *)saleOrder {

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
    
    cell.infoLabel.backgroundColor = [UIColor blackColor];
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell = nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedOrder = [self.resultsController objectAtIndexPath:indexPath];

    [self performSegueWithIdentifier:@"showOrderInfo" sender:self];
    
    return indexPath;
    
}


#pragma mark - NSFetchedResultsController delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [super controllerDidChangeContent:controller];
    
    [self setupToolbar];
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
//    NSLog(@"anObject xid %@", [anObject valueForKey:@"xid"]);
//    NSLog(@"type %d", type);
    
    [super controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
    
}

- (NSArray *)fetchProperty:(NSString *)property {
    
    NSString *entityName = NSStringFromClass([STMSaleOrder class]);
    
    STMEntityDescription *entity = [STMEntityDescription entityForName:entityName inManagedObjectContext:self.document.managedObjectContext];
    
    NSPropertyDescription *entityProperty = entity.propertiesByName[property];

    if (entityProperty) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        
        request.resultType = NSManagedObjectResultType;
        
        NSArray *result = [self.document.managedObjectContext executeFetchRequest:request error:nil];
        
        NSMutableArray *resultArray = [NSMutableArray array];
        
        for (STMSaleOrder *saleOrder in result) {
            
            NSString *propertyValue = [saleOrder valueForKey:property];
            
            NSDictionary *dic = @{property:propertyValue};
            
            if (![resultArray containsObject:dic]) {
                [resultArray addObject:dic];
            }
            
//            NSLog(@"%@.%@ %@", entityName, property, propertyValue);
            
        }
        
//        NSLog(@"resultArray %@", resultArray);
        
        return resultArray;
        
        
//        NSString *propertyName = property;
//        
//        //    NSExpression *keypath = [NSExpression expressionForKeyPath:propertyName];
//        //    NSExpressionDescription *description = [[NSExpressionDescription alloc] init];
//        //    description.expression = keypath;
//        //    description.name = propertyName;
//        //    description.expressionResultType = NSStringAttributeType;
//        
//        request.propertiesToFetch = @[entityProperty];
//        request.propertiesToGroupBy = @[propertyName];
//        
//        request.resultType = NSDictionaryResultType;
//        
//        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:propertyName ascending:YES]];
//        
//        result = [self.document.managedObjectContext executeFetchRequest:request error:nil];
//        
//        NSLog(@"result %@", result);
//
//        return result;

        
    } else {
        
        return nil;
        
    }
    
}

#pragma mark - view lifecycle

- (void)setupToolbar {
    
    STMBarButtonItem *flexibleSpace = [STMBarButtonItem flexibleSpace];
//    [self setToolbarItems:@[flexibleSpace, self.filterProcessedButton, flexibleSpace]];

    NSMutableArray *toolbarItems = [NSMutableArray array];
    [toolbarItems addObject:flexibleSpace];
    
    NSString *propertyName = @"processing";
    
    NSArray *processings = [self fetchProperty:propertyName];
    
    NSMutableArray *processingArray = [NSMutableArray array];
    
    for (NSDictionary *processing in processings) {
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:processing];
        [dic setObject:[STMSaleOrderController labelForProcessing:processing[propertyName]] forKey:@"label"];
        
        [processingArray addObject:dic];
        
    }
    
    NSSortDescriptor *labelDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"label" ascending:YES];
    
    processings = [processingArray sortedArrayUsingDescriptors:@[labelDescriptor]];
    
//    NSLog(@"processings %@", processings);
    
    for (NSDictionary *processing in processings) {
        
        NSString *processingName = processing[propertyName];
        
        STMBarButtonItem *button = self.filterButtons[processingName];
        
        if (!button) {
            
            button = [self filterButtonForProcessing:processingName];
            [self.filterButtons setObject:button forKey:processingName];
            
        }
        
        [toolbarItems addObject:button];
        
    }
    
    [toolbarItems addObject:flexibleSpace];
    
    [self setToolbarItems:toolbarItems];
    
}

- (void)customInit {
    
//    [self setupToolbar];
    [self performFetch];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self setupToolbar];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"showOrderInfo"]) {
        
        STMOrderInfoTVC *orderInfoTVC = (STMOrderInfoTVC *)segue.destinationViewController;
        orderInfoTVC.saleOrder = self.selectedOrder;
        
    }
    
}


@end
