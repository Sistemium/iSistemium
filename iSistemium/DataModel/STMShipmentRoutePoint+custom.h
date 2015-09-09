//
//  STMShipmentRoutePoint+custom.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 01/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShipmentRoutePoint.h"
#import <MapKit/MapKit.h>


@interface STMShipmentRoutePoint (custom)

- (NSString *)shortInfo;
- (void)updateShippingLocationWithGeocodedLocation:(CLLocation *)location;
- (void)updateShippingLocationWithConfirmedLocation:(CLLocation *)location;
- (void)updateShippingLocationWithUserLocation:(CLLocation *)location;


@end
