//
//  STMPhotosController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 12/05/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMPhotosController.h"

@implementation STMPhotosController

- (void)addPhotoReportToWaitingLocation:(STMPhotoReport *)photoReport {
    
    [self.waitingLocationPhotos addObject:photoReport];
    [[self locationTracker] getLocation];
    
}

- (void)photoReportWasDeleted:(STMPhotoReport *)photoReport {
    [self.waitingLocationPhotos removeObject:photoReport];
}


@end
