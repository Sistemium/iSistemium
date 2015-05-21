//
//  STMPicturesController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 29/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMPicturesController.h"
#import "STMFunctions.h"
#import "STMConstants.h"
#import "STMSessionManager.h"
#import "STMObjectsController.h"

#import "STMCampaignPicture.h"
#import "STMUncashingPicture.h"
#import "STMPhoto.h"

#import <AWSCore.h>
#import <AWSS3.h>
#import <objc/runtime.h>

#import <Security/Security.h>
#import "KeychainItemWrapper.h"

@interface STMPicturesController() <NSFetchedResultsControllerDelegate>

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

@property (nonatomic, strong) NSFetchedResultsController *unloadedPicturesResultsController;


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

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        [self addObservers];
        [self performFetch];
        
    }
    return self;
    
}

- (void)addObservers {
 
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(authStateChanged)
               name:@"authControllerStateChanged"
             object:[STMAuthController authController]];

}

- (void)authStateChanged {
    
    if ([STMAuthController authController].controllerState != STMAuthSuccess) {
        
        self.downloadQueue = nil;
        self.uploadQueue = nil;
        self.hrefDictionary = nil;
        self.secondAttempt = nil;
        self.s3keychainItem = nil;
        self.accessKey = nil;
        self.secretKey = nil;
        self.s3Initialized = NO;
        self.session = nil;
        self.settings = nil;
        self.unloadedPicturesResultsController = nil;
        
    }
    
}

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
        
        AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:self.accessKey secretKey:self.secretKey];
        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionEUWest1 credentialsProvider:credentialsProvider];
        [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
        
        self.s3Initialized = YES;
        
    }
    
    return self.s3Initialized;
    
}

- (NSFetchedResultsController *)unloadedPicturesResultsController {
    
    if (!_unloadedPicturesResultsController) {
        
        STMFetchRequest *request = [[STMFetchRequest alloc] initWithEntityName:NSStringFromClass([STMPicture class])];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"href != %@ AND imageThumbnail == %@", nil, nil];
        
        request.sortDescriptors = @[sortDescriptor];
        request.predicate = [STMPredicate predicateWithNoFantomsFromPredicate:predicate];
        
        _unloadedPicturesResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                                 managedObjectContext:self.session.document.managedObjectContext
                                                                                   sectionNameKeyPath:nil
                                                                                            cacheName:nil];
        _unloadedPicturesResultsController.delegate = self;
        
    }
    return _unloadedPicturesResultsController;
    
}

- (void)performFetch {
    
    NSError *error;
    if (![self.unloadedPicturesResultsController performFetch:&error]) {
        NSLog(@"unloadedPicturesResultsController fetch error: ", error.localizedDescription);
    }

}

- (NSUInteger)unloadedPicturesCount {
    return self.unloadedPicturesResultsController.fetchedObjects.count;
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"unloadedPicturesCountDidChange" object:self];
    
}


#pragma mark - class methods

+ (CGFloat)jpgQuality {
    
    NSDictionary *appSettings = [self.session.settingsController currentSettingsForGroup:@"appSettings"];
    CGFloat jpgQuality = [[appSettings valueForKey:@"jpgQuality"] floatValue];

    return jpgQuality;
    
}

+ (void)checkPhotos {
    
    [self checkPicturesPaths];
    [self checkBrokenPhotos];
    [self checkUploadedPhotos];
    
}

+ (void)checkPicturesPaths {
    
    NSString *sessionUID = [STMSessionManager sharedManager].currentSessionUID;
    NSString *keyToCheck = [@"picturePathsDidCheckedAlready_" stringByAppendingString:sessionUID];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL picturePathsDidCheckedAlready = [[defaults objectForKey:keyToCheck] boolValue];
    
    if (!picturePathsDidCheckedAlready) {
        
        [self startCheckingPicturesPaths];
        
        [defaults setObject:@YES forKey:keyToCheck];
        [defaults synchronize];
        
    }
    
}

+ (void)startCheckingPicturesPaths {
    
    NSArray *result = [STMObjectsController objectsForEntityName:NSStringFromClass([STMPicture class])];
    
    if (result.count > 0) {

        NSLogMethodName;

        for (STMPicture *picture in result) {
            
            NSArray *pathComponents = [picture.imagePath pathComponents];
            
            if (pathComponents.count == 0) {
                
                if (picture.href) {
                    [self hrefProcessingForObject:picture];
                } else {
                    NSLog(@"picture %@ has no both imagePath and href, will be deleted", picture.xid);
                    [self deletePicture:picture];
                }
                
            } else {
                
                if (pathComponents.count > 1) {
                    [self imagePathsConvertingFromAbsoluteToRelativeForPicture:picture];
                }
                
            }
            
        }

    }
    
}

