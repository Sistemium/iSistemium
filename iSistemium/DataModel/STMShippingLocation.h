//
//  STMShippingLocation.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMLocation, STMShipmentRoutePoint, STMShippingLocationPicture;

@interface STMShippingLocation : STMComment

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * isLocationConfirmed;
@property (nonatomic, retain) STMLocation *location;
@property (nonatomic, retain) NSSet *shipmentRoutePoints;
@property (nonatomic, retain) NSSet *shippingLocationPictures;
@end

@interface STMShippingLocation (CoreDataGeneratedAccessors)

- (void)addShipmentRoutePointsObject:(STMShipmentRoutePoint *)value;
- (void)removeShipmentRoutePointsObject:(STMShipmentRoutePoint *)value;
- (void)addShipmentRoutePoints:(NSSet *)values;
- (void)removeShipmentRoutePoints:(NSSet *)values;

- (void)addShippingLocationPicturesObject:(STMShippingLocationPicture *)value;
- (void)removeShippingLocationPicturesObject:(STMShippingLocationPicture *)value;
- (void)addShippingLocationPictures:(NSSet *)values;
- (void)removeShippingLocationPictures:(NSSet *)values;

@end
