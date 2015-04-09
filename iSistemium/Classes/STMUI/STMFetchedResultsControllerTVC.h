//
//  STMFetchedResultsControllerTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 11/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "STMDocument.h"
#import "STMSessionManager.h"

#import "STMAuthController.h"

@interface STMFetchedResultsControllerTVC : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, strong) STMDocument *document;

@property (nonatomic, strong) NSMutableIndexSet *deletedSectionIndexes;
@property (nonatomic, strong) NSMutableIndexSet *insertedSectionIndexes;
@property (nonatomic, strong) NSMutableArray *deletedRowIndexPaths;
@property (nonatomic, strong) NSMutableArray *insertedRowIndexPaths;
@property (nonatomic, strong) NSMutableArray *updatedRowIndexPaths;

- (NSIndexPath *)tableView:(UITableView *)tableView nearestIndexPathFor:(NSIndexPath *)indexPath;

@end