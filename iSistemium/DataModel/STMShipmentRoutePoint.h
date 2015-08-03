//
//  STMShipmentRoutePoint.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMLocation, STMShipment, STMShipmentRoute, STMShippingLocation;

@interface STMShipmentRoutePoint : STMComment

@property (nonatomic, retain) NSNumber * isReached;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * ord;
@property (nonatomic, retain) NSNumber * localOrd;
@property (nonatomic, retain) STMLocation *reachedAtLocation;
@property (nonatomic, retain) STMShipmentRoute *shipmentRoute;
@property (nonatomic, retain) NSSet *shipments;
@property (nonatomic, retain) STMShippingLocation *shippingLocation;
@end

@interface STMShipmentRoutePoint (CoreDataGeneratedAccessors)

- (void)addShipmentsObject:(STMShipment *)value;
- (void)removeShipmentsObject:(STMShipment *)value;
- (void)addShipments:(NSSet *)values;
- (void)removeShipments:(NSSet *)values;

@end