+ (void)imagePathsConvertingFromAbsoluteToRelativeForPicture:(STMPicture *)picture {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *newImagePath = [self convertImagePath:picture.imagePath];
    NSString *newResizedImagePath = [self convertImagePath:picture.resizedImagePath];
    
    if (newImagePath) {

        NSLog(@"set new imagePath for picture %@", picture.xid);
        picture.imagePath = newImagePath;

        if (newResizedImagePath) {
            
            NSLog(@"set new resizedImagePath for picture %@", picture.xid);
            picture.resizedImagePath = newResizedImagePath;
            
        } else {
            
            NSLog(@"! new resizedImagePath for picture %@", picture.xid);

            if ([fileManager fileExistsAtPath:picture.resizedImagePath]) {
                [fileManager removeItemAtPath:picture.resizedImagePath error:nil];
            }

            NSLog(@"save new resizedImage file for picture %@", picture.xid);
            NSData *imageData = [NSData dataWithContentsOfFile:[STMFunctions absolutePathForPath:newImagePath]];
            [self saveResizedImageFile:[@"resized_" stringByAppendingString:newImagePath] forPicture:picture fromImageData:imageData];
            
        }
        
    } else {

        NSLog(@"! new imagePath for picture %@", picture.xid);

        if (picture.href) {
            
            NSLog(@"have href, flush picture and download data again");
            
            [self removeImageFilesForPicture:picture];
            [self hrefProcessingForObject:picture];
            
        } else {

            NSLog(@"no href, delete picture");
            
            [self deletePicture:picture];
            
        }

    }

}

+ (NSString *)convertImagePath:(NSString *)path {
    
    NSString *lastPathComponent = [path lastPathComponent];
    NSString *imagePath = [STMFunctions absolutePathForPath:lastPathComponent];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        return lastPathComponent;
    } else {
        return nil;
    }

}

+ (void)checkBrokenPhotos {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPicture class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"imageThumbnail == %@", nil];
    
    NSError *error;
    NSArray *result = [[self document].managedObjectContext executeFetchRequest:request error:&error];
    
    for (STMPicture *picture in result) {
        
        if (picture.imagePath) {
            
            NSData *photoData = [NSData dataWithContentsOfFile:[STMFunctions absolutePathForPath:picture.imagePath]];
            
            if (photoData) {
                
                [self setImagesFromData:photoData forPicture:picture];
                
            } else {
                
                [self deletePicture:picture];
                
            }
            
        } else {
            
            [self hrefProcessingForObject:picture];
            
        }

    }
    
}

+ (void)checkUploadedPhotos {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPhoto class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"href == %@", nil];
    
    NSError *error;
    NSArray *result = [[self document].managedObjectContext executeFetchRequest:request error:&error];
    
    for (STMPicture *picture in result) {
        
        NSString *xid = [STMFunctions UUIDStringFromUUIDData:picture.xid];
        NSString *fileName = [xid stringByAppendingString:@".jpg"];
        
        NSData *photoData = [NSData dataWithContentsOfFile:[STMFunctions absolutePathForPath:picture.imagePath]];

        [[self sharedController] addUploadOperationForPicture:picture withFileName:fileName data:photoData];
        
    }
    
}

+ (void)hrefProcessingForObject:(NSManagedObject *)object {
    
    NSString *href = [object valueForKey:@"href"];
    
    if (href) {
        
        if ([object isKindOfClass:[STMPicture class]]) {
            
            if (![[self sharedController].hrefDictionary.allKeys containsObject:href]) {
                
                ([self sharedController].hrefDictionary)[href] = object;
                [[self sharedController] addOperationForObject:object];
                
            }
            
        }
        
    }
    
}


+ (void)setImagesFromData:(NSData *)data forPicture:(STMPicture *)picture {
    
    NSData *weakData = data;
    STMPicture *weakPicture = picture;
    
    NSString *fileName = nil;
    
    if ([picture isKindOfClass:[STMPhoto class]]) {
        
        NSString *xid = [STMFunctions UUIDStringFromUUIDData:picture.xid];
        fileName = [xid stringByAppendingString:@".jpg"];
        
        [[self sharedController] addUploadOperationForPicture:picture withFileName:fileName data:weakData];

    } else if ([picture isKindOfClass:[STMPicture class]]) {
        
        fileName = [[NSURL URLWithString:picture.href] lastPathComponent];
        
    }
    
    [self setThumbnailForPicture:weakPicture fromImageData:weakData];
    [self saveImageFile:fileName forPicture:weakPicture fromImageData:weakData];
    [self saveResizedImageFile:[@"resized_" stringByAppendingString:fileName] forPicture:weakPicture fromImageData:weakData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadPicture" object:weakPicture];
    });
    
}

