//
//  STMLocation+category.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/04/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMLocation.h"

@class STMShipmentRoutePoint, STMShippingLocation, STMTrack;

NS_ASSUME_NONNULL_BEGIN

@interface STMLocation (category)

@property (nullable, nonatomic, retain) STMShipmentRoutePoint *shipmentRoutePoint;
@property (nullable, nonatomic, retain) NSSet<STMShippingLocation *> *shippings;
@property (nullable, nonatomic, retain) STMTrack *track;

@end

@interface STMLocation (CoreDataGeneratedAccessorsPulp)

- (void)addShippingsObject:(STMShippingLocation *)value;
- (void)removeShippingsObject:(STMShippingLocation *)value;
- (void)addShippings:(NSSet<STMShippingLocation *> *)values;
- (void)removeShippings:(NSSet<STMShippingLocation *> *)values;

@end

NS_ASSUME_NONNULL_END
