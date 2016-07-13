//
//  STMAppDelegate.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 01/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMAppDelegate.h"

#import "STMAuthController.h"
#import "STMSessionManager.h"
#import "STMRootTBC.h"


@implementation STMAppDelegate

- (void)startAuthController {
    [STMAuthController authController];
}

- (STMCoreSessionManager *)sessionManager {
    return [STMSessionManager sharedManager];
}

- (void)setupWindow {
    
    if (!self.window) {
        
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.rootViewController = [STMRootTBC sharedRootVC];
        [self.window makeKeyAndVisible];
        
    }

}


#pragma mark - Crashlytics

- (void)startCrashlytics {
    
//    [[Crashlytics sharedInstance] setDebugMode:YES];
    
    [Fabric with:@[CrashlyticsKit]];
    
    [[Crashlytics sharedInstance] setObjectValue:[[UIDevice currentDevice] name] forKey:@"deviceName"];
    [[Crashlytics sharedInstance] setObjectValue:[STMFunctions devicePlatform] forKey:@"devicePlatform"];
    [[Crashlytics sharedInstance] setObjectValue:[ASIdentifierManager sharedManager].advertisingIdentifier forKey:@"advertisingIdentifier"];
    [[Crashlytics sharedInstance] setObjectValue:[STMAuthController authController].userID forKey:@"userID"];
    [[Crashlytics sharedInstance] setObjectValue:[STMAuthController authController].userName forKey:@"userName"];
    [[Crashlytics sharedInstance] setObjectValue:[STMAuthController authController].phoneNumber forKey:@"phoneNumber"];
    
}


@end
