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

    NSArray *stcEntitiesArray = [self stcEntitiesArray];
    
    for (STMEntity *entity in stcEntitiesArray) {
    
        NSString *capFirstLetter = (entity.name) ? [[entity.name substringToIndex:1] capitalizedString] : nil;
        
        NSString *capEntityName = [entity.name stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:capFirstLetter];
        
        stcEntities[[@"STM" stringByAppendingString:capEntityName]] = entity;
        
    }
    
    return (stcEntities.count > 0) ? stcEntities : nil;
    
}

+ (NSArray *)stcEntitiesArray {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMEntity class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
    
    NSError *error;
    NSArray *result = [[[self document] managedObjectContext] executeFetchRequest:request error:&error];

    return result;
    
}

+ (NSSet *)entityNamesWithLifeTime {
    
    NSMutableDictionary *stcEntities = [[self stcEntities] mutableCopy];
    
    NSSet *filteredKeys = [stcEntities keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        return ([[obj valueForKey:@"lifeTime"] doubleValue] > 0);
    }];

    return filteredKeys;
    
}

+ (NSArray *)entitiesWithLifeTime {
    
    NSArray *stcEntitiesArray = [self stcEntitiesArray];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lifeTime.intValue > 0"];
    NSArray *result = [stcEntitiesArray filteredArrayUsingPredicate:predicate];
    
    return result;
    
}

+ (STMEntity *)entityWithName:(NSString *)name {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMEntity class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"name == %@", name];

    NSError *error;
    NSArray *result = [[[self document] managedObjectContext] executeFetchRequest:request error:&error];

    return [result lastObject];
    
}

+ (void)deleteEntityWithName:(NSString *)name {

    __weak STMEntity *entityToDelete = ([self stcEntities])[name];

    if (entityToDelete) {
        
        __weak NSManagedObjectContext *context = entityToDelete.managedObjectContext;
        
        [context performBlock:^{
            
            [context deleteObject:entityToDelete];
            
        }];

    } else {
        
        NSString *logMessage = [NSString stringWithFormat:@"where is no entity with name %@ to delete", name];
        [[STMLogger sharedLogger] saveLogMessageWithText:logMessage];
        
    }
    
}


@end
