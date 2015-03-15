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
    
// insert duplicates
    
    if (result.count < 40) {
        
        STMEntity *result0 = result[20];

        STMEntity *duplicateEntity = [STMEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STMEntity class]) inManagedObjectContext:[self document].managedObjectContext];

        duplicateEntity.name = result0.name;

        [returnValue addObject:duplicateEntity];

    }
    
// end of insert duplicates
    
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
    
    NSArray *entitiesArray = [self stcEntitiesArray];

    NSLog(@"entitiesArray.count %d", entitiesArray.count);
    
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
//    NSPropertyDescription *xidProperty = entity.propertiesByName[@"xid"];
    
    if (entityProperty) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        
//        NSExpression *keypath = [NSExpression expressionForKeyPath:propertyName];
//        NSExpressionDescription *description = [[NSExpressionDescription alloc] init];
//        description.expression = keypath;
//        description.name = propertyName;
//        description.expressionResultType = NSStringAttributeType;

        NSExpression *expression = [NSExpression expressionForKeyPath:property];
        NSExpression *countExpression = [NSExpression expressionForFunction:@"count:" arguments:[NSArray arrayWithObject:expression]];
        NSExpressionDescription *ed = [[NSExpressionDescription alloc] init];
        ed.expression = countExpression;
        ed.expressionResultType = NSInteger64AttributeType;
        ed.name = @"nameCount";
        
        request.propertiesToFetch = @[entityProperty, ed];
        request.propertiesToGroupBy = @[entityProperty];
        
//        request.havingPredicate = [NSPredicate predicateWithFormat:@"%@ > 1", ed];
        
        request.resultType = NSDictionaryResultType;
        
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:property ascending:YES]];
        
        NSArray *result = [self.document.managedObjectContext executeFetchRequest:request error:nil];
        
        result = [result filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"nameCount > 1"]];

        if (result.count > 0) {
            
            for (NSDictionary *entity in result) {
                
                NSString *message = [NSString stringWithFormat:@"Entity %@ have %@ duplicates", entity[property], entity[ed.name]];
                [[STMLogger sharedLogger] saveLogMessageWithText:message type:@"error"];
                
            }
            
        } else {
            NSLog(@"stc.entity duplicates not found");
        }
        
//        return result;
        
    } else {
        
//        return nil;
        
    }

    
}


@end
