//
//  STMPhotoReportsSVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/10/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMSplitViewController.h"

#import "STMCampaignGroupTVC.h"
#import "STMPhotoReportsDetailTVC.h"

#import "STMDataModel.h"
#import "STMNS.h"
#import "STMUI.h"
#import "STMFunctions.h"


@interface STMPhotoReportsSVC : STMSplitViewController

@property (nonatomic, strong) STMCampaignGroupTVC *masterVC;
@property (nonatomic, strong) STMPhotoReportsDetailTVC *detailVC;


@end
