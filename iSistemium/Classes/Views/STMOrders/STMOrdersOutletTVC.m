//
//  STMOrdersOutletTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMOrdersOutletTVC.h"
#import "STMOrdersSVC.h"


@interface STMOrdersOutletTVC ()

@end


@implementation STMOrdersOutletTVC

@synthesize cellIdentifier = _cellIdentifier;


- (NSString *)cellIdentifier {
    
    if (!_cellIdentifier) {
        _cellIdentifier = @"ordersOutletCell";
    }
    return _cellIdentifier;
    
}

- (NSFetchRequest *)fetchRequest {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMOutlet class])];
    
    NSSortDescriptor *partnerNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"partner.name"
                                                                                ascending:YES
                                                                                 selector:@selector(compare:)];
    
    NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"shortName"
                                                                         ascending:YES
                                                                          selector:@selector(caseInsensitiveCompare:)];
    
    request.sortDescriptors = @[partnerNameSortDescriptor, nameSortDescriptor];
    
    request.predicate = [self predicate];
    
    self.sectionNameKeyPath = @"partner.name";
    
    return request;
    
}

- (NSPredicate *)predicate {
    
    NSMutableArray *subpredicates = [NSMutableArray array];
    
    NSPredicate *outletPredicate = [NSPredicate predicateWithFormat:@"(saleOrders.@count > 0) AND (partner.name != %@)", nil];
    
    [subpredicates addObject:outletPredicate];
    
    if (self.splitVC.searchString && ![self.splitVC.searchString isEqualToString:@""]) {
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", self.searchBar.text]];
    }
    
    if (self.splitVC.selectedDate) {
        
        NSPredicate *datePredicate = [NSPredicate predicateWithFormat:@"ANY saleOrders.date == %@", self.splitVC.selectedDate];
        [subpredicates addObject:datePredicate];
        
    }
    
    if (self.splitVC.selectedSalesman) {
        
        NSPredicate *salesmanPredicate = [NSPredicate predicateWithFormat:@"ANY saleOrders.salesman == %@", self.splitVC.selectedSalesman];
        [subpredicates addObject:salesmanPredicate];
        
    }
    
    NSCompoundPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
    
    return predicate;
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (self.splitVC.selectedOutlet) self.splitVC.selectedOutlet = nil;
    self.splitVC.searchString = searchText;

    [super searchBar:searchBar textDidChange:searchText];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    self.splitVC.searchString = nil;
    [super searchBarCancelButtonClicked:searchBar];
    
}

- (void)showSearchButton {
    
    NSMutableArray *toolbarItems = self.parentViewController.toolbarItems.mutableCopy;
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonPressed)];
    [toolbarItems addObject:searchButton];
    [self.parentViewController setToolbarItems:toolbarItems];
    
}

- (void)hideSearchButton {

    if ([self.parentViewController isKindOfClass:[STMOrdersMasterPVC class]]) {
        
        [self.parentViewController setToolbarItems:[(STMOrdersMasterPVC *)self.parentViewController defaultToolbarItemsArray]];
                
    }
    
}

- (void)resetFilter {
    
    [super resetFilter];
    [self searchBarCancelButtonClicked:self.searchBar];
    
}


#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [STMFunctions shortCompanyName:[super tableView:tableView titleForHeaderInSection:section]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMCustom7TVCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    [self fillCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

- (void)fillCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMCustom7TVCell *customCell = nil;
    
    if ([cell isKindOfClass:[STMCustom7TVCell class]]) {
        customCell = (STMCustom7TVCell *)cell;
    }
    
    STMOutlet *outlet = [self.resultsController objectAtIndexPath:indexPath];
    
    UIColor *textColor = (!outlet.isActive || [outlet.isActive boolValue]) ? [UIColor blackColor] : [UIColor redColor];
    
    customCell.titleLabel.textColor = textColor;
    customCell.detailLabel.textColor = textColor;
    
    customCell.titleLabel.text = outlet.shortName;
    
    NSUInteger count = outlet.saleOrders.count;
    NSString *pluralType = [STMFunctions pluralTypeForCount:count];
    NSString *ordersString = [pluralType stringByAppendingString:@"ORDERS"];
    
    NSString *ordersCountString = [NSString stringWithFormat:@"%lu %@", (unsigned long)count, NSLocalizedString(ordersString, nil)];
    
    customCell.detailLabel.text = ordersCountString;
    
    [super fillCell:customCell atIndexPath:indexPath];
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell = nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMOutlet *outlet = [self.resultsController objectAtIndexPath:indexPath];
    
    NSArray *selectedIndexPaths = [tableView indexPathsForSelectedRows];
    
    if ([selectedIndexPaths containsObject:indexPath]) {
        
        self.splitVC.selectedOutlet = nil;
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        return nil;
        
    } else {
        
        self.splitVC.selectedOutlet = outlet;
        
        return indexPath;
        
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([STMCustom7TVCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.cellIdentifier];

    [super customInit];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (self.splitVC.selectedOutlet) {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
            NSIndexPath *indexPath = [self.resultsController indexPathForObject:(STMOutlet * _Nonnull)self.splitVC.selectedOutlet];
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];

        }];
        
    }
    
    if (self.searchFieldIsScrolledAway) {
        [self showSearchButton];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self hideSearchButton];
    
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
