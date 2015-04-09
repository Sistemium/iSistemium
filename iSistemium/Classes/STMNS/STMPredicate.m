//
//  STMPredicate.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMPredicate.h"

@implementation STMPredicate

+ (NSPredicate *)predicateWithNoFantomsFromPredicate:(NSPredicate *)predicate {
    
    NSPredicate *notFantom = [NSPredicate predicateWithFormat:@"(isFantom == NO) OR (isFantom == nil)"];

    predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, notFantom]];
    
    return predicate;
    
}


@end