+ (void)setThumbnailForPicture:(STMPicture *)picture fromImageData:(NSData *)data {
    
    UIImage *imageThumbnail = [STMFunctions resizeImage:[UIImage imageWithData:data] toSize:CGSizeMake(150, 150)];
    NSData *thumbnail = UIImageJPEGRepresentation(imageThumbnail, [self jpgQuality]);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        picture.imageThumbnail = thumbnail;
    });

}

+ (void)saveImageFile:(NSString *)fileName forPicture:(STMPicture *)picture fromImageData:(NSData *)data {
    
    UIImage *image = [UIImage imageWithData:data];
    CGFloat maxDimension = MAX(image.size.height, image.size.width);
    
    if (maxDimension > MAX_PICTURE_SIZE) {
        
        image = [STMFunctions resizeImage:image toSize:CGSizeMake(MAX_PICTURE_SIZE, MAX_PICTURE_SIZE) allowRetina:NO];
        data = UIImageJPEGRepresentation(image, [self jpgQuality]);

    }
    
    NSString *imagePath = [STMFunctions absolutePathForPath:fileName];
    [data writeToFile:imagePath atomically:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        picture.imagePath = fileName;
    });

}

+ (void)saveResizedImageFile:(NSString *)resizedFileName forPicture:(STMPicture *)picture fromImageData:(NSData *)data {

    NSString *resizedImagePath = [STMFunctions absolutePathForPath:resizedFileName];
    
    UIImage *resizedImage = [STMFunctions resizeImage:[UIImage imageWithData:data] toSize:CGSizeMake(1024, 1024) allowRetina:NO];
    NSData *resizedImageData = nil;
    resizedImageData = UIImageJPEGRepresentation(resizedImage, [self jpgQuality]);
    [resizedImageData writeToFile:resizedImagePath atomically:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        picture.resizedImagePath = resizedFileName;
    });

}

- (void)addOperationForObject:(NSManagedObject *)object {
    
    NSString *href = [object valueForKey:@"href"];
    
//    if ([self.secondAttempt containsObject:href]) {
        //        NSLog(@"second attempt for %@", href);
//    }
    
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
                
//                NSLog(@"%@ load successefully", href);
                
                [self.hrefDictionary removeObjectForKey:href];

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
        
        NSString *xid = [STMFunctions UUIDStringFromUUIDData:picture.xid];
        NSString *fileName = [xid stringByAppendingString:@".jpg"];
        
        NSData *data = [NSData dataWithContentsOfFile:[STMFunctions absolutePathForPath:picture.imagePath]];

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
                
                [AWSS3 registerS3WithConfiguration:[AWSServiceManager defaultServiceManager].defaultServiceConfiguration  forKey: @"EUWest1S3"];
                AWSS3 *transferManager = [AWSS3 S3ForKey:@"EUWest1S3"];
                
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
                            
                            __block STMSession *session = [STMSessionManager sharedManager].currentSession;
                            
                            [session.document saveDocument:^(BOOL success) {
                                if (success) [session.syncer setSyncerState:STMSyncerSendDataOnce];
                            }];
                            
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

//    NSLog(@"delete picture %@", picture);
    
    [self removeImageFilesForPicture:picture];
    
    [STMObjectsController removeObject:picture];

    [[self document] saveDocument:^(BOOL success) {
        
    }];
    
}

+ (void)removeImageFilesForPicture:(STMPicture *)picture {
    
    if (picture.imagePath) [self removeImageFile:picture.imagePath];
    if (picture.resizedImagePath) [self removeImageFile:picture.resizedImagePath];
    
}

+ (void)removeImageFile:(NSString *)filePath {
    
    NSString *imagePath = [STMFunctions absolutePathForPath:filePath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:imagePath isDirectory:nil]) {

        NSError *error;
        BOOL success = [fileManager removeItemAtPath:imagePath error:&error];
        
        if (success) {
            
            NSLog(@"file %@ was successefully removed", [filePath lastPathComponent]);
            
        } else {
            
            NSLog(@"removeItemAtPath error: %@ ",[error localizedDescription]);
            
        }

    }
    
}


@end
