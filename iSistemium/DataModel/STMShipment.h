//
//  STMShipment.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMComment.h"

@class STMDriver, STMOutlet, STMSaleOrder, STMSalesman, STMShipmentPosition, STMShipmentRoutePoint;

NS_ASSUME_NONNULL_BEGIN

@interface STMShipment : STMComment

- (NSUInteger)approximateBoxCount;
- (NSUInteger)bottleCount;

- (NSString *)positionsCountString;
- (NSString *)approximateBoxCountString;
- (NSString *)bottleCountString;


@end

NS_ASSUME_NONNULL_END

#import "STMShipment+CoreDataProperties.h"
