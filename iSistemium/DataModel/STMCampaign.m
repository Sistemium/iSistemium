//
//  STMCampaign.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 30/10/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMCampaign.h"
#import "STMArticle.h"
#import "STMCampaignGroup.h"
#import "STMCampaignPicture.h"
#import "STMOutlet.h"
#import "STMPhotoReport.h"

@implementation STMCampaign

- (BOOL)photoReportsArePresent {
    
    if (self.photoReports.count == 0) {
        
        return NO;
        
    } else {
        
        return YES;
        
    }
    
}


@end
