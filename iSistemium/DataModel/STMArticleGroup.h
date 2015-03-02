//
//  STMArticleGroup.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMArticle, STMArticleGroup;

@interface STMArticleGroup : STMComment

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * ord;
@property (nonatomic, retain) NSSet *articleGroup;
@property (nonatomic, retain) STMArticleGroup *articleGroups;
@property (nonatomic, retain) NSSet *articles;
@end

@interface STMArticleGroup (CoreDataGeneratedAccessors)

- (void)addArticleGroupObject:(STMArticleGroup *)value;
- (void)removeArticleGroupObject:(STMArticleGroup *)value;
- (void)addArticleGroup:(NSSet *)values;
- (void)removeArticleGroup:(NSSet *)values;

- (void)addArticlesObject:(STMArticle *)value;
- (void)removeArticlesObject:(STMArticle *)value;
- (void)addArticles:(NSSet *)values;
- (void)removeArticles:(NSSet *)values;

@end
