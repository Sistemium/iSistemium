//
//  STMShipmentRoute.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 23/09/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMDriver, STMShipmentRoutePoint;

@interface STMShipmentRoute : STMComment

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * processing;
@property (nonatomic, retain) NSString * processingMessage;
@property (nonatomic, retain) STMDriver *driver;
@property (nonatomic, retain) NSSet *shipmentRoutePoints;
@end

@interface STMShipmentRoute (CoreDataGeneratedAccessors)

- (void)addShipmentRoutePointsObject:(STMShipmentRoutePoint *)value;
- (void)removeShipmentRoutePointsObject:(STMShipmentRoutePoint *)value;
- (void)addShipmentRoutePoints:(NSSet *)values;
- (void)removeShipmentRoutePoints:(NSSet *)values;

@end
