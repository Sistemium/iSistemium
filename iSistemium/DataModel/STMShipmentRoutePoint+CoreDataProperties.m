//
//  STMShipmentRoutePoint+CoreDataProperties.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/04/2017.
//  Copyright © 2017 Sistemium UAB. All rights reserved.
//

#import "STMShipmentRoutePoint+CoreDataProperties.h"

@implementation STMShipmentRoutePoint (CoreDataProperties)

+ (NSFetchRequest<STMShipmentRoutePoint *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"STMShipmentRoutePoint"];
}

@dynamic address;
@dynamic commentText;
@dynamic deviceCts;
@dynamic deviceTs;
@dynamic id;
@dynamic isFantom;
@dynamic isReached;
@dynamic lts;
@dynamic name;
@dynamic ord;
@dynamic ownerXid;
@dynamic processing;
@dynamic processingMessage;
@dynamic shortName;
@dynamic source;
@dynamic sqts;
@dynamic sts;
@dynamic xid;
@dynamic reachedAtLocation;
@dynamic shipmentRoute;
@dynamic shipments;
@dynamic shippingLocation;
@dynamic photos;

@end
