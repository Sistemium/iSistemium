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
#import "STMEntityController.h"
#import "STMClientDataController.h"
#import "STMPicturesController.h"
#import "STMRecordStatusController.h"

#import "STMPartner.h"
#import "STMOutlet.h"
#import "STMSalesman.h"
#import "STMCampaign.h"
#import "STMCampaignPicture.h"
#import "STMPhotoReport.h"
#import "STMPhoto.h"
#import "STMArticle.h"
#import "STMArticleGroup.h"
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
#import "STMCampaignGroup.h"
#import "STMSaleOrder.h"
#import "STMSaleOrderPosition.h"

#import "STMFetchRequest.h"

@implementation STMObjectsController


#pragma mark - singleton

+ (STMObjectsController *)sharedController {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedController = nil;
    
    dispatch_once(&pred, ^{
        _sharedController = [[self alloc] init];
    });
    
    return _sharedController;
    
}


#pragma mark - recieved objects management

+ (void)processingOfDataArray:(NSArray *)array roleName:(NSString *)roleName withCompletionHandler:(void (^)(BOOL success))completionHandler {

    if (roleName) {
        
        [self setRelationshipsFromArray:array withCompletionHandler:^(BOOL success) {
            completionHandler(success);
        }];
        
    } else {
        
        [self insertObjectsFromArray:array withCompletionHandler:^(BOOL success) {
            completionHandler(success);
        }];
        
    }

}

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
    
    NSString *name = dictionary[@"name"];
    NSDictionary *properties = dictionary[@"properties"];

    NSArray *nameExplode = [name componentsSeparatedByString:@"."];
    NSString *nameTail = (nameExplode.count > 1) ? nameExplode[1] : name;
    NSString *capEntityName = [nameTail stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[nameTail substringToIndex:1] capitalizedString]];

    NSString *entityName = [@"STM" stringByAppendingString:capEntityName];
    
    NSArray *dataModelEntityNames = [self localDataModelEntityNames];
    
    if ([dataModelEntityNames containsObject:entityName]) {
        
        NSString *xid = dictionary[@"xid"];
        NSData *xidData = (xid) ? [STMFunctions dataFromString:[xid stringByReplacingOccurrencesOfString:@"-" withString:@""]] : nil;
        
        STMRecordStatus *recordStatus = [STMRecordStatusController existingRecordStatusForXid:xidData];
        
        if (![recordStatus.isRemoved boolValue]) {
            
            NSManagedObject *object = nil;
            
            if ([entityName isEqualToString:NSStringFromClass([STMSetting class])]) {
                
                object = [[[self session] settingsController] settingForDictionary:dictionary];
                
            } else if ([entityName isEqualToString:NSStringFromClass([STMEntity class])]) {
                
                NSString *internalName = properties[@"name"];
                object = [STMEntityController entityWithName:internalName];
                
            }
            
            if (!object) {
            
                object = (xid) ? [self objectForEntityName:entityName andXid:xid] : [self newObjectForEntityName:entityName];

            }
            
            if (![self isWaitingToSyncForObject:object]) {
                
                [object setValue:@NO forKey:@"isFantom"];
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
        
        id value = properties[key];
        
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
    
    if ([[entityAttributes[key] attributeValueClassName] isEqualToString:NSStringFromClass([NSDecimalNumber class])]) {
        
        value = [NSDecimalNumber decimalNumberWithString:value];
        
    } else if ([[entityAttributes[key] attributeValueClassName] isEqualToString:NSStringFromClass([NSDate class])]) {
        
        value = [[STMFunctions dateFormatter] dateFromString:value];
        
    } else if ([[entityAttributes[key] attributeValueClassName] isEqualToString:NSStringFromClass([NSNumber class])]) {
        
        value = @([value intValue]);
        
    } else if ([[entityAttributes[key] attributeValueClassName] isEqualToString:NSStringFromClass([NSData class])]) {
        
        value = [STMFunctions dataFromString:[value stringByReplacingOccurrencesOfString:@"-" withString:@""]];
        
    }

    return value;
    
}

+ (void)processingOfRelationshipsForObject:(NSManagedObject *)object withEntityName:(NSString *)entityName andValues:(NSDictionary *)properties {
    
    NSDictionary *ownObjectRelationships = [self singleRelationshipsForEntityName:entityName];
    
    for (NSString *relationship in [ownObjectRelationships allKeys]) {
        
        if ([properties[relationship] isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *relationshipDictionary = properties[relationship];
            NSString *destinationObjectXid = relationshipDictionary[@"xid"];
            
            if (destinationObjectXid) {
                
                NSManagedObject *destinationObject = [self objectForEntityName:ownObjectRelationships[relationship] andXid:destinationObjectXid];
                
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

        } else {
            
            if (properties[relationship]) {
                
                NSString *logMessage = [NSString stringWithFormat:@"not correct %@ relationship dictionary for %@ %@", relationship, entityName, [object valueForKey:@"xid"]];
                [[STMLogger sharedLogger] saveLogMessageWithText:logMessage type:@"error"];

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
    
    NSString *name = dictionary[@"name"];
    NSArray *nameExplode = [name componentsSeparatedByString:@"."];
    NSString *entityName = [@"STM" stringByAppendingString:nameExplode[1]];

    NSDictionary *serverDataModel = [[STMEntityController stcEntities] copy];

    if ([[serverDataModel allKeys] containsObject:entityName]) {
        
        STMEntity *entityModel = serverDataModel[entityName];
        NSString *roleOwner = entityModel.roleOwner;
        NSString *roleOwnerEntityName = [@"STM" stringByAppendingString:roleOwner];
        NSString *roleName = entityModel.roleName;
        NSDictionary *ownerRelationships = [self ownObjectRelationshipsForEntityName:roleOwnerEntityName];
        NSString *destinationEntityName = ownerRelationships[roleName];
        NSString *destination = [destinationEntityName stringByReplacingOccurrencesOfString:@"STM" withString:@""];
        NSDictionary *properties = dictionary[@"properties"];
        NSDictionary *ownerData = properties[roleOwner];
        NSDictionary *destinationData = properties[destination];
        NSString *ownerXid = ownerData[@"xid"];
        NSString *destinationXid = destinationData[@"xid"];
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
//                                       NSStringFromClass([STMTrack class]),
                                       NSStringFromClass([STMOutlet class]),
                                       NSStringFromClass([STMPartner class]),
                                       NSStringFromClass([STMLocation class]),
                                       NSStringFromClass([STMSaleOrder class]),
                                       NSStringFromClass([STMLogMessage class])
                                       ];
    
    return entityNamesForSyncing;

}


#pragma mark - getting specified objects

+ (NSManagedObject *)objectForXid:(NSData *)xidData {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMDatum class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
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
    [object setValue:@YES forKey:@"isFantom"];
    
    return object;
    
}


#pragma mark - getting entity properties

+ (NSSet *)ownObjectKeysForEntityName:(NSString *)entityName {
    
    STMEntityDescription *coreEntity = [STMEntityDescription entityForName:NSStringFromClass([STMDatum class]) inManagedObjectContext:[self document].managedObjectContext];
    NSSet *coreKeys = [NSSet setWithArray:[[coreEntity attributesByName] allKeys]];

    STMEntityDescription *objectEntity = [STMEntityDescription entityForName:entityName inManagedObjectContext:[self document].managedObjectContext];
    NSMutableSet *objectKeys = [NSMutableSet setWithArray:[[objectEntity attributesByName] allKeys]];

    [objectKeys minusSet:coreKeys];
    
    return objectKeys;
    
}

+ (NSDictionary *)ownObjectRelationshipsForEntityName:(NSString *)entityName {
    
    STMEntityDescription *coreEntity = [STMEntityDescription entityForName:NSStringFromClass([STMDatum class]) inManagedObjectContext:[self document].managedObjectContext];
    NSSet *coreRelationshipNames = [NSSet setWithArray:[[coreEntity relationshipsByName] allKeys]];
    
    STMEntityDescription *objectEntity = [STMEntityDescription entityForName:entityName inManagedObjectContext:[self document].managedObjectContext];
    NSMutableSet *objectRelationshipNames = [NSMutableSet setWithArray:[[objectEntity relationshipsByName] allKeys]];
    
    [objectRelationshipNames minusSet:coreRelationshipNames];
    
    NSMutableDictionary *objectRelationships = [NSMutableDictionary dictionary];
    
    for (NSString *relationshipName in objectRelationshipNames) {
        
        NSRelationshipDescription *relationship = [objectEntity relationshipsByName][relationshipName];
        objectRelationships[relationshipName] = [relationship destinationEntity].name;
        
    }
    
//    NSLog(@"objectRelationships %@", objectRelationships);
    
    return objectRelationships;
    
}

+ (NSDictionary *)singleRelationshipsForEntityName:(NSString *)entityName {
    
    STMEntityDescription *coreEntity = [STMEntityDescription entityForName:NSStringFromClass([STMDatum class]) inManagedObjectContext:[self document].managedObjectContext];
    NSSet *coreRelationshipNames = [NSSet setWithArray:[[coreEntity relationshipsByName] allKeys]];
    
    STMEntityDescription *objectEntity = [STMEntityDescription entityForName:entityName inManagedObjectContext:[self document].managedObjectContext];
    NSMutableSet *objectRelationshipNames = [NSMutableSet setWithArray:[[objectEntity relationshipsByName] allKeys]];
    
    [objectRelationshipNames minusSet:coreRelationshipNames];
    
    NSMutableDictionary *objectRelationships = [NSMutableDictionary dictionary];
    
    for (NSString *relationshipName in objectRelationshipNames) {
        
        NSRelationshipDescription *relationship = [objectEntity relationshipsByName][relationshipName];
        
        if (![relationship isToMany]) {
            objectRelationships[relationshipName] = [relationship destinationEntity].name;
        }
        
    }
    
    return objectRelationships;

}

+ (NSArray *)localDataModelEntityNames {
    
    return [[self document].managedObjectModel.entitiesByName allKeys];
    
}


#pragma mark - flushing

+ (STMRecordStatus *)removeObject:(NSManagedObject *)object {
    
    STMRecordStatus *recordStatus = [STMRecordStatusController recordStatusForObject:object];
    recordStatus.isRemoved = @YES;
    
    [self.document.managedObjectContext deleteObject:object];
    [self.document saveDocument:^(BOOL success) {
        
        if (success) {
            
            [self syncer].syncerState = STMSyncerSendDataOnce;
            
        }
        
    }];

    return recordStatus;

}

+ (void)checkObjectsForFlushing {

    NSArray *entitiesWithLifeTime = [STMEntityController entitiesWithLifeTime];

    NSMutableSet *objectsSet = [NSMutableSet set];
    
    for (STMEntity *entity in entitiesWithLifeTime) {
        
        double lifeTime = [entity.lifeTime doubleValue];
        NSDate *terminatorDate = [NSDate dateWithTimeInterval:-lifeTime*3600 sinceDate:[NSDate date]];
        
        NSString *capFirstLetter = (entity.name) ? [[entity.name substringToIndex:1] capitalizedString] : nil;
        NSString *capEntityName = [entity.name stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:capFirstLetter];
        NSString *entityName = [@"STM" stringByAppendingString:capEntityName];
        
        NSError *error;
        
        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:entityName];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"deviceCts < %@", terminatorDate];
        NSArray *fetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];
        
        for (NSManagedObject *object in fetchResult) {
            [self checkObject:object forAddingTo:objectsSet];
        }
        
    }
    
    if (objectsSet.count > 0) {
        
        NSLog(@"flush %d objects with expired lifetime", objectsSet.count);
        
        for (NSManagedObject *object in objectsSet) {
            [[[self document] managedObjectContext] deleteObject:object];
        }

    } else {
        
        NSLog(@"No objects for flushing");
        
    }
    
}

+ (void)checkObject:(NSManagedObject *)object forAddingTo:(NSMutableSet *)objectsSet {
    
    if ([object isKindOfClass:[STMTrack class]]) {
    
        STMTrack *track = (STMTrack *)object;

        if (track != [self session].locationTracker.currentTrack) {
            [objectsSet addObject:object];
        } else {
            NSLog(@"track %@ is current track now, flush declined", track.xid);
        }
        
    } else {
    
        if (![self isWaitingToSyncForObject:object]) {
            
            if ([object isKindOfClass:[STMLocation class]]) {
        
                STMLocation *location = (STMLocation *)object;
                
                if (location.photos.count == 0) {
                    [objectsSet addObject:object];
                } else {
                    NSLog(@"location %@ linked with picture, flush declined", location.xid);
                }

//            } else if ([object isKindOfClass:[STMTrack class]]) {
//                
//                STMTrack *track = (STMTrack *)object;
//                
//                if (track != [self session].locationTracker.currentTrack) {
//                    [objectsSet addObject:object];
//                } else {
//                    NSLog(@"track %@ is in use now, flush declined", track.xid);
//                }
                
            } else {

                [objectsSet addObject:object];

            }

        }
        
    }

}

#pragma mark - recieve of objects is finished

+ (void)dataLoadingFinished {
    
    [self checkObjectsForFlushing];
    
#ifdef DEBUG
    [self totalNumberOfObjects];
#else

#endif
    
    [[self document] saveDocument:^(BOOL success) {

    }];

}

+ (void)totalNumberOfObjects {
    
    NSArray *entityNames = @[NSStringFromClass([STMDatum class]),
                             NSStringFromClass([STMPartner class]),
                             NSStringFromClass([STMCampaign class]),
                             NSStringFromClass([STMCampaignGroup class]),
                             NSStringFromClass([STMCampaignPicture class]),
                             NSStringFromClass([STMPhotoReport class]),
                             NSStringFromClass([STMArticle class]),
                             NSStringFromClass([STMArticleGroup class]),
                             NSStringFromClass([STMSalesman class]),
                             NSStringFromClass([STMSaleOrder class]),
                             NSStringFromClass([STMSaleOrderPosition class]),
                             NSStringFromClass([STMOutlet class]),
                             NSStringFromClass([STMDebt class]),
                             NSStringFromClass([STMCashing class]),
                             NSStringFromClass([STMUncashing class]),
                             NSStringFromClass([STMUncashingPlace class]),
                             NSStringFromClass([STMUncashingPicture class]),
                             NSStringFromClass([STMMessage class]),
                             NSStringFromClass([STMTrack class]),
                             NSStringFromClass([STMLocation class]),
                             NSStringFromClass([STMSetting class]),
                             NSStringFromClass([STMClientData class]),
                             NSStringFromClass([STMRecordStatus class]),
                             NSStringFromClass([STMLogMessage class]),
                             NSStringFromClass([STMEntity class])];
    
    NSUInteger totalCount = [self numberOfObjectsForEntityName:NSStringFromClass([STMDatum class])];
    NSUInteger counter = totalCount;
    
    for (NSString *entityName in entityNames) {
        
        if (![entityName isEqualToString:NSStringFromClass([STMDatum class])]) {
            
            NSUInteger count = [self numberOfObjectsForEntityName:entityName];
            NSLog(@"%@ count %d", entityName, count);
            counter -= count;

        }

    }
    
    NSLog(@"unknow count %d", counter);
    NSLog(@"total count %d", totalCount);

}

+ (NSArray *)objectsForEntityName:(NSString *)entityName {

    if ([[self localDataModelEntityNames] containsObject:entityName]) {

        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)]];
        NSError *error;
        NSArray *result = [[self document].managedObjectContext executeFetchRequest:request error:&error];
        
        return result;

    } else {
        
        return nil;
        
    }
    
}

+ (NSUInteger)numberOfObjectsForEntityName:(NSString *)entityName {

    if ([[self localDataModelEntityNames] containsObject:entityName]) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)]];
        NSError *error;
        NSUInteger result = [[self document].managedObjectContext countForFetchRequest:request error:&error];
        
        return result;
        
    } else {
        
        return 0;
        
    }

}


