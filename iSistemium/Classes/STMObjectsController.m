//
//  STMObjectsController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMObjectsController.h"
#import "STMSessionManager.h"
#import "STMSession.h"
#import "STMDocument.h"
#import "STMFunctions.h"
#import "STMSyncer.h"
#import <Security/Security.h>
#import <KeychainItemWrapper/KeychainItemWrapper.h>

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

#import <AWSiOSSDKv2/AWSCore.h>
#import <AWSiOSSDKv2/S3.h>
#import <objc/runtime.h>
#import "AWXMLRequestSerializerFixed.h"


@interface STMObjectsController()

@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@property (nonatomic, strong) NSOperationQueue *uploadQueue;
@property (nonatomic, strong) NSMutableDictionary *hrefDictionary;
@property (nonatomic, strong) NSMutableArray *secondAttempt;
@property (nonatomic, strong) KeychainItemWrapper *s3keychainItem;
@property (nonatomic, strong) NSString *accessKey;
@property (nonatomic, strong) NSString *secretKey;
@property (nonatomic) BOOL s3Initialized;
@property (nonatomic, strong) STMSession *session;
@property (nonatomic, strong) NSMutableDictionary *settings;

@end


@implementation STMObjectsController

@synthesize accessKey = _accessKey;
@synthesize secretKey = _secretKey;


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


#pragma mark - amazon S3 init

- (BOOL)s3Init {
    
    if (self.accessKey && self.secretKey && !self.s3Initialized) {
        
        AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:self.accessKey secretKey:self.secretKey];
        AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionEUWest1 credentialsProvider:credentialsProvider];
        [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
        
        
        // Get both the methods from the object by its selectors
        Method originalMethod = class_getInstanceMethod(NSClassFromString(@"AWSS3RequestSerializer"), @selector(serializeRequest:headers:parameters:error:));
        Method newMethod = class_getInstanceMethod([AWXMLRequestSerializerFixed class], @selector(__serializeRequest:headers:parameters:error:));
        method_exchangeImplementations(originalMethod, newMethod);
        
        self.s3Initialized = YES;
        
    }

    return self.s3Initialized;
    
}


#pragma mark - checking client state

+ (void)checkDeviceToken {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL clientDataWaitingForSync = [[defaults objectForKey:@"clientDataWaitingForSync"] boolValue];

    if (clientDataWaitingForSync) {
        
        NSData *deviceToken = [defaults objectForKey:@"deviceToken"];
    
        NSLog(@"hasDeviceTokenForSync %@", deviceToken);
        
        if ([self document].managedObjectContext) {
            
            NSString *entityName = NSStringFromClass([STMClientData class]);
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
            request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
            
            NSError *error;
            NSArray *fetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];
            
            STMClientData *clientData = [fetchResult lastObject];
            
            if (!clientData) {
                
                clientData = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:[self document].managedObjectContext];
                
            }
            
            clientData.deviceToken = deviceToken;
            
#ifdef DEBUG
            
            clientData.buildType = @"debug";
            
#else
            
            clientData.buildType = @"release";
            
#endif
            

        }
        
    }
    
}

