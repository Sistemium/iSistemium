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

@interface STMFetchedResultsControllerTVC : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, strong) STMDocument *document;

@end