#pragma mark - messages

+ (NSUInteger)unreadMessagesCount {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMMessage class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
//    request.predicate = [NSPredicate predicateWithFormat:@"isRead == NO || isRead == nil"];
    
    NSError *error;
    NSArray *result = [[self document].managedObjectContext executeFetchRequest:request error:&error];
    
    NSMutableArray *messageXids = [NSMutableArray array];
    
    for (STMMessage *message in result) {
        
        [messageXids addObject:message.xid];
        
    }
    
    request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMRecordStatus class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"objectXid IN %@ && isRead == YES", messageXids];

    NSUInteger resultCount = [[self document].managedObjectContext countForFetchRequest:request error:&error];
    
    return messageXids.count - resultCount;

//    result = [[self document].managedObjectContext executeFetchRequest:request error:&error];
//    
//    return messageXids.count - result.count;
    
}


#pragma mark - create dictionary from object

+ (NSDictionary *)dictionaryForObject:(NSManagedObject *)object {
    
    NSString *entityName = object.entity.name;
    NSString *name = [@"stc." stringByAppendingString:[entityName stringByReplacingOccurrencesOfString:@"STM" withString:@""]];
    NSData *xidData = [object valueForKey:@"xid"];
    NSString *xid = [STMFunctions xidStringFromXidData:xidData];
    
    NSDictionary *propertiesDictionary = [self propertiesDictionaryForObject:object];
    
    return @{@"name":name, @"xid":xid, @"properties":propertiesDictionary};
    
}

