//
//  STMPicturesController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 29/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMPicture.h"

@interface STMPicturesController : NSObject

+ (void)removeImageFilesForPicture:(STMPicture *)picture;

@end
