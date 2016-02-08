//
//  STMSalesman+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMSalesman.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMSalesman (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<STMOutlet *> *outlets;
@property (nullable, nonatomic, retain) NSSet<STMPhotoReport *> *photoReports;
@property (nullable, nonatomic, retain) NSSet<STMSaleOrder *> *saleOrders;
@property (nullable, nonatomic, retain) NSSet<STMShipment *> *shipments;

@end

@interface STMSalesman (CoreDataGeneratedAccessors)

- (void)addOutletsObject:(STMOutlet *)value;
- (void)removeOutletsObject:(STMOutlet *)value;
- (void)addOutlets:(NSSet<STMOutlet *> *)values;
- (void)removeOutlets:(NSSet<STMOutlet *> *)values;

- (void)addPhotoReportsObject:(STMPhotoReport *)value;
- (void)removePhotoReportsObject:(STMPhotoReport *)value;
- (void)addPhotoReports:(NSSet<STMPhotoReport *> *)values;
- (void)removePhotoReports:(NSSet<STMPhotoReport *> *)values;

- (void)addSaleOrdersObject:(STMSaleOrder *)value;
- (void)removeSaleOrdersObject:(STMSaleOrder *)value;
- (void)addSaleOrders:(NSSet<STMSaleOrder *> *)values;
- (void)removeSaleOrders:(NSSet<STMSaleOrder *> *)values;

- (void)addShipmentsObject:(STMShipment *)value;
- (void)removeShipmentsObject:(STMShipment *)value;
- (void)addShipments:(NSSet<STMShipment *> *)values;
- (void)removeShipments:(NSSet<STMShipment *> *)values;

@end

NS_ASSUME_NONNULL_END
