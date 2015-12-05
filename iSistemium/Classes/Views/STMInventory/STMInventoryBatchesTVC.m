//
//  STMInventoryBatchesTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 05/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMInventoryBatchesTVC.h"


@interface STMInventoryBatchesTVC ()

@property (nonatomic, strong) UIAlertView *infoAlert;


@end


@implementation STMInventoryBatchesTVC

@synthesize resultsController = _resultsController;

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
    
        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMInventoryBatch class])];
        
        NSSortDescriptor *ctsDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"deviceCts"
                                                                        ascending:NO
                                                                         selector:@selector(compare:)];
        request.sortDescriptors = @[ctsDescriptor];
        
        request.predicate = [STMPredicate predicateWithNoFantoms];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                 managedObjectContext:self.document.managedObjectContext
                                                                   sectionNameKeyPath:@"ctsDayAsString"
                                                                            cacheName:nil];
        _resultsController.delegate = self;
        
    }
    return _resultsController;
    
}

- (void)showInfoAlert {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
       
//        self.infoAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"INVENTORY INFO TITLE", nil)
//                                                    message:NSLocalizedString(@"INVENTORY INFO MESSAGE", nil)
//                                                   delegate:nil
//                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
//                                          otherButtonTitles:nil];
//        [self.infoAlert show];
        
    }];
    
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [super controllerDidChangeContent:controller];
    
//    if (self.infoAlert.visible) {
//        [self.infoAlert dismissWithClickedButtonIndex:-1 animated:NO];
//    }
    
}


#pragma mark - table view data

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMTableViewCellStyleSubtitle *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    STMInventoryBatch *batch = [self.resultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = [[STMFunctions noDateShortTimeFormatter] stringFromDate:batch.deviceCts];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", @(batch.inventoryBatchItems.count)];
    
    return cell;
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];

    if (self.resultsController.fetchedObjects.count == 0) {
        [self showInfoAlert];
    }
    
    [self.tableView registerClass:[STMTableViewCellStyleSubtitle class] forCellReuseIdentifier:self.cellIdentifier];
    
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
