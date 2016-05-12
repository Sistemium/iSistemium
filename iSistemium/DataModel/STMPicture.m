//
//  STMPicture.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 12/05/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMPicture.h"

#import "STMPhotoReport.h"
#import "STMPhotosController.h"


@implementation STMPicture

- (void)checkPictureClass {
    
    if ([self isKindOfClass:[STMPhotoReport class]]) {
        [[STMPhotosController sharedController] photoReportWasDeleted:(STMPhotoReport *)self];
    }
    
}


@end
