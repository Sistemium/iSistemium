//
//  STMShipment+custom.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 31/07/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShipment+custom.h"
#import "STMDataModel.h"


@implementation STMShipment (custom)

- (NSUInteger)approximateBoxCount {
    
    double approximateVolume = 0;
    
    for (STMShipmentPosition *position in self.shipmentPositions) {
        approximateVolume += position.volume.doubleValue / position.article.packageRel.integerValue;
    }
    
    NSUInteger boxesCount = ceil(approximateVolume);
    
    return boxesCount;

}

- (NSUInteger)bottleCount {
    
    NSNumber *volumeSum = [self.shipmentPositions valueForKeyPath:@"@sum.volume"];
    return (volumeSum.integerValue > 0) ? volumeSum.integerValue : 0;
    
}


@end
