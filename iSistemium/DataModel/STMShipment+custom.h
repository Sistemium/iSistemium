//
//  STMShipment+custom.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 31/07/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShipment.h"

@interface STMShipment (custom)

- (NSUInteger)approximateBoxCount;
- (NSUInteger)bottleCount;

- (NSString *)positionsCountString;
- (NSString *)approximateBoxCountString;
- (NSString *)bottleCountString;

@end
