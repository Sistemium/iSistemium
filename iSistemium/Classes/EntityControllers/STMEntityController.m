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
    
    NSMutableArray *returnValue = result.mutableCopy;
    
//    STMEntity *result0 = result[0];
//    
//    STMEntity *duplicateEntity = [STMEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STMEntity class]) inManagedObjectContext:[self document].managedObjectContext];
//    
//    duplicateEntity.name = result0.name;
//    
//    [returnValue addObject:duplicateEntity];

    return returnValue;
    
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

+ (void)checkEntitiesForDuplicates {
    
// TODO: checkEntitiesForDuplicates
    
//    NSArray *entitiesArray = [self stcEntitiesArray];

//    for (STMEntity *entity in entitiesArray) {
//        
//        NSLog(@"entity.name %@", entity.name);
//        NSLog(@"entity.deviceCts %@", entity.deviceCts);
//        
//    }
    
    NSString *entityName = NSStringFromClass([STMEntity class]);
    NSString *property = @"name";

    STMEntityDescription *entity = [STMEntityDescription entityForName:entityName inManagedObjectContext:self.document.managedObjectContext];

    NSPropertyDescription *entityProperty = entity.propertiesByName[property];
    
    if (entityProperty) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        
        NSString *propertyName = property;
        
//        NSExpression *keypath = [NSExpression expressionForKeyPath:propertyName];
//        NSExpressionDescription *description = [[NSExpressionDescription alloc] init];
//        description.expression = keypath;
//        description.name = propertyName;
//        description.expressionResultType = NSStringAttributeType;

        NSExpression *expression = [NSExpression expressionForKeyPath:propertyName];
        NSExpression *countExpression = [NSExpression expressionForFunction:@"count:" arguments:[NSArray arrayWithObject:expression]];
        NSExpressionDescription *ed = [[NSExpressionDescription alloc] init];
        ed.expression = countExpression;
        ed.expressionResultType = NSInteger64AttributeType;
        ed.name = @"count";

        
        request.propertiesToFetch = @[entityProperty, ed];
        request.propertiesToGroupBy = @[propertyName];
        
        request.resultType = NSDictionaryResultType;
        
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:propertyName ascending:YES]];
        
        NSArray *result = [self.document.managedObjectContext executeFetchRequest:request error:nil];
        
        NSLog(@"result %@", result);
        
//        return result;
        
    } else {
        
//        return nil;
        
    }

    
}


@end
