//
//  STMCampaignGroup.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 27/10/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMComment.h"

@class STMCampaign;

NS_ASSUME_NONNULL_BEGIN

@interface STMCampaignGroup : STMComment

- (NSString *)displayName;


@end

NS_ASSUME_NONNULL_END

#import "STMCampaignGroup+CoreDataProperties.h"
