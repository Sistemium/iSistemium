//
//  STMProductionInfoType+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMProductionInfoType.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMProductionInfoType (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *commentText;
@property (nullable, nonatomic, retain) NSString *datatype;
@property (nullable, nonatomic, retain) NSDate *deviceCts;
@property (nullable, nonatomic, retain) NSDate *deviceTs;
@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSNumber *isFantom;
@property (nullable, nonatomic, retain) NSDate *lts;
@property (nullable, nonatomic, retain) NSString *mask;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSData *ownerXid;
@property (nullable, nonatomic, retain) NSString *separator;
@property (nullable, nonatomic, retain) NSString *source;
@property (nullable, nonatomic, retain) NSDate *sqts;
@property (nullable, nonatomic, retain) NSDate *sts;
@property (nullable, nonatomic, retain) NSData *xid;
@property (nullable, nonatomic, retain) NSSet<STMArticleProductionInfo *> *articleProductionInfo;
@property (nullable, nonatomic, retain) NSSet<STMArticle *> *articles;

@end

@interface STMProductionInfoType (CoreDataGeneratedAccessors)

- (void)addArticleProductionInfoObject:(STMArticleProductionInfo *)value;
- (void)removeArticleProductionInfoObject:(STMArticleProductionInfo *)value;
- (void)addArticleProductionInfo:(NSSet<STMArticleProductionInfo *> *)values;
- (void)removeArticleProductionInfo:(NSSet<STMArticleProductionInfo *> *)values;

- (void)addArticlesObject:(STMArticle *)value;
- (void)removeArticlesObject:(STMArticle *)value;
- (void)addArticles:(NSSet<STMArticle *> *)values;
- (void)removeArticles:(NSSet<STMArticle *> *)values;

@end

NS_ASSUME_NONNULL_END
