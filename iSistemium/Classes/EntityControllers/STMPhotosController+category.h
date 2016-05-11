//
//  STMPhotosController+category.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/04/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMPhotosController.h"

#import "STMController.h"


@interface STMPhotosController (category)

- (void)addPhotoReportToWaitingLocation:(STMPhotoReport *)photoReport;
- (void)photoReportWasDeleted:(STMPhotoReport *)photoReport;


@end
