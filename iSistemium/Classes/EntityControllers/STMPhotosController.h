//
//  STMPhotosController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 12/05/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMCorePhotosController.h"

#import "STMDataModel.h"


@interface STMPhotosController : STMCorePhotosController

- (void)addPhotoReportToWaitingLocation:(STMPhotoReport *)photoReport;
- (void)photoReportWasDeleted:(STMPhotoReport *)photoReport;


@end
