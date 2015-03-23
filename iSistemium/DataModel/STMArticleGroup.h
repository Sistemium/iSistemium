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
@property (nonatomic, retain) STMArticleGroup *parents;
@property (nonatomic, retain) STMArticleGroup *children;
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

@end
