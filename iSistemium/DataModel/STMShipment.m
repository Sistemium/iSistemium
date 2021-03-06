//
//  STMShipment.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMShipment.h"
#import "STMDriver.h"
#import "STMOutlet.h"
#import "STMSaleOrder.h"
#import "STMSalesman.h"
#import "STMShipmentPosition.h"
#import "STMShipmentRoutePoint.h"

#import "STMArticle.h"
#import "STMFunctions.h"
#import "STMSessionManager.h"


@implementation STMShipment

- (NSUInteger)approximateBoxCount {
    
    double approximateVolume = 0;
    
    for (STMShipmentPosition *position in self.shipmentPositions) {
        
        if (position.article.packageRel.integerValue > 0) {
            approximateVolume += position.volume.doubleValue / position.article.packageRel.integerValue;
        }
        
    }
    
    NSUInteger boxesCount = ceil(approximateVolume);
    
    return boxesCount;
    
}

- (NSUInteger)bottleCount {
    
    NSNumber *volumeSum = [self.shipmentPositions valueForKeyPath:@"@sum.volume"];
    return (volumeSum.integerValue > 0) ? volumeSum.integerValue : 0;
    
}

- (NSString *)positionsCountString {
    
    NSUInteger positionsCount = self.shipmentPositions.count;
    
    if (positionsCount > 0) {
        
        NSString *pluralType = [STMFunctions pluralTypeForCount:positionsCount];
        NSString *positionString = [NSString stringWithFormat:@"%@POSITIONS", pluralType];
        
        return [NSString stringWithFormat:@"%lu %@", (unsigned long)positionsCount, NSLocalizedString(positionString, nil)];
        
    } else {
        return NSLocalizedString(@"0POSITIONS", nil);
    }
    
}

- (NSString *)approximateBoxCountString {
    
    if (self.shipmentPositions.count > 0) {
        
        NSUInteger boxesCount = [self approximateBoxCount];
        
        NSString *pluralType = [STMFunctions pluralTypeForCount:boxesCount];
        NSString *boxString = [NSString stringWithFormat:@"%@BOXES", pluralType];
        NSString *boxes = [NSString stringWithFormat:@"%lu %@", (unsigned long)boxesCount, NSLocalizedString(boxString, nil)];
        
        return boxes;
        
    } else {
        return NSLocalizedString(@"0BOXES", nil);
    }
    
}

- (NSString *)bottleCountString {
    
    NSDictionary *appSettings = [[STMSessionManager sharedManager].currentSession.settingsController currentSettingsForGroup:@"appSettings"];
    BOOL enableShowBottles = [appSettings[@"enableShowBottles"] boolValue];
    
    if (self.shipmentPositions.count > 0) {
        
        NSUInteger bottleCount = [self bottleCount];
        
        NSString *pluralType = [STMFunctions pluralTypeForCount:bottleCount];
        
        NSString *bottleString = (enableShowBottles) ? [NSString stringWithFormat:@"%@BOTTLES", pluralType] : [NSString stringWithFormat:@"%@PIECES", pluralType];
        NSString *bottles = [NSString stringWithFormat:@"%lu %@", (unsigned long)bottleCount, NSLocalizedString(bottleString, nil)];
        
        return bottles;
        
    } else {
        return (enableShowBottles) ? NSLocalizedString(@"0BOTTLES", nil) : NSLocalizedString(@"0PIECES", nil);
    }
    
}


@end
