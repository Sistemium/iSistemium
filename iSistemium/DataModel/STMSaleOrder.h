//
//  STMSaleOrder.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 16/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMOutlet, STMSaleOrderPosition, STMSalesman;

@interface STMSaleOrder : STMComment

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * processing;
@property (nonatomic, retain) NSDecimalNumber * totalCost;
@property (nonatomic, retain) NSString * processingMessage;
@property (nonatomic, retain) STMOutlet *outlet;
@property (nonatomic, retain) NSSet *saleOrderPositions;
@property (nonatomic, retain) STMSalesman *salesman;
@end

@interface STMSaleOrder (CoreDataGeneratedAccessors)

- (void)addSaleOrderPositionsObject:(STMSaleOrderPosition *)value;
- (void)removeSaleOrderPositionsObject:(STMSaleOrderPosition *)value;
- (void)addSaleOrderPositions:(NSSet *)values;
- (void)removeSaleOrderPositions:(NSSet *)values;

@end
