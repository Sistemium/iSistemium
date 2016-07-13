//
//  STMLocation+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 13/07/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMLocation.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMLocation (CoreDataProperties)

@property (nullable, nonatomic, retain) STMShipmentRoutePoint *shipmentRoutePoint;
@property (nullable, nonatomic, retain) NSSet<STMShippingLocation *> *shippings;
@property (nullable, nonatomic, retain) STMTrack *track;

@end

@interface STMLocation (CoreDataGeneratedAccessors)

- (void)addShippingsObject:(STMShippingLocation *)value;
- (void)removeShippingsObject:(STMShippingLocation *)value;
- (void)addShippings:(NSSet<STMShippingLocation *> *)values;
- (void)removeShippings:(NSSet<STMShippingLocation *> *)values;

@end

NS_ASSUME_NONNULL_END
