//
//  STMSession.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 11/05/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMSession.h"

#import "STMSettingsController.h"
#import "STMLocationTracker.h"
#import "STMDataModel.h"


@implementation STMSession

#pragma mark - properties classes definition (may override in subclasses)

- (Class)settingsControllerClass {
    return [STMSettingsController class];
}

- (Class)locationTrackerClass {
    return [STMLocationTracker class];
}

- (Class)locationClass {
    return [STMLocation class];
}


@end
