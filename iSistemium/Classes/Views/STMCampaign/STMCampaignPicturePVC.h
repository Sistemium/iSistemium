//
//  STMCampaignPicturePVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 23/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMCampaign.h"

@interface STMCampaignPicturePVC : UIPageViewController

@property (nonatomic, strong) STMCampaign *campaign;
@property (nonatomic) NSUInteger currentIndex;


@end
