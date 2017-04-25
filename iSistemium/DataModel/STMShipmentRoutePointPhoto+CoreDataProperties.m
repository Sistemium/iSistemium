//
//  STMShipmentRoutePointPhoto+CoreDataProperties.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/04/2017.
//  Copyright © 2017 Sistemium UAB. All rights reserved.
//

#import "STMShipmentRoutePointPhoto+CoreDataProperties.h"

@implementation STMShipmentRoutePointPhoto (CoreDataProperties)

+ (NSFetchRequest<STMShipmentRoutePointPhoto *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"STMShipmentRoutePointPhoto"];
}

@dynamic shipmentRoutePoint;

@end
