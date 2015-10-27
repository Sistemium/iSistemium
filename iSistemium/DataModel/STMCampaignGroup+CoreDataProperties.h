//
//  STMCampaignGroup+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 27/10/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMCampaignGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMCampaignGroup (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *ord;
@property (nullable, nonatomic, retain) NSSet<STMCampaign *> *campaign;

@end

@interface STMCampaignGroup (CoreDataGeneratedAccessors)

- (void)addCampaignObject:(STMCampaign *)value;
- (void)removeCampaignObject:(STMCampaign *)value;
- (void)addCampaign:(NSSet<STMCampaign *> *)values;
- (void)removeCampaign:(NSSet<STMCampaign *> *)values;

@end

NS_ASSUME_NONNULL_END
