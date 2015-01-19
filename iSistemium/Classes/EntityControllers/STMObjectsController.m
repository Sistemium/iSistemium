//
//  STMObjectsController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMObjectsController.h"
#import "STMAuthController.h"
#import "STMFunctions.h"
#import "STMSyncer.h"
#import "STMEntityDescription.h"
#import "STMEntityController.h"
#import "STMClientDataController.h"
#import "STMPicturesController.h"

#import "STMPartner.h"
#import "STMOutlet.h"
#import "STMSalesman.h"
#import "STMCampaign.h"
#import "STMCampaignPicture.h"
#import "STMPhotoReport.h"
#import "STMPhoto.h"
#import "STMArticle.h"
#import "STMArticlePicture.h"
#import "STMSetting.h"
#import "STMLogMessage.h"
#import "STMDebt.h"
#import "STMCashing.h"
#import "STMUncashing.h"
#import "STMMessage.h"
#import "STMClientData.h"
#import "STMLocation.h"
#import "STMUncashingPicture.h"
#import "STMUncashingPlace.h"
#import "STMTrack.h"
#import "STMEntity.h"


@implementation STMObjectsController


#pragma mark - singleton

+ (STMObjectsController *)sharedController {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedController = nil;
    
    dispatch_once(&pred, ^{
    
//        NSLog(@"STMObjectsController init");
        _sharedController = [[self alloc] init];
    
    });
    
    return _sharedController;
    
}


#pragma mark - recieved objects management

+ (void)insertObjectsFromArray:(NSArray *)array withCompletionHandler:(void (^)(BOOL success))completionHandler {
    
    __block BOOL result = YES;
    
    for (NSDictionary *datum in array) {
        
        [self insertObjectFromDictionary:datum withCompletionHandler:^(BOOL success) {
            
            result &= success;
            
        }];
        
    }

    completionHandler(result);

}

+ (void)insertObjectFromDictionary:(NSDictionary *)dictionary withCompletionHandler:(void (^)(BOOL success))completionHandler {
    
    NSString *name = [dictionary objectForKey:@"name"];
    NSDictionary *properties = [dictionary objectForKey:@"properties"];

    NSArray *nameExplode = [name componentsSeparatedByString:@"."];
    NSString *nameTail = (nameExplode.count > 1) ? [nameExplode objectAtIndex:1] : name;
    NSString *capEntityName = [nameTail stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[nameTail substringToIndex:1] capitalizedString]];

    NSString *entityName = [@"STM" stringByAppendingString:capEntityName];
    
    NSArray *dataModelEntityNames = [self localDataModelEntityNames];
    
    if ([dataModelEntityNames containsObject:entityName]) {
        
        NSString *xid = [dictionary objectForKey:@"xid"];
        NSData *xidData = (xid) ? [STMFunctions dataFromString:[xid stringByReplacingOccurrencesOfString:@"-" withString:@""]] : nil;
        
        STMRecordStatus *recordStatus = [self existingRecordStatusForXid:xidData];
        
        if (![recordStatus.isRemoved boolValue]) {
            
            NSManagedObject *object = nil;
            
            if ([entityName isEqualToString:NSStringFromClass([STMSetting class])]) {
                
                object = [[[self session] settingsController] settingForDictionary:dictionary];
                
            } else if ([entityName isEqualToString:NSStringFromClass([STMEntity class])]) {
                
                NSString *internalName = [properties objectForKey:@"name"];
                object = [STMEntityController entityWithName:internalName];
                
            }
            
            if (!object) {
            
                object = (xid) ? [self objectForEntityName:entityName andXid:xid] : [self newObjectForEntityName:entityName];

            }
            
            if (![self isWaitingToSyncForObject:object]) {
                
                [object setValue:[NSNumber numberWithBool:NO] forKey:@"isFantom"];
                [self processingOfObject:object withEntityName:entityName fillWithValues:properties];
                
            }

        } else {
            
            NSLog(@"object %@ with xid %@ have recordStatus.isRemoved == YES", entityName, xid);
            
        }
            
        completionHandler(YES);
        
    } else {
        
        completionHandler(NO);
        
    }
    
}

