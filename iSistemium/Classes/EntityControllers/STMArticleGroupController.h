//
//  STMArticleGroupController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMController.h"
#import "STMArticleGroup.h"

@interface STMArticleGroupController : STMController

+ (NSUInteger)numberOfArticlesInGroup:(STMArticleGroup *)articleGroup;

+ (void)refillParents;

+ (NSSet *)parentsForArticleGroup:(STMArticleGroup *)articleGroup;


@end
