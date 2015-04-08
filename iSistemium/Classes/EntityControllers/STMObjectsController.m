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

#import "STMConstants.h"

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
#import "STMPriceType.h"
#import "STMPrice.h"
#import "STMStock.h"

#import "STMFetchRequest.h"

@interface STMObjectsController()

@property (nonatomic, strong) NSMutableDictionary *timesDic;
@property (nonatomic, strong) NSMutableDictionary *entitiesOwnKeys;
@property (nonatomic, strong) NSMutableDictionary *entitiesOwnRelationships;
@property (nonatomic, strong) NSMutableDictionary *entitiesSingleRelationships;
@property (nonatomic, strong) NSMutableDictionary *objectsCache;


@end


@implementation STMObjectsController

- (NSMutableDictionary *)timesDic {
    
    if (!_timesDic) {
        
        _timesDic = [@{} mutableCopy];
        _timesDic[@"1"] = [@[] mutableCopy];
        _timesDic[@"2"] = [@[] mutableCopy];
        _timesDic[@"3"] = [@[] mutableCopy];
        _timesDic[@"4"] = [@[] mutableCopy];
        _timesDic[@"5"] = [@[] mutableCopy];
        _timesDic[@"6"] = [@[] mutableCopy];
        _timesDic[@"7"] = [@[] mutableCopy];
        _timesDic[@"8"] = [@[] mutableCopy];
        _timesDic[@"9"] = [@[] mutableCopy];
        
    }
    return _timesDic;
    
}

- (NSMutableDictionary *)entitiesOwnKeys {
    
    if (!_entitiesOwnKeys) {
        _entitiesOwnKeys = [@{} mutableCopy];
    }
    return _entitiesOwnKeys;
    
}

- (NSMutableDictionary *)entitiesOwnRelationships {
    
    if (!_entitiesOwnRelationships) {
        _entitiesOwnRelationships = [@{} mutableCopy];
    }
    return _entitiesOwnRelationships;
    
}

- (NSMutableDictionary *)entitiesSingleRelationships {
    
    if (!_entitiesSingleRelationships) {
        _entitiesSingleRelationships = [@{} mutableCopy];
    }
    return _entitiesSingleRelationships;
    
}

- (NSMutableDictionary *)objectsCache {
    
    if (!_objectsCache) {
        _objectsCache = [@{} mutableCopy];
    }
    return _objectsCache;
    
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self addObservers];
    }
    return self;
    
}

- (void)addObservers {
    
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(sessionStatusChanged:)
               name:@"sessionStatusChanged"
             object:nil];

}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)sessionStatusChanged:(NSNotification *)notification {
    
    if ([notification.object isKindOfClass:[STMSession class]]) {
        
        STMSession *session = notification.object;
        
        if (![session.status isEqualToString:@"running"]) {
            self.objectsCache = nil;
        }
        
    }
    
}

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

//    NSDate *start = [NSDate date];
//    NSString *startString = [[STMFunctions dateFormatter] stringFromDate:start];
//    NSLog(@"--------------------s %@", startString);
    
    if (roleName) {
        
        [self setRelationshipsFromArray:array withCompletionHandler:^(BOOL success) {
            completionHandler(success);
        }];
        
    } else {
        
        [self insertObjectsFromArray:array withCompletionHandler:^(BOOL success) {
            completionHandler(success);
        }];
        
    }

//    NSDate *finish = [NSDate date];
//    NSString *finishString = [[STMFunctions dateFormatter] stringFromDate:finish];
//    NSLog(@"--------------------f %@", finishString);

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

