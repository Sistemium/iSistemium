//
//  STMCampaignGroup.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 04/02/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMCampaign;

@interface STMCampaignGroup : STMComment

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * ord;
@property (nonatomic, retain) NSSet *campaign;
@end

@interface STMCampaignGroup (CoreDataGeneratedAccessors)

- (void)addCampaignObject:(STMCampaign *)value;
- (void)removeCampaignObject:(STMCampaign *)value;
- (void)addCampaign:(NSSet *)values;
- (void)removeCampaign:(NSSet *)values;

@end
