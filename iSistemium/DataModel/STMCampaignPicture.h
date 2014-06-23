//
//  STMCampaignPicture.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 22/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMPicture.h"

@class STMCampaign;

@interface STMCampaignPicture : STMPicture

@property (nonatomic, retain) NSSet *campaigns;
@end

@interface STMCampaignPicture (CoreDataGeneratedAccessors)

- (void)addCampaignsObject:(STMCampaign *)value;
- (void)removeCampaignsObject:(STMCampaign *)value;
- (void)addCampaigns:(NSSet *)values;
- (void)removeCampaigns:(NSSet *)values;

@end