+ (void)processingOfObject:(NSManagedObject *)object withEntityName:(NSString *)entityName fillWithValues:(NSDictionary *)properties {
    
    NSSet *ownObjectKeys = [self ownObjectKeysForEntityName:entityName];
    
    STMEntityDescription *currentEntity = (STMEntityDescription *)[object entity];
    NSDictionary *entityAttributes = [currentEntity attributesByName];
    
    for (NSString *key in ownObjectKeys) {
        
        id value = [properties objectForKey:key];
        
        if (value) {
            
            value = [self typeConversionForValue:value key:key entityAttributes:entityAttributes];
            
            [object setValue:value forKey:key];
            
            if ([key isEqualToString:@"href"]) {
                [STMPicturesController hrefProcessingForObject:object];
            }
            
        } else {
            
            [object setValue:nil forKey:key];
            
        }
        
    }
    
    [self processingOfRelationshipsForObject:object withEntityName:entityName andValues:properties];
    
    [object setValue:[NSDate date] forKey:@"lts"];

    [self postprocessingForObject:object withEntityName:entityName];

}

+ (id)typeConversionForValue:(id)value key:(NSString *)key entityAttributes:(NSDictionary *)entityAttributes {
    
    if ([[[entityAttributes objectForKey:key] attributeValueClassName] isEqualToString:NSStringFromClass([NSDecimalNumber class])]) {
        
        value = [NSDecimalNumber decimalNumberWithString:value];
        
    } else if ([[[entityAttributes objectForKey:key] attributeValueClassName] isEqualToString:NSStringFromClass([NSDate class])]) {
        
        value = [[STMFunctions dateFormatter] dateFromString:value];
        
    } else if ([[[entityAttributes objectForKey:key] attributeValueClassName] isEqualToString:NSStringFromClass([NSNumber class])]) {
        
        value = [NSNumber numberWithBool:[value boolValue]];
        
    } else if ([[[entityAttributes objectForKey:key] attributeValueClassName] isEqualToString:NSStringFromClass([NSData class])]) {
        
        value = [STMFunctions dataFromString:[value stringByReplacingOccurrencesOfString:@"-" withString:@""]];
        
    }

    return value;
    
}

+ (void)processingOfRelationshipsForObject:(NSManagedObject *)object withEntityName:(NSString *)entityName andValues:(NSDictionary *)properties {
    
    NSDictionary *ownObjectRelationships = [self singleRelationshipsForEntityName:entityName];
    
    for (NSString *relationship in [ownObjectRelationships allKeys]) {
        
        NSDictionary *relationshipDictionary = [properties objectForKey:relationship];
        NSString *destinationObjectXid = [relationshipDictionary objectForKey:@"xid"];
        
        if (destinationObjectXid) {
            
            NSManagedObject *destinationObject = [self objectForEntityName:[ownObjectRelationships objectForKey:relationship] andXid:destinationObjectXid];
            
            if (![[object valueForKey:relationship] isEqual:destinationObject]) {
                
                BOOL waitingForSync = [self isWaitingToSyncForObject:destinationObject];
                
                [object setValue:destinationObject forKey:relationship];
                
                if (!waitingForSync) {
                    
                    [destinationObject addObserver:[self sharedController]
                                        forKeyPath:@"deviceTs"
                                           options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                                           context:nil];
                    
                }
                
            }
            
        } else {
            
            NSManagedObject *destinationObject = [object valueForKey:relationship];
            
            if (destinationObject) {
                
                BOOL waitingForSync = [self isWaitingToSyncForObject:destinationObject];
                
                [object setValue:nil forKey:relationship];
                
                if (!waitingForSync) {

                    [destinationObject addObserver:[self sharedController]
                                        forKeyPath:@"deviceTs"
                                           options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                                           context:nil];

                }

            }
            
        }
        
    }
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    [object removeObserver:self forKeyPath:keyPath];
    
    if ([object isKindOfClass:[NSManagedObject class]]) {
        
        [(NSManagedObject *)object setValue:[change valueForKey:NSKeyValueChangeOldKey] forKey:keyPath];
        
    }

}

