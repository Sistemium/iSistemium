//
//  STMUncashingDetailsTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMFetchedResultsControllerTVC.h"
#import "STMUncashing.h"
#import "STMUI.h"
#import "STMCashingController.h"

@interface STMUncashingDetailsTVC : STMFetchedResultsControllerTVC //<UISplitViewControllerDelegate>

@property (nonatomic, strong) STMUncashing *uncashing;
@property (nonatomic, strong) STMUIBarButtonItem *uncashingProcessButton;


- (void)dismissAddCashingPopover;

@end
