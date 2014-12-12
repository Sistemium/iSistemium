//
//  STMEntityDescription.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 12/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMEntityDescription.h"

@implementation STMEntityDescription

+ (id)insertNewObjectForEntityForName:(NSString *)entityName inManagedObjectContext:(NSManagedObjectContext *)context {
    
    NSString *eName = [NSString stringWithFormat:@"%@", entityName];
    
    return [super insertNewObjectForEntityForName:eName inManagedObjectContext:context];
    
}

+ (STMEntityDescription *)entityForName:(NSString *)entityName inManagedObjectContext:(NSManagedObjectContext *)context {
    
    NSString *eName = [NSString stringWithFormat:@"%@", entityName];
    
    return (STMEntityDescription *)[super entityForName:eName inManagedObjectContext:context];
    
}

@end
