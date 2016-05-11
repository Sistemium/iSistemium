//
//  STMSession.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 11/05/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMSession.h"

@implementation STMSession

- (void)checkTrackersToStart {
    
    if ([self.startTrackers containsObject:@"location"]) {
        
        self.locationTracker = [[STMCoreLocationTracker alloc] init];
        self.trackers[self.locationTracker.group] = self.locationTracker;
        
    }
    
    if ([self.startTrackers containsObject:@"battery"]) {
        
        self.batteryTracker = [[STMCoreBatteryTracker alloc] init];
        self.trackers[self.batteryTracker.group] = self.batteryTracker;
        
    }
    
}


@end
