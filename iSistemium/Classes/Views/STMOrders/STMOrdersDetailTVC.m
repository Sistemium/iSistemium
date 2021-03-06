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

#import "STMSalesmanController.h"


@interface STMOrdersDetailTVC () <UIPopoverControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) STMOrdersSVC *splitVC;

@property (nonatomic, strong) STMSaleOrder *selectedOrder;
@property (nonatomic, strong) STMSaleOrder *processingOrder;

@property (nonatomic ,strong) NSArray *processingRoutes;

@property (nonatomic, strong) UIActionSheet *routesActionSheet;
@property (nonatomic) BOOL routesActionSheetWasVisible;

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

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMSaleOrder class])];
        
        NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO selector:@selector(compare:)];
        NSSortDescriptor *salesmanDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"salesman.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        NSSortDescriptor *outletDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"outlet.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        NSSortDescriptor *costDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"totalCost" ascending:NO selector:@selector(compare:)];
        
        request.sortDescriptors = @[dateDescriptor, salesmanDescriptor, outletDescriptor, costDescriptor];
        
//        NSCompoundPredicate *predicate = [self requestPredicate];
//        if (predicate.subpredicates.count > 0) request.predicate = predicate;
        
        request.predicate = [STMPredicate predicateWithNoFantomsFromPredicate:[self requestPredicate]];

        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:@"date" cacheName:nil];

        _resultsController.delegate = self;
        
    }
    
    return _resultsController;
    
}

- (NSCompoundPredicate *)selectingPredicate {

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
    
    if (self.splitVC.searchString && ![self.splitVC.searchString isEqualToString:@""]) {
        
        NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"outlet.name CONTAINS[cd] %@", self.splitVC.searchString];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, searchPredicate]];
        
    }
    
    NSPredicate *outletNamePredicate = [NSPredicate predicateWithFormat:@"outlet.name != %@", nil];
    predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, outletNamePredicate]];
    
    return predicate;

}

- (NSCompoundPredicate *)requestPredicate {
    
    NSCompoundPredicate *predicate = [self selectingPredicate];
    
    for (NSString *processing in self.splitVC.currentFilterProcessings) {
        
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
        [self setupToolbar];
        
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
        outlet = [STMFunctions shortCompanyName:self.splitVC.selectedOutlet.name];
    }

    if (self.splitVC.selectedDate) {
        
        NSDateFormatter *dateFormatter = [STMFunctions dateShortNoTimeFormatter];
        date = [dateFormatter stringFromDate:self.splitVC.selectedDate];
        
    }

    if (self.splitVC.selectedSalesman) {
        
        NSArray *salesmanNames = [self.splitVC.selectedSalesman.name componentsSeparatedByString:@" "];
        salesman = salesmanNames[0];
        
    }

    NSString *title = ([STMSalesmanController isItOnlyMeAmongSalesman]) ? [NSString stringWithFormat:@"%@ / %@", date, outlet] : [NSString stringWithFormat:@"%@ / %@ / %@", date, salesman, outlet];
    
    self.navigationItem.title = title;
    
}

- (void)infoLabelTapped:(id)sender {
    
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        
        UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
        
        STMCustom1TVCell *cell = [self cellForView:tap.view];
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        STMSaleOrder *saleOrder = [self.resultsController objectAtIndexPath:indexPath];
        
        self.processingRoutes = [STMSaleOrderController availableRoutesForProcessing:saleOrder.processing];

        self.processingOrder = saleOrder;
        [self showRoutesActionSheet];

    }
    
}

- (STMCustom1TVCell *)cellForView:(UIView *)view {
    
    UIView *superView = view.superview;
    
    if (superView) {
        
        if ([superView isKindOfClass:[STMCustom1TVCell class]]) {
            return (STMCustom1TVCell *)superView;
        } else {
            return [self cellForView:superView];
        }

    } else {
        return nil;
    }
    
}


#pragma mark - filter buttons

