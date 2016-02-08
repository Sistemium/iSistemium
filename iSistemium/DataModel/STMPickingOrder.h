//
//  STMPickingOrder.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 16/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMDatum.h"

@class STMPicker, STMPickingOrderPosition;

NS_ASSUME_NONNULL_BEGIN

@interface STMPickingOrder : STMDatum

- (NSString *)positionsCountString;

- (NSUInteger)approximateBoxCount;
- (NSString *)approximateBoxCountString;

- (NSUInteger)bottleCount;
- (NSString *)bottleCountString;


@end

NS_ASSUME_NONNULL_END

#import "STMPickingOrder+CoreDataProperties.h"
