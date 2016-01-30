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

#import <objc/runtime.h>

#import <Security/Security.h>
#import "KeychainItemWrapper.h"

@interface STMPicturesController() <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSOperationQueue *uploadQueue;
@property (nonatomic, strong) NSMutableDictionary *hrefDictionary;
@property (nonatomic, strong) NSMutableArray *secondAttempt;
@property (nonatomic, strong) STMSession *session;
@property (nonatomic, strong) NSMutableDictionary *settings;

@property (nonatomic, strong) NSFetchedResultsController *nonloadedPicturesResultsController;


@end

@implementation STMPicturesController


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
//        [self performFetch];
        
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
        
        self.downloadQueue.suspended = YES;
        [self.downloadQueue cancelAllOperations];
        self.downloadQueue = nil;

        self.uploadQueue.suspended = YES;
        [self.uploadQueue cancelAllOperations];
        self.uploadQueue = nil;
        
        self.hrefDictionary = nil;
        self.secondAttempt = nil;
        self.session = nil;
        self.settings = nil;
        self.nonloadedPicturesResultsController = nil;
        
    }
    
}

- (STMSession *)session {
    return [STMSessionManager sharedManager].currentSession;
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
        _downloadQueue.maxConcurrentOperationCount = 1;
        _downloadQueue.suspended = YES;
        
    }
    return _downloadQueue;
    
}

- (NSOperationQueue *)uploadQueue {
    
    if (!_uploadQueue) {
        _uploadQueue = [[NSOperationQueue alloc] init];
    }
    return _uploadQueue;
    
}

- (NSFetchedResultsController *)nonloadedPicturesResultsController {
    
    if (!_nonloadedPicturesResultsController) {
        
        NSManagedObjectContext *context = self.session.document.managedObjectContext;
        
        if (context && [self.session.status isEqualToString:@"running"]) {
            
            STMFetchRequest *request = [[STMFetchRequest alloc] initWithEntityName:NSStringFromClass([STMPicture class])];
            
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(href != %@) AND (imageThumbnail == %@)", nil, nil];
            
            request.sortDescriptors = @[sortDescriptor];
            request.predicate = [STMPredicate predicateWithNoFantomsFromPredicate:predicate];
            
            _nonloadedPicturesResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                                     managedObjectContext:context
                                                                                       sectionNameKeyPath:nil
                                                                                                cacheName:nil];
            _nonloadedPicturesResultsController.delegate = self;
            
            [_nonloadedPicturesResultsController performFetch:nil];

        } else {
            
            _nonloadedPicturesResultsController = nil;
            
        }
        
    }
    return _nonloadedPicturesResultsController;
    
}

//- (void)performFetch {
//    
//    NSError *error;
//    if (![self.nonloadedPicturesResultsController performFetch:&error]) {
//        NSLog(@"unloadedPicturesResultsController fetch error: ", error.localizedDescription);
//    }
//
//}

- (NSArray *)photoEntitiesNames {
    
    return @[NSStringFromClass([STMPhotoReport class]),
             NSStringFromClass([STMUncashingPicture class])];

}

- (NSArray *)instantLoadPicturesEntityNames {
    return @[NSStringFromClass([STMMessagePicture class])];
}