+ (void)checkAppVersion {
    
    if ([self document].managedObjectContext) {
        
        NSString *entityName = NSStringFromClass([STMClientData class]);
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
        
        NSError *error;
        NSArray *fetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];
        
        STMClientData *clientData = [fetchResult lastObject];
        
        if (!clientData) {
            
            clientData = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:[self document].managedObjectContext];
            
        }
        
        NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
        
        if (![bundleVersion isEqualToString:clientData.appVersion]) {
            clientData.appVersion = bundleVersion;
        }
        
        
        entityName = NSStringFromClass([STMSetting class]);
        
        request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"name == %@", @"availableVersion"];
        
        fetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];
        
        STMSetting *availableVersionSetting = [fetchResult lastObject];
        
        if (availableVersionSetting) {
            
            NSNumber *availableVersion = [NSNumber numberWithInteger:[availableVersionSetting.value integerValue]];
            NSNumber *currentVersion = [NSNumber numberWithInteger:[clientData.appVersion integerValue]];
            
            if ([availableVersion compare:currentVersion] == NSOrderedDescending) {
                
                request.predicate = [NSPredicate predicateWithFormat:@"name == %@", @"appDownloadUrl"];
                fetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];
                STMSetting *appDownloadUrlSetting = [fetchResult lastObject];

                if (appDownloadUrlSetting) {
                    
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

                    [defaults setObject:[NSNumber numberWithBool:YES] forKey:@"newAppVersionAvailable"];
                    [defaults setObject:availableVersion forKey:@"availableVersion"];
                    [defaults setObject:appDownloadUrlSetting.value forKey:@"appDownloadUrl"];
                    [defaults synchronize];

                    [[NSNotificationCenter defaultCenter] postNotificationName:@"newAppVersionAvailable" object:nil userInfo:@{@"availableVersion": availableVersion, @"appDownloadUrl":appDownloadUrlSetting.value}];
                                        
                }
                
            } else {

                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:[NSNumber numberWithBool:NO] forKey:@"newAppVersionAvailable"];
                [defaults removeObjectForKey:@"availableVersion"];
                [defaults removeObjectForKey:@"appDownloadUrl"];
                [defaults synchronize];

            }

        }
        
    }

    
}

+ (void)checkPhotos {
    
    [self checkBrokenPhotos];
    [self checkUploadedPhotos];
    
}

+ (void)checkBrokenPhotos {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPhoto class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"imageThumbnail == %@", nil];
    
    NSError *error;
    NSArray *result = [[self document].managedObjectContext executeFetchRequest:request error:&error];
    
    for (STMPhoto *photo in result) {
        
//        NSLog(@"broken photo %@", photo);

        if (photo.imagePath) {
            
            NSData *photoData = [NSData dataWithContentsOfFile:photo.imagePath];
            
            if (photoData) {
                
                [self setImagesFromData:photoData forPicture:photo];
                
            } else {
                
                [self deletePhoto:photo];
                
            }
            
        } else {
            
            [self deletePhoto:photo];
            
        }
        
    }
    
}

+ (void)checkUploadedPhotos {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPicture class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"href == %@", nil];
    
    NSError *error;
    NSArray *result = [[self document].managedObjectContext executeFetchRequest:request error:&error];

    for (STMPhoto *photo in result) {
        
        NSString *xid = [STMFunctions xidStringFromXidData:photo.xid];
        NSString *fileName = [xid stringByAppendingString:@".jpg"];
        NSData *photoData = [NSData dataWithContentsOfFile:photo.imagePath];
        
        [[self sharedController] addUploadOperationForPhoto:photo withFileName:fileName data:photoData];
        
    }
    
}

+ (void)deletePhoto:(STMPhoto *)photo {
    
//    NSLog(@"delete photo %@", photo);
    
    [[self document].managedObjectContext deleteObject:photo];
    
    [[self document] saveDocument:^(BOOL success) {
        
    }];
    
}


#pragma mark - instance properties

- (STMSession *)session {

    return [STMSessionManager sharedManager].currentSession;
    
}

- (NSMutableDictionary *)settings {
    if (!_settings) {
        _settings = [self.session.settingsController currentSettingsForGroup:@"amazon"];
    }
    return _settings;
}

- (KeychainItemWrapper *)s3keychainItem {
    
    if (!_s3keychainItem) {
        
        NSString *bundleIdentifier = [@"S3." stringByAppendingString:[[NSBundle mainBundle] bundleIdentifier]];
        _s3keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:bundleIdentifier accessGroup:nil];
        
    }
    
    return _s3keychainItem;
    
}

