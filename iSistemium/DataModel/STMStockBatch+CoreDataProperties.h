//
//  STMStockBatch+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMStockBatch.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMStockBatch (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *processing;
@property (nullable, nonatomic, retain) NSString *productionInfo;
@property (nullable, nonatomic, retain) NSNumber *volume;
@property (nullable, nonatomic, retain) NSNumber *isInventarized;
@property (nullable, nonatomic, retain) STMArticle *article;
@property (nullable, nonatomic, retain) NSSet<STMStockBatchBarCode *> *barCodes;
@property (nullable, nonatomic, retain) NSSet<STMInventoryBatch *> *inventoryBatches;
@property (nullable, nonatomic, retain) NSSet<STMPickingOrderPositionPicked *> *pickingOrderPositionsPicked;
@property (nullable, nonatomic, retain) STMQualityClass *qualityClass;

@end

@interface STMStockBatch (CoreDataGeneratedAccessors)

- (void)addBarCodesObject:(STMStockBatchBarCode *)value;
- (void)removeBarCodesObject:(STMStockBatchBarCode *)value;
- (void)addBarCodes:(NSSet<STMStockBatchBarCode *> *)values;
- (void)removeBarCodes:(NSSet<STMStockBatchBarCode *> *)values;

- (void)addInventoryBatchesObject:(STMInventoryBatch *)value;
- (void)removeInventoryBatchesObject:(STMInventoryBatch *)value;
- (void)addInventoryBatches:(NSSet<STMInventoryBatch *> *)values;
- (void)removeInventoryBatches:(NSSet<STMInventoryBatch *> *)values;

- (void)addPickingOrderPositionsPickedObject:(STMPickingOrderPositionPicked *)value;
- (void)removePickingOrderPositionsPickedObject:(STMPickingOrderPositionPicked *)value;
- (void)addPickingOrderPositionsPicked:(NSSet<STMPickingOrderPositionPicked *> *)values;
- (void)removePickingOrderPositionsPicked:(NSSet<STMPickingOrderPositionPicked *> *)values;

@end

NS_ASSUME_NONNULL_END
