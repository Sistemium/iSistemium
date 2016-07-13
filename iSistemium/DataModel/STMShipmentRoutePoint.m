//
//  STMShipmentRoutePoint.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMShipmentRoutePoint.h"
#import "STMLocation.h"
#import "STMShipment.h"
#import "STMShipmentRoute.h"
#import "STMShippingLocation.h"

#import "STMObjectsController.h"
#import "STMLocationController.h"


@implementation STMShipmentRoutePoint

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
        
        NSDictionary *appSettings = [[STMObjectsController session].settingsController currentSettingsForGroup:@"appSettings"];
        BOOL enableShowBottles = [appSettings[@"enableShowBottles"] boolValue];
        
        NSString *bottleString = (enableShowBottles) ? NSLocalizedString(@"_BOTTLES", nil) : NSLocalizedString(@"_PIECES", nil);
        
        NSNumber *bottleCount = [self.shipments valueForKeyPath:@"@sum.bottleCount"];
        NSString *bottleCountString = [NSString stringWithFormat:@"%@%@", bottleCount, bottleString];
        detailText = [detailText stringByAppendingString:bottleCountString];
        
    } else {
        detailText = NSLocalizedString(@"0SHIPMENTS", nil);
    }
    
    return detailText;
    
}

- (void)updateShippingLocationWithGeocodedLocation:(CLLocation *)location {
    [self updateShippingLocationWithLocation:location confirmed:NO source:@"geocoder"];
}

- (void)updateShippingLocationWithUserLocation:(CLLocation *)location {
    [self updateShippingLocationWithLocation:location confirmed:NO source:@"user"];
}

- (void)updateShippingLocationWithConfirmedLocation:(CLLocation *)location {
    [self updateShippingLocationWithLocation:location confirmed:YES source:nil];
}

- (void)updateShippingLocationWithLocation:(CLLocation *)location confirmed:(BOOL)confirmed source:(NSString *)source {
    
    if (!self.shippingLocation) {
        
        STMShippingLocation *shippingLocation = (STMShippingLocation *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMShippingLocation class]) isFantom:NO];
        
        self.shippingLocation = shippingLocation;
        
    }
    
    STMLocation *locationObject = (STMLocation *)[STMLocationController locationObjectFromCLLocation:location];
    
    if (source) locationObject.source = source;
    
    self.shippingLocation.location = locationObject;
    self.shippingLocation.isLocationConfirmed = @(confirmed);
    self.shippingLocation.name = self.shortName;
    self.shippingLocation.address = self.address;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shippingLocationUpdated" object:self];
    
}


@end