+ (void)postprocessingForObject:(NSManagedObject *)object withEntityName:(NSString *)entityName {
    
    if ([entityName isEqualToString:NSStringFromClass([STMMessage class])]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"gotNewMessage" object:nil];
        
    } else if ([entityName isEqualToString:NSStringFromClass([STMRecordStatus class])]) {
        
        STMRecordStatus *recordStatus = (STMRecordStatus *)object;
        
        NSManagedObject *affectedObject = [self objectForXid:recordStatus.objectXid];
        
        if (affectedObject) {
            
            if ([recordStatus.isRead boolValue]) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"messageIsRead" object:nil];
                
            }
            
            if ([recordStatus.isRemoved boolValue]) {
                
                [[self document].managedObjectContext deleteObject:affectedObject];
//                [[self document].managedObjectContext deleteObject:recordStatus];
                
            }
            
        }
        
    } else if ([entityName isEqualToString:NSStringFromClass([STMSetting class])]) {
        
        STMSetting *setting = (STMSetting *)object;
        
        if ([setting.group isEqualToString:@"appSettings"]) {
            
            [STMClientDataController checkAppVersion];
            
        }
        
    }

}


#pragma mark - recieved relationships management

+ (void)setRelationshipsFromArray:(NSArray *)array withCompletionHandler:(void (^)(BOOL success))completionHandler {
    
    __block BOOL result = YES;
    
    for (NSDictionary *datum in array) {
        
        [self setRelationshipFromDictionary:datum withCompletionHandler:^(BOOL success) {
            
            result &= success;
            
        }];
        
    }

    completionHandler(result);
    
}

+ (void)setRelationshipFromDictionary:(NSDictionary *)dictionary withCompletionHandler:(void (^)(BOOL success))completionHandler {
    
    NSString *name = [dictionary objectForKey:@"name"];
    NSArray *nameExplode = [name componentsSeparatedByString:@"."];
    NSString *entityName = [@"STM" stringByAppendingString:[nameExplode objectAtIndex:1]];

    NSDictionary *serverDataModel = [[STMEntityController stcEntities] copy];

    if ([[serverDataModel allKeys] containsObject:entityName]) {
        
        STMEntity *entityModel = [serverDataModel objectForKey:entityName];
        NSString *roleOwner = entityModel.roleOwner;
        NSString *roleOwnerEntityName = [@"STM" stringByAppendingString:roleOwner];
        NSString *roleName = entityModel.roleName;
        NSDictionary *ownerRelationships = [self ownObjectRelationshipsForEntityName:roleOwnerEntityName];
        NSString *destinationEntityName = [ownerRelationships objectForKey:roleName];
        NSString *destination = [destinationEntityName stringByReplacingOccurrencesOfString:@"STM" withString:@""];
        NSDictionary *properties = [dictionary objectForKey:@"properties"];
        NSDictionary *ownerData = [properties objectForKey:roleOwner];
        NSDictionary *destinationData = [properties objectForKey:destination];
        NSString *ownerXid = [ownerData objectForKey:@"xid"];
        NSString *destinationXid = [destinationData objectForKey:@"xid"];
        BOOL ok = YES;
        
        if (!ownerXid || [ownerXid isEqualToString:@""] || !destinationXid || [destinationXid isEqualToString:@""]) {
            
            ok = NO;
            NSLog(@"Not ok relationship dictionary %@", dictionary);
            
        }
        
        if (ok) {
            
            NSManagedObject *ownerObject = [self objectForEntityName:roleOwnerEntityName andXid:ownerXid];
            NSManagedObject *destinationObject = [self objectForEntityName:destinationEntityName andXid:destinationXid];
            
            NSSet *destinationSet = [ownerObject valueForKey:roleName];
            
            if ([destinationSet containsObject:destinationObject]) {

                NSLog(@"already have relationship %@ %@ — %@ %@", roleOwnerEntityName, ownerXid, destinationEntityName, destinationXid);
                
                
            } else {

                BOOL ownerIsWaitingForSync = [self isWaitingToSyncForObject:ownerObject];
                BOOL destinationIsWaitingForSync = [self isWaitingToSyncForObject:destinationObject];
                
                NSDate *ownerDeviceTs = [ownerObject valueForKey:@"deviceTs"];
                NSDate *destinationDeviceTs = [destinationObject valueForKey:@"deviceTs"];
                
                [[ownerObject mutableSetValueForKey:roleName] addObject:destinationObject];

                if (!ownerIsWaitingForSync) {
                    [ownerObject setValue:ownerDeviceTs forKey:@"deviceTs"];
                }
                
                if (!destinationIsWaitingForSync) {
                    [destinationObject setValue:destinationDeviceTs forKey:@"deviceTs"];
                }
                
            }
            
            
        }
        
        completionHandler(YES);
        
    } else {
        
        completionHandler(NO);
    }
    
}


