//
//  STMOrdersSVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMSplitViewController.h"
#import "STMSaleOrderController.h"
#import "STMOrdersMasterNC.h"
#import "STMOrdersMasterPVC.h"
#import "STMOrdersDetailTVC.h"

#import "STMSaleOrder.h"
#import "STMSaleOrderPosition.h"
#import "STMSalesman.h"
#import "STMOutlet.h"
#import "STMPartner.h"
#import "STMArticle.h"

#import "STMUI.h"
#import "STMFunctions.h"
#import "STMConstants.h"

@interface STMOrdersSVC : STMSplitViewController

@property (nonatomic, strong) STMOrdersMasterNC *masterNC;
@property (nonatomic, strong) STMOrdersMasterPVC *masterPVC;
@property (nonatomic, strong) STMOrdersDetailTVC *detailTVC;

@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) STMOutlet *selectedOutlet;
@property (nonatomic, strong) STMSalesman *selectedSalesman;
@property (nonatomic, strong) STMSaleOrder *selectedOrder;

- (void)orderWillSelected;

@end
