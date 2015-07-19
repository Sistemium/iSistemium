//
//  STMShipment.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 19/07/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMDriver, STMOutlet, STMSaleOrder, STMSalesman, STMShipmentPosition, STMShipmentRoutePoint;

@interface STMShipment : STMComment

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * isShipped;
@property (nonatomic, retain) NSString * ndoc;
@property (nonatomic, retain) NSNumber * needCashing;
@property (nonatomic, retain) STMDriver *driver;
@property (nonatomic, retain) STMOutlet *outlet;
@property (nonatomic, retain) STMSaleOrder *saleOrder;
@property (nonatomic, retain) STMSalesman *salesman;
@property (nonatomic, retain) NSSet *shipmentPositions;
@property (nonatomic, retain) NSSet *shipmentRoutePoints;
@end

@interface STMShipment (CoreDataGeneratedAccessors)

- (void)addShipmentPositionsObject:(STMShipmentPosition *)value;
- (void)removeShipmentPositionsObject:(STMShipmentPosition *)value;
- (void)addShipmentPositions:(NSSet *)values;
- (void)removeShipmentPositions:(NSSet *)values;

- (void)addShipmentRoutePointsObject:(STMShipmentRoutePoint *)value;
- (void)removeShipmentRoutePointsObject:(STMShipmentRoutePoint *)value;
- (void)addShipmentRoutePoints:(NSSet *)values;
- (void)removeShipmentRoutePoints:(NSSet *)values;

@end
