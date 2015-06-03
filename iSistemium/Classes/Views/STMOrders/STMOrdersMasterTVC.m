//
//  STMOrdersMasterTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMOrdersMasterTVC.h"
#import "STMOrdersOutletTVC.h"

@interface STMOrdersMasterTVC ()

@end


@implementation STMOrdersMasterTVC

@synthesize resultsController = _resultsController;

- (STMOrdersSVC *)splitVC {
    
    if (!_splitVC) {
        
        if ([self.splitViewController isKindOfClass:[STMOrdersSVC class]]) {
            _splitVC = (STMOrdersSVC *)self.splitViewController;
        }
        
    }
    return _splitVC;
    
}

- (NSFetchRequest *)fetchRequest {
    return nil;
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [self fetchRequest];
        
        request.predicate = [STMPredicate predicateWithNoFantomsFromPredicate:request.predicate];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:self.sectionNameKeyPath cacheName:nil];
        
        _resultsController.delegate = self;
        
    }
    
    return _resultsController;
    
}

- (void)resetFilter {
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    [self performFetch];
    
    if ([self isKindOfClass:[STMOrdersOutletTVC class]]) {
        [super customInit];
    }
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

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
