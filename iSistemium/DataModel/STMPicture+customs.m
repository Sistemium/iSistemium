//
//  STMPicture+customs.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 29/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMPicture+customs.h"

#import "STMPicturesController.h"
#import "STMPhotosController.h"


@implementation STMPicture (customs)

- (void)willSave {
    
    if (self.isDeleted) {
        
        if ([self isKindOfClass:[STMPhotoReport class]]) {
            [[STMPhotosController sharedController] photoReportWasDeleted:(STMPhotoReport *)self];
        }
        
        [STMPicturesController removeImageFilesForPicture:self];
        
    }
    
    [super willSave];
    
}


@end
