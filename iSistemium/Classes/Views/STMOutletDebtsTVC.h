//
//  STMOutletDebtsTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMOutlet.h"
#import "STMFetchedResultsControllerTVC.h"
#import "STMDebtsDetailsPVC.h"

@interface STMOutletDebtsTVC : STMFetchedResultsControllerTVC

@property (nonatomic, strong) STMOutlet *outlet;
@property (nonatomic, weak) STMDebtsDetailsPVC *parentVC;
//@property (nonatomic, strong) NSDecimalNumber *totalSum;

- (void)updateRowWithDebt:(STMDebt *)debt;

@end