// time checking
//    NSDate *start = [NSDate date];
// -------------
    
    NSString *name = dictionary[@"name"];
    NSDictionary *properties = dictionary[@"properties"];

    NSArray *nameExplode = [name componentsSeparatedByString:@"."];
    NSString *nameTail = (nameExplode.count > 1) ? nameExplode[1] : name;
    NSString *capEntityName = [nameTail stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[nameTail substringToIndex:1] capitalizedString]];

    NSString *entityName = [@"STM" stringByAppendingString:capEntityName];
    
    NSArray *dataModelEntityNames = [self localDataModelEntityNames];
    
    if ([dataModelEntityNames containsObject:entityName]) {
        
        NSString *xid = dictionary[@"xid"];
        NSData *xidData = [STMFunctions xidDataFromXidString:xid];
        
        STMRecordStatus *recordStatus = [STMRecordStatusController existingRecordStatusForXid:xidData];
        
        if (![recordStatus.isRemoved boolValue]) {
            
            NSManagedObject *object = nil;
            
            if ([entityName isEqualToString:NSStringFromClass([STMSetting class])]) {
                
                object = [[[self session] settingsController] settingForDictionary:dictionary];
                
            } else if ([entityName isEqualToString:NSStringFromClass([STMEntity class])]) {
                
                NSString *internalName = properties[@"name"];
                object = [STMEntityController entityWithName:internalName];
                
            }

// time checking
//            [[self sharedController].timesDic[@"1"] addObject:@([start timeIntervalSinceNow])];
// -------------
            
            if (!object) {
                object = (xid) ? [self objectForEntityName:entityName andXid:xid] : [self newObjectForEntityName:entityName];
            }
            
// time checking
//            [[self sharedController].timesDic[@"2"] addObject:@([start timeIntervalSinceNow])];
// -------------
            
            if (![self isWaitingToSyncForObject:object]) {
                
                [object setValue:@NO forKey:@"isFantom"];
                [self processingOfObject:object withEntityName:entityName fillWithValues:properties];
                
            }
            
// time checking
//            [[self sharedController].timesDic[@"3"] addObject:@([start timeIntervalSinceNow])];
// -------------
            
        } else {
            
            NSLog(@"object %@ with xid %@ have recordStatus.isRemoved == YES", entityName, xid);
            
        }
            
        completionHandler(YES);
        
    } else {
        
        NSLog(@"dataModel have no object's entity with name %@", entityName);
        
        completionHandler(NO);
        
    }
    
}

+ (void)processingOfObject:(NSManagedObject *)object withEntityName:(NSString *)entityName fillWithValues:(NSDictionary *)properties {
    
// time checking
//    NSDate *start = [NSDate date];
// -------------
    
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

// time checking
//    [[self sharedController].timesDic[@"4"] addObject:@([start timeIntervalSinceNow])];
// -------------
    
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
    
// time checking
//    NSDate *start = [NSDate date];
// -------------
    
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

// time checking
//        [[self sharedController].timesDic[@"5"] addObject:@([start timeIntervalSinceNow])];
// -------------
        
        if (ok) {
            
            NSManagedObject *ownerObject = [self objectForEntityName:roleOwnerEntityName andXid:ownerXid];
            NSManagedObject *destinationObject = [self objectForEntityName:destinationEntityName andXid:destinationXid];
            
// time checking
//            [[self sharedController].timesDic[@"6"] addObject:@([start timeIntervalSinceNow])];
// -------------
            
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
        
// time checking
//        [[self sharedController].timesDic[@"7"] addObject:@([start timeIntervalSinceNow])];
// -------------
        
        completionHandler(YES);
        
    } else {
        
        NSLog(@"dataModel have no relationship's entity with name %@", entityName);

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
    
    NSManagedObject *cachedObject = [self sharedController].objectsCache[xidData];
    
    return cachedObject;

//    if (!cachedObject) {
//        
//// time checking
//        NSDate *start = [NSDate date];
//// -------------
//        
//        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMDatum class])];
//        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)]];
//        request.predicate = [NSPredicate predicateWithFormat:@"SELF.xid == %@", xidData];
//        request.fetchLimit = 1;
//        
//        NSError *error;
//        NSArray *fetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];
//        
//        NSManagedObject *object = [fetchResult lastObject];
//
//// time checking
//        [[self sharedController].timesDic[@"8"] addObject:@([start timeIntervalSinceNow])];
//// -------------
//        
//        [self sharedController].objectsCache[xidData] = object;
//
//        return object;
//        
//    } else {
//    
//        return cachedObject;
//        
//    }
    
}

+ (NSManagedObject *)objectForEntityName:(NSString *)entityName andXid:(NSString *)xid {
    
    NSArray *dataModelEntityNames = [self localDataModelEntityNames];
    
    if ([dataModelEntityNames containsObject:entityName]) {
        
        NSData *xidData = [STMFunctions xidDataFromXidString:xid];

        NSManagedObject *object = [self objectForXid:xidData];
        
        if (object) {
            
            if (![object.entity.name isEqualToString:entityName]) {
                
                NSLog(@"No %@ object with xid %@, %@ object fetched instead", entityName, xid, object.entity.name);
                object = nil;
                
            }
            
        } else {
            
            object = [self newObjectForEntityName:entityName andXid:xidData];
        
        }
        
        return object;
        
    } else {
        
        return nil;
        
    }
    
}

+ (NSManagedObject *)newObjectForEntityName:(NSString *)entityName andXid:(NSData *)xidData {

// time checking
//    NSDate *start = [NSDate date];
// -------------
    
    NSManagedObject *object = [STMEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:[self document].managedObjectContext];
    [object setValue:@YES forKey:@"isFantom"];
    
    if (xidData) {
        [object setValue:xidData forKey:@"xid"];
    } else {
        xidData = [object valueForKey:@"xid"];
    }

    [self sharedController].objectsCache[xidData] = object;


// time checking
//    [[self sharedController].timesDic[@"9"] addObject:@([start timeIntervalSinceNow])];
// -------------
    
    return object;

}

+ (NSManagedObject *)newObjectForEntityName:(NSString *)entityName {
    return [self newObjectForEntityName:entityName andXid:nil];
}

+ (NSArray *)objectsWithXids:(NSArray *)xids {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMDatum class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"xid IN %@", xids];
    
    NSError *error;
    NSArray *fetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];
    
    return fetchResult;

}