- (NSString *)accessKey {
    
    if (!_accessKey) {
        
        NSString *accessKey = [self.s3keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
        
        if (![accessKey boolValue]) {
            
            accessKey = [self.settings valueForKey:@"S3.AccessKeyID"];
            
            [self.s3keychainItem setObject:accessKey forKey:(__bridge id)(kSecAttrAccount)];
            
        }
        
        _accessKey = accessKey;
        
    }
    
    return _accessKey;
    
}

- (void)setAccessKey:(NSString *)accessKey {
    
    if (accessKey != _accessKey) {
        
        [self.s3keychainItem setObject:accessKey forKey:(__bridge id)(kSecAttrAccount)];
        _accessKey = accessKey;
        
    }
    
}

- (NSString *)secretKey {
    
    if (!_secretKey) {
        
        NSString *secretKey = [self.s3keychainItem objectForKey:(__bridge id)(kSecValueData)];
        
        if (![secretKey boolValue]) {
            
            secretKey = [self.settings valueForKey:@"S3.SecretAccessKey"];
            
            [self.s3keychainItem setObject:secretKey forKey:(__bridge id)(kSecValueData)];

        }
        
        _secretKey = secretKey;
        
    }
    
    return _secretKey;
    
}

- (void)setSecretKey:(NSString *)secretKey {
    
    if (secretKey != _secretKey) {
        
        [self.s3keychainItem setObject:secretKey forKey:(__bridge id)(kSecValueData)];
        _secretKey = secretKey;
        
    }
    
}


- (NSMutableDictionary *)hrefDictionary {
    
    if (!_hrefDictionary) {
        
        _hrefDictionary = [NSMutableDictionary dictionary];
        
    }
    
    return _hrefDictionary;
    
}

- (NSMutableArray *)secondAttempt {
    
    if (!_secondAttempt) {
        
        _secondAttempt = [NSMutableArray array];
        
    }
    
    return _secondAttempt;
    
}

- (NSOperationQueue *)downloadQueue {

    if (!_downloadQueue) {
        
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.maxConcurrentOperationCount = 2;

    }
    
    return _downloadQueue;
    
}

- (NSOperationQueue *)uploadQueue {
    
    if (!_uploadQueue) {
        
        _uploadQueue = [[NSOperationQueue alloc] init];
        
    }
    
    return _uploadQueue;
    
}

+ (STMDocument *)document {
    
    return (STMDocument *)[STMSessionManager sharedManager].currentSession.document;
    
}


#pragma mark - recieved objects management

+ (void)insertObjectsFromArray:(NSArray *)array withCompletionHandler:(void (^)(BOOL success))completionHandler {
    
    __block BOOL result = YES;
    
    for (NSDictionary *datum in array) {
        
        [self insertObjectFromDictionary:datum withCompletionHandler:^(BOOL success) {
            
            result &= success;
            
        }];
        
    }
    
    [[self document] saveDocument:^(BOOL success) {
    
        result &= success;
        completionHandler(result);

    }];
    
}

+ (void)insertObjectFromDictionary:(NSDictionary *)dictionary withCompletionHandler:(void (^)(BOOL success))completionHandler {
    
    NSString *name = [dictionary objectForKey:@"name"];
    NSArray *nameExplode = [name componentsSeparatedByString:@"."];
    NSString *entityName = [@"STM" stringByAppendingString:[nameExplode objectAtIndex:1]];
    
    NSArray *dataModelEntityNames = [self localDataModelEntityNames];
    
    if ([dataModelEntityNames containsObject:entityName]) {
        
        NSString *xid = [dictionary objectForKey:@"xid"];
        NSData *xidData = [STMFunctions dataFromString:[xid stringByReplacingOccurrencesOfString:@"-" withString:@""]];
        
        STMRecordStatus *recordStatus = [self existingRecordStatusForXid:xidData];
        
        if (![recordStatus.isRemoved boolValue]) {
            
            NSManagedObject *object = [self objectForEntityName:entityName andXid:xid];
            
            if (![self isWaitingToSyncForObject:object]) {
                
                NSDictionary *properties = [dictionary objectForKey:@"properties"];
                [self processingOfObject:object withEntityName:entityName fillWithValues:properties];
                
            }

        } else {
            
            NSLog(@"object with xid %@ have recordStatus.isRemoved == YES", xid);
            
        }
            
        completionHandler(YES);
        
    } else {
        
        completionHandler(NO);
        
    }
    
}

+ (void)processingOfObject:(NSManagedObject *)object withEntityName:(NSString *)entityName fillWithValues:(NSDictionary *)properties {
    
    NSSet *ownObjectKeys = [self ownObjectKeysForEntityName:entityName];
    
    NSEntityDescription *currentEntity = [object entity];
    NSDictionary *entityAttributes = [currentEntity attributesByName];
    
    for (NSString *key in ownObjectKeys) {
        
        id value = [properties objectForKey:key];
        
        if (value) {
            
            value = [self typeConversionForValue:value key:key entityAttributes:entityAttributes];
            
            [object setValue:value forKey:key];
            
            if ([key isEqualToString:@"href"]) {
                [self hrefProcessingForObject:object];
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
        
/*
        if ([entityName isEqualToString:@"STMCashing"] && [[ownObjectRelationships objectForKey:relationship] isEqualToString:@"STMUncashing"]) {
        
            NSLog(@"object %@", object);
            NSLog(@"properties %@", properties);
            NSLog(@"destinationObjectXid %@", destinationObjectXid);
            
        }
*/
        
        if (destinationObjectXid) {
            
            NSManagedObject *destinationObject = [self objectForEntityName:[ownObjectRelationships objectForKey:relationship] andXid:destinationObjectXid];
            
/*
            if ([entityName isEqualToString:@"STMCashing"] && [[ownObjectRelationships objectForKey:relationship] isEqualToString:@"STMUncashing"]) {
                
                NSLog(@"destinationObject before 1 %@", destinationObject);
                
            }
*/
            
            if (![[object valueForKey:relationship] isEqual:destinationObject]) {
                
                BOOL waitingForSync = [self isWaitingToSyncForObject:destinationObject];
                
//                NSDate *deviceTs = [destinationObject valueForKey:@"deviceTs"];
                
//                [object setPrimitiveValue:destinationObject forKey:relationship];
                [object setValue:destinationObject forKey:relationship];
                
                if (!waitingForSync) {
//                    [destinationObject setValue:deviceTs forKey:@"deviceTs"];
                    
                    [destinationObject addObserver:[self sharedController] forKeyPath:@"deviceTs" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
                    
                }
                
/*
                if ([entityName isEqualToString:@"STMCashing"] && [[ownObjectRelationships objectForKey:relationship] isEqualToString:@"STMUncashing"]) {
                    
                    NSLog(@"destinationObject after 1 %@", destinationObject);
                    
                }
*/
                
                
            }
            
        } else {
            
            NSManagedObject *destinationObject = [object valueForKey:relationship];
            
/*
            if ([entityName isEqualToString:@"STMCashing"] && [[ownObjectRelationships objectForKey:relationship] isEqualToString:@"STMUncashing"]) {
                
                NSLog(@"destinationObject before 2 %@", destinationObject);
                
            }
*/
            
            if (destinationObject) {
                
                BOOL waitingForSync = [self isWaitingToSyncForObject:destinationObject];
                
//                NSDate *deviceTs = [destinationObject valueForKey:@"deviceTs"];
                
                [object setValue:nil forKey:relationship];
                
                if (!waitingForSync) {
//                    [destinationObject setValue:deviceTs forKey:@"deviceTs"];
                    [destinationObject addObserver:[self sharedController] forKeyPath:@"deviceTs" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];

                }

/*
                if ([entityName isEqualToString:@"STMCashing"] && [[ownObjectRelationships objectForKey:relationship] isEqualToString:@"STMUncashing"]) {
                    
                    NSLog(@"destinationObject after 2 %@", destinationObject);
                    
                }
*/
                
                
            }
            
        }
        
    }
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
//    NSLog(@"object before %@", object);
//    
//    NSDate *old = [change valueForKey:NSKeyValueChangeOldKey];
//    NSDate *lts = [(NSManagedObject *)object valueForKey:@"lts"];
//    
//    NSLog(@"old %@, lts %@", [[STMFunctions dateFormatter] stringFromDate:old], [[STMFunctions dateFormatter] stringFromDate:lts]);
    
    [object removeObserver:self forKeyPath:keyPath];
    
    if ([object isKindOfClass:[NSManagedObject class]]) {
        
        [(NSManagedObject *)object setValue:[change valueForKey:NSKeyValueChangeOldKey] forKey:keyPath];
        
    }

//    NSLog(@"object after %@", object);
//    
//    NSLog(@"current time: %@", [[STMFunctions dateFormatter] stringFromDate:[NSDate date]]);

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
            
            [self checkAppVersion];
            
        }
        
    }

}

+ (void)setRelationshipsFromArray:(NSArray *)array withCompletionHandler:(void (^)(BOOL success))completionHandler {
    
    __block BOOL result = YES;
    
    for (NSDictionary *datum in array) {
        
        [self setRelationshipFromDictionary:datum withCompletionHandler:^(BOOL success) {
            
            result &= success;
            
        }];
        
    }
    
    [[self document] saveDocument:^(BOOL success) {
        
        result &= success;
        completionHandler(YES);
        
    }];

}

+ (void)setRelationshipFromDictionary:(NSDictionary *)dictionary withCompletionHandler:(void (^)(BOOL success))completionHandler {
    
    NSString *name = [dictionary objectForKey:@"name"];
    NSArray *nameExplode = [name componentsSeparatedByString:@"."];
    NSString *entityName = [@"STM" stringByAppendingString:[nameExplode objectAtIndex:1]];

    NSDictionary *serverDataModel = [(STMSyncer *)[STMSessionManager sharedManager].currentSession.syncer entitySyncInfo];

    if ([[serverDataModel allKeys] containsObject:entityName]) {
        
        NSDictionary *modelProperties = [serverDataModel objectForKey:entityName];
        NSString *roleOwner = [modelProperties objectForKey:@"roleOwner"];
        NSString *roleOwnerEntityName = [@"STM" stringByAppendingString:roleOwner];
        NSString *roleName = [modelProperties objectForKey:@"roleName"];
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

+ (BOOL)isWaitingToSyncForObject:(NSManagedObject *)object {
    
    BOOL isInSyncList = [[self entityNamesForSyncing] containsObject:object.entity.name];

    NSDate *lts = [object valueForKey:@"lts"];
    NSDate *deviceTs = [object valueForKey:@"deviceTs"];
    
/*
    if ([object.entity.name isEqualToString:@"STMUncashing"]) {
        
        NSLog(@"object isWaiting? %@", object);
        NSLog(@"isWaiting? %d", (isInSyncList && lts && [lts compare:deviceTs] == NSOrderedAscending));
        
    }
*/
    
    return (isInSyncList && lts && [lts compare:deviceTs] == NSOrderedAscending);
    
}

+ (NSArray *)entityNamesForSyncing {
    
    NSArray *entityNamesForSyncing = @[
                                       NSStringFromClass([STMPhotoReport class]),
                                       NSStringFromClass([STMCashing class]),
                                       NSStringFromClass([STMUncashing class]),
                                       NSStringFromClass([STMClientData class]),
                                       NSStringFromClass([STMRecordStatus class]),
                                       NSStringFromClass([STMUncashingPicture class]),
                                       NSStringFromClass([STMLocation class])
                                       ];
    
    return entityNamesForSyncing;

}

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
            
            object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:[self document].managedObjectContext];
            [object setValue:xidData forKey:@"xid"];
            
        }
        
        return object;
        
    } else {
        
        return nil;
        
    }
    
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
        
        recordStatus = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STMRecordStatus class]) inManagedObjectContext:[self document].managedObjectContext];
        recordStatus.objectXid = objectXid;
        
    }
    
    return recordStatus;
    
}


