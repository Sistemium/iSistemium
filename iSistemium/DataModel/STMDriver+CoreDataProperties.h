//
//  STMDriver+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMDriver.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMDriver (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<STMShipmentRoute *> *shipmentRoutes;
@property (nullable, nonatomic, retain) NSSet<STMShipment *> *shipments;

@end

@interface STMDriver (CoreDataGeneratedAccessors)

- (void)addShipmentRoutesObject:(STMShipmentRoute *)value;
- (void)removeShipmentRoutesObject:(STMShipmentRoute *)value;
- (void)addShipmentRoutes:(NSSet<STMShipmentRoute *> *)values;
- (void)removeShipmentRoutes:(NSSet<STMShipmentRoute *> *)values;

- (void)addShipmentsObject:(STMShipment *)value;
- (void)removeShipmentsObject:(STMShipment *)value;
- (void)addShipments:(NSSet<STMShipment *> *)values;
- (void)removeShipments:(NSSet<STMShipment *> *)values;

@end

NS_ASSUME_NONNULL_END
