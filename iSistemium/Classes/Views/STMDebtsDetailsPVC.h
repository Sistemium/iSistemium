//
//  STMDebtDetailsPVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 31/07/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMOutlet.h"
#import "STMDebtsDetailsVC.h"

@interface STMDebtsDetailsPVC : UIPageViewController <UISplitViewControllerDelegate>

@property (nonatomic, strong) STMOutlet *outlet;
//@property (nonatomic) BOOL isCashingProcessing;
@property (nonatomic, strong) STMDebtsDetailsVC *debtsCombineVC;
@property (nonatomic, strong) STMDebtsDetailsVC *outletCashingVC;

- (void)cashingButtonPressed;

- (void)dismissAddDebt;

@end
