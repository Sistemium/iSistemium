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
    
    return request;

}

- (NSArray *)ordersDates {
    
    NSMutableArray *ordersDates = [NSMutableArray array];
    
    for (STMSaleOrder *saleOrder in self.resultsController.fetchedObjects) {
        [ordersDates addObject:saleOrder.date];
    }
    
    NSSet *ordersDatesSet = [NSSet setWithArray:ordersDates];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO selector:@selector(compare:)];
    
    ordersDates = [[ordersDatesSet sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
    
    NSLog(@"volumes %@", ordersDates);
    
    return ordersDates;
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"ordersDateCell";
    
    STMUIInfoTableViewCell *cell = [[STMUIInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    NSDate *date = self.saleOrdersDates[indexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    cell.textLabel.text = [dateFormatter stringFromDate:date];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell = nil;
}


#pragma mark - NSFetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    self.saleOrdersDates = [self ordersDates];
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
