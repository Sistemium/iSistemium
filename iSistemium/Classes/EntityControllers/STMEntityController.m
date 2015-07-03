//
//  STMEntityController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 13/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMEntityController.h"
#import "STMObjectsController.h"

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
        
        if (capEntityName) {
            stcEntities[[@"STM" stringByAppendingString:capEntityName]] = entity;
        }
        
    }
    
    return (stcEntities.count > 0) ? stcEntities : nil;
    
}

+ (NSArray *)stcEntitiesArray {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMEntity class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
    
    NSError *error;
    NSArray *result = [[self document].managedObjectContext executeFetchRequest:request error:&error];
    
    NSMutableArray *returnValue = result.mutableCopy;
        
    return returnValue;
    
}

+ (NSArray *)uploadableEntitiesNames {

    NSMutableDictionary *stcEntities = [[self stcEntities] mutableCopy];
    
    NSSet *filteredKeys = [stcEntities keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        return ([[obj valueForKey:@"isUploadable"] boolValue] == YES);
    }];
        
    return filteredKeys.allObjects;

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
    NSArray *result = [[self document].managedObjectContext executeFetchRequest:request error:&error];
    
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
    
/* next two lines is for generating duplicates
 
    NSArray *entitiesArray = [self stcEntitiesArray];
    NSLog(@"entitiesArray.count %d", entitiesArray.count);
 
*/
    NSString *entityName = NSStringFromClass([STMEntity class]);
    NSString *property = @"name";
    
    STMEntityDescription *entity = [STMEntityDescription entityForName:entityName inManagedObjectContext:self.document.managedObjectContext];
    
    NSPropertyDescription *entityProperty = entity.propertiesByName[property];
    
    if (entityProperty) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        
        NSExpression *expression = [NSExpression expressionForKeyPath:property];
        NSExpression *countExpression = [NSExpression expressionForFunction:@"count:" arguments:[NSArray arrayWithObject:expression]];
        NSExpressionDescription *ed = [[NSExpressionDescription alloc] init];
        ed.expression = countExpression;
        ed.expressionResultType = NSInteger64AttributeType;
        ed.name = @"count";
        
        request.propertiesToFetch = @[entityProperty, ed];
        request.propertiesToGroupBy = @[entityProperty];
        request.resultType = NSDictionaryResultType;
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:property ascending:YES]];
        
        NSArray *result = [self.document.managedObjectContext executeFetchRequest:request error:nil];
        
        result = [result filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"count > 1"]];

        if (result.count > 0) {
            
            for (NSDictionary *entity in result) {
                
                NSString *message = [NSString stringWithFormat:@"Entity %@ have %@ duplicates", entity[property], entity[ed.name]];
                [[STMLogger sharedLogger] saveLogMessageWithText:message type:@"error"];
                
                [self removeDuplicatesWithName:entity[property]];
                
            }
            
        } else {
            [[STMLogger sharedLogger] saveLogMessageWithText:@"stc.entity duplicates not found"];
        }
        
    }
    
}

+ (void)removeDuplicatesWithName:(NSString *)name {
    
    NSLog(@"remove entity duplicates for %@", name);
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMEntity class])];
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    
    NSError *error;
    NSArray *result = [[self document].managedObjectContext executeFetchRequest:request error:&error];
    
    STMEntity *actualEntity = [result lastObject];
    NSMutableArray *mutableResult = result.mutableCopy;
    [mutableResult removeObject:actualEntity];
    
    for (STMEntity *entity in mutableResult) {
        [STMObjectsController removeObject:entity];
    }
    
    [[self document] saveDocument:^(BOOL success) {}];
    
}


@end
