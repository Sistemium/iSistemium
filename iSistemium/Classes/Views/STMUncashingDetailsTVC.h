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
@property (nonatomic, strong) UIBarButtonItem *handOverButton;
@property (nonatomic, strong) NSMutableDictionary *cashingDictionary;

- (void)uncashingDoneWithSum:(NSDecimalNumber *)summ;

@end