#pragma mark - getting entity properties

+ (NSSet *)ownObjectKeysForEntityName:(NSString *)entityName {
    
    NSEntityDescription *coreEntity = [NSEntityDescription entityForName:@"STMComment" inManagedObjectContext:[self document].managedObjectContext];
    NSSet *coreKeys = [NSSet setWithArray:[[coreEntity attributesByName] allKeys]];

    NSEntityDescription *objectEntity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self document].managedObjectContext];
    NSMutableSet *objectKeys = [NSMutableSet setWithArray:[[objectEntity attributesByName] allKeys]];

    [objectKeys minusSet:coreKeys];
    
    return objectKeys;
    
}

+ (NSDictionary *)ownObjectRelationshipsForEntityName:(NSString *)entityName {
    
    NSEntityDescription *coreEntity = [NSEntityDescription entityForName:@"STMComment" inManagedObjectContext:[self document].managedObjectContext];
    NSSet *coreRelationshipNames = [NSSet setWithArray:[[coreEntity relationshipsByName] allKeys]];
    
    NSEntityDescription *objectEntity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self document].managedObjectContext];
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
    
    NSEntityDescription *coreEntity = [NSEntityDescription entityForName:@"STMComment" inManagedObjectContext:[self document].managedObjectContext];
    NSSet *coreRelationshipNames = [NSSet setWithArray:[[coreEntity relationshipsByName] allKeys]];
    
    NSEntityDescription *objectEntity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self document].managedObjectContext];
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

