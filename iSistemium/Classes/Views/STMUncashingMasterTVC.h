//
//  STMUncashingMasterTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMFetchedResultsControllerTVC.h"
#import "STMUncashing.h"

@interface STMUncashingMasterTVC : STMFetchedResultsControllerTVC

@property (nonatomic, strong) NSDecimalNumber *cashingSum;

- (void)selectRowWithUncashing:(STMUncashing *)uncashing;

@end


@interface STMCashingSumFRCD : NSObject <NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) UITableView *cashingSumTableView;


@end