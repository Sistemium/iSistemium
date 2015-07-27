//
//  STMShipment.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 19/07/15.
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
@dynamic isShipped;
@dynamic ndoc;
@dynamic needCashing;
@dynamic driver;
@dynamic outlet;
@dynamic saleOrder;
@dynamic salesman;
@dynamic shipmentPositions;
@dynamic shipmentRoutePoints;

@end
