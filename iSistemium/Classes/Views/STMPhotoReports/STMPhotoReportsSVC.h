//
//  STMPhotoReportsSVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/10/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMSplitViewController.h"

#import "STMCampaignGroupTVC.h"
#import "STMPhotoReportsCVC.h"

#import "STMDataModel.h"
#import "STMNS.h"
#import "STMUI.h"


@interface STMPhotoReportsSVC : STMSplitViewController

@property (nonatomic, strong) STMCampaignGroupTVC *masterVC;
@property (nonatomic, strong) STMPhotoReportsCVC *detailVC;


@end