+ (void)removeAllObjects {
    
    [[[STMSessionManager sharedManager].currentSession logger] saveLogMessageWithText:@"reload data" type:nil];

    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMDatum class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
    NSArray *datumFetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];
    
    request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMSetting class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
    NSArray *settingsFetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];

    request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMLogMessage class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
    NSArray *logMessageFetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];

    NSMutableSet *datumSet = [NSMutableSet setWithArray:datumFetchResult];
    NSSet *settingsSet = [NSSet setWithArray:settingsFetchResult];
    NSSet *logMessagesSet = [NSSet setWithArray:logMessageFetchResult];

    [datumSet minusSet:settingsSet];
    [datumSet minusSet:logMessagesSet];
        
    for (id datum in datumSet) {
        
        [[self document].managedObjectContext deleteObject:datum];
        
    }
    
    STMSyncer *syncer = [[STMSessionManager sharedManager].currentSession syncer];
    [syncer flushEntitySyncInfo];
    syncer.syncerState = STMSyncerReceiveData;
    
}


#pragma mark - picture processing

+ (void)hrefProcessingForObject:(NSManagedObject *)object {
    
    NSString *href = [object valueForKey:@"href"];
    
    if (href) {
        
        if ([object isKindOfClass:[STMPicture class]]) {

            if (![[self sharedController].hrefDictionary.allKeys containsObject:href]) {
                
                [[self sharedController].hrefDictionary setObject:object forKey:href];
//                NSLog(@"hrefDictionary.allKeys1 %d", [self sharedController].hrefDictionary.allKeys.count);

                [[self sharedController] addOperationForObject:object];

            }
            
        }
        
    }
    
}

