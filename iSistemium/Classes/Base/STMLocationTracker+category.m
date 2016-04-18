//
//  STMLocationTracker+category.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/04/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMLocationTracker+category.h"

#import "STMShipmentRouteController.h"


@implementation STMLocationTracker (category)

- (void)successAuthorization {
    
    if ([self.geotrackerControl isEqualToString:GEOTRACKER_CONTROL_SHIPMENT_ROUTE]) {
        
        NSUInteger startedRoutesCount = [STMShipmentRouteController routesWithProcessing:@"started"].count;

        if (startedRoutesCount > 0) {

            [self checkAccuracyToStartTracking];

        } else {

            if (self.tracking) [self stopTracking];

        }
        
    } else {
        
        [self initTimers];
        [self checkAccuracyToStartTracking];
        
    }
    
}


@end
