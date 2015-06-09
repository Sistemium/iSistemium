//
//  STMOrdersDateTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMOrdersDateTVC.h"
#import "STMOrdersSVC.h"

@interface STMOrdersDateTVC ()

@property (nonatomic, strong) NSArray *saleOrdersDates;


@end


@implementation STMOrdersDateTVC

@synthesize saleOrdersDates = _saleOrdersDates;

- (NSArray *)saleOrdersDates {
    
    if (!_saleOrdersDates) {
        _saleOrdersDates = [self ordersDates];
    }
    return _saleOrdersDates;
    
}

- (void)setSaleOrdersDates:(NSArray *)saleOrdersDates {
    
    if (![_saleOrdersDates isEqualToArray:saleOrdersDates]) {
        
        _saleOrdersDates = saleOrdersDates;
        [self.tableView reloadData];
        
    }
    
}


- (NSFetchRequest *)fetchRequest {

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMSaleOrder class])];
    
    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO selector:@selector(compare:)];
    
    request.sortDescriptors = @[dateSortDescriptor];
    request.predicate = [self predicate];
    
    return request;

}

- (void)performFetch {
    
    self.saleOrdersDates = nil;

    [super performFetch];
    
}

- (NSArray *)ordersDates {
    
    NSMutableArray *ordersDates = [NSMutableArray array];
    
    for (STMSaleOrder *saleOrder in self.resultsController.fetchedObjects) {
        [ordersDates addObject:saleOrder.date];
    }
    
    NSSet *ordersDatesSet = [NSSet setWithArray:ordersDates];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO selector:@selector(compare:)];
    
    ordersDates = [[ordersDatesSet sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
    
    return ordersDates;
    
}

- (NSPredicate *)predicate {
    
    NSMutableArray *subpredicates = [NSMutableArray array];
    
    if (self.splitVC.selectedOutlet) {
        
        NSPredicate *outletPredicate = [NSPredicate predicateWithFormat:@"outlet == %@", self.splitVC.selectedOutlet];
        [subpredicates addObject:outletPredicate];
        
    }

    if (self.splitVC.searchString && ![self.splitVC.searchString isEqualToString:@""]) {
        
        NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"outlet.name CONTAINS[cd] %@", self.splitVC.searchString];
        [subpredicates addObject:searchPredicate];
        
    }
    
    if (self.splitVC.selectedSalesman) {
        
        NSPredicate *salesmanPredicate = [NSPredicate predicateWithFormat:@"salesman == %@", self.splitVC.selectedSalesman];
        [subpredicates addObject:salesmanPredicate];
        
    }
    
    NSCompoundPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
    
    return predicate;
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.saleOrdersDates.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [super tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"ordersDateCell";
    
    STMInfoTableViewCell *cell = [[STMInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    NSDate *date = self.saleOrdersDates[indexPath.row];
    
    cell.textLabel.text = [STMFunctions dayWithDayOfWeekFromDate:date];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell = nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDate *date = self.saleOrdersDates[indexPath.row];
    
    NSArray *selectedIndexPaths = [tableView indexPathsForSelectedRows];
    
    if ([selectedIndexPaths containsObject:indexPath]) {
        
        self.splitVC.selectedDate = nil;
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        return nil;
        
    } else {
        
        self.splitVC.selectedDate = date;
                
        return indexPath;
        
    }
    
}


#pragma mark - NSFetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    self.saleOrdersDates = [self ordersDates];
    [self.tableView reloadData];
    
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
}


#pragma mark - view lifecycle

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    [self performFetch];
    
    if (self.splitVC.selectedDate) {
        
        NSUInteger index = [self.saleOrdersDates indexOfObject:self.splitVC.selectedDate];
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
