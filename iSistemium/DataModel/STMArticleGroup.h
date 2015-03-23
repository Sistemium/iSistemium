//
//  STMArticleGroup.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 23/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMArticle, STMArticleGroup;

@interface STMArticleGroup : STMComment

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * ord;
@property (nonatomic, retain) STMArticleGroup *articleGroup;
@property (nonatomic, retain) NSSet *articleGroups;
@property (nonatomic, retain) NSSet *articles;
@property (nonatomic, retain) NSSet *parents;
@property (nonatomic, retain) NSSet *children;
@end

@interface STMArticleGroup (CoreDataGeneratedAccessors)

- (void)addArticleGroupsObject:(STMArticleGroup *)value;
- (void)removeArticleGroupsObject:(STMArticleGroup *)value;
- (void)addArticleGroups:(NSSet *)values;
- (void)removeArticleGroups:(NSSet *)values;

- (void)addArticlesObject:(STMArticle *)value;
- (void)removeArticlesObject:(STMArticle *)value;
- (void)addArticles:(NSSet *)values;
- (void)removeArticles:(NSSet *)values;

- (void)addParentsObject:(STMArticleGroup *)value;
- (void)removeParentsObject:(STMArticleGroup *)value;
- (void)addParents:(NSSet *)values;
- (void)removeParents:(NSSet *)values;

- (void)addChildrenObject:(STMArticleGroup *)value;
- (void)removeChildrenObject:(STMArticleGroup *)value;
- (void)addChildren:(NSSet *)values;
- (void)removeChildren:(NSSet *)values;

@end
