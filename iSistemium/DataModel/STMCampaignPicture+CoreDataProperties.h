//
//  STMCampaignPicture+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMCampaignPicture.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMCampaignPicture (CoreDataProperties)

@property (nullable, nonatomic, retain) NSSet<STMCampaign *> *campaigns;

@end

@interface STMCampaignPicture (CoreDataGeneratedAccessors)

- (void)addCampaignsObject:(STMCampaign *)value;
- (void)removeCampaignsObject:(STMCampaign *)value;
- (void)addCampaigns:(NSSet<STMCampaign *> *)values;
- (void)removeCampaigns:(NSSet<STMCampaign *> *)values;

@end

NS_ASSUME_NONNULL_END
