//
//  STMCampaignController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 30/04/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMController+category.h"

@interface STMCampaignController : STMController

+ (BOOL)hasUnreadPicturesInCampaign:(STMCampaign *)campaign;

+ (NSUInteger)numberOfUnreadCampaign;

@end