#pragma mark - info methods

+ (BOOL)isWaitingToSyncForObject:(NSManagedObject *)object {
    
    BOOL isInSyncList = [[self entityNamesForSyncing] containsObject:object.entity.name];

    NSDate *lts = [object valueForKey:@"lts"];
    NSDate *deviceTs = [object valueForKey:@"deviceTs"];
    
    return (isInSyncList && lts && [lts compare:deviceTs] == NSOrderedAscending);
    
}

+ (NSArray *)entityNamesForSyncing {
    
    NSArray *entityNamesForSyncing = @[
                                       NSStringFromClass([STMEntity class]),
                                       NSStringFromClass([STMPhotoReport class]),
                                       NSStringFromClass([STMCashing class]),
                                       NSStringFromClass([STMUncashing class]),
                                       NSStringFromClass([STMClientData class]),
                                       NSStringFromClass([STMRecordStatus class]),
                                       NSStringFromClass([STMUncashingPicture class]),
                                       NSStringFromClass([STMDebt class]),
                                       NSStringFromClass([STMTrack class]),
                                       NSStringFromClass([STMOutlet class]),
                                       NSStringFromClass([STMPartner class]),
                                       NSStringFromClass([STMLocation class])
                                       ];
    
    return entityNamesForSyncing;

}

/*
+ (NSArray *)entityNamesForFlushing {
    
    NSDictionary *entitisDic = [STMEntityController stcEntities];
    
    
    NSArray *entityNamesForFlushing = @[
                                       NSStringFromClass([STMTrack class]),
                                       NSStringFromClass([STMLocation class]),
                                       NSStringFromClass([STMLogMessage class])
                                       ];
    
    return entityNamesForFlushing;

}
*/


#pragma mark - getting specified objects

+ (NSManagedObject *)objectForXid:(NSData *)xidData {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMDatum class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"SELF.xid == %@", xidData];
    
    NSError *error;
    NSArray *fetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];
    
    NSManagedObject *object = [fetchResult lastObject];

    return object;
    
}

+ (NSManagedObject *)objectForEntityName:(NSString *)entityName andXid:(NSString *)xid {
    
    NSArray *dataModelEntityNames = [self localDataModelEntityNames];
    
    if ([dataModelEntityNames containsObject:entityName]) {
        
        NSData *xidData = [STMFunctions dataFromString:[xid stringByReplacingOccurrencesOfString:@"-" withString:@""]];

        NSManagedObject *object = [self objectForXid:xidData];
        
        if (object) {
        
            if (![object.entity.name isEqualToString:entityName]) {
                
                NSLog(@"No %@ object with xid %@, %@ object fetched instead", entityName, xid, object.entity.name);
                object = nil;
                
            }
        
        } else {
            
            object = [self newObjectForEntityName:entityName];
            [object setValue:xidData forKey:@"xid"];
            
        }
        
        return object;
        
    } else {
        
        return nil;
        
    }
    
}

+ (NSManagedObject *)newObjectForEntityName:(NSString *)entityName {
    
    NSManagedObject *object = [STMEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:[self document].managedObjectContext];
    [object setValue:[NSNumber numberWithBool:YES] forKey:@"isFantom"];
    
    return object;
    
}

+ (STMRecordStatus *)existingRecordStatusForXid:(NSData *)objectXid {

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMRecordStatus class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"SELF.objectXid == %@", objectXid];
    
    NSError *error;
    NSArray *fetchResult = [self.document.managedObjectContext executeFetchRequest:request error:&error];
    
    STMRecordStatus *recordStatus = [fetchResult lastObject];

    return recordStatus;
    
}

+ (STMRecordStatus *)recordStatusForObject:(NSManagedObject *)object {
    
    NSData *objectXid = [object valueForKey:@"xid"];

    STMRecordStatus *recordStatus = [self existingRecordStatusForXid:objectXid];
    
    if (!recordStatus) {
        
        recordStatus = [STMEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STMRecordStatus class]) inManagedObjectContext:[self document].managedObjectContext];
        recordStatus.objectXid = objectXid;
        
    }
    
    return recordStatus;
    
}


