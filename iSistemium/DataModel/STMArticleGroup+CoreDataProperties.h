//
//  STMArticleGroup+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMArticleGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMArticleGroup (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *checksum;
@property (nullable, nonatomic, retain) NSString *commentText;
@property (nullable, nonatomic, retain) NSDate *deviceCts;
@property (nullable, nonatomic, retain) NSDate *deviceTs;
@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSNumber *isFantom;
@property (nullable, nonatomic, retain) NSDate *lts;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *ord;
@property (nullable, nonatomic, retain) NSData *ownerXid;
@property (nullable, nonatomic, retain) NSString *source;
@property (nullable, nonatomic, retain) NSDate *sqts;
@property (nullable, nonatomic, retain) NSDate *sts;
@property (nullable, nonatomic, retain) NSData *xid;
@property (nullable, nonatomic, retain) STMArticleGroup *articleGroup;
@property (nullable, nonatomic, retain) NSSet<STMArticleGroup *> *articleGroups;
@property (nullable, nonatomic, retain) NSSet<STMArticle *> *articles;
@property (nullable, nonatomic, retain) NSSet<STMArticleGroup *> *children;
@property (nullable, nonatomic, retain) NSSet<STMArticleGroup *> *parents;

@end

@interface STMArticleGroup (CoreDataGeneratedAccessors)

- (void)addArticleGroupsObject:(STMArticleGroup *)value;
- (void)removeArticleGroupsObject:(STMArticleGroup *)value;
- (void)addArticleGroups:(NSSet<STMArticleGroup *> *)values;
- (void)removeArticleGroups:(NSSet<STMArticleGroup *> *)values;

- (void)addArticlesObject:(STMArticle *)value;
- (void)removeArticlesObject:(STMArticle *)value;
- (void)addArticles:(NSSet<STMArticle *> *)values;
- (void)removeArticles:(NSSet<STMArticle *> *)values;

- (void)addChildrenObject:(STMArticleGroup *)value;
- (void)removeChildrenObject:(STMArticleGroup *)value;
- (void)addChildren:(NSSet<STMArticleGroup *> *)values;
- (void)removeChildren:(NSSet<STMArticleGroup *> *)values;

- (void)addParentsObject:(STMArticleGroup *)value;
- (void)removeParentsObject:(STMArticleGroup *)value;
- (void)addParents:(NSSet<STMArticleGroup *> *)values;
- (void)removeParents:(NSSet<STMArticleGroup *> *)values;

@end

NS_ASSUME_NONNULL_END
