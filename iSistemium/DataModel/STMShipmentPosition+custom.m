//
//  STMShipmentPosition+custom.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 10/07/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShipmentPosition+custom.h"
#import "STMArticle.h"


@implementation STMShipmentPosition (custom)

- (BOOL)wasProcessed {
    return (self.isProcessed) ? self.isProcessed.boolValue : NO;
}

- (NSString *)infoText {
    
    NSString *volumeUnitString = nil;
    NSString *infoText = nil;
    
    int volume = [self.volume intValue];
    int packageRel = [self.article.packageRel intValue];
    
    if (packageRel != 0 && volume >= packageRel) {
        
        int package = floor(volume / packageRel);
        
        volumeUnitString = NSLocalizedString(@"VOLUME UNIT1", nil);
        NSString *packageString = [NSString stringWithFormat:@"%d %@", package, volumeUnitString];
        
        int bottle = volume % packageRel;
        
        if (bottle > 0) {
            
            volumeUnitString = NSLocalizedString(@"VOLUME UNIT2", nil);
            NSString *bottleString = [NSString stringWithFormat:@" %d %@", bottle, volumeUnitString];
            
            packageString = [packageString stringByAppendingString:bottleString];
            
        }
        
        infoText = packageString;
        
    } else {
        
        volumeUnitString = NSLocalizedString(@"VOLUME UNIT2", nil);
        infoText = [NSString stringWithFormat:@"%@ %@", self.volume, volumeUnitString];
        
    }
    
    return infoText;
    
}


@end
