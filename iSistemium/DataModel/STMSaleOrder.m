//
//  STMSaleOrder.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMSaleOrder.h"
#import "STMOutlet.h"
#import "STMSaleOrderPosition.h"
#import "STMSalesman.h"
#import "STMShipment.h"


@implementation STMSaleOrder

@dynamic date;
@dynamic processing;
@dynamic processingMessage;
@dynamic totalCost;
@dynamic outlet;
@dynamic saleOrderPositions;
@dynamic salesman;
@dynamic shipments;

@end
