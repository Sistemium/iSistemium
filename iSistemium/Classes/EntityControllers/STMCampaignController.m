//
//  STMCampaignController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 30/04/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMCampaignController.h"
#import "STMRecordStatusController.h"
#import "STMObjectsController.h"


@implementation STMCampaignController

+ (BOOL)hasUnreadPicturesInCampaign:(STMCampaign *)campaign {
    
    BOOL result = NO;
    
    for (STMCampaignPicture *picture in campaign.pictures) {
        
        STMRecordStatus *recordStatus = [STMRecordStatusController existingRecordStatusForXid:picture.xid];
        
        if (![recordStatus.isRead boolValue]) {
            
            result = YES;
            break;
            
        }
        
    }
    
    return result;

}

+ (NSUInteger)numberOfUnreadCampaign {
    
    NSUInteger result = 0;
    
    NSArray *campaigns = [STMObjectsController objectsForEntityName:NSStringFromClass([STMCampaign class])];
    NSPredicate *notFantomPredicate = [STMPredicate predicateWithNoFantoms];
    campaigns = [campaigns filteredArrayUsingPredicate:notFantomPredicate];
    
    for (STMCampaign *campaign in campaigns) {
        
        if ([self hasUnreadPicturesInCampaign:campaign]) result++;
        
    }
    
    return result;
    
}


@end
