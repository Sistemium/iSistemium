//
//  STMOrderInfoTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMFetchedResultsControllerTVC.h"
#import "STMOrdersSVC.h"


@interface STMOrderInfoTVC : STMFetchedResultsControllerTVC

#warning — have to use STMVariableCellsHeightTVC class?

@property (nonatomic, strong) STMSaleOrder *saleOrder;


@end
