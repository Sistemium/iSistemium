//
//  STMPhotosController+category.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/04/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMPhotosController+category.h"

#import "STMDataModel.h"


@implementation STMPhotosController (category)

- (void)addPhotoReportToWaitingLocation:(STMPhotoReport *)photoReport {

    [self.waitingLocationPhotos addObject:photoReport];
    [[self locationTracker] getLocation];

}

- (void)photoReportWasDeleted:(STMPhotoReport *)photoReport {
    [self.waitingLocationPhotos removeObject:photoReport];
}


@end
