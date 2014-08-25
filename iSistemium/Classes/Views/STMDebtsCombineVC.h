//
//  STMDebtsCombineVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMDebtsDetailsVC.h"
#import "STMOutletDebtsTVC.h"
#import "STMCashingControlsVC.h"

@interface STMDebtsCombineVC : STMDebtsDetailsVC

@property (nonatomic, strong) STMOutletDebtsTVC *tableVC;
@property (nonatomic, strong) STMCashingControlsVC *controlsVC;

@end
