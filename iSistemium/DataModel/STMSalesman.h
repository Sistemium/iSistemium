//
//  STMSalesman.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 06/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMOutlet, STMPhotoReport, STMSaleOrder;

@interface STMSalesman : STMComment

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *outlets;
@property (nonatomic, retain) NSSet *photoReports;
@property (nonatomic, retain) NSSet *saleOrders;
@end

@interface STMSalesman (CoreDataGeneratedAccessors)

- (void)addOutletsObject:(STMOutlet *)value;
- (void)removeOutletsObject:(STMOutlet *)value;
- (void)addOutlets:(NSSet *)values;
- (void)removeOutlets:(NSSet *)values;

- (void)addPhotoReportsObject:(STMPhotoReport *)value;
- (void)removePhotoReportsObject:(STMPhotoReport *)value;
- (void)addPhotoReports:(NSSet *)values;
- (void)removePhotoReports:(NSSet *)values;

- (void)addSaleOrdersObject:(STMSaleOrder *)value;
- (void)removeSaleOrdersObject:(STMSaleOrder *)value;
- (void)addSaleOrders:(NSSet *)values;
- (void)removeSaleOrders:(NSSet *)values;

@end
