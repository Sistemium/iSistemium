//
//  STMCampaignGroup.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 27/10/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMCampaignGroup.h"
#import "STMCampaign.h"

@implementation STMCampaignGroup

- (NSString *)displayName {
    return (self.name) ? (NSString * _Nonnull)self.name : @"";
}


@end
