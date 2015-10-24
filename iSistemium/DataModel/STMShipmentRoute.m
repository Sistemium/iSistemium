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

#import "STMObjectsController.h"
#import "STMShippingProcessController.h"
#import "STMShipmentRouteSummaryTVC.h"


@implementation STMShipmentRoute

- (NSString *)planSummary {
    
    NSUInteger pointsCount = self.shipmentRoutePoints.count;
    
    if (pointsCount > 0) {
    
        NSSet *shipments = [self.shipmentRoutePoints valueForKeyPath:@"@distinctUnionOfSets.shipments"];
        NSUInteger shipmentsCount = shipments.count;
        
        NSSet *positions = [shipments valueForKeyPath:@"@distinctUnionOfSets.shipmentPositions"];
        NSUInteger positionsCount = positions.count;

        NSNumber *boxes = [shipments valueForKeyPath:@"@sum.approximateBoxCount"];
        NSUInteger boxesCount = boxes.integerValue;
        
        NSNumber *bottles = [shipments valueForKeyPath:@"@sum.bottleCount"];
        NSUInteger bottlesCount = bottles.integerValue;

        NSNumber *pieceWeight = [positions valueForKeyPath:@"@sum.article.pieceWeight"];
        double weight = pieceWeight.doubleValue;
        
        return [self summaryForPointsCount:pointsCount
                            shipmentsCount:shipmentsCount
                            positionsCount:positionsCount
                                boxesCount:boxesCount
                              bottlesCount:bottlesCount
                                    weight:weight];
        
    } else {
        
        return NSLocalizedString(@"0SRPOINTS", nil);
        
    }
    
}

- (NSString *)doneSummary {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ALL shipments.isShipped.boolValue == YES"];
    
    NSSet *donePoints = [self.shipmentRoutePoints filteredSetUsingPredicate:predicate];
    NSUInteger pointsCount = donePoints.count;
    
    NSSet *shipments = [NSSet setWithArray:[self shippedShipments]];
    NSUInteger shipmentsCount = shipments.count;
    
    NSSet *positions = [shipments valueForKeyPath:@"@distinctUnionOfSets.shipmentPositions"];
    NSUInteger positionsCount = positions.count;
    
    NSNumber *boxes = [shipments valueForKeyPath:@"@sum.approximateBoxCount"];
    NSUInteger boxesCount = boxes.integerValue;
    
    NSNumber *bottles = [shipments valueForKeyPath:@"@sum.bottleCount"];
    NSUInteger bottlesCount = bottles.integerValue;

    NSNumber *pieceWeight = [positions valueForKeyPath:@"@sum.article.pieceWeight"];
    double weight = pieceWeight.doubleValue;

    NSString *doneSummary = [self summaryForPointsCount:pointsCount
                                         shipmentsCount:shipmentsCount
                                         positionsCount:positionsCount
                                             boxesCount:boxesCount
                                           bottlesCount:bottlesCount
                                                 weight:weight];

    if ([self haveIssuesInProcessedShipments]) {
        doneSummary = [doneSummary stringByAppendingString:[self issuesSummary]];
    }
    
    return doneSummary;
    
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

- (NSString *)summaryForPointsCount:(NSUInteger)pointsCount shipmentsCount:(NSUInteger)shipmentsCount positionsCount:(NSUInteger)positionsCount boxesCount:(NSUInteger)boxesCount bottlesCount:(NSUInteger)bottlesCount weight:(double)weight {
    
    NSString *pointsString = [NSString stringWithFormat:@"%lu%@", (unsigned long)pointsCount, NSLocalizedString(@"_POINTS", nil)];
    
    NSString *shipmentsString = [NSString stringWithFormat:@"%lu%@", (unsigned long)shipmentsCount, NSLocalizedString(@"_SHIPMENTS", nil)];
    
    NSString *positionsString = [NSString stringWithFormat:@"%lu%@", (unsigned long)positionsCount, NSLocalizedString(@"_POSITIONS", nil)];
    
    NSString *boxesCountString = [NSString stringWithFormat:@"%lu%@", (unsigned long)boxesCount, NSLocalizedString(@"_BOXES", nil)];
    
    NSDictionary *appSettings = [[STMObjectsController session].settingsController currentSettingsForGroup:@"appSettings"];
    BOOL enableShowBottles = [appSettings[@"enableShowBottles"] boolValue];
    
    NSString *bottlesString = (enableShowBottles) ? NSLocalizedString(@"_BOTTLES", nil) : NSLocalizedString(@"_PIECES", nil);
    
    NSString *bottlesCountString = [NSString stringWithFormat:@"%lu%@", (unsigned long)bottlesCount, bottlesString];

    NSMutableArray *stringsArray = @[pointsString, shipmentsString, positionsString, boxesCountString, bottlesCountString].mutableCopy;

    if (weight > 0) {
    
        NSString *weightString = [NSString stringWithFormat:@"%.0f%@", weight, NSLocalizedString(@"_KG", nil)];
        [stringsArray addObject:weightString];

    }

    NSString *planSummaryString = [stringsArray componentsJoinedByString:@" "];
    
    return planSummaryString;

}

- (NSString *)issuesSummary {
    
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
    
    return (volumesString) ? [@"\n\n" stringByAppendingString:volumesString] : @"";

}

- (NSString *)pointsCountStringForCount:(NSUInteger)pointsCount {
    
    if (pointsCount > 0) {
        
        NSString *pluralString = [STMFunctions pluralTypeForCount:pointsCount];
        NSString *pointsString = NSLocalizedString([pluralString stringByAppendingString:@"SRPOINTS"], nil);
        
        NSString *pointsCountString = [NSString stringWithFormat:@"%lu %@", (unsigned long)pointsCount, pointsString];
        
        return pointsCountString;

    } else {
        
        return NSLocalizedString(@"0SRPOINTS", nil);
        
    }
    
}

- (NSString *)shipmentsCountStringForCount:(NSUInteger)shipmentsCount {
    
    if (shipmentsCount > 0) {
        
        NSString *pluralString = [STMFunctions pluralTypeForCount:shipmentsCount];
        NSString *shipmentsString = NSLocalizedString([pluralString stringByAppendingString:@"SHIPMENTS"], nil);
        
        NSString *shipmentsCountString = [NSString stringWithFormat:@"%lu %@", (unsigned long)shipmentsCount, shipmentsString];
        
        return shipmentsCountString;
        
    } else {
        
        return NSLocalizedString(@"0SHIPMENTS", nil);
        
    }
    
}


#pragma mark - volumes summary

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
