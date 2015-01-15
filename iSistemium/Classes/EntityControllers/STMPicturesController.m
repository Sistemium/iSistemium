//
//  STMPicturesController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 29/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMPicturesController.h"


@implementation STMPicturesController

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

@end
