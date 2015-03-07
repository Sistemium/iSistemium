//
//  STMOrdersSVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMUISplitViewController.h"
#import "STMOrdersMasterPVC.h"
#import "STMOrdersDetailTVC.h"

#import "STMSaleOrder.h"
#import "STMSaleOrderPosition.h"
#import "STMSalesman.h"
#import "STMOutlet.h"
#import "STMArticle.h"

#import "STMUI.h"
#import "STMFunctions.h"
#import "STMConstants.h"

@interface STMOrdersSVC : STMUISplitViewController

@property (nonatomic, strong) STMOrdersMasterPVC *masterPVC;
@property (nonatomic, strong) STMOrdersDetailTVC *detailTVC;

@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) STMOutlet *selectedOutlet;
@property (nonatomic, strong) STMSalesman *selectedSalesman;


@end
