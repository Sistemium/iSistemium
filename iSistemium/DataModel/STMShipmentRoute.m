//
//  STMShipmentRoute.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 24/10/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMShipmentRoute.h"
#import "STMDriver.h"
#import "STMShipmentRoutePoint.h"

#import "STMFunctions.h"
#import "STMNS.h"

#import "STMShippingProcessController.h"


@implementation STMShipmentRoute

- (NSString *)planSummary {
    
    NSString *pluralString = [STMFunctions pluralTypeForCount:self.shipmentRoutePoints.count];
    NSString *pointsString = NSLocalizedString([pluralString stringByAppendingString:@"SRPOINTS"], nil);
    
    
    return [NSString stringWithFormat:@"\n%lu %@\n", (unsigned long)self.shipmentRoutePoints.count, pointsString];

}

- (NSString *)doneSummary {
    
    NSNumber *badVolume = [self badVolumeSummary];
    NSNumber *shortageVolume = [self shortageVolumeSummary];
    NSNumber *excessVolume = [self excessVolumeSummary];
    NSNumber *regradeVolume = [self regradeVolumeSummary];
    NSNumber *brokenVolume = [self brokenVolumeSummary];
    
    NSString *volumesString = [[STMShippingProcessController sharedInstance] volumesStringWithDoneVolume:0
                                                                                               badVolume:badVolume.integerValue
                                                                                            excessVolume:excessVolume.integerValue
                                                                                          shortageVolume:shortageVolume.integerValue
                                                                                           regradeVolume:regradeVolume.integerValue
                                                                                            brokenVolume:brokenVolume.integerValue
                                                                                              packageRel:0];
    
    return (volumesString) ? [@"\n" stringByAppendingString:volumesString] : @"";

}

- (NSNumber *)badVolumeSummary {
    
    NSArray *positions = [[self shippedShipments] valueForKeyPath:@"@distinctUnionOfSets.shipmentPositions"];
    NSNumber *volume = [positions valueForKeyPath:@"@sum.badVolume"];
    
    return volume;
    
}

- (NSNumber *)shortageVolumeSummary {
    
    NSArray *positions = [[self shippedShipments] valueForKeyPath:@"@distinctUnionOfSets.shipmentPositions"];
    NSNumber *volume = [positions valueForKeyPath:@"@sum.shortageVolume"];
    
    return volume;
    
}

- (NSNumber *)excessVolumeSummary {
    
    NSArray *positions = [[self shippedShipments] valueForKeyPath:@"@distinctUnionOfSets.shipmentPositions"];
    NSNumber *volume = [positions valueForKeyPath:@"@sum.excessVolume"];
    
    return volume;
    
}

- (NSNumber *)regradeVolumeSummary {
    
    NSArray *positions = [[self shippedShipments] valueForKeyPath:@"@distinctUnionOfSets.shipmentPositions"];
    NSNumber *volume = [positions valueForKeyPath:@"@sum.regradeVolume"];
    
    return volume;
    
}

- (NSNumber *)brokenVolumeSummary {
    
    NSArray *positions = [[self shippedShipments] valueForKeyPath:@"@distinctUnionOfSets.shipmentPositions"];
    NSNumber *volume = [positions valueForKeyPath:@"@sum.brokenVolume"];
    
    return volume;
    
}

- (NSArray *)shippedShipments {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isShipped.boolValue == YES"];
    
    NSSet *shipments = [self.shipmentRoutePoints valueForKeyPath:@"@distinctUnionOfSets.shipments"];
    shipments = [shipments filteredSetUsingPredicate:[STMPredicate predicateWithNoFantomsFromPredicate:predicate]];
    
    return [shipments allObjects];
    
}

@end