- (NSMutableDictionary *)filterButtons {
    
    if (!_filterButtons) {
        _filterButtons = [NSMutableDictionary dictionary];
    }
    return _filterButtons;
    
}

- (STMBarButtonItem *)filterButtonForProcessing:(NSString *)processing {
    
    NSString *filterProcessedLabel = [STMSaleOrderController labelForProcessing:processing];

    filterProcessedLabel = (filterProcessedLabel) ? filterProcessedLabel : processing;
    
    if (filterProcessedLabel) {
        
        STMSegmentedControl *filterProcessedSegmentedControl = [[STMSegmentedControl alloc] initWithItems:@[filterProcessedLabel]];
        filterProcessedSegmentedControl.selectedSegmentIndex = 0;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterButtonPressed:)];
        [filterProcessedSegmentedControl addGestureRecognizer:tap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(filterButtonLongPressed:)];
        [filterProcessedSegmentedControl addGestureRecognizer:longPress];
        
        STMBarButtonItem *filterButton = [[STMBarButtonItem alloc] initWithCustomView:filterProcessedSegmentedControl];
        return filterButton;

    } else {
        return nil;
    }
    
}

- (void)filterButtonPressed:(id)sender {
    
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        
        STMSegmentedControl *segmentedControl = (STMSegmentedControl *)[(UITapGestureRecognizer *)sender view];
        NSString *processing = [self processingForSegmentedControl:segmentedControl];
        
        if (segmentedControl.selectedSegmentIndex == 0) {
            
            segmentedControl.selectedSegmentIndex = -1;
            [self.splitVC addFilterProcessing:processing];
            
        } else {
            
            segmentedControl.selectedSegmentIndex = 0;
            [self.splitVC removeFilterProcessing:processing];
            
        }
        
    }
    
}

- (void)filterButtonLongPressed:(id)sender {
    
    if ([sender isKindOfClass:[UILongPressGestureRecognizer class]]) {
        
        UILongPressGestureRecognizer *longPressGesture = (UILongPressGestureRecognizer *)sender;
        
        if (longPressGesture.state == UIGestureRecognizerStateBegan) {
     
            self.splitVC.currentFilterProcessings = nil;

            STMSegmentedControl *pressedControl = (STMSegmentedControl *)[(UITapGestureRecognizer *)sender view];
            NSString *pressedProcessing = [self processingForSegmentedControl:pressedControl];
            
            pressedControl.selectedSegmentIndex = 0;

            NSMutableArray *remainingProcessings = [self.filterButtons.allKeys mutableCopy];
            [remainingProcessings removeObject:pressedProcessing];
            
            BOOL isAlone = YES;
            
            for (NSString *key in remainingProcessings) isAlone &= ![self processingIsSelectedForButton:self.filterButtons[key]];

            [self setProcessings:remainingProcessings selected:isAlone];
            
        }
        
    }
    
}

- (STMSegmentedControl *)segmentedControlForButton:(STMBarButtonItem *)button {
    
    if ([button.customView isKindOfClass:[STMSegmentedControl class]]) {
        return (STMSegmentedControl *)button.customView;
    } else {
        return nil;
    }
    
}

- (NSString *)processingForSegmentedControl:(STMSegmentedControl *)segmentedControl {
    
    NSString *title = [segmentedControl titleForSegmentAtIndex:0];
    NSString *processing = [STMSaleOrderController processingForLabel:title];
    
    return processing;
    
}

- (BOOL)processingIsSelectedForButton:(STMBarButtonItem *)button {
    
    STMSegmentedControl *control = [self segmentedControlForButton:button];
    return (control.selectedSegmentIndex != -1);
    
}

- (void)setProcessings:(NSArray *)processings selected:(BOOL)selected {
    
    for (NSString *processing in processings) {
        
        STMSegmentedControl *control = [self segmentedControlForButton:self.filterButtons[processing]];

        if (selected) {

            control.selectedSegmentIndex = 0;
            [self.splitVC removeFilterProcessing:processing];

        } else {
            
            control.selectedSegmentIndex = -1;
            [self.splitVC addFilterProcessing:processing];

        }
        
    }

}


