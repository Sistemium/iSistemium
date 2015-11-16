//
//  STMPicturesController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 29/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMController.h"
#import "STMPicture.h"

@interface STMPicturesController : STMController

@property (nonatomic, strong) NSOperationQueue *downloadQueue;

+ (STMPicturesController *)sharedController;

- (NSUInteger)nonloadedPicturesCount;

+ (CGFloat)jpgQuality;

+ (void)checkPhotos;
+ (void)checkUploadedPhotos;

+ (void)hrefProcessingForObject:(NSManagedObject *)object;
+ (void)downloadConnectionForObject:(NSManagedObject *)object;

//+ (void)setImagesFromData:(NSData *)data forPicture:(STMPicture *)picture;
+ (void)setImagesFromData:(NSData *)data forPicture:(STMPicture *)picture andUpload:(BOOL)shouldUpload;
+ (void)saveImageFile:(NSString *)fileName forPicture:(STMPicture *)picture fromImageData:(NSData *)data;

+ (void)removeImageFilesForPicture:(STMPicture *)picture;


@end