+ (NSArray *)allObjects {

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMDatum class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)]];
    
    NSError *error;
    NSArray *fetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];
    
    return fetchResult;

}

+ (void)initObjectsCache {

    [self sharedController].objectsCache = nil;
    
//    NSLog(@"initObjectsCache");
//    TICK;
    NSArray *allObects = [self allObjects];
//    TOCK;
    
    NSArray *keys = [allObects valueForKeyPath:@"xid"];
    
    [self sharedController].objectsCache = [NSMutableDictionary dictionaryWithObjects:allObects forKeys:keys];
    
}


#pragma mark - getting entity properties

+ (NSSet *)ownObjectKeysForEntityName:(NSString *)entityName {
    
    NSMutableDictionary *entitiesOwnKeys = [self sharedController].entitiesOwnKeys;
    NSMutableSet *objectKeys = entitiesOwnKeys[entityName];
    
    if (!objectKeys) {

        STMEntityDescription *coreEntity = [STMEntityDescription entityForName:NSStringFromClass([STMDatum class]) inManagedObjectContext:[self document].managedObjectContext];
        NSSet *coreKeys = [NSSet setWithArray:[[coreEntity attributesByName] allKeys]];

        STMEntityDescription *objectEntity = [STMEntityDescription entityForName:entityName inManagedObjectContext:[self document].managedObjectContext];
        objectKeys = [NSMutableSet setWithArray:[[objectEntity attributesByName] allKeys]];
        [objectKeys minusSet:coreKeys];
        
        entitiesOwnKeys[entityName] = objectKeys;
        
    }
    
    return objectKeys;
    
}

+ (NSDictionary *)ownObjectRelationshipsForEntityName:(NSString *)entityName {
    
    NSMutableDictionary *entitiesOwnRelationships = [self sharedController].entitiesOwnRelationships;
    NSMutableDictionary *objectRelationships = entitiesOwnRelationships[entityName];
    
    if (!objectRelationships) {

        STMEntityDescription *coreEntity = [STMEntityDescription entityForName:NSStringFromClass([STMDatum class]) inManagedObjectContext:[self document].managedObjectContext];
        NSSet *coreRelationshipNames = [NSSet setWithArray:[[coreEntity relationshipsByName] allKeys]];
        
        STMEntityDescription *objectEntity = [STMEntityDescription entityForName:entityName inManagedObjectContext:[self document].managedObjectContext];
        NSMutableSet *objectRelationshipNames = [NSMutableSet setWithArray:[[objectEntity relationshipsByName] allKeys]];
        
        [objectRelationshipNames minusSet:coreRelationshipNames];
        
        objectRelationships = [NSMutableDictionary dictionary];
        
        for (NSString *relationshipName in objectRelationshipNames) {
            
            NSRelationshipDescription *relationship = [objectEntity relationshipsByName][relationshipName];
            objectRelationships[relationshipName] = [relationship destinationEntity].name;
            
        }
    
        entitiesOwnRelationships[entityName] = objectRelationships;
        
    }

//    NSLog(@"objectRelationships %@", objectRelationships);
    
    return objectRelationships;
    
}

