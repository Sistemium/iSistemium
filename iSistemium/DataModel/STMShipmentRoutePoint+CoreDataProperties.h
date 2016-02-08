//
//  STMShipmentRoutePoint+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMShipmentRoutePoint.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMShipmentRoutePoint (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *address;
@property (nullable, nonatomic, retain) NSNumber *isReached;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *ord;
@property (nullable, nonatomic, retain) NSString *processing;
@property (nullable, nonatomic, retain) NSString *processingMessage;
@property (nullable, nonatomic, retain) NSString *shortName;
@property (nullable, nonatomic, retain) STMLocation *reachedAtLocation;
@property (nullable, nonatomic, retain) STMShipmentRoute *shipmentRoute;
@property (nullable, nonatomic, retain) NSSet<STMShipment *> *shipments;
@property (nullable, nonatomic, retain) STMShippingLocation *shippingLocation;

@end

@interface STMShipmentRoutePoint (CoreDataGeneratedAccessors)

- (void)addShipmentsObject:(STMShipment *)value;
- (void)removeShipmentsObject:(STMShipment *)value;
- (void)addShipments:(NSSet<STMShipment *> *)values;
- (void)removeShipments:(NSSet<STMShipment *> *)values;

@end

NS_ASSUME_NONNULL_END
