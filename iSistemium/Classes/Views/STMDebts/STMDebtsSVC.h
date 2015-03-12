//
//  STMDebtsSVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 31/07/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMOutletsTVC.h"
#import "STMDebtsDetailsPVC.h"
#import "STMCashingControlsVC.h"
#import "STMUI.h"

@interface STMDebtsSVC : STMSplitViewController

@property (nonatomic, strong) STMOutletsTVC *masterVC;
@property (nonatomic, strong) STMDebtsDetailsPVC *detailVC;
@property (nonatomic, weak) STMCashingControlsVC *controlsVC;

@property (nonatomic) BOOL outletLocked;

@end