- (void)addOperationForObject:(NSManagedObject *)object {
    
    NSString *href = [object valueForKey:@"href"];
    
    if ([self.secondAttempt containsObject:href]) {
//        NSLog(@"second attempt for %@", href);
    }
    
    __weak NSManagedObject *weakObject = object;
    
    [self.downloadQueue addOperationWithBlock:^{
        
//        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:href] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            if (error) {
                
                if (error.code == -1001) {
                    
                    NSLog(@"error code -1001 timeout for %@", href);
                    
                    if ([self.secondAttempt containsObject:href]) {
                        
                        NSLog(@"second load attempt fault for %@", href);
                        
                        [self.secondAttempt removeObject:href];
                        [self.hrefDictionary removeObjectForKey:href];
                        
                    } else {
                        
                        [self.secondAttempt addObject:href];

//                        double delayInSeconds = 2.0;
//                        
//                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//
//                            [self addOperationForObject:object];
//                            
//                        });

                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self performSelector:@selector(addOperationForObject:) withObject:weakObject afterDelay:0];
                        });

//                        NSLog(@"secondAttempt.count %d", self.secondAttempt.count);
                        
                    }
                    
                } else {
                    
                    NSLog(@"error %@ in %@", error.description, [object valueForKey:@"name"]);
                    [self.hrefDictionary removeObjectForKey:href];
                    
                }
                
            } else {
                
//                NSLog(@"%@ load successefully", href);
                
                [self.hrefDictionary removeObjectForKey:href];
                
                NSData *dataCopy = [data copy];
                    
//                @autoreleasepool {
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^ {
                
                        [[self class] setImagesFromData:dataCopy forPicture:(STMPicture *)weakObject];
                        
//                    });
//                }
                
//                NSLog(@"hrefDictionary.allKeys2 %d", self.hrefDictionary.allKeys.count);
                
            }
            
//            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
        }] resume];
        
    }];

}

