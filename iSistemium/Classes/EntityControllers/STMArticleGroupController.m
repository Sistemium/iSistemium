//
//  STMArticleGroupController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMArticleGroupController.h"
#import "STMObjectsController.h"

@interface STMArticleGroupController()

@property (nonatomic, strong) NSMutableDictionary *articleGroupsDic;

@end


@implementation STMArticleGroupController

+ (STMArticleGroupController *)sharedInstance {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
    
}


+ (NSUInteger)numberOfArticlesInGroup:(STMArticleGroup *)articleGroup {

    NSUInteger result = articleGroup.articles.count;

    for (STMArticleGroup *group in articleGroup.articleGroups) {
        result += [self numberOfArticlesInGroup:group];
    }

    return result;
    
}

+ (void)refillParents {
    
    NSArray *articleGroups = [STMObjectsController objectsForEntityName:NSStringFromClass([STMArticleGroup class])];
    
    for (STMArticleGroup *articleGroup in articleGroups) {
        
        [articleGroup removeParents:articleGroup.parents];
        [articleGroup removeChildren:articleGroup.children];
        
    }

    [self sharedInstance].articleGroupsDic = [NSMutableDictionary dictionary];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"articleGroups.@count == 0"];
    NSArray *childlessArticleGroups = [articleGroups filteredArrayUsingPredicate:predicate];
    
    for (STMArticleGroup *articleGroup in childlessArticleGroups) [self parentsForArticleGroup:articleGroup];
    
}

+ (NSSet *)parentsForArticleGroup:(STMArticleGroup *)articleGroup {
    
    if (articleGroup.articleGroup) {
        
        NSMutableSet *parents = [NSMutableSet setWithObject:articleGroup.articleGroup];

        NSSet *cachedParents = [self sharedInstance].articleGroupsDic[articleGroup.articleGroup.xid];
        
        if (cachedParents) {
            [parents unionSet:cachedParents];
        } else {
            [parents unionSet:[self parentsForArticleGroup:articleGroup.articleGroup]];
        }
        
        [self sharedInstance].articleGroupsDic[articleGroup.xid] = parents;
        [articleGroup addParents:parents];
        
        return parents;

    } else {
        
        NSSet *emptySet = [NSSet set];
        
        [self sharedInstance].articleGroupsDic[articleGroup.xid] = emptySet;
        [articleGroup addParents:emptySet];
        
        return emptySet;
        
    }
    
}


@end
