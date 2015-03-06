//
//  STMSaleOrder.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 06/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMOutlet, STMSaleOrderPosition, STMSalesman;

@interface STMSaleOrder : STMComment

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDecimalNumber * totalCost;
@property (nonatomic, retain) NSString * processing;
@property (nonatomic, retain) STMOutlet *outlet;
@property (nonatomic, retain) STMSalesman *salesman;
@property (nonatomic, retain) NSSet *saleOrderPositions;
@end

@interface STMSaleOrder (CoreDataGeneratedAccessors)

- (void)addSaleOrderPositionsObject:(STMSaleOrderPosition *)value;
- (void)removeSaleOrderPositionsObject:(STMSaleOrderPosition *)value;
- (void)addSaleOrderPositions:(NSSet *)values;
- (void)removeSaleOrderPositions:(NSSet *)values;

@end
