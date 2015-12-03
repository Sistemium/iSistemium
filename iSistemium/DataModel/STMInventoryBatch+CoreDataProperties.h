//
//  STMInventoryBatch+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMInventoryBatch.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMInventoryBatch (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) NSString *productionInfo;
@property (nullable, nonatomic, retain) STMArticle *article;
@property (nullable, nonatomic, retain) STMStockBatch *stockBatch;
@property (nullable, nonatomic, retain) NSSet<STMInventoryBatchItem *> *inventoryBatchItems;

@end

@interface STMInventoryBatch (CoreDataGeneratedAccessors)

- (void)addInventoryBatchItemsObject:(STMInventoryBatchItem *)value;
- (void)removeInventoryBatchItemsObject:(STMInventoryBatchItem *)value;
- (void)addInventoryBatchItems:(NSSet<STMInventoryBatchItem *> *)values;
- (void)removeInventoryBatchItems:(NSSet<STMInventoryBatchItem *> *)values;

@end

NS_ASSUME_NONNULL_END
