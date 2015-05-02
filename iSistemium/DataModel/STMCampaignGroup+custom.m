//
//  STMCampaignGroup+custom.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 30/04/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMCampaignGroup+custom.h"

@implementation STMCampaignGroup (custom)

- (NSString *)displayName {

    return (self.name) ? self.name : @"";
    
}

@end
