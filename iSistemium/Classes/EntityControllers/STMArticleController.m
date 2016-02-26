//
//  STMArticleController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 19/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMArticleController.h"

@implementation STMArticleController

+ (NSArray *)packageRels {
    
    STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMArticle class])];
    
    request.predicate = [NSPredicate predicateWithFormat:@"packageRel != nil"];
    
    NSArray *result = [[self document].managedObjectContext executeFetchRequest:request error:nil];
    
    result = [result valueForKeyPath:@"@distinctUnionOfObjects.packageRel"];
    result = [result sortedArrayUsingSelector:@selector(compare:)];
    
    return result;
    
}

@end
