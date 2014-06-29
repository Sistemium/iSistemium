//
//  STMCampaignDetailsPVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMCampaign.h"

@interface STMCampaignDetailsPVC : UIPageViewController <UISplitViewControllerDelegate>

@property (nonatomic, strong) STMCampaign *campaign;

@end
