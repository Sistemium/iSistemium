//
//  STMObjectsController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMObjectsController.h"
#import "STMSessionManager.h"
#import "STMDocument.h"
#import "STMFunctions.h"
#import "STMSyncer.h"

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

#import <AWSiOSSDKv2/AWSCore.h>
#import <AWSiOSSDKv2/S3.h>
#import <objc/runtime.h>
#import "AWXMLRequestSerializerFixed.h"


@interface STMObjectsController()

@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@property (nonatomic, strong) NSOperationQueue *uploadQueue;
@property (nonatomic, strong) NSMutableDictionary *hrefDictionary;
@property (nonatomic, strong) NSMutableArray *secondAttempt;

@end


@implementation STMObjectsController

+ (STMObjectsController *)sharedController {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedController = nil;
    
    dispatch_once(&pred, ^{
    
        NSLog(@"STMObjectsController init");
        _sharedController = [[self alloc] init];
        [self s3Init];
        [self checkBrokenPhotos];
    
    });
    
    return _sharedController;
    
}

+ (void)s3Init {
    
    NSArray *currentSettings = [[[STMSessionManager sharedManager].currentSession settingsController] currentSettings];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH %@", @"S3"];
    NSArray *s3Settings = [currentSettings filteredArrayUsingPredicate:predicate];

    NSPredicate *secretKeyPredicate = [NSPredicate predicateWithFormat:@"name == %@", @"S3.SecretAccessKey"];
    NSString *secretKey = [[[s3Settings filteredArrayUsingPredicate:secretKeyPredicate] lastObject] valueForKey:@"value"];

    NSPredicate *accessKeyPredicate = [NSPredicate predicateWithFormat:@"name == %@", @"S3.AccessKeyID"];
    NSString *accessKey = [[[s3Settings filteredArrayUsingPredicate:accessKeyPredicate] lastObject] valueForKey:@"value"];

    AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:accessKey secretKey:secretKey];
    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionEUWest1 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    
    // Get both the methods from the object by its selectors
    Method originalMethod = class_getInstanceMethod(NSClassFromString(@"AWSS3RequestSerializer"), @selector(serializeRequest:headers:parameters:error:));
    Method newMethod = class_getInstanceMethod([AWXMLRequestSerializerFixed class], @selector(__serializeRequest:headers:parameters:error:));
    method_exchangeImplementations(originalMethod, newMethod);

}

+ (void)checkBrokenPhotos {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPhoto class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
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

+ (void)deletePhoto:(STMPhoto *)photo {
    
//    NSLog(@"delete photo %@", photo);
    
    STMPhotoReport *photoReport = photo.photoReport;
    
    [[self document].managedObjectContext deleteObject:photo];
    
    if (photoReport.photos.count == 0) {
        
        [[self document].managedObjectContext deleteObject:photoReport];
        
    }
    
    [[self document] saveDocument:^(BOOL success) {
        
    }];
    
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
    
    NSArray *dataModelEntityNames = [self dataModelEntityNames];
    
    if ([dataModelEntityNames containsObject:entityName]) {
        
        NSString *xid = [dictionary objectForKey:@"xid"];
        NSManagedObject *object = [self objectForEntityName:entityName andXid:xid];
        NSDictionary *properties = [dictionary objectForKey:@"properties"];
        NSSet *ownObjectKeys = [self ownObjectKeysForEntityName:entityName];

        for (NSString *key in ownObjectKeys) {
            
            id value = [properties objectForKey:key];
            if (value) {
                
                [object setValue:value forKey:key];
                
                if ([key isEqualToString:@"href"]) {
                    [self hrefProcessingForObject:object];
                }
                
            }
            
        }

        NSDictionary *ownObjectRelationships = [self ownObjectRelationshipsForEntityName:entityName];
        
        for (NSString *relationship in [ownObjectRelationships allKeys]) {
            
            NSDictionary *relationshipDictionary = [properties objectForKey:relationship];
            NSString *destinationObjectXid = [relationshipDictionary objectForKey:@"xid"];
            
            if (destinationObjectXid) {
                
                NSManagedObject *destinationObject = [self objectForEntityName:[ownObjectRelationships objectForKey:relationship] andXid:destinationObjectXid];
                [object setValue:destinationObject forKey:relationship];
                
            }
            
        }
        
//        [[self document] saveDocument:^(BOOL success) {}];

    }
    
    completionHandler(YES);
    
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
            
            if ([destinationSet containsObject:destinationObject] && [destinationEntityName isEqualToString:@"STMCampaignPicture"]) {

                NSLog(@"already in set: %@, %@, %@", roleOwnerEntityName, destinationEntityName, destinationXid);
                
            } else {

                [[ownerObject mutableSetValueForKey:roleName] addObject:destinationObject];
//                [[self document] saveDocument:^(BOOL success) {}];

            }
            
            
        }
        
    }
    
    completionHandler(YES);
    
}

