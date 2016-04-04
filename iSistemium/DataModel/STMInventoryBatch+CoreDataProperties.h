//
//  STMInventoryBatch+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMInventoryBatch.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMInventoryBatch (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) NSString *commentText;
@property (nullable, nonatomic, retain) NSDate *deviceCts;
@property (nullable, nonatomic, retain) NSDate *deviceTs;
@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSNumber *isDone;
@property (nullable, nonatomic, retain) NSNumber *isFantom;
@property (nullable, nonatomic, retain) NSDate *lts;
@property (nullable, nonatomic, retain) NSData *ownerXid;
@property (nullable, nonatomic, retain) NSString *productionInfo;
@property (nullable, nonatomic, retain) NSString *source;
@property (nullable, nonatomic, retain) NSDate *sqts;
@property (nullable, nonatomic, retain) NSString *stockBatchCode;
@property (nullable, nonatomic, retain) NSDate *sts;
@property (nullable, nonatomic, retain) NSData *xid;
@property (nullable, nonatomic, retain) STMArticle *article;
@property (nullable, nonatomic, retain) NSSet<STMInventoryBatchItem *> *inventoryBatchItems;
@property (nullable, nonatomic, retain) STMStockBatch *stockBatch;

@end

@interface STMInventoryBatch (CoreDataGeneratedAccessors)

- (void)addInventoryBatchItemsObject:(STMInventoryBatchItem *)value;
- (void)removeInventoryBatchItemsObject:(STMInventoryBatchItem *)value;
- (void)addInventoryBatchItems:(NSSet<STMInventoryBatchItem *> *)values;
- (void)removeInventoryBatchItems:(NSSet<STMInventoryBatchItem *> *)values;

@end

NS_ASSUME_NONNULL_END
