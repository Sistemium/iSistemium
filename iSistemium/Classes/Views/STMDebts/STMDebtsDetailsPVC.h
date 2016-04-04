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
#import "STMBarButtonItem.h"

@interface STMDebtsDetailsPVC : UIPageViewController //<UISplitViewControllerDelegate>

@property (nonatomic, strong) STMOutlet *outlet;
@property (nonatomic, strong) STMDebtsDetailsVC *debtsCombineVC;
@property (nonatomic, strong) STMDebtsDetailsVC *outletCashingVC;
@property (nonatomic, strong) UIBarButtonItem *addDebtButton;
@property (nonatomic, strong) UIBarButtonItem *editDebtsButton;
@property (nonatomic, strong) STMBarButtonItemDone *cashingButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

- (void)cashingProcessDone;

- (void)cashingButtonPressed;

- (void)cashingProcessStart;

- (void)dismissAddDebt;

- (void)setupSegmentedControl;

- (void)buttonsForVC:(UIViewController *)vc;

- (void)addDebtButtonPressed:(id)sender;

- (void)cashingProcessCancel;

- (void)addObservers;

@end
