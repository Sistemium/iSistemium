//
//  STMInventoryBatchItemsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 05/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMInventoryBatchItemsTVC.h"

#import "STMInventoryProcessController.h"


@interface STMInventoryBatchItemsTVC ()


@end


@implementation STMInventoryBatchItemsTVC

@synthesize resultsController = _resultsController;

- (void)setBatch:(STMInventoryBatch *)batch {
    
    _batch = batch;
    [self performFetch];
    
}

- (NSFetchedResultsController *)resultsController {

    if (!_resultsController) {
        
        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMInventoryBatchItem class])];
        
        NSSortDescriptor *ctsDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"deviceCts"
                                                                        ascending:NO
                                                                         selector:@selector(compare:)];
        request.sortDescriptors = @[ctsDescriptor];
        request.predicate = [NSPredicate predicateWithFormat:@"inventoryBatch == %@", self.batch];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                 managedObjectContext:self.document.managedObjectContext
                                                                   sectionNameKeyPath:nil
                                                                            cacheName:nil];
        _resultsController.delegate = self;
        
    }
    return _resultsController;
    
}


#pragma mark - table view data

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMTableViewSubtitleStyleCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    STMInventoryBatchItem *item = [self.resultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = [[STMFunctions noDateMediumTimeFormatter] stringFromDate:item.deviceCts];
    
    cell.detailTextLabel.text = item.code;
    
    return cell;
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        STMInventoryBatchItem *item = [self.resultsController objectAtIndexPath:indexPath];
        [STMInventoryProcessController removeInventoryBatchItem:item];
        
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    [self.tableView registerClass:[STMTableViewSubtitleStyleCell class] forCellReuseIdentifier:self.cellIdentifier];
    
    [self performFetch];
    
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