+ (NSManagedObject *)objectForEntityName:(NSString *)entityName andXid:(NSString *)xid {
    
    NSArray *dataModelEntityNames = [self dataModelEntityNames];
    
    if ([dataModelEntityNames containsObject:entityName]) {
        
        xid = [xid stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
        NSData *xidData = [STMFunctions dataFromString:xid];

        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMDatum class])];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"SELF.xid == %@", xidData];

        NSError *error;
        NSArray *fetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];
        
        NSManagedObject *object = [fetchResult lastObject];
        
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

+ (NSArray *)dataModelEntityNames {
    
    return [[self document].managedObjectModel.entitiesByName allKeys];
    
}

+ (void)removeAllObjects {
    
    [[[STMSessionManager sharedManager].currentSession logger] saveLogMessageWithText:@"reload data" type:nil];

    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMDatum class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
    NSArray *datumFetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];
    
    request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMSetting class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
    NSArray *settingsFetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];

    request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMLogMessage class])];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
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
    syncer.syncerState = STMSyncerRecieveData;
    
}

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
    
    [self.downloadQueue addOperationWithBlock:^{
        
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
                            [self performSelector:@selector(addOperationForObject:) withObject:object afterDelay:0];
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
                [[self class] setImagesFromData:data forPicture:(STMPicture *)object];
                
//                NSLog(@"hrefDictionary.allKeys2 %d", self.hrefDictionary.allKeys.count);
                
            }
            
        }] resume];
        
    }];

}

- (void)addUploadOperationForPhoto:(STMPhoto *)photo withFileName:(NSString *)filename data:(NSData *)data {
    
    NSLog(@"filename %@", filename);
    
    NSArray *currentSettings = [[[STMSessionManager sharedManager].currentSession settingsController] currentSettings];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH %@", @"S3"];
    NSArray *s3Settings = [currentSettings filteredArrayUsingPredicate:predicate];
    
    predicate = [NSPredicate predicateWithFormat:@"name == %@", @"S3.IMGUploadBucket"];
    NSString *bucket = [[[s3Settings filteredArrayUsingPredicate:predicate] lastObject] valueForKey:@"value"];

    
    [self.uploadQueue addOperationWithBlock:^{
        
        AWSS3 *transferManager = [[AWSS3 alloc] initWithConfiguration:[AWSServiceManager defaultServiceManager].defaultServiceConfiguration];
        AWSS3PutObjectRequest *photoRequest = [[AWSS3PutObjectRequest alloc] init];
        photoRequest.bucket = bucket;
        photoRequest.key = filename;
        photoRequest.contentType = @"image/jpeg";
        photoRequest.body = data;
        photoRequest.contentLength = [NSNumber numberWithInteger:data.length];
        
        [[transferManager putObject:photoRequest] continueWithBlock:^id(BFTask *task) {
            
            if (task.error) {
                
                NSLog(@"Upload error: %@",task.error);
                
            } else {
                
                NSLog(@"%@ upload successefully", filename);
                NSLog(@"Got here: %@", task.result);
                
                NSArray *urlArray = [NSArray arrayWithObjects:transferManager.endpoint.URL, bucket, filename, nil];
                NSString *href = [urlArray componentsJoinedByString:@"/"];
                
                photo.href = href;
                
                NSLog(@"photo %@", photo);
                
            }
            
            return nil;
            
        }];

        
/*
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
                            [self performSelector:@selector(addOperationForObject:) withObject:object afterDelay:0];
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
                [[self class] setImagesFromData:data forPicture:(STMPicture *)object];
                
                //                NSLog(@"hrefDictionary.allKeys2 %d", self.hrefDictionary.allKeys.count);
                
            }
            
        }] resume];
*/
    }];
    
}