#pragma mark - routesActionSheet

- (UIActionSheet *)routesActionSheet {
    
    if (!_routesActionSheet) {
        
        NSString *title = [STMSaleOrderController descriptionForProcessing:self.processingOrder.processing];
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
        if (self.processingRoutes.count > 0) {
            
            for (NSString *processing in self.processingRoutes) {
                [actionSheet addButtonWithTitle:[STMSaleOrderController labelForProcessing:processing]];
            }

        } else {
            [actionSheet addButtonWithTitle:@""];
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
            
            [self hideRoutesActionSheet];
            
            [self performSelector:@selector(showEditablesPopover) withObject:nil afterDelay:0];
            
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
        STMCustom1TVCell *cell = (STMCustom1TVCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        if (cell) {

            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.routesActionSheet showFromRect:cell.infoLabel.frame inView:cell.contentView animated:YES];
            }];
            
        }
        
    }
    
}

- (void)hideRoutesActionSheet {
    
    [self.routesActionSheet dismissWithClickedButtonIndex:-1 animated:NO];
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
    
    [self.editablesPopover presentPopoverFromRect:cell.infoLabel.frame
                                           inView:cell.contentView
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                         animated:YES];
    
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
    }
    [self hideEditablesPopover];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    self.cachedCellsHeights = nil;
    [self.tableView reloadData];
    
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

- (NSString *)cellIdentifier {
    return @"STMCustom1TVCell";
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (self.resultsController.sections.count > 0) {
        
        id <NSFetchedResultsSectionInfo> sectionInfo = self.resultsController.sections[section];
        
        STMSaleOrder *saleOrder = [[sectionInfo objects] lastObject];
        
        return (saleOrder.date) ? [STMFunctions dayWithDayOfWeekFromDate:(NSDate *)saleOrder.date] : nil;
        
    } else {
        
        return nil;
        
    }
    
}

- (UITableViewCell *)cellForHeightCalculationForIndexPath:(NSIndexPath *)indexPath {
    
    static STMCustom1TVCell *cell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    });
    
    return cell;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    STMCustom1TVCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];

    [self fillCell:cell atIndexPath:indexPath];

    return cell;
    
}

- (void)fillCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[STMCustom1TVCell class]]) {
        [self fillCustomCell:(STMCustom1TVCell *)cell atIndexPath:indexPath];
    }
    [super fillCell:cell atIndexPath:indexPath];
    
}

- (void)fillCustomCell:(STMCustom1TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMSaleOrder *saleOrder = [self.resultsController objectAtIndexPath:indexPath];
    
    UIColor *textColor = (!saleOrder.outlet.isActive || [saleOrder.outlet.isActive boolValue]) ? [UIColor blackColor] : [UIColor redColor];
    
    cell.titleLabel.textColor = textColor;
//    cell.detailLabel.textColor = textColor;
    
    cell.titleLabel.text = [STMFunctions shortCompanyName:saleOrder.outlet.name];
    
    NSNumberFormatter *currencyFormatter = [STMFunctions currencyFormatter];
    NSString *totalCostString = [currencyFormatter stringFromNumber:(NSDecimalNumber *)saleOrder.totalCost];
    
    NSUInteger positionsCount = saleOrder.saleOrderPositions.count;
    NSString *pluralTypeString = [[STMFunctions pluralTypeForCount:positionsCount] stringByAppendingString:@"POSITIONS"];
    
    NSString *positionsCountString = nil;
    
    if (positionsCount == 0) {
        positionsCountString = [NSString stringWithFormat:@"%@",NSLocalizedString(pluralTypeString, nil)];
    } else {
        positionsCountString = [NSString stringWithFormat:@"%lu %@", (unsigned long)positionsCount, NSLocalizedString(pluralTypeString, nil)];
    }
    
    NSString *detailText = nil;
    
    if ([STMSalesmanController isItOnlyMeAmongSalesman]) {
        detailText = [NSString stringWithFormat:@"%@, %@", totalCostString, positionsCountString];
    } else {
        detailText = [NSString stringWithFormat:@"%@, %@, %@", totalCostString, positionsCountString, saleOrder.salesman.name];
    }
    
    cell.detailLabel.text = detailText;
    
    cell.messageLabel.text = saleOrder.processingMessage;
    cell.messageLabel.textColor = [STMSaleOrderController messageColorForProcessing:saleOrder.processing];
    
    [self setupInfoLabelForCell:cell andSaleOrder:saleOrder];
    
}

