//
//  STMPhotoReportsDetailTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 29/10/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMFetchedResultsControllerTVC.h"

#import "STMDataModel.h"

#import "STMPhotoReportsFilterTVC.h"


typedef NS_ENUM(NSUInteger, STMPhotoReportGrouping) {
    STMPhotoReportGroupingCampaign,
    STMPhotoReportGroupingOutlet
};


@interface STMPhotoReportsDetailTVC : STMFetchedResultsControllerTVC

@property (nonatomic, weak) STMCampaignGroup *selectedCampaignGroup;
@property (nonatomic, weak) STMOutlet *selectedOutlet;
@property (nonatomic, weak) STMCampaign *selectedCampaign;

@property (nonatomic, strong) STMOutlet *selectedOutletForPhotoReport;
@property (nonatomic, strong) STMCampaign *selectedCampaignForPhotoReport;

@property (nonatomic) STMPhotoReportGrouping currentGrouping;
@property (nonatomic, weak) STMPhotoReportsFilterTVC *filterTVC;

- (void)deletePhotoReport:(STMPhotoReport *)photoReport;


@end