+ (void)setImagesFromData:(NSData *)data forPicture:(STMPicture *)picture {

    NSString *fileName = nil;
    NSString *fileType = nil;
    
    BOOL pngType;

    if ([picture isKindOfClass:[STMCampaignPicture class]]) {

        fileName = [[NSURL URLWithString:picture.href] lastPathComponent];
        fileType = [[[fileName componentsSeparatedByString:@"."] lastObject] lowercaseString];
        
        pngType = [fileType isEqualToString:@"png"];

    } else if ([picture isKindOfClass:[STMPhoto class]]) {
        
        NSString *xid = [NSString stringWithFormat:@"%@", picture.xid];
        NSCharacterSet *charsToRemove = [NSCharacterSet characterSetWithCharactersInString:@"< >"];
        xid = [[xid stringByTrimmingCharactersInSet:charsToRemove] stringByReplacingOccurrencesOfString:@" " withString:@""];

        fileName = [xid stringByAppendingString:@".jpg"];
        pngType = NO;
//        NSLog(@"fileName %@", fileName);
        
        [[self sharedController] addUploadOperationForPhoto:(STMPhoto *)picture withFileName:fileName data:data];
        
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSString *resizedImagePath = [documentsDirectory stringByAppendingPathComponent:[@"resized_" stringByAppendingString:fileName]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        UIImage *imageThumbnail = [STMFunctions resizeImage:[UIImage imageWithData:data] toSize:CGSizeMake(150, 150)];
        
        dispatch_async(dispatch_get_main_queue(), ^{

            if (pngType) {
                picture.imageThumbnail = UIImagePNGRepresentation(imageThumbnail);
            } else {
                picture.imageThumbnail = UIImageJPEGRepresentation(imageThumbnail, 0.0);
            }
            
        
        });

        [data writeToFile:imagePath atomically:YES];

        UIImage *resizedImage = [STMFunctions resizeImage:[UIImage imageWithData:data] toSize:CGSizeMake(1024, 1024)];
        NSData *resizedImageData = nil;
        
        if (pngType) {
            resizedImageData = UIImagePNGRepresentation(resizedImage);
        } else {
            resizedImageData = UIImageJPEGRepresentation(resizedImage, 0.0);
        }
        
        [resizedImageData writeToFile:resizedImagePath atomically:YES];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            picture.imagePath = imagePath;
            picture.resizedImagePath = resizedImagePath;
            
        });
        
    });

}

+ (void)dataLoadingFinished {
    
//    [self generatePhotoReports];
    [self totalNumberOfObjects];
    
}

+ (void)generatePhotoReports {

    NSArray *outlets = [self objectsForEntityName:NSStringFromClass([STMOutlet class])];
    NSArray *campaigns = [self objectsForEntityName:NSStringFromClass([STMCampaign class])];
    
    for (STMCampaign *campaign in campaigns) {
        
        for (STMOutlet *outlet in outlets) {
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPhotoReport class])];
            request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
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
                             NSStringFromClass([STMPhoto class])];
    
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

    if ([[self dataModelEntityNames] containsObject:entityName]) {

        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
        NSError *error;
        NSArray *result = [[self document].managedObjectContext executeFetchRequest:request error:&error];
        
        return result;

    } else {
        
        return nil;
        
    }
    
}

@end
