//
//  STMPicturesController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 29/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMPicturesController.h"
#import "STMFunctions.h"
#import "STMSessionManager.h"

#import "STMCampaignPicture.h"
#import "STMUncashingPicture.h"
#import "STMPhoto.h"

#import <AWSiOSSDKv2/AWSCore.h>
#import <AWSiOSSDKv2/S3.h>
#import <objc/runtime.h>

#import <Security/Security.h>
#import "KeychainItemWrapper.h"

@interface STMPicturesController()

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

@implementation STMPicturesController

@synthesize accessKey = _accessKey;
@synthesize secretKey = _secretKey;


+ (STMPicturesController *)sharedController {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedController = nil;
    
    dispatch_once(&pred, ^{
        
        //        NSLog(@"STMObjectsController init");
        _sharedController = [[self alloc] init];
        
    });
    
    return _sharedController;
    
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

- (BOOL)s3Init {
    
    if (self.accessKey && self.secretKey && !self.s3Initialized) {
        
        AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:self.accessKey secretKey:self.secretKey];
        AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionEUWest1 credentialsProvider:credentialsProvider];
        [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
        
        self.s3Initialized = YES;
        
    }
    
    return self.s3Initialized;
    
}



+ (void)checkPhotos {
    
    [self checkBrokenPhotos];
    [self checkUploadedPhotos];
    
}

+ (void)checkBrokenPhotos {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPicture class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"imageThumbnail == %@", nil];
    
    NSError *error;
    NSArray *result = [[self document].managedObjectContext executeFetchRequest:request error:&error];
    
    for (STMPicture *picture in result) {
        
        //        NSLog(@"broken photo %@", photo);
        
        if (picture.imagePath) {
            
            NSData *photoData = [NSData dataWithContentsOfFile:picture.imagePath];
            
            if (photoData) {
                
                [self setImagesFromData:photoData forPicture:picture];
                
            } else {
                
                [self deletePicture:picture];
                
            }
            
        } else {
            
            [self deletePicture:picture];
            
        }
        
    }
    
}

+ (void)checkUploadedPhotos {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPicture class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"href == %@", nil];
    
    NSError *error;
    NSArray *result = [[self document].managedObjectContext executeFetchRequest:request error:&error];
    
    for (STMPicture *picture in result) {
        
        NSString *xid = [STMFunctions xidStringFromXidData:picture.xid];
        NSString *fileName = [xid stringByAppendingString:@".jpg"];
        NSData *photoData = [NSData dataWithContentsOfFile:picture.imagePath];
        
        [[self sharedController] addUploadOperationForPicture:picture withFileName:fileName data:photoData];
        
    }
    
}

+ (void)hrefProcessingForObject:(NSManagedObject *)object {
    
    NSString *href = [object valueForKey:@"href"];
    
    if (href) {
        
        if ([object isKindOfClass:[STMPicture class]]) {
            
            if (![[self sharedController].hrefDictionary.allKeys containsObject:href]) {
                
                ([self sharedController].hrefDictionary)[href] = object;
                //                NSLog(@"hrefDictionary.allKeys1 %d", [self sharedController].hrefDictionary.allKeys.count);
                
                [[self sharedController] addOperationForObject:object];
                
            }
            
        }
        
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
        
        [[self sharedController] addUploadOperationForPicture:picture withFileName:fileName data:weakData];
        
    }
    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = ([paths count] > 0) ? paths[0] : nil;
    NSString *documentsDirectory = @"";
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

- (void)addOperationForObject:(NSManagedObject *)object {
    
    NSString *href = [object valueForKey:@"href"];
    
    if ([self.secondAttempt containsObject:href]) {
        //        NSLog(@"second attempt for %@", href);
    }
    
    __weak NSManagedObject *weakObject = object;
    
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
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self performSelector:@selector(addOperationForObject:) withObject:weakObject afterDelay:0];
                        });
                        
                    }
                    
                } else {
                    
                    NSLog(@"error %@ in %@", error.description, [object valueForKey:@"name"]);
                    [self.hrefDictionary removeObjectForKey:href];
                    
                }
                
            } else {
                
                NSLog(@"%@ load successefully", href);
                
                NSData *dataCopy = [data copy];
                
                [[self class] setImagesFromData:dataCopy forPicture:(STMPicture *)weakObject];
                
                [self.hrefDictionary removeObjectForKey:href];

            }
            
        }] resume];
        
    }];
    
}

