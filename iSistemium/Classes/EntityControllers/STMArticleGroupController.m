//
//  STMArticleGroupController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMArticleGroupController.h"
#import "STMObjectsController.h"

@implementation STMArticleGroupController

+ (NSUInteger)numberOfArticlesInGroup:(STMArticleGroup *)articleGroup {

    NSUInteger result = articleGroup.articles.count;

    for (STMArticleGroup *group in articleGroup.articleGroups) {
        result += [self numberOfArticlesInGroup:group];
    }

    return result;
    
}

+ (void)checkParentAndChildrenFields {
    
    NSArray *articleGroups = [STMObjectsController objectsForEntityName:NSStringFromClass([STMArticleGroup class])];

    NSMutableSet *parentsSet = [NSMutableSet set];
    
    for (STMArticleGroup *articleGroup in articleGroups) {
        
        [self addParentFromArticleGroup:articleGroup toMutableset:parentsSet];
        [articleGroup addParents:parentsSet];
        
    }
    
}

+ (void)addParentFromArticleGroup:(STMArticleGroup *)articleGroup toMutableset:(NSMutableSet *)parentsSet {
    
    if (articleGroup.articleGroup) {
        
        [parentsSet addObject:articleGroup.articleGroup];
        [self addParentFromArticleGroup:articleGroup.articleGroup toMutableset:parentsSet];
        
    }
    
}

@end
