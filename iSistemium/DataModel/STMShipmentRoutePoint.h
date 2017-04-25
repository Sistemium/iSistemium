//
//  STMShipmentRoutePoint.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMDatum.h"

#import <MapKit/MapKit.h>


@class STMLocation, STMShipment, STMShipmentRoute, STMShipmentRoutePointPhoto, STMShippingLocation;

NS_ASSUME_NONNULL_BEGIN

@interface STMShipmentRoutePoint : STMDatum

- (NSString *)shortInfo;
- (void)updateShippingLocationWithGeocodedLocation:(CLLocation *)location;
- (void)updateShippingLocationWithConfirmedLocation:(CLLocation *)location;
- (void)updateShippingLocationWithUserLocation:(CLLocation *)location;


@end

NS_ASSUME_NONNULL_END

#import "STMShipmentRoutePoint+CoreDataProperties.h"
