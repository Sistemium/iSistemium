//
//  STMShippingLocation.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMLocation.h"

@class STMShipmentRoutePoint, STMShippingLocationPicture;

@interface STMShippingLocation : STMLocation

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSSet *shippingLocationPictures;
@property (nonatomic, retain) NSSet *shipmentRoutePoints;
@end

@interface STMShippingLocation (CoreDataGeneratedAccessors)

- (void)addShippingLocationPicturesObject:(STMShippingLocationPicture *)value;
- (void)removeShippingLocationPicturesObject:(STMShippingLocationPicture *)value;
- (void)addShippingLocationPictures:(NSSet *)values;
- (void)removeShippingLocationPictures:(NSSet *)values;

- (void)addShipmentRoutePointsObject:(STMShipmentRoutePoint *)value;
- (void)removeShipmentRoutePointsObject:(STMShipmentRoutePoint *)value;
- (void)addShipmentRoutePoints:(NSSet *)values;
- (void)removeShipmentRoutePoints:(NSSet *)values;

@end
