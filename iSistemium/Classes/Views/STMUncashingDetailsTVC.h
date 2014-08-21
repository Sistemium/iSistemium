//
//  STMUncashingDetailsTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMFetchedResultsControllerTVC.h"
#import "STMUncashing.h"

@interface STMUncashingDetailsTVC : STMFetchedResultsControllerTVC <UISplitViewControllerDelegate>

@property (nonatomic, strong) STMUncashing *uncashing;

- (void)uncashingDone;

@end
