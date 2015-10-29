//
//  STMOrdersListTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 29/05/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMOrdersListTVC.h"
#import "STMOrdersSVC.h"
#import "STMNS.h"

@interface STMOrdersListTVC ()

@property (nonatomic, weak) STMOrdersSVC *splitVC;


@end


@implementation STMOrdersListTVC

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
        
#warning - have to add index to sorting keys
        
        NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO selector:@selector(compare:)];
        NSSortDescriptor *salesmanDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"salesman.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        NSSortDescriptor *outletDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"outlet.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        NSSortDescriptor *costDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"totalCost" ascending:NO selector:@selector(compare:)];
        
        request.sortDescriptors = @[dateDescriptor, salesmanDescriptor, outletDescriptor, costDescriptor];
        
        request.predicate = [STMPredicate predicateWithNoFantomsFromPredicate:[self requestPredicate]];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:@"date" cacheName:nil];
        
        _resultsController.delegate = self;
        
    }
    
    return _resultsController;
    
}

- (NSCompoundPredicate *)requestPredicate {
    
    NSCompoundPredicate *predicate = [self selectingPredicate];
    
    for (NSString *processing in self.splitVC.currentFilterProcessings) {
        
        NSPredicate *processedPredicate = [NSPredicate predicateWithFormat:@"processing != %@", processing];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, processedPredicate]];
        
    }
    
    return predicate;
    
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

- (void)performFetch {
    
    self.resultsController = nil;
    
    NSError *error;
    if (![self.resultsController performFetch:&error]) {
        
        NSLog(@"performFetch error %@", error);
        
    } else {
        
        [self.tableView reloadData];
        
    }
    
}

- (void)refreshTable {
    
    [self performFetch];
    [self highlightSelectedOrder];
    
}

- (NSString *)cellIdentifier {
    return @"STMCustom6TVCell";
}

- (void)highlightSelectedOrder {
    
    NSIndexPath *indexPath = [self.resultsController indexPathForObject:self.splitVC.selectedOrder];
    
    if (indexPath) {
        
        if (self.resultsController.fetchedObjects.lastObject) {
            
            NSIndexPath *lastIndexPath = [self.resultsController indexPathForObject:(id _Nonnull)self.resultsController.fetchedObjects.lastObject];
            [self.tableView selectRowAtIndexPath:lastIndexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];

        }
        
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
        
    } else {
        
        if (self.resultsController.fetchedObjects.count > 0) {
            
            self.splitVC.selectedOrder = self.resultsController.fetchedObjects.firstObject;
            [self highlightSelectedOrder];
            
        }
        
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

- (UITableViewCell *)cellForHeightCalculationForIndexPath:(NSIndexPath *)indexPath {
    
    static STMCustom6TVCell *cell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    });
    
    return cell;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMCustom6TVCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    [self fillCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

- (void)fillCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[STMCustom6TVCell class]]) {
        [self fillCustomCell:(STMCustom6TVCell *)cell atIndexPath:indexPath];
    }
    [super fillCell:cell atIndexPath:indexPath];
    
}


- (void)fillCustomCell:(STMCustom6TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMSaleOrder *saleOrder = [self.resultsController objectAtIndexPath:indexPath];
    
    UIColor *textColor = (!saleOrder.outlet.isActive || [saleOrder.outlet.isActive boolValue]) ? [UIColor blackColor] : [UIColor redColor];
    
    cell.titleLabel.textColor = textColor;
    //    cell.detailLabel.textColor = textColor;
    
    cell.titleLabel.text = [STMFunctions shortCompanyName:saleOrder.outlet.name];
    
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

    NSString *detailText = nil;
    
    if ([STMSalesmanController isItOnlyMeAmongSalesman]) {
        detailText = [NSString stringWithFormat:@"%@, %@", totalCostString, positionsCountString];
    } else {
        detailText = [NSString stringWithFormat:@"%@, %@, %@", totalCostString, positionsCountString, saleOrder.salesman.name];
    }

    cell.detailLabel.text = detailText;
    
    cell.messageLabel.text = saleOrder.processingMessage;
    cell.messageLabel.textColor = [STMSaleOrderController messageColorForProcessing:saleOrder.processing];
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMSaleOrder *saleOrder = [self.resultsController objectAtIndexPath:indexPath];
    UIColor *processingColor = [STMSaleOrderController colorForProcessing:saleOrder.processing];

    [[cell.contentView viewWithTag:1] removeFromSuperview];
    
    CGFloat fillWidth = 5;
    
    CGRect rect = CGRectMake(cell.frame.size.width - fillWidth, 1, fillWidth, cell.frame.size.height-2);
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.tag = 1;
    view.backgroundColor = (processingColor) ? processingColor : [UIColor blackColor];
    
    [cell.contentView addSubview:view];
    [cell.contentView sendSubviewToBack:view];
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.splitVC.selectedOrder = [self.resultsController objectAtIndexPath:indexPath];
    
    return indexPath;
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([STMCustom6TVCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.cellIdentifier];
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self performFetch];
    
    [super customInit];

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
//    [self customInit];

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self highlightSelectedOrder];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [self.splitVC backButtonPressed];
    }
    [super viewWillDisappear:animated];
    
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