#pragma mark - getting entity properties

+ (NSSet *)ownObjectKeysForEntityName:(NSString *)entityName {
    
    STMEntityDescription *coreEntity = [STMEntityDescription entityForName:NSStringFromClass([STMComment class]) inManagedObjectContext:[self document].managedObjectContext];
    NSSet *coreKeys = [NSSet setWithArray:[[coreEntity attributesByName] allKeys]];

    STMEntityDescription *objectEntity = [STMEntityDescription entityForName:entityName inManagedObjectContext:[self document].managedObjectContext];
    NSMutableSet *objectKeys = [NSMutableSet setWithArray:[[objectEntity attributesByName] allKeys]];

    [objectKeys minusSet:coreKeys];
    
    return objectKeys;
    
}

+ (NSDictionary *)ownObjectRelationshipsForEntityName:(NSString *)entityName {
    
    STMEntityDescription *coreEntity = [STMEntityDescription entityForName:NSStringFromClass([STMComment class]) inManagedObjectContext:[self document].managedObjectContext];
    NSSet *coreRelationshipNames = [NSSet setWithArray:[[coreEntity relationshipsByName] allKeys]];
    
    STMEntityDescription *objectEntity = [STMEntityDescription entityForName:entityName inManagedObjectContext:[self document].managedObjectContext];
    NSMutableSet *objectRelationshipNames = [NSMutableSet setWithArray:[[objectEntity relationshipsByName] allKeys]];
    
    [objectRelationshipNames minusSet:coreRelationshipNames];
    
    NSMutableDictionary *objectRelationships = [NSMutableDictionary dictionary];
    
    for (NSString *relationshipName in objectRelationshipNames) {
        
        NSRelationshipDescription *relationship = [[objectEntity relationshipsByName] objectForKey:relationshipName];
        [objectRelationships setObject:[relationship destinationEntity].name forKey:relationshipName];
        
    }
    
//    NSLog(@"objectRelationships %@", objectRelationships);
    
    return objectRelationships;
    
}

+ (NSDictionary *)singleRelationshipsForEntityName:(NSString *)entityName {
    
    STMEntityDescription *coreEntity = [STMEntityDescription entityForName:NSStringFromClass([STMComment class]) inManagedObjectContext:[self document].managedObjectContext];
    NSSet *coreRelationshipNames = [NSSet setWithArray:[[coreEntity relationshipsByName] allKeys]];
    
    STMEntityDescription *objectEntity = [STMEntityDescription entityForName:entityName inManagedObjectContext:[self document].managedObjectContext];
    NSMutableSet *objectRelationshipNames = [NSMutableSet setWithArray:[[objectEntity relationshipsByName] allKeys]];
    
    [objectRelationshipNames minusSet:coreRelationshipNames];
    
    NSMutableDictionary *objectRelationships = [NSMutableDictionary dictionary];
    
    for (NSString *relationshipName in objectRelationshipNames) {
        
        NSRelationshipDescription *relationship = [[objectEntity relationshipsByName] objectForKey:relationshipName];
        
        if (![relationship isToMany]) {
            [objectRelationships setObject:[relationship destinationEntity].name forKey:relationshipName];
        }
        
    }
    
    return objectRelationships;

}

+ (NSArray *)localDataModelEntityNames {
    
    return [[self document].managedObjectModel.entitiesByName allKeys];
    
}


#pragma mark - flushing

+ (STMRecordStatus *)removeObject:(NSManagedObject *)object {
    
    STMRecordStatus *recordStatus = [self recordStatusForObject:object];
    recordStatus.isRemoved = [NSNumber numberWithBool:YES];
    
    [self.document.managedObjectContext deleteObject:object];
    [self.document saveDocument:^(BOOL success) {
        
        if (success) {
            
            [self syncer].syncerState = STMSyncerSendDataOnce;
            
        }
        
    }];

    return recordStatus;

}

