//
//  STMFetchRequest.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 11/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMFetchRequest.h"
#import "STMNS.h"

@interface STMFetchRequest()


@end


@implementation STMFetchRequest

+ (STMFetchRequest *)fetchRequestWithEntityName:(NSString *)entityName {
    
    entityName = [NSString stringWithFormat:@"%@", entityName];
    
    return (STMFetchRequest *)[super fetchRequestWithEntityName:entityName];
    
}

- (void)setPredicate:(NSPredicate *)predicate {
    
    predicate  = [STMPredicate predicateWithNoFantomsFromPredicate:predicate];
    
    [super setPredicate:predicate];
    
}

@end