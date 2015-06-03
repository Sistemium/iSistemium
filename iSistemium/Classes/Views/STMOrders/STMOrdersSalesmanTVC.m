//
//  STMOrdersSalesmanTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMOrdersSalesmanTVC.h"
#import "STMOrdersSVC.h"

@interface STMOrdersSalesmanTVC ()

@end


@implementation STMOrdersSalesmanTVC

- (NSFetchRequest *)fetchRequest {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMSalesman class])];
    
    NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    request.sortDescriptors = @[nameSortDescriptor];
    
    return request;
    
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [super tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"ordersSalesmanCell";
    
    STMInfoTableViewCell *cell = [[STMInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    STMSalesman *salesman = [self.resultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = salesman.name;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell = nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMSalesman *salesman = [self.resultsController objectAtIndexPath:indexPath];
    
    NSArray *selectedIndexPaths = [tableView indexPathsForSelectedRows];
    
    if ([selectedIndexPaths containsObject:indexPath]) {
        
        self.splitVC.selectedSalesman = nil;
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        return nil;
        
    } else {
        
        self.splitVC.selectedSalesman = salesman;
        
        return indexPath;
        
    }
    
}


#pragma mark - view lifecycle

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (self.splitVC.selectedSalesman) {
        
        NSIndexPath *indexPath = [self.resultsController indexPathForObject:self.splitVC.selectedSalesman];
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
