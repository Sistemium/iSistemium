//
//  STMQualityClass+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMQualityClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMQualityClass (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *ord;
@property (nullable, nonatomic, retain) NSSet<STMPickingOrderPosition *> *pickingOrderPositions;
@property (nullable, nonatomic, retain) NSSet<STMStockBatch *> *stockBatches;

@end

@interface STMQualityClass (CoreDataGeneratedAccessors)

- (void)addPickingOrderPositionsObject:(STMPickingOrderPosition *)value;
- (void)removePickingOrderPositionsObject:(STMPickingOrderPosition *)value;
- (void)addPickingOrderPositions:(NSSet<STMPickingOrderPosition *> *)values;
- (void)removePickingOrderPositions:(NSSet<STMPickingOrderPosition *> *)values;

- (void)addStockBatchesObject:(STMStockBatch *)value;
- (void)removeStockBatchesObject:(STMStockBatch *)value;
- (void)addStockBatches:(NSSet<STMStockBatch *> *)values;
- (void)removeStockBatches:(NSSet<STMStockBatch *> *)values;

@end

NS_ASSUME_NONNULL_END
