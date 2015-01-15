//
//  STMEntityController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 13/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMEntityController.h"

@interface STMEntityController()

@end


@implementation STMEntityController

+ (STMEntityController *)sharedInstance {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
    
}

+ (NSDictionary *)stcEntities {
    
    NSMutableDictionary *stcEntities = [NSMutableDictionary dictionary];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMEntity class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)]];

    NSError *error;
    NSArray *result = [[[self document] managedObjectContext] executeFetchRequest:request error:&error];
    
    for (STMEntity *entity in result) {
    
        NSString *capFirstLetter = (entity.name) ? [[entity.name substringToIndex:1] capitalizedString] : nil;
        
        NSString *capEntityName = [entity.name stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:capFirstLetter];
        
        [stcEntities setObject:entity forKey:[@"STM" stringByAppendingString:capEntityName]];
        
    }
    
    return (stcEntities.count > 0) ? stcEntities : nil;
    
}

+ (NSSet *)entityNamesWithLifeTime {
    
    NSMutableDictionary *stcEntities = [[self stcEntities] mutableCopy];
    
    NSSet *filteredKeys = [stcEntities keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        return ([[obj valueForKey:@"lifeTime"] doubleValue] > 0);
    }];

    return filteredKeys;
    
}

+ (STMEntity *)entityWithName:(NSString *)name {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMEntity class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"name == %@", name];

    NSError *error;
    NSArray *result = [[[self document] managedObjectContext] executeFetchRequest:request error:&error];

    return [result lastObject];
    
}

@end