+ (NSDictionary *)propertiesDictionaryForObject:(NSManagedObject *)object {
    
    NSMutableDictionary *propertiesDictionary = [NSMutableDictionary dictionary];
    
    for (NSString *key in object.entity.attributesByName.allKeys) {
        
        if (![key isEqualToString:@"xid"]) {
            
            id value = [object valueForKey:key];
            
            if (value) {
                
                if ([value isKindOfClass:[NSDate class]]) {
                    
                    value = [[STMFunctions dateFormatter] stringFromDate:value];
                    
                } else if ([value isKindOfClass:[NSData class]]) {
                    
                    if ([key isEqualToString:@"objectXid"]) {
                        
                        value = [STMFunctions xidStringFromXidData:value];
                        
                    } else {
                        
                        value = [STMFunctions hexStringFromData:value];
                        
                    }
                    
                }
                
                [propertiesDictionary setValue:[NSString stringWithFormat:@"%@", value] forKey:key];
                
            }
            
        }
        
    }
    
    for (NSString *key in object.entity.relationshipsByName.allKeys) {
        
        NSRelationshipDescription *relationshipDescription = [object.entity.relationshipsByName valueForKey:key];
        
        if (![relationshipDescription isToMany]) {
            
            NSManagedObject *relationshipObject = [object valueForKey:key];
            
            if (relationshipObject) {
                
                NSData *xidData = [relationshipObject valueForKey:@"xid"];
                
                if (xidData.length != 0) {
                    
                    NSString *xid = [STMFunctions xidStringFromXidData:xidData];
                    NSString *entityName = key;
                    [propertiesDictionary setValue:[NSDictionary dictionaryWithObjectsAndKeys:entityName, @"name", xid, @"xid", nil] forKey:key];
                    
                }
                
            }
            
        }
        
    }
    
    return propertiesDictionary;
    
}