- (void)repeatUploadOperationForObject:(NSManagedObject *)object {
    
    if ([object isKindOfClass:[STMPicture class]]) {
        
        STMPicture *picture = (STMPicture *)object;
        
        NSString *xid = [STMFunctions xidStringFromXidData:picture.xid];
        NSString *fileName = [xid stringByAppendingString:@".jpg"];
        NSData *data = [NSData dataWithContentsOfFile:picture.imagePath];
        
        [self addUploadOperationForPicture:picture withFileName:fileName data:data];
        
    }
    
}

- (void)addUploadOperationForPicture:(STMPicture *)picture withFileName:(NSString *)filename data:(NSData *)data {
    
    if ([self s3Init]) {
        
        NSString *bucket = [self.settings valueForKey:@"S3.IMGUploadBucket"];
        
        NSString *entityName = picture.entity.name;
        
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
                photoRequest.contentLength = @((int)data.length);
                
                [[transferManager putObject:photoRequest] continueWithBlock:^id(BFTask *task) {
                    
                    if (task.error) {
                        
                        NSLog(@"Upload error: %@", task.error);
                        
                        NSTimeInterval interval = [(STMSyncer *)[[STMSessionManager sharedManager].currentSession syncer] syncInterval];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self performSelector:@selector(repeatUploadOperationForObject:) withObject:picture afterDelay:interval];
                        });
                        
                    } else {
                        
                        //                    NSLog(@"Got here: %@", task.result);
                        
                        NSArray *urlArray = @[transferManager.configuration.endpoint.URL, bucket, filename];
                        NSString *href = [urlArray componentsJoinedByString:@"/"];
                        
                        NSLog(@"%@ upload successefully", href);
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            picture.href = href;
                            picture.deviceTs = [NSDate date];
                            [(STMSyncer *)[STMSessionManager sharedManager].currentSession.syncer setSyncerState:STMSyncerSendDataOnce];
                            
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
            [self performSelector:@selector(repeatUploadOperationForObject:) withObject:picture afterDelay:interval];
        });
        
    }
    
    
    
}

+ (void)deletePicture:(STMPicture *)picture {

    [self removeImageFilesForPicture:picture];
    
    [[self document].managedObjectContext deleteObject:picture];

    [[self document] saveDocument:^(BOOL success) {
        
    }];
    
}

+ (void)removeImageFilesForPicture:(STMPicture *)picture {
    
    [self removeImage:picture.imagePath];
    [self removeImage:picture.resizedImagePath];
    
}

+ (void)removeImage:(NSString *)filePath {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:filePath isDirectory:nil]) {

        NSError *error;
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
        
        if (success) {
            
            NSLog(@"file %@ was successefully removed", [filePath lastPathComponent]);
            
        } else {
            
            NSLog(@"removeItemAtPath error: %@ ",[error localizedDescription]);
            
        }

    }
    
}


//+ (void)generatePhotoReports {
//    
//    NSArray *outlets = [self objectsForEntityName:NSStringFromClass([STMOutlet class])];
//    NSArray *campaigns = [self objectsForEntityName:NSStringFromClass([STMCampaign class])];
//    
//    for (STMCampaign *campaign in campaigns) {
//        
//        for (STMOutlet *outlet in outlets) {
//            
//            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPhotoReport class])];
//            request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
//            request.predicate = [NSPredicate predicateWithFormat:@"campaign == %@ AND outlet == %@", campaign, outlet];
//            
//            NSError *error;
//            NSArray *photoReports = [self.document.managedObjectContext executeFetchRequest:request error:&error];
//            
//            if (photoReports.count == 0) {
//                
//                STMPhotoReport *photoReport = [STMEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STMPhotoReport class]) inManagedObjectContext:self.document.managedObjectContext];
//                photoReport.outlet = outlet;
//                photoReport.campaign = campaign;
//                
//            }
//            
//        }
//        
//    }
//    
//}


@end
