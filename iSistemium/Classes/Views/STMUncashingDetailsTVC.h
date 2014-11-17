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

@interface STMUncashingDetailsTVC : STMFetchedResultsControllerTVC <UISplitViewControllerDelegate>

@property (nonatomic, strong) STMUncashing *uncashing;
@property (nonatomic, strong) STMUIBarButtonItem *handOverButton;
@property (nonatomic, strong) NSMutableDictionary *cashingDictionary;

- (void)cancelUncashingProccess;

- (void)uncashingDoneWithSum:(NSDecimalNumber *)summ
                       image:(UIImage *)image
                        type:(NSString *)type
                     comment:(NSString *)comment
                       place:(STMUncashingPlace *)place;

@end
