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

- (NSFetchRequest *)fetchRequest {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMOutlet class])];
    
    NSSortDescriptor *partnerNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"partner.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"shortName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    request.sortDescriptors = @[partnerNameSortDescriptor, nameSortDescriptor];
    
    request.predicate = [NSPredicate predicateWithFormat:@"saleOrders.@count > 0"];
    
    self.sectionNameKeyPath = @"partner.name";
    
    return request;
    
}


#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"ordersOutletCell";
    
    STMUIInfoTableViewCell *cell = [[STMUIInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    STMOutlet *outlet = [self.resultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = outlet.shortName;
    
    NSUInteger count = outlet.saleOrders.count;
    NSString *pluralType = [STMFunctions pluralTypeForCount:count];
    NSString *ordersString = [pluralType stringByAppendingString:@"ORDERS"];
    
    NSString *ordersCountString = [NSString stringWithFormat:@"%lu %@", (unsigned long)count, NSLocalizedString(ordersString, nil)];
    
    cell.detailTextLabel.text = ordersCountString;
    
    return cell;
    
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

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (self.splitVC.selectedOutlet) {
        
        NSIndexPath *indexPath = [self.resultsController indexPathForObject:self.splitVC.selectedOutlet];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        
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
