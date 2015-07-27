//
//  STMSaleOrder.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMOutlet, STMSaleOrderPosition, STMSalesman, STMShipment;

@interface STMSaleOrder : STMComment

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * processing;
@property (nonatomic, retain) NSString * processingMessage;
@property (nonatomic, retain) NSDecimalNumber * totalCost;
@property (nonatomic, retain) STMOutlet *outlet;
@property (nonatomic, retain) NSSet *saleOrderPositions;
@property (nonatomic, retain) STMSalesman *salesman;
@property (nonatomic, retain) NSSet *shipments;
@end

@interface STMSaleOrder (CoreDataGeneratedAccessors)

- (void)addSaleOrderPositionsObject:(STMSaleOrderPosition *)value;
- (void)removeSaleOrderPositionsObject:(STMSaleOrderPosition *)value;
- (void)addSaleOrderPositions:(NSSet *)values;
- (void)removeSaleOrderPositions:(NSSet *)values;

- (void)addShipmentsObject:(STMShipment *)value;
- (void)removeShipmentsObject:(STMShipment *)value;
- (void)addShipments:(NSSet *)values;
- (void)removeShipments:(NSSet *)values;

@end
