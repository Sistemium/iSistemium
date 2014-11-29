//
//  STMCashingControlsVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMOutlet.h"
#import "STMDebt.h"
#import "STMOutletDebtsTVC.h"

@interface STMCashingControlsVC : UIViewController

@property (nonatomic, strong) STMOutlet *outlet;
@property (nonatomic, strong) STMOutletDebtsTVC *tableVC;
//@property (nonatomic, strong) NSMutableDictionary *debtsDictionary;
//@property (nonatomic, strong) NSMutableArray *debtsArray;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic) BOOL cashingLimitIsReached;

- (void)addCashing:(STMDebt *)debt;
- (void)removeCashing:(STMDebt *)debt;

@end
