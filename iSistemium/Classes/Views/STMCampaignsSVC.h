//
//  STMCampaignsSVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 22/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMCampaignsTVC.h"
#import "STMCampaignDetailsPVC.h"

@interface STMCampaignsSVC : UISplitViewController

@property (nonatomic, strong) STMCampaignDetailsPVC *detailVC;
@property (nonatomic, strong) STMCampaignsTVC *masterVC;

@end
