//
//  STMPickingOrderArticle+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMPickingOrderArticle.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMPickingOrderArticle (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *volume;
@property (nullable, nonatomic, retain) NSNumber *ord;
@property (nullable, nonatomic, retain) STMArticle *article;
@property (nullable, nonatomic, retain) STMPickingOrder *pickingOrder;
@property (nullable, nonatomic, retain) NSSet<STMPickingOrderArticlePicked *> *pickingOrderArticlesPicked;
@property (nullable, nonatomic, retain) STMQualityClass *qualityClass;

@end

@interface STMPickingOrderArticle (CoreDataGeneratedAccessors)

- (void)addPickingOrderArticlesPickedObject:(STMPickingOrderArticlePicked *)value;
- (void)removePickingOrderArticlesPickedObject:(STMPickingOrderArticlePicked *)value;
- (void)addPickingOrderArticlesPicked:(NSSet<STMPickingOrderArticlePicked *> *)values;
- (void)removePickingOrderArticlesPicked:(NSSet<STMPickingOrderArticlePicked *> *)values;

@end

NS_ASSUME_NONNULL_END
