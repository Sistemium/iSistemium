//
//  STMLocationTracker.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 11/05/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMLocationTracker.h"

#import "STMShipmentRouteController.h"


@implementation STMLocationTracker

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
