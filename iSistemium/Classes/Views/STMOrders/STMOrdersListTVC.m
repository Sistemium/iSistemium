//
//  STMOrdersListTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 29/05/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMOrdersListTVC.h"
#import "STMOrdersSVC.h"


@interface STMOrdersListTVC ()

@property (nonatomic, weak) STMOrdersSVC *splitVC;

@property (nonatomic, strong) NSMutableArray *currentFilterProcessings;
@property (nonatomic, strong) NSMutableDictionary *cachedCellsHeights;
@property (nonatomic, strong) NSString *custom6CellIdentifier;


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

- (NSMutableArray *)currentFilterProcessings {
    
    if (!_currentFilterProcessings) {
        _currentFilterProcessings = self.splitVC.currentFilterProcessings;
    }
    return _currentFilterProcessings;
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMSaleOrder class])];
        
        NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO selector:@selector(compare:)];
        NSSortDescriptor *salesmanDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"salesman.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        NSSortDescriptor *outletDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"outlet.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        NSSortDescriptor *costDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"totalCost" ascending:NO selector:@selector(compare:)];
        
        request.sortDescriptors = @[dateDescriptor, salesmanDescriptor, outletDescriptor, costDescriptor];
        
        NSCompoundPredicate *predicate = [self requestPredicate];
        if (predicate.subpredicates.count > 0) request.predicate = predicate;
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:@"date" cacheName:nil];
        
        _resultsController.delegate = self;
        
    }
    
    return _resultsController;
    
}

- (NSCompoundPredicate *)requestPredicate {
    
    NSCompoundPredicate *predicate = [self selectingPredicate];
    
    for (NSString *processing in self.currentFilterProcessings) {
        
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

- (NSString *)custom6CellIdentifier {
    
    if (!_custom6CellIdentifier) {
        _custom6CellIdentifier = @"STMCustom6TVCell";
    }
    return _custom6CellIdentifier;
    
}

- (void)highlightSelectedOrder {
    
    NSIndexPath *indexPath = [self.resultsController indexPathForObject:self.splitVC.selectedOrder];
    
    if (indexPath) {
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
    
}


#pragma mark - cell's height caching

- (NSMutableDictionary *)cachedCellsHeights {
    
    if (!_cachedCellsHeights) {
        _cachedCellsHeights = [NSMutableDictionary dictionary];
    }
    return _cachedCellsHeights;
    
}

- (void)putCachedHeight:(CGFloat)height forIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObjectID *objectID = [[self.resultsController objectAtIndexPath:indexPath] objectID];
    
    self.cachedCellsHeights[objectID] = @(height);
    
}

- (NSNumber *)getCachedHeightForIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObjectID *objectID = [[self.resultsController objectAtIndexPath:indexPath] objectID];
    
    return self.cachedCellsHeights[objectID];
    
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

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static CGFloat standardCellHeight;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        standardCellHeight = [[UITableViewCell alloc] init].frame.size.height;
    });
    
    return standardCellHeight + 1.0f;  // Add 1.0f for the cell separator height
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSNumber *cachedHeight = [self getCachedHeightForIndexPath:indexPath];
    CGFloat height = (cachedHeight) ? cachedHeight.floatValue : [self heightForCellAtIndexPath:indexPath];
    
    return height;
    
}

- (CGFloat)heightForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    static STMCustom6TVCell *cell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cell = [self.tableView dequeueReusableCellWithIdentifier:self.custom6CellIdentifier];
    });
    
    [self fillCell:cell atIndexPath:indexPath];
    
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(cell.bounds));
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    CGFloat height = size.height + 1.0f; // Add 1.0f for the cell separator height
    
    [self putCachedHeight:height forIndexPath:indexPath];
    
    return height;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMCustom6TVCell *cell = [tableView dequeueReusableCellWithIdentifier:self.custom6CellIdentifier forIndexPath:indexPath];
    
    [self fillCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

- (void)fillCell:(STMCustom6TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMSaleOrder *saleOrder = [self.resultsController objectAtIndexPath:indexPath];
    
    UIColor *textColor = (!saleOrder.outlet.isActive || [saleOrder.outlet.isActive boolValue]) ? [UIColor blackColor] : [UIColor redColor];
    
    cell.titleLabel.textColor = textColor;
    //    cell.detailLabel.textColor = textColor;
    
    cell.titleLabel.text = saleOrder.outlet.name;
    
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
    
    cell.detailLabel.text = detailText;
    
    cell.messageLabel.text = saleOrder.processingMessage;
    cell.messageLabel.textColor = [STMSaleOrderController messageColorForProcessing:saleOrder.processing];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.splitVC.selectedOrder = [self.resultsController objectAtIndexPath:indexPath];
    
    return indexPath;
    
}


#pragma mark - NSFetchedResultsController delegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if ([anObject isKindOfClass:[NSManagedObject class]]) {
        
        NSManagedObjectID *objectID = [(NSManagedObject *)anObject objectID];
        [self.cachedCellsHeights removeObjectForKey:objectID];
        
    }
    
    [super controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STMCustom6TVCell" bundle:nil] forCellReuseIdentifier:self.custom6CellIdentifier];
    self.clearsSelectionOnViewWillAppear = NO;
    
    [self performFetch];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

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
