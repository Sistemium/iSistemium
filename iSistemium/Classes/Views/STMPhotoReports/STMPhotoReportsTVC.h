//
//  STMPhotoReportsTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 29/10/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMFetchedResultsControllerTVC.h"

#import "STMDataModel.h"


@interface STMPhotoReportsTVC : STMFetchedResultsControllerTVC

@property (nonatomic, weak) STMCampaignGroup *selectedCampaignGroup;
@property (nonatomic, weak) STMOutlet *selectedOutlet;


@end
