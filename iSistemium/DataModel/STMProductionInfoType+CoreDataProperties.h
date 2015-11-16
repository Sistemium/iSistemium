//
//  STMProductionInfoType+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 16/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMProductionInfoType.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMProductionInfoType (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *datatype;
@property (nullable, nonatomic, retain) NSSet<STMArticle *> *articles;
@property (nullable, nonatomic, retain) NSSet<STMArticleProductionInfo *> *articleProductionInfo;

@end

@interface STMProductionInfoType (CoreDataGeneratedAccessors)

- (void)addArticlesObject:(STMArticle *)value;
- (void)removeArticlesObject:(STMArticle *)value;
- (void)addArticles:(NSSet<STMArticle *> *)values;
- (void)removeArticles:(NSSet<STMArticle *> *)values;

- (void)addArticleProductionInfoObject:(STMArticleProductionInfo *)value;
- (void)removeArticleProductionInfoObject:(STMArticleProductionInfo *)value;
- (void)addArticleProductionInfo:(NSSet<STMArticleProductionInfo *> *)values;
- (void)removeArticleProductionInfo:(NSSet<STMArticleProductionInfo *> *)values;

@end

NS_ASSUME_NONNULL_END