+ (void)checkObjectsForFlushing {

    NSSet *entityNamesForFlushing = [STMEntityController entityNamesWithLifeTime];
    
//    NSDictionary *appSettings = [[[STMSessionManager sharedManager].currentSession settingsController] currentSettingsForGroup:@"appSettings"];
//    
//    double lifeTime = [[appSettings valueForKey:@"objectsLifeTime"] doubleValue];
    
    NSMutableSet *objectsSet = [NSMutableSet set];
    
    for (NSString *entityName in entityNamesForFlushing) {

        STMEntity *entity = [[STMEntityController stcEntities] objectForKey:entityName];
        double lifeTime = [entity.lifeTime doubleValue];
        NSDate *terminatorDate = [NSDate dateWithTimeInterval:-lifeTime*3600 sinceDate:[NSDate date]];

        NSError *error;
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"deviceCts < %@", terminatorDate];
        NSArray *fetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];
        
        for (NSManagedObject *object in fetchResult) {
            if (![self isWaitingToSyncForObject:object]) [objectsSet addObject:object];
        }
        
    }
    
    if (objectsSet.count > 0) {
        
        NSLog(@"flush %d objects with expired lifetime", objectsSet.count);
        
        for (NSManagedObject *object in objectsSet) {
            
            if ([object isKindOfClass:[STMLocation class]]) {
                
                STMLocation *location = (STMLocation *)object;
                
                if (location.photos.count == 0) {
                    [[[self document] managedObjectContext] deleteObject:object];
                } else {
                    NSLog(@"location %@ linked with picture, flush canceled", location.xid);
                }
                
            } else {
                
                [[[self document] managedObjectContext] deleteObject:object];
                
            }
            
        }

    }
    
}


#pragma mark - recieve of objects is finished

+ (void)dataLoadingFinished {
    
    [self totalNumberOfObjects];
    
    [[self document] saveDocument:^(BOOL success) {

    }];

}

+ (void)totalNumberOfObjects {
    
    NSArray *entityNames = @[NSStringFromClass([STMDatum class]),
                             NSStringFromClass([STMSetting class]),
                             NSStringFromClass([STMLogMessage class]),
                             NSStringFromClass([STMPartner class]),
                             NSStringFromClass([STMCampaign class]),
                             NSStringFromClass([STMArticle class]),
                             NSStringFromClass([STMCampaignPicture class]),
                             NSStringFromClass([STMSalesman class]),
                             NSStringFromClass([STMOutlet class]),
                             NSStringFromClass([STMPhotoReport class]),
                             NSStringFromClass([STMDebt class]),
                             NSStringFromClass([STMCashing class]),
                             NSStringFromClass([STMUncashing class]),
                             NSStringFromClass([STMMessage class]),
                             NSStringFromClass([STMClientData class]),
                             NSStringFromClass([STMRecordStatus class]),
                             NSStringFromClass([STMUncashingPicture class]),
                             NSStringFromClass([STMUncashingPlace class]),
                             NSStringFromClass([STMTrack class]),
                             NSStringFromClass([STMLocation class]),
                             NSStringFromClass([STMEntity class])];
    
    NSUInteger totalCount = [self objectsForEntityName:NSStringFromClass([STMDatum class])].count;
    NSLog(@"total count %d", totalCount);
    
    for (NSString *entityName in entityNames) {
        
        if (![entityName isEqualToString:NSStringFromClass([STMDatum class])]) {
            
            NSUInteger count = [self objectsForEntityName:entityName].count;
            NSLog(@"%@ count %d", entityName, count);
            totalCount -= count;

        }

    }
    
    NSLog(@"unknow count %d", totalCount);
    
}

+ (NSArray *)objectsForEntityName:(NSString *)entityName {

    if ([[self localDataModelEntityNames] containsObject:entityName]) {

        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
        NSError *error;
        NSArray *result = [[self document].managedObjectContext executeFetchRequest:request error:&error];
        
        return result;

    } else {
        
        return nil;
        
    }
    
}


#pragma mark - messages

+ (NSUInteger)unreadMessagesCount {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMMessage class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
//    request.predicate = [NSPredicate predicateWithFormat:@"isRead == NO || isRead == nil"];
    
    NSError *error;
    NSArray *result = [[self document].managedObjectContext executeFetchRequest:request error:&error];
    
    NSMutableArray *messageXids = [NSMutableArray array];
    
    for (STMMessage *message in result) {
        
        [messageXids addObject:message.xid];
        
    }
    
    request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMRecordStatus class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"objectXid IN %@ && isRead == YES", messageXids];

    result = [[self document].managedObjectContext executeFetchRequest:request error:&error];
    
    return messageXids.count - result.count;
    
}

@end
