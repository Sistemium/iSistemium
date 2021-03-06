//
//  STMPicker+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 14/03/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMPicker.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMPicker (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *commentText;
@property (nullable, nonatomic, retain) NSDate *deviceCts;
@property (nullable, nonatomic, retain) NSDate *deviceTs;
@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSNumber *isFantom;
@property (nullable, nonatomic, retain) NSDate *lts;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSData *ownerXid;
@property (nullable, nonatomic, retain) NSString *source;
@property (nullable, nonatomic, retain) NSDate *sqts;
@property (nullable, nonatomic, retain) NSDate *sts;
@property (nullable, nonatomic, retain) NSData *xid;
@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) NSString *password;
@property (nullable, nonatomic, retain) NSSet<STMPickingOrder *> *pickingOrders;

@end

@interface STMPicker (CoreDataGeneratedAccessors)

- (void)addPickingOrdersObject:(STMPickingOrder *)value;
- (void)removePickingOrdersObject:(STMPickingOrder *)value;
- (void)addPickingOrders:(NSSet<STMPickingOrder *> *)values;
- (void)removePickingOrders:(NSSet<STMPickingOrder *> *)values;

@end

NS_ASSUME_NONNULL_END