- (NSArray *)nonloadedPictures {
    
    NSArray *predicateArray = [[self photoEntitiesNames] arrayByAddingObjectsFromArray:[self instantLoadPicturesEntityNames]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (entity.name IN %@)", predicateArray];
    return [self.nonloadedPicturesResultsController.fetchedObjects filteredArrayUsingPredicate:predicate];
    
}

- (NSUInteger)nonloadedPicturesCount {
    
    NSUInteger nonloadedPicturesCount = [self nonloadedPictures].count;
    
    if (nonloadedPicturesCount == 0) {

        [self.session.document saveDocument:^(BOOL success) {
            
        }];
        
        self.downloadQueue.suspended = YES;
    
    }
    
    return nonloadedPicturesCount;
    
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"nonloadedPicturesCountDidChange" object:self];
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
    
    if (sessionUID) {
        
        NSString *keyToCheck = [@"picturePathsDidCheckedAlready_" stringByAppendingString:sessionUID];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        BOOL picturePathsDidCheckedAlready = [[defaults objectForKey:keyToCheck] boolValue];
        
        if (!picturePathsDidCheckedAlready) {
            
            [self startCheckingPicturesPaths];
            
            [defaults setObject:@YES forKey:keyToCheck];
            [defaults synchronize];
            
        }

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

            if ([fileManager fileExistsAtPath:(NSString * _Nonnull)picture.resizedImagePath]) {
                [fileManager removeItemAtPath:(NSString * _Nonnull)picture.resizedImagePath error:nil];
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
            
            if (photoData && photoData.length > 0) {
                
                [self setImagesFromData:photoData forPicture:picture andUpload:NO];
                
            } else {
                
                NSString *logMessage = [NSString stringWithFormat:@"attempt to set images for picture %@, photoData %@, length %lu", picture, photoData, (unsigned long)photoData.length];
                [[STMLogger sharedLogger] saveLogMessageWithText:logMessage type:@"error"];
                
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
        
        if (!picture.objectID.temporaryID) {
            
            NSData *photoData = [NSData dataWithContentsOfFile:[STMFunctions absolutePathForPath:picture.imagePath]];
            
            if (photoData && photoData.length > 0) {
                
                [[self sharedController] addUploadOperationForPicture:picture data:photoData];
                
            } else {
                
                NSString *logMessage = [NSString stringWithFormat:@"attempt to upload picture %@, photoData %@, length %lu — object will be deleted", picture, photoData, (unsigned long)photoData.length];
                [[STMLogger sharedLogger] saveLogMessageWithText:logMessage type:@"error"];
                [self deletePicture:picture];
                
            }

        }
        
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

//+ (void)setImagesFromData:(NSData *)data forPicture:(STMPicture *)picture {
//    [self setImagesFromData:data forPicture:picture andUpload:NO];
//}

+ (void)setImagesFromData:(NSData *)data forPicture:(STMPicture *)picture andUpload:(BOOL)shouldUpload {
    
    NSData *weakData = data;
    STMPicture *weakPicture = picture;
    
    NSString *xid = [STMFunctions UUIDStringFromUUIDData:picture.xid];
    NSString *fileName = [xid stringByAppendingString:@".jpg"];

//    NSString *fileName = nil;
    
    if ([picture isKindOfClass:[STMPhoto class]]) {
        
//        NSString *xid = [STMFunctions UUIDStringFromUUIDData:picture.xid];
//        fileName = [xid stringByAppendingString:@".jpg"];
        
        if (shouldUpload) {
            [[self sharedController] addUploadOperationForPicture:picture data:weakData];
        }

    } else if ([picture isKindOfClass:[STMPicture class]]) {
        
//        fileName = [[NSURL URLWithString:picture.href] lastPathComponent];

// https://github.com/Sistemium/iSistemium/issues/323
//#warning - have to use xid for filename like STMPhoto class

    }
    
//#warning should check filename is not nil
////https://crashlytics.com/sistemium2/ios/apps/com.sistemium.isistemium/issues/5572b38ef505b5ccf00d93eb
    
    if (fileName) {
        
        [self saveImageFile:fileName forPicture:weakPicture fromImageData:weakData];
        [self saveResizedImageFile:[@"resized_" stringByAppendingString:fileName] forPicture:weakPicture fromImageData:weakData];
        [self setThumbnailForPicture:weakPicture fromImageData:weakData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadPicture" object:weakPicture];
            //        NSLog(@"images set for %@", weakPicture.href);
            
        });

    } else {
        
        CLS_LOG(@"nil filename for picture %@", picture);
        
    }
    
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

+ (void)setThumbnailForPicture:(STMPicture *)picture fromImageData:(NSData *)data {
    
    UIImage *imageThumbnail = [STMFunctions resizeImage:[UIImage imageWithData:data] toSize:CGSizeMake(150, 150)];
    NSData *thumbnail = UIImageJPEGRepresentation(imageThumbnail, [self jpgQuality]);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        picture.imageThumbnail = thumbnail;
    });
    
}

- (void)addOperationForObject:(NSManagedObject *)object {
    
    if ([[self instantLoadPicturesEntityNames] containsObject:NSStringFromClass([object class])]) {
        
        [self downloadConnectionForObject:object];
        
    } else {
    
        __weak NSManagedObject *weakObject = object;

        [self.downloadQueue addOperationWithBlock:^{
            [self downloadConnectionForObject:weakObject];
        }];

    }
    
}

+ (void)downloadConnectionForObject:(NSManagedObject *)object {
    [[self sharedController] downloadConnectionForObject:object];
}

- (void)downloadConnectionForObject:(NSManagedObject *)object {
    
    NSString *href = [object valueForKey:@"href"];

    if (href) {
        
        if ([object valueForKey:@"imageThumbnail"]) {
            
            [self.hrefDictionary removeObjectForKey:href];
            
        } else {
            
            NSURL *url = [NSURL URLWithString:href];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            NSURLResponse *response = nil;
            NSError *error = nil;
            
            //        NSLog(@"start loading %@", url.lastPathComponent);
            
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            if (error) {
                
                if (error.code == -1001) {
                    
                    NSLog(@"error code -1001 timeout for %@", href);
                    
                    if ([self.secondAttempt containsObject:href]) {
                        
                        NSLog(@"second load attempt fault for %@", href);
                        
                        [self.secondAttempt removeObject:href];
                        [self.hrefDictionary removeObjectForKey:href];
                        
                    } else {
                        
                        [self.secondAttempt addObject:href];
                        
#warning Is it really need to dispath_async & addOperationForObject here? secondAttempt?
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self performSelector:@selector(addOperationForObject:) withObject:object afterDelay:0];
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
                
                if ([object isKindOfClass:[STMPicture class]]) {
                    [[self class] setImagesFromData:dataCopy forPicture:(STMPicture *)object andUpload:NO];
                }
                
            }
            
        }
        
    }
    
}

- (void)repeatUploadOperationForObject:(NSManagedObject *)object {
    
    if ([object isKindOfClass:[STMPicture class]]) {
        
        STMPicture *picture = (STMPicture *)object;
        
        NSData *data = [NSData dataWithContentsOfFile:[STMFunctions absolutePathForPath:picture.imagePath]];

        [self addUploadOperationForPicture:picture data:data];
        
    }
    
}

- (void)addUploadOperationForPicture:(STMPicture *)picture data:(NSData *)data {
    
    NSDictionary *appSettings = [self.session.settingsController currentSettingsForGroup:@"appSettings"];
    NSString *url = [[appSettings valueForKey:@"IMS.url"] stringByAppendingString:@"?folder="];
    
    NSString *entityName = picture.entity.name;
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy";
    NSString *year = [dateFormatter stringFromDate:currentDate];
    dateFormatter.dateFormat = @"MM";
    NSString *month = [dateFormatter stringFromDate:currentDate];
    dateFormatter.dateFormat = @"dd";
    NSString *day = [dateFormatter stringFromDate:currentDate];
    
    NSURL *imsURL = [NSURL URLWithString:[url stringByAppendingString:[NSString stringWithFormat:@"%@/%@/%@/%@", entityName, year, month, day]]];
    
    NSMutableURLRequest *request = [[[STMAuthController authController] authenticateRequest:[NSURLRequest requestWithURL:imsURL]] mutableCopy];
    [request setHTTPMethod:@"POST"];
    [request setValue: @"image/jpeg" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:data];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (!error) {
            
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            
            if (statusCode == 200){
                
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                NSData *picturesJson = [NSJSONSerialization dataWithJSONObject: (NSDictionary * _Nonnull) dictionary[@"pictures"] options:0 error: &error];
                
                if (!error) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        for (NSDictionary *dict in dictionary[@"pictures"]){
                            if ([dict[@"name"] isEqual:@"original"]){
                                picture.href = dict[@"src"];
                            }
                        }
                        
                        NSString *info = [[NSString alloc] initWithData:picturesJson encoding:NSUTF8StringEncoding];
                        picture.picturesInfo = [info stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
                        
                        NSLog(picture.picturesInfo)
                        
                        __block STMSession *session = [STMSessionManager sharedManager].currentSession;
                        
                        [session.document saveDocument:^(BOOL success) {
                        }];
                        
                    });
                    
                }
                
            } else {
                
                NSLog(@"Request error, statusCode: %d", statusCode);
                
            }
            
        } else {
            
            NSLog(@"connectionError %@", error.localizedDescription);
            
        }
        
    }];
    
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
