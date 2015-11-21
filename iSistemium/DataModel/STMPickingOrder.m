//
//  STMPickingOrder.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 16/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMPickingOrder.h"
#import "STMPicker.h"
#import "STMPickingOrderPosition.h"

#import "STMArticle.h"
#import "STMFunctions.h"
#import "STMSessionManager.h"


@implementation STMPickingOrder

- (NSString *)positionsCountString {
    
    NSUInteger positionsCount = self.pickingOrderPositions.count;
    
    if (positionsCount > 0) {
        
        NSString *pluralType = [STMFunctions pluralTypeForCount:positionsCount];
        NSString *positionString = [NSString stringWithFormat:@"%@POSITIONS", pluralType];
        
        NSString *countString = [NSString stringWithFormat:@"%lu %@", (unsigned long)positionsCount, NSLocalizedString(positionString, nil)];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nonPickedVolume == 0"];
        NSSet *pickedPositions = [self.pickingOrderPositions filteredSetUsingPredicate:predicate];
        
        if (pickedPositions.count > 0) {
            countString = [NSString stringWithFormat:@"%@ (%@ %@)", countString, NSLocalizedString(@"POSITION PICKED", nil), @(pickedPositions.count).stringValue];
        }
        
        return countString;

    } else {
        return NSLocalizedString(@"0POSITIONS", nil);
    }
    
}

- (NSUInteger)approximateBoxCount {
    
    double approximateVolume = 0;
    
    for (STMPickingOrderPosition *position in self.pickingOrderPositions) {
        
        if (position.article.packageRel.integerValue > 0) {
            approximateVolume += position.volume.doubleValue / position.article.packageRel.integerValue;
        }
        
    }
    
    NSUInteger boxesCount = ceil(approximateVolume);
    
    return boxesCount;
    
}

- (NSString *)approximateBoxCountString {
    
    if (self.pickingOrderPositions.count > 0) {
        
        NSUInteger boxesCount = [self approximateBoxCount];
        
        NSString *pluralType = [STMFunctions pluralTypeForCount:boxesCount];
        NSString *boxString = [NSString stringWithFormat:@"%@BOXES", pluralType];
        NSString *boxes = [NSString stringWithFormat:@"%lu %@", (unsigned long)boxesCount, NSLocalizedString(boxString, nil)];
        
        return boxes;
        
    } else {
        return NSLocalizedString(@"0BOXES", nil);
    }
    
}

- (NSUInteger)bottleCount {
    
    NSNumber *volumeSum = [self.pickingOrderPositions valueForKeyPath:@"@sum.volume"];
    return (volumeSum.integerValue > 0) ? volumeSum.integerValue : 0;
    
}


- (NSString *)bottleCountString {
    
    NSDictionary *appSettings = [[STMSessionManager sharedManager].currentSession.settingsController currentSettingsForGroup:@"appSettings"];
    BOOL enableShowBottles = [appSettings[@"enableShowBottles"] boolValue];
    
    if (self.pickingOrderPositions.count > 0) {
        
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
