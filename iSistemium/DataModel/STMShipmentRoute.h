//
//  STMShipmentRoute.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 24/10/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMDatum.h"

@class STMDriver, STMShipmentRoutePoint;

NS_ASSUME_NONNULL_BEGIN

@interface STMShipmentRoute : STMDatum

- (NSString *)planSummary;
- (NSString *)doneSummary;
- (NSArray *)shippedShipments;
- (BOOL)haveIssuesInProcessedShipments;


@end

NS_ASSUME_NONNULL_END

#import "STMShipmentRoute+CoreDataProperties.h"