- (void)repeatUploadOperationForObject:(NSManagedObject *)object {
    
    if ([object isKindOfClass:[STMPhoto class]]) {
        
        STMPhoto *photo = (STMPhoto *)object;
        
        NSString *xid = [STMFunctions xidStringFromXidData:photo.xid];
        NSString *fileName = [xid stringByAppendingString:@".jpg"];
        NSData *photoData = [NSData dataWithContentsOfFile:photo.imagePath];

        [self addUploadOperationForPhoto:photo withFileName:fileName data:photoData];
        
    }
    
}

- (void)addUploadOperationForPhoto:(STMPhoto *)photo withFileName:(NSString *)filename data:(NSData *)data {

    if ([self s3Init]) {
        
        NSString *bucket = [self.settings valueForKey:@"S3.IMGUploadBucket"];
        
        NSString *entityName = photo.entity.name;
        
        NSDate *currentDate = [NSDate date];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy";
        
        NSString *year = [dateFormatter stringFromDate:currentDate];
        
        dateFormatter.dateFormat = @"MM";
        
        NSString *month = [dateFormatter stringFromDate:currentDate];

        dateFormatter.dateFormat = @"dd";
        
        NSString *day = [dateFormatter stringFromDate:currentDate];

        bucket = [bucket stringByAppendingString:[NSString stringWithFormat:@"/%@/%@/%@/%@", entityName, year, month, day]];
        
        if (bucket) {
            
            [self.uploadQueue addOperationWithBlock:^{
                
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                
                AWSS3 *transferManager = [[AWSS3 alloc] initWithConfiguration:[AWSServiceManager defaultServiceManager].defaultServiceConfiguration];
                AWSS3PutObjectRequest *photoRequest = [[AWSS3PutObjectRequest alloc] init];
                photoRequest.bucket = bucket;
                photoRequest.key = filename;
                photoRequest.contentType = @"image/jpeg";
                photoRequest.body = data;
                photoRequest.contentLength = [NSNumber numberWithInteger:data.length];
                
                [[transferManager putObject:photoRequest] continueWithBlock:^id(BFTask *task) {
                    
                    if (task.error) {
                        
                        NSLog(@"Upload error: %@", task.error);
                        
                        NSTimeInterval interval = [(STMSyncer *)[[STMSessionManager sharedManager].currentSession syncer] syncInterval];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self performSelector:@selector(repeatUploadOperationForObject:) withObject:photo afterDelay:interval];
                        });
                        
                    } else {
                        
                        //                    NSLog(@"Got here: %@", task.result);
                        
                        NSArray *urlArray = [NSArray arrayWithObjects:transferManager.endpoint.URL, bucket, filename, nil];
                        NSString *href = [urlArray componentsJoinedByString:@"/"];
                        
                        NSLog(@"%@ upload successefully", href);
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            photo.href = href;
                            [(STMSyncer *)[STMSessionManager sharedManager].currentSession.syncer setSyncerState:STMSyncerSendData];
                            
                        });
                        
                    }
                    
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                    
                    return nil;
                    
                }];
                
            }];

            
        } else {
            
            NSLog(@"have no S3.IMGUploadBucket");
            
        }
        
        
    } else {
        
        NSTimeInterval interval = [(STMSyncer *)[[STMSessionManager sharedManager].currentSession syncer] syncInterval];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(repeatUploadOperationForObject:) withObject:photo afterDelay:interval];
        });

    }
    

    
}

