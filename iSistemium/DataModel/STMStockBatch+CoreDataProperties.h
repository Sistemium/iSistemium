//
//  STMStockBatch+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMStockBatch.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMStockBatch (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *processing;
@property (nullable, nonatomic, retain) NSNumber *volume;
@property (nullable, nonatomic, retain) STMArticle *article;
@property (nullable, nonatomic, retain) NSSet<STMPickingOrderPositionPicked *> *pickingOrderPositionsPicked;
@property (nullable, nonatomic, retain) STMQualityClass *qualityClass;
@property (nullable, nonatomic, retain) NSSet<STMStockBatchBarCode *> *barCodes;

@end

@interface STMStockBatch (CoreDataGeneratedAccessors)

- (void)addPickingOrderPositionsPickedObject:(STMPickingOrderPositionPicked *)value;
- (void)removePickingOrderPositionsPickedObject:(STMPickingOrderPositionPicked *)value;
- (void)addPickingOrderPositionsPicked:(NSSet<STMPickingOrderPositionPicked *> *)values;
- (void)removePickingOrderPositionsPicked:(NSSet<STMPickingOrderPositionPicked *> *)values;

- (void)addBarCodesObject:(STMStockBatchBarCode *)value;
- (void)removeBarCodesObject:(STMStockBatchBarCode *)value;
- (void)addBarCodes:(NSSet<STMStockBatchBarCode *> *)values;
- (void)removeBarCodes:(NSSet<STMStockBatchBarCode *> *)values;

@end

NS_ASSUME_NONNULL_END
