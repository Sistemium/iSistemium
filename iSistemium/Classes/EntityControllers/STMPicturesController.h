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

+ (void)removeImageFilesForPicture:(STMPicture *)picture;

@end