+ (NSDictionary *)singleRelationshipsForEntityName:(NSString *)entityName {
    
    NSMutableDictionary *entitiesSingleRelationships = [self sharedController].entitiesSingleRelationships;
    NSMutableDictionary *objectRelationships = entitiesSingleRelationships[entityName];
    
    if (!objectRelationships) {

        STMEntityDescription *coreEntity = [STMEntityDescription entityForName:NSStringFromClass([STMDatum class]) inManagedObjectContext:[self document].managedObjectContext];
        NSSet *coreRelationshipNames = [NSSet setWithArray:[[coreEntity relationshipsByName] allKeys]];
        
        STMEntityDescription *objectEntity = [STMEntityDescription entityForName:entityName inManagedObjectContext:[self document].managedObjectContext];
        NSMutableSet *objectRelationshipNames = [NSMutableSet setWithArray:[[objectEntity relationshipsByName] allKeys]];
        
        [objectRelationshipNames minusSet:coreRelationshipNames];
        
        objectRelationships = [NSMutableDictionary dictionary];
        
        for (NSString *relationshipName in objectRelationshipNames) {
            
            NSRelationshipDescription *relationship = [objectEntity relationshipsByName][relationshipName];
            
            if (![relationship isToMany]) {
                objectRelationships[relationshipName] = [relationship destinationEntity].name;
            }
            
        }
    
        entitiesSingleRelationships[entityName] = objectRelationships;
        
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
            [[self document].managedObjectContext deleteObject:object];
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

#pragma mark - finish of recieving objects

+ (void)avgTimesCalc {
    
    NSArray *first = [self sharedController].timesDic[@"1"];
    NSArray *second = [self sharedController].timesDic[@"2"];
    NSArray *third = [self sharedController].timesDic[@"3"];
    NSArray *fourth = [self sharedController].timesDic[@"4"];
    NSArray *fifth = [self sharedController].timesDic[@"5"];
    NSArray *sixth = [self sharedController].timesDic[@"6"];
    NSArray *seventh = [self sharedController].timesDic[@"7"];
    NSArray *eighth = [self sharedController].timesDic[@"8"];
    NSArray *nineth = [self sharedController].timesDic[@"9"];
    
    NSNumber *avgFirst = [first valueForKeyPath:@"@avg.self"];
    NSNumber *avgSecond = [second valueForKeyPath:@"@avg.self"];
    NSNumber *avgThird = [third valueForKeyPath:@"@avg.self"];
    NSNumber *avgFourth = [fourth valueForKeyPath:@"@avg.self"];
    NSNumber *avgFifth = [fifth valueForKeyPath:@"@avg.self"];
    NSNumber *avgSixth = [sixth valueForKeyPath:@"@avg.self"];
    NSNumber *avgSeventh = [seventh valueForKeyPath:@"@avg.self"];
    NSNumber *avgEighth = [eighth valueForKeyPath:@"@avg.self"];
    NSNumber *avgNineth = [nineth valueForKeyPath:@"@avg.self"];
    
    NSLog(@"avgFirst %@", avgFirst);
    NSLog(@"avgSecond %@", avgSecond);
    NSLog(@"avgThird %@", avgThird);
    NSLog(@"avgFourth %@", avgFourth);
    NSLog(@"avgFifth %@", avgFifth);
    NSLog(@"avgSixth %@", avgSixth);
    NSLog(@"avgSeventh %@", avgSeventh);
    NSLog(@"avgEighth %@", avgEighth);
    NSLog(@"avgNineth %@", avgNineth);
    
    NSLog(@"eighth.count %d", eighth.count)
    NSLog(@"nineth.count %d", nineth.count)
    
}

+ (void)dataLoadingFinished {
    
//    [self avgTimesCalc];
    
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
                             NSStringFromClass([STMPriceType class]),
                             NSStringFromClass([STMPrice class]),
                             NSStringFromClass([STMStock class]),
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
    
    NSArray *allKeys;
    
    if ([object.entity.name isEqualToString:NSStringFromClass([STMEntity class])]) {
        allKeys = @[@"eTag", @"name", @"deviceCts", @"deviceTs"];
    } else {
        allKeys = object.entity.attributesByName.allKeys;
    }
    
    for (NSString *key in allKeys) {
        
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
    NSData *xidData = [STMFunctions xidDataFromXidString:xid];
    
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
                
                NSString *entityName = object.entity.name;
                
                NSString *logMessage = [NSString stringWithFormat:@"successefully sync %@ with xid %@", entityName, xid];
                NSLog(logMessage);
                
//                if ([entityName isEqualToString:NSStringFromClass([STMEntity class])]) {
//
//                    STMEntity *entity = (STMEntity *)object;
//                    
//                    if ([entity.name isEqualToString:@"Salesman"]) {
//                        NSLog(@"object %@", object);
//                    }
//                    
//                    NSLog(@"object %@", object);
//                
//                }
                
            } else {
                
                [[self session].logger saveLogMessageWithText:[NSString stringWithFormat:@"Sync: no object with xid: %@", xid] type:@"error"];
                
            }
            
//        }];
        
    }

}


@end
