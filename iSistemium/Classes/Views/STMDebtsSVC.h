//
//  STMDebtsSVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 31/07/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMDebtsTVC.h"
#import "STMDebtsDetailsTVC.h"

@interface STMDebtsSVC : UISplitViewController

@property (nonatomic, strong) STMDebtsTVC *masterVC;
@property (nonatomic, strong) STMDebtsDetailsTVC *detailVC;

@end
