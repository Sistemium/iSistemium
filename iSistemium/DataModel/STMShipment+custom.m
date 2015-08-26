//
//  STMShipment+custom.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 31/07/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShipment+custom.h"
#import "STMDataModel.h"
#import "STMFunctions.h"


@implementation STMShipment (custom)

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
    
    if (self.shipmentPositions.count > 0) {
        
        NSUInteger bottleCount = [self bottleCount];
        
        NSString *pluralType = [STMFunctions pluralTypeForCount:bottleCount];
        NSString *bottleString = [NSString stringWithFormat:@"%@BOTTLES", pluralType];
        NSString *bottles = [NSString stringWithFormat:@"%lu %@", (unsigned long)bottleCount, NSLocalizedString(bottleString, nil)];

        return bottles;
        
    } else {
        return NSLocalizedString(@"0BOTTLES", nil);
    }

}


@end