#pragma mark - sync object

+ (void)syncObject:(NSDictionary *)objectDictionary {
    
    NSString *result = [objectDictionary valueForKey:@"result"];
    NSString *xid = [objectDictionary valueForKey:@"xid"];
    NSString *xidString = [xid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSData *xidData = [STMFunctions dataFromString:xidString];
    
    if (!result || ![result isEqualToString:@"ok"]) {
        
        NSString *errorMessage = [NSString stringWithFormat:@"Sync result not ok xid: %@", xid];
        [[self session].logger saveLogMessageWithText:errorMessage type:@"error"];
        
    } else {
        
//        __weak __block
        NSManagedObject *object = [self objectForXid:xidData];
        
//        __weak NSManagedObjectContext *context = object.managedObjectContext;
//        
//        [context performBlock:^{
        
            if (object) {
                
                if ([object isKindOfClass:[STMRecordStatus class]] && [[(STMRecordStatus *)object valueForKey:@"isRemoved"] boolValue]) {
                    [[self session].document.managedObjectContext deleteObject:object];
                } else {
                    [object setValue:[object valueForKey:@"sts"] forKey:@"lts"];
                }
                
                NSString *logMessage = [NSString stringWithFormat:@"successefully sync %@ with xid %@", object.entity.name, xid];
                NSLog(logMessage);
                
            } else {
                
                [[self session].logger saveLogMessageWithText:[NSString stringWithFormat:@"Sync: no object with xid: %@", xid] type:@"error"];
                
            }
            
//        }];
        
    }

}


@end