+ (void)setImagesFromData:(NSData *)data forPicture:(STMPicture *)picture {

//    NSLog(@"data.length %d", data.length);
    
    NSData *weakData = data;
    STMPicture *weakPicture = picture;
    
//    NSLog(@"weakData.length %d", weakData.length);
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^ {

        
        NSString *fileName = nil;

        if ([picture isKindOfClass:[STMCampaignPicture class]]) {

            fileName = [[NSURL URLWithString:picture.href] lastPathComponent];

        } else if ([picture isKindOfClass:[STMPhoto class]] || [picture isKindOfClass:[STMUncashingPicture class]]) {
            
            NSString *xid = [STMFunctions xidStringFromXidData:picture.xid];
            fileName = [xid stringByAppendingString:@".jpg"];
            
            [[self sharedController] addUploadOperationForPhoto:(STMPhoto *)picture withFileName:fileName data:weakData];
            
        }
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:fileName];
        NSString *resizedImagePath = [documentsDirectory stringByAppendingPathComponent:[@"resized_" stringByAppendingString:fileName]];
    
//        NSLog(@"weakData %d", weakData.length);
    
        UIImage *imageThumbnail = [STMFunctions resizeImage:[UIImage imageWithData:weakData] toSize:CGSizeMake(150, 150)];
        NSData *thumbnail = UIImageJPEGRepresentation(imageThumbnail, 0.0);
//        NSLog(@"thumbnail before the block %@", thumbnail);
    
        dispatch_async(dispatch_get_main_queue(), ^{
    
//            NSLog(@"weakPicture %@", weakPicture);
//            NSLog(@"thumbnail %@", thumbnail);

                weakPicture.imageThumbnail = thumbnail;
        
        });

        [weakData writeToFile:imagePath atomically:YES];

        UIImage *resizedImage = [STMFunctions resizeImage:[UIImage imageWithData:weakData] toSize:CGSizeMake(1024, 1024)];
        NSData *resizedImageData = nil;
        
            resizedImageData = UIImageJPEGRepresentation(resizedImage, 0.0);
        
        [resizedImageData writeToFile:resizedImagePath atomically:YES];

        dispatch_async(dispatch_get_main_queue(), ^{
    
            weakPicture.imagePath = imagePath;
            weakPicture.resizedImagePath = resizedImagePath;
            
        });
    
   // });

}

+ (void)generatePhotoReports {

    NSArray *outlets = [self objectsForEntityName:NSStringFromClass([STMOutlet class])];
    NSArray *campaigns = [self objectsForEntityName:NSStringFromClass([STMCampaign class])];
    
    for (STMCampaign *campaign in campaigns) {
        
        for (STMOutlet *outlet in outlets) {
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPhotoReport class])];
            request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
            request.predicate = [NSPredicate predicateWithFormat:@"campaign == %@ AND outlet == %@", campaign, outlet];
            
            NSError *error;
            NSArray *photoReports = [self.document.managedObjectContext executeFetchRequest:request error:&error];
            
            if (photoReports.count == 0) {
                
                STMPhotoReport *photoReport = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STMPhotoReport class]) inManagedObjectContext:self.document.managedObjectContext];
                photoReport.outlet = outlet;
                photoReport.campaign = campaign;
                
            }
            
        }
        
    }

}


#pragma mark - recieve of objects is finished

+ (void)dataLoadingFinished {
    
    //    [self generatePhotoReports];
    [self totalNumberOfObjects];
    
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
                             NSStringFromClass([STMLocation class])];
    
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
