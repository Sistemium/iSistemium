//
//  STMQualityClass+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 16/11/15.
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
@property (nullable, nonatomic, retain) NSSet<STMStockBatch *> *stockBatches;
@property (nullable, nonatomic, retain) NSSet<STMPickingOrderArticle *> *pickingOrderArticles;

@end

@interface STMQualityClass (CoreDataGeneratedAccessors)

- (void)addStockBatchesObject:(STMStockBatch *)value;
- (void)removeStockBatchesObject:(STMStockBatch *)value;
- (void)addStockBatches:(NSSet<STMStockBatch *> *)values;
- (void)removeStockBatches:(NSSet<STMStockBatch *> *)values;

- (void)addPickingOrderArticlesObject:(STMPickingOrderArticle *)value;
- (void)removePickingOrderArticlesObject:(STMPickingOrderArticle *)value;
- (void)addPickingOrderArticles:(NSSet<STMPickingOrderArticle *> *)values;
- (void)removePickingOrderArticles:(NSSet<STMPickingOrderArticle *> *)values;

@end

NS_ASSUME_NONNULL_END
