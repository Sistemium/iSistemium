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

+ (STMPicturesController *)sharedController;

- (NSUInteger)unloadedPicturesCount;

+ (CGFloat)jpgQuality;

+ (void)checkPhotos;
+ (void)checkUploadedPhotos;

+ (void)hrefProcessingForObject:(NSManagedObject *)object;
+ (void)setImagesFromData:(NSData *)data forPicture:(STMPicture *)picture;
+ (void)saveImageFile:(NSString *)fileName forPicture:(STMPicture *)picture fromImageData:(NSData *)data;

+ (void)removeImageFilesForPicture:(STMPicture *)picture;

@end
