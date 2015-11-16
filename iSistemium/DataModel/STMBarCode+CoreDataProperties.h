//
//  STMBarCode+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 16/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMBarCode.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMBarCode (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) NSSet<STMStockBatch *> *stockBatches;
@property (nullable, nonatomic, retain) NSSet<STMArticle *> *articles;
@property (nullable, nonatomic, retain) NSSet<STMPickingOrderArticlePicked *> *pickingOrderArticlesPicked;

@end

@interface STMBarCode (CoreDataGeneratedAccessors)

- (void)addStockBatchesObject:(STMStockBatch *)value;
- (void)removeStockBatchesObject:(STMStockBatch *)value;
- (void)addStockBatches:(NSSet<STMStockBatch *> *)values;
- (void)removeStockBatches:(NSSet<STMStockBatch *> *)values;

- (void)addArticlesObject:(STMArticle *)value;
- (void)removeArticlesObject:(STMArticle *)value;
- (void)addArticles:(NSSet<STMArticle *> *)values;
- (void)removeArticles:(NSSet<STMArticle *> *)values;

- (void)addPickingOrderArticlesPickedObject:(STMPickingOrderArticlePicked *)value;
- (void)removePickingOrderArticlesPickedObject:(STMPickingOrderArticlePicked *)value;
- (void)addPickingOrderArticlesPicked:(NSSet<STMPickingOrderArticlePicked *> *)values;
- (void)removePickingOrderArticlesPicked:(NSSet<STMPickingOrderArticlePicked *> *)values;

@end

NS_ASSUME_NONNULL_END
