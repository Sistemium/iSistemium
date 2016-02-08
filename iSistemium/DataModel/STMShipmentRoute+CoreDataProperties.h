//
//  STMShipmentRoute+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMShipmentRoute.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMShipmentRoute (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSString *processing;
@property (nullable, nonatomic, retain) NSString *processingMessage;
@property (nullable, nonatomic, retain) STMDriver *driver;
@property (nullable, nonatomic, retain) NSSet<STMShipmentRoutePoint *> *shipmentRoutePoints;

@end

@interface STMShipmentRoute (CoreDataGeneratedAccessors)

- (void)addShipmentRoutePointsObject:(STMShipmentRoutePoint *)value;
- (void)removeShipmentRoutePointsObject:(STMShipmentRoutePoint *)value;
- (void)addShipmentRoutePoints:(NSSet<STMShipmentRoutePoint *> *)values;
- (void)removeShipmentRoutePoints:(NSSet<STMShipmentRoutePoint *> *)values;

@end

NS_ASSUME_NONNULL_END
