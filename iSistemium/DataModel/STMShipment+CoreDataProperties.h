//
//  STMShipment+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMShipment.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMShipment (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSNumber *isShipped;
@property (nullable, nonatomic, retain) NSString *ndoc;
@property (nullable, nonatomic, retain) NSNumber *needCashing;
@property (nullable, nonatomic, retain) STMDriver *driver;
@property (nullable, nonatomic, retain) STMOutlet *outlet;
@property (nullable, nonatomic, retain) STMSaleOrder *saleOrder;
@property (nullable, nonatomic, retain) STMSalesman *salesman;
@property (nullable, nonatomic, retain) NSSet<STMShipmentPosition *> *shipmentPositions;
@property (nullable, nonatomic, retain) NSSet<STMShipmentRoutePoint *> *shipmentRoutePoints;

@end

@interface STMShipment (CoreDataGeneratedAccessors)

- (void)addShipmentPositionsObject:(STMShipmentPosition *)value;
- (void)removeShipmentPositionsObject:(STMShipmentPosition *)value;
- (void)addShipmentPositions:(NSSet<STMShipmentPosition *> *)values;
- (void)removeShipmentPositions:(NSSet<STMShipmentPosition *> *)values;

- (void)addShipmentRoutePointsObject:(STMShipmentRoutePoint *)value;
- (void)removeShipmentRoutePointsObject:(STMShipmentRoutePoint *)value;
- (void)addShipmentRoutePoints:(NSSet<STMShipmentRoutePoint *> *)values;
- (void)removeShipmentRoutePoints:(NSSet<STMShipmentRoutePoint *> *)values;

@end

NS_ASSUME_NONNULL_END
