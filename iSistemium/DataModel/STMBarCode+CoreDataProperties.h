//
//  STMBarCode+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMBarCode.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMBarCode (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) NSSet<STMArticle *> *articles;
@property (nullable, nonatomic, retain) NSSet<STMPickingOrderPositionPicked *> *pickingOrderPositionssPicked;
@property (nullable, nonatomic, retain) NSSet<STMStockBatch *> *stockBatches;

@end

@interface STMBarCode (CoreDataGeneratedAccessors)

- (void)addArticlesObject:(STMArticle *)value;
- (void)removeArticlesObject:(STMArticle *)value;
- (void)addArticles:(NSSet<STMArticle *> *)values;
- (void)removeArticles:(NSSet<STMArticle *> *)values;

- (void)addPickingOrderPositionssPickedObject:(STMPickingOrderPositionPicked *)value;
- (void)removePickingOrderPositionssPickedObject:(STMPickingOrderPositionPicked *)value;
- (void)addPickingOrderPositionssPicked:(NSSet<STMPickingOrderPositionPicked *> *)values;
- (void)removePickingOrderPositionssPicked:(NSSet<STMPickingOrderPositionPicked *> *)values;

- (void)addStockBatchesObject:(STMStockBatch *)value;
- (void)removeStockBatchesObject:(STMStockBatch *)value;
- (void)addStockBatches:(NSSet<STMStockBatch *> *)values;
- (void)removeStockBatches:(NSSet<STMStockBatch *> *)values;

@end

NS_ASSUME_NONNULL_END
