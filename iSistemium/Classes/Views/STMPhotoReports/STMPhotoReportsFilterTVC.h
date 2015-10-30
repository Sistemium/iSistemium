//
//  STMPhotoReportsFilterTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 28/10/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"
#import "STMDataModel.h"


@interface STMPhotoReportsFilterTVC : STMVariableCellsHeightTVC

@property (nonatomic, weak) STMCampaignGroup *selectedCampaignGroup;

- (void)photoReportGroupingChanged;


@end
