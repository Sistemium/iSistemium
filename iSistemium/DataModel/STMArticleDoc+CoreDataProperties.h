//
//  STMArticleDoc+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMArticleDoc.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMArticleDoc (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *dateImport;
@property (nullable, nonatomic, retain) NSDate *dateProduction;
@property (nullable, nonatomic, retain) NSNumber *volume;
@property (nullable, nonatomic, retain) STMArticle *article;
@property (nullable, nonatomic, retain) NSSet<STMSupplyOrderArticleDoc *> *supplyOrderArticleDocs;

@end

@interface STMArticleDoc (CoreDataGeneratedAccessors)

- (void)addSupplyOrderArticleDocsObject:(STMSupplyOrderArticleDoc *)value;
- (void)removeSupplyOrderArticleDocsObject:(STMSupplyOrderArticleDoc *)value;
- (void)addSupplyOrderArticleDocs:(NSSet<STMSupplyOrderArticleDoc *> *)values;
- (void)removeSupplyOrderArticleDocs:(NSSet<STMSupplyOrderArticleDoc *> *)values;

@end

NS_ASSUME_NONNULL_END
