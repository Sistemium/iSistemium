//
//  STMPartner+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMPartner.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMPartner (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<STMOutlet *> *outlets;
@property (nullable, nonatomic, retain) NSSet<STMSupplyOrder *> *supplyOrders;

@end

@interface STMPartner (CoreDataGeneratedAccessors)

- (void)addOutletsObject:(STMOutlet *)value;
- (void)removeOutletsObject:(STMOutlet *)value;
- (void)addOutlets:(NSSet<STMOutlet *> *)values;
- (void)removeOutlets:(NSSet<STMOutlet *> *)values;

- (void)addSupplyOrdersObject:(STMSupplyOrder *)value;
- (void)removeSupplyOrdersObject:(STMSupplyOrder *)value;
- (void)addSupplyOrders:(NSSet<STMSupplyOrder *> *)values;
- (void)removeSupplyOrders:(NSSet<STMSupplyOrder *> *)values;

@end

NS_ASSUME_NONNULL_END
