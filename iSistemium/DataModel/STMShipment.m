//
//  STMShipment.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 10/07/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShipment.h"
#import "STMDriver.h"
#import "STMOutlet.h"
#import "STMSaleOrder.h"
#import "STMSalesman.h"
#import "STMShipmentPosition.h"
#import "STMShipmentRoutePoint.h"


@implementation STMShipment

@dynamic date;
@dynamic ndoc;
@dynamic needCashing;
@dynamic isProcessed;
@dynamic driver;
@dynamic outlet;
@dynamic saleOrder;
@dynamic salesman;
@dynamic shipmentPositions;
@dynamic shipmentRoutePoints;

@end
