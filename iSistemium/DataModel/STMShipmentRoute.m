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
#import "STMShipmentRouteSummaryTVC.h"


@implementation STMShipmentRoute

- (NSString *)planSummary {
    
    NSString *pointsString = [self pointsCountStringForCount:self.shipmentRoutePoints.count];
    NSString *shipmentsString = [self shipmentsCountStringForCount:0];
    
    return @"";

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

- (NSArray *)shippedShipments {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isShipped.boolValue == YES"];
    
    NSSet *shipments = [self.shipmentRoutePoints valueForKeyPath:@"@distinctUnionOfSets.shipments"];
    shipments = [shipments filteredSetUsingPredicate:[STMPredicate predicateWithNoFantomsFromPredicate:predicate]];
    
    return [shipments allObjects];
    
}

- (BOOL)haveIssuesInProcessedShipments {
    
    NSArray *shippedShipments = [self shippedShipments];
    
    NSArray *positions = [shippedShipments valueForKeyPath:@"@distinctUnionOfSets.shipmentPositions"];
    
    NSArray *availableTypes = @[@(STMSummaryTypeBad),
                                @(STMSummaryTypeExcess),
                                @(STMSummaryTypeShortage),
                                @(STMSummaryTypeRegrade),
                                @(STMSummaryTypeBroken)];
    
    NSUInteger issuesCount = 0;
    
    for (NSNumber *typeNumber in availableTypes) {
        
        STMSummaryType type = typeNumber.integerValue;
        NSString *typeString = [STMShipmentRouteSummaryTVC stringVolumePropertyForType:type];
        
        NSString *predicateFormat = [typeString stringByAppendingString:@".integerValue > 0"];
        NSPredicate *volumePredicate = [NSPredicate predicateWithFormat:predicateFormat];
        
        NSArray *filteredPositions = [positions filteredArrayUsingPredicate:volumePredicate];
        
        if (filteredPositions.count > 0) issuesCount++;
        
    }
    
    return (issuesCount > 0);
    
}

- (NSString *)pointsCountStringForCount:(NSUInteger)pointsCount {
    
    if (pointsCount > 0) {
        
        NSString *pluralString = [STMFunctions pluralTypeForCount:pointsCount];
        NSString *pointsString = NSLocalizedString([pluralString stringByAppendingString:@"SRPOINTS"], nil);
        
        NSString *pointsCountString = [NSString stringWithFormat:@"\n%lu %@\n", (unsigned long)pointsCount, pointsString];
        
        return pointsCountString;

    } else {
        
        return NSLocalizedString(@"0SRPOINTS", nil);
        
    }
    
}

- (NSString *)shipmentsCountStringForCount:(NSUInteger)shipmentsCount {
    
    if (shipmentsCount > 0) {
        
        NSString *pluralString = [STMFunctions pluralTypeForCount:shipmentsCount];
        NSString *shipmentsString = NSLocalizedString([pluralString stringByAppendingString:@"SHIPMENTS"], nil);
        
        NSString *shipmentsCountString = [NSString stringWithFormat:@"\n%lu %@\n", (unsigned long)shipmentsCount, shipmentsString];
        
        return shipmentsCountString;
        
    } else {
        
        return NSLocalizedString(@"0SHIPMENTS", nil);
        
    }
    
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


@end
