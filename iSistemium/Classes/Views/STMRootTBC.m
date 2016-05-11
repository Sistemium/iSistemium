//
//  STMRootTBC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/04/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMRootTBC.h"

#import "STMMessageController.h"
#import "STMCampaignController.h"


@implementation STMRootTBC

- (void)initAllTabs {

    [super initAllTabs];
    
    [self showUnreadCampaignCount];
    
}

- (void)showUnreadCampaignCount {

    UIViewController *vc = (self.tabs)[@"STMCampaigns"];

    if (vc) {

        NSUInteger unreadCount = [STMCampaignController numberOfUnreadCampaign];
        NSString *badgeValue = unreadCount == 0 ? nil : [NSString stringWithFormat:@"%lu", (unsigned long)unreadCount];
        vc.tabBarItem.badgeValue = badgeValue;
//        [UIApplication sharedApplication].applicationIconBadgeNumber = [badgeValue integerValue];

    }

}

- (void)setDocumentReady {
    
    [super setDocumentReady];
    
    [STMMessageController showMessageVCsIfNeeded];
    
}

- (void)addObservers {
    
    [super addObservers];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(showUnreadCampaignCount)
               name:@"readCampaignsCountIsChanged"
             object:nil];
    
    //    [nc addObserver:self
    //           selector:@selector(showUnreadCampaignCount)
    //               name:@"gotNewCampaignPicture"
    //             object:nil];
    
    //    [nc addObserver:self
    //           selector:@selector(showUnreadCampaignCount)
    //               name:@"gotNewCampaign"
    //             object:nil];
    
    //    [nc addObserver:self
    //           selector:@selector(showUnreadCampaignCount)
    //               name:@"campaignPictureIsRead"
    //             object:nil];

}


@end
