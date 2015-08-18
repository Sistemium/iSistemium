//
//  STMShipmentRoutePoint+custom.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 01/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShipmentRoutePoint+custom.h"

#import "STMObjectsController.h"
#import "STMLocationController.h"


@implementation STMShipmentRoutePoint (custom)

- (NSString *)shortInfo {
    
    NSString *detailText = @"";
    
    if (self.shipments.count > 0) {
        
        NSString *shipmentsString = [NSString stringWithFormat:@"%lu%@ ", (unsigned long)self.shipments.count, NSLocalizedString(@"_SHIPMENTS", nil)];
        detailText = [detailText stringByAppendingString:shipmentsString];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"needCashing == YES"];
        NSUInteger needCashingCount = [self.shipments filteredSetUsingPredicate:predicate].count;
        
        if (needCashingCount > 0) {
            
            NSString *needCashingString = [NSString stringWithFormat:@"%lu%@ ", (unsigned long)needCashingCount, NSLocalizedString(@"_NEED_CASHING", nil)];
            detailText = [detailText stringByAppendingString:needCashingString];
            
        }
        
        NSNumber *positionsCount = [self.shipments valueForKeyPath:@"@sum.shipmentPositions.@count"];
        NSString *positionsString = [NSString stringWithFormat:@"%@%@ ", positionsCount, NSLocalizedString(@"_POSITIONS", nil)];
        detailText = [detailText stringByAppendingString:positionsString];
        
        NSNumber *approximateBoxCount = [self.shipments valueForKeyPath:@"@sum.approximateBoxCount"];
        NSString *boxCountString = [NSString stringWithFormat:@"%@%@ ", approximateBoxCount, NSLocalizedString(@"_BOXES", nil)];
        detailText = [detailText stringByAppendingString:boxCountString];
        
        NSNumber *bottleCount = [self.shipments valueForKeyPath:@"@sum.bottleCount"];
        NSString *bottleCountString = [NSString stringWithFormat:@"%@%@", bottleCount, NSLocalizedString(@"_BOTTLES", nil)];
        detailText = [detailText stringByAppendingString:bottleCountString];
        
    } else {        
        detailText = NSLocalizedString(@"0SHIPMENTS", nil);
    }

    return detailText;
    
}

- (void)updateShippingLocationWithGeocodedLocation:(CLLocation *)location {
    [self updateShippingLocationWithLocation:location confirmed:NO];
}

- (void)updateShippingLocationWithConfirmedLocation:(CLLocation *)location {
    [self updateShippingLocationWithLocation:location confirmed:YES];
}

- (void)updateShippingLocationWithLocation:(CLLocation *)location confirmed:(BOOL)confirmed {
    
    if (!self.shippingLocation) {
        
        STMShippingLocation *shippingLocation = (STMShippingLocation *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMShippingLocation class])];
        shippingLocation.isFantom = @(NO);
        
        self.shippingLocation = shippingLocation;
        
    }
    
    self.shippingLocation.location = [STMLocationController locationObjectFromCLLocation:location];
    self.shippingLocation.isLocationConfirmed = @(confirmed);

}

@end
