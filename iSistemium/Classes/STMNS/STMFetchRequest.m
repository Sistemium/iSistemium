//
//  STMFetchRequest.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 11/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMFetchRequest.h"

@implementation STMFetchRequest

+ (STMFetchRequest *)fetchRequestWithEntityName:(NSString *)entityName {
    
    entityName = [NSString stringWithFormat:@"%@", entityName];
    
    return (STMFetchRequest *)[super fetchRequestWithEntityName:entityName];
    
}


@end