- (void)setupInfoLabelForCell:(STMCustom1TVCell *)cell andSaleOrder:(STMSaleOrder *)saleOrder {

    NSString *processingLabel = [STMSaleOrderController labelForProcessing:saleOrder.processing];
    
    cell.infoLabel.text = (processingLabel) ? processingLabel : saleOrder.processing;
    
    for (UIGestureRecognizer *gestures in cell.infoLabel.gestureRecognizers) {
        [cell.infoLabel removeGestureRecognizer:gestures];
    }
    
    cell.infoLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(infoLabelTapped:)];
    [cell.infoLabel addGestureRecognizer:tap];
    
    UIColor *processingColor = [STMSaleOrderController colorForProcessing:saleOrder.processing];
    
    cell.infoLabel.textColor = (processingColor) ? processingColor : [UIColor blackColor];
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedOrder = [self.resultsController objectAtIndexPath:indexPath];

    [self performSegueWithIdentifier:@"showOrderInfo" sender:self];
    
    self.splitVC.selectedOrder = self.selectedOrder;
    [self.splitVC orderWillSelected];
    
    return indexPath;
    
}


#pragma mark - NSFetchedResultsController delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [super controllerDidChangeContent:controller];
    
    [self setupToolbar];
    
}


#pragma mark - toolbar

- (NSArray *)fetchSaleOrderProperty:(NSString *)property {
    
    NSString *entityName = NSStringFromClass([STMSaleOrder class]);
    
    STMEntityDescription *entity = [STMEntityDescription entityForName:entityName inManagedObjectContext:self.document.managedObjectContext];
    
    NSPropertyDescription *entityProperty = entity.propertiesByName[property];

    if (entityProperty) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        
        request.resultType = NSDictionaryResultType;
        request.returnsDistinctResults = YES;
        request.predicate = [self selectingPredicate];
        request.propertiesToFetch = @[property];
        
        NSArray *result = [self.document.managedObjectContext executeFetchRequest:request error:nil];
        
        return result;
        
    } else {
        
        return nil;
        
    }
    
}

- (NSArray *)processingLabelsForPropertyName:(NSString *)propertyName {

    NSArray *processings = [self fetchSaleOrderProperty:propertyName];

//    NSLog(@"processings %@", processings);
    
    NSMutableArray *processingLabels = [NSMutableArray array];
    
    for (NSDictionary *processing in processings) {
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:processing];
        dic[@"label"] = [STMSaleOrderController labelForProcessing:processing[propertyName]];
        
        [processingLabels addObject:dic];
        
    }
    
    NSSortDescriptor *labelDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"label" ascending:YES];
    
    NSArray *result = [processingLabels sortedArrayUsingDescriptors:@[labelDescriptor]];
    
    return result;

}

- (void)setupToolbar {
    
    NSString *propertyName = @"processing";

    NSArray *toolbarItems = [self toolbarItemsForPropertyName:propertyName];
    
    [self setScrollViewForToolbar:self.navigationController.toolbar withItems:toolbarItems];
    
}

- (NSArray *)toolbarItemsForPropertyName:(NSString *)propertyName {

    NSMutableArray *toolbarItems = [NSMutableArray array];
    
    STMBarButtonItem *flexibleSpace = [STMBarButtonItem flexibleSpace];
    [toolbarItems addObject:flexibleSpace];
    
    NSArray *processings = [self processingLabelsForPropertyName:propertyName];
    
    for (NSDictionary *processing in processings) {
        
        NSString *processingName = processing[propertyName];
        
        STMBarButtonItem *button = self.filterButtons[processingName];
        
        if (!button) {
            
            button = [self filterButtonForProcessing:processingName];
            if (button) self.filterButtons[processingName] = button;
            
        }
        
        if (button) [toolbarItems addObject:button];
        
    }
//// ------------------- TESTING DUBLICATE
//    for (NSDictionary *processing in processings) {
//        NSString *processingName = processing[propertyName];
//        STMBarButtonItem *button = [self filterButtonForProcessing:processingName];
//        [self.filterButtons setObject:button forKey:processingName];
//        [toolbarItems addObject:button];
//    }
//    for (NSDictionary *processing in processings) {
//        NSString *processingName = processing[propertyName];
//        STMBarButtonItem *button = [self filterButtonForProcessing:processingName];
//        [self.filterButtons setObject:button forKey:processingName];
//        [toolbarItems addObject:button];
//    }
//// -------------------
    [toolbarItems addObject:flexibleSpace];

    return toolbarItems;
    
}

- (void)setScrollViewForToolbar:(UIToolbar *)toolbar withItems:(NSArray *)toolbarItems {
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(0, 0, toolbar.frame.size.width, toolbar.frame.size.height);
    scrollView.bounds = toolbar.bounds;
    scrollView.autoresizingMask = toolbar.autoresizingMask;
    scrollView.bounces = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    
    UIToolbar *filtersToolbar = [[UIToolbar alloc] init];
    filtersToolbar.autoresizingMask = UIViewAutoresizingNone;
    [filtersToolbar setItems:toolbarItems];

    CGRect frame = [self requiredFrameForToolbar:filtersToolbar];
    filtersToolbar.frame = frame;
    
    scrollView.contentSize = frame.size;
    
    scrollView.tag = 1;
    [[toolbar viewWithTag:1] removeFromSuperview];
    
    [scrollView addSubview:filtersToolbar];
    [toolbar addSubview:scrollView];
    
}

- (CGRect)requiredFrameForToolbar:(UIToolbar *)toolbar {
    
    BOOL firstSegmentedControl = YES;
    CGFloat minX = 0.0;
    CGFloat maxX = 0.0;
    
    for (UIView *view in toolbar.subviews) {
        
        if ([view isKindOfClass:[STMSegmentedControl class]]) {
            
            CGPoint origin = view.frame.origin;
            CGSize size = view.frame.size;
            
            if (firstSegmentedControl) {
                
                minX = origin.x;
                maxX = origin.x + size.width;
                firstSegmentedControl = NO;

            }
            
            minX = (minX <= origin.x) ? minX : origin.x;
            maxX = (maxX >= origin.x + size.width) ? maxX : origin.x + size.width;
            
        }
        
    }

    CGFloat padding = 10;
    CGFloat width = maxX - minX + 2 * padding;
    
    UIToolbar *standardToolbar = self.navigationController.toolbar;
    CGSize standardSize = standardToolbar.frame.size;

    CGFloat minWidth = standardSize.width;
    
    width = (width > minWidth) ? width : minWidth;
    
    return CGRectMake(0, 0, width, standardSize.height);
    
}

- (void)toolBarLayoutDone {
    [self setupToolbar];
}

#pragma mark - device orientation

//- (void)deviceOrientationDidChangeNotification:(NSNotification *)notification {
//    
//}

#pragma mark - view lifecycle

- (void)customInit {
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([STMCustom1TVCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.cellIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(toolBarLayoutDone)
                                                 name:@"toolBarLayoutDone"
                                               object:self.navigationController.toolbar];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(deviceOrientationDidChangeNotification:)
//                                                 name:UIDeviceOrientationDidChangeNotification
//                                               object:nil];

    [self performFetch];
    
    [super customInit];

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
//    [self customInit];

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
        orderInfoTVC.navigationItem.title = self.navigationItem.title;
        
    }
    
}


@end
