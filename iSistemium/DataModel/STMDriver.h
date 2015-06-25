//
//  STMDriver.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMShipment, STMShipmentRoute;

@interface STMDriver : STMComment

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *shipments;
@property (nonatomic, retain) NSSet *shipmentRoutes;
@end

@interface STMDriver (CoreDataGeneratedAccessors)

- (void)addShipmentsObject:(STMShipment *)value;
- (void)removeShipmentsObject:(STMShipment *)value;
- (void)addShipments:(NSSet *)values;
- (void)removeShipments:(NSSet *)values;

- (void)addShipmentRoutesObject:(STMShipmentRoute *)value;
- (void)removeShipmentRoutesObject:(STMShipmentRoute *)value;
- (void)addShipmentRoutes:(NSSet *)values;
- (void)removeShipmentRoutes:(NSSet *)values;

@end
