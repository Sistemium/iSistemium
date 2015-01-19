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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
/* deprecated in iOS 8.0
    UIRemoteNotificationType types = [UIApplication sharedApplication].enabledRemoteNotificationTypes;
    
    if (types & UIRemoteNotificationTypeAlert) {
        NSLog(@"UIRemoteNotificationTypeAlert");
    }
    if (types & UIRemoteNotificationTypeBadge) {
        NSLog(@"UIRemoteNotificationTypeBadge");
    }
    if (types & UIRemoteNotificationTypeSound) {
        NSLog(@"UIRemoteNotificationTypeSound");
    }
    if (types & UIRemoteNotificationTypeNewsstandContentAvailability) {
        NSLog(@"UIRemoteNotificationTypeNewsstandContentAvailability");
    }
    if (types == UIRemoteNotificationTypeNone) {
        NSLog(@"UIRemoteNotificationTypeNone");
    }
*/
    
    [STMAuthController authController];
    
    [self registerForRemoteNotification];
    
    if (launchOptions != nil) {
        
        NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        
        if (remoteNotification) {

            [self receiveRemoteNotification:remoteNotification];
            
        }

    }

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [STMRootTBC sharedRootVC];
    [self.window makeKeyAndVisible];

    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    return YES;
    
}

- (void)registerForRemoteNotification {
    
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if (systemVersion >= 8.0) {
        
        UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        
    } else if (systemVersion >= 3.0 && systemVersion < 8.0) {
        
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        
    }

}


- (void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    NSLog(@"didReceiveLocalNotification: %@", notification);
    
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
    
	NSLog(@"deviceToken: %@", deviceToken);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"" forKey:@"deviceTokenError"];
    [defaults synchronize];

    [self recieveDeviceToken:deviceToken];

}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
    
	NSLog(@"Failed to register with error: %@", error);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:error.localizedDescription forKey:@"deviceTokenError"];
    [defaults synchronize];
    
    [self recieveDeviceToken:[NSData data]];
    
}

- (void)recieveDeviceToken:(NSData *)deviceToken {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *oldDeviceToken = [defaults objectForKey:@"deviceToken"];
    
    if (![deviceToken isEqualToData:oldDeviceToken]) {
        
        [defaults setObject:deviceToken forKey:@"deviceToken"];
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:@"clientDataWaitingForSync"];
        
    } else {

    }

    [defaults synchronize];

}

- (void)receiveRemoteNotification:(NSDictionary *)remoteNotification {
    
    NSString *msg = [NSString stringWithFormat:@"%@", [[remoteNotification objectForKey:@"aps"] objectForKey:@"alert"]];
    NSString *logMessage = [NSString stringWithFormat:@"didReceiveRemoteNotification: %@", msg];
    [[[STMSessionManager sharedManager].currentSession logger] saveLogMessageWithText:logMessage type:nil];
    
    id <STMSession> session = [STMSessionManager sharedManager].currentSession;
    
    if ([[session status] isEqualToString:@"running"]) {
        
        [[session syncer] setSyncerState:STMSyncerSendData];

    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    NSString *logMessage = [NSString stringWithFormat:@"applicationWillResignActive"];
    [[[STMSessionManager sharedManager].currentSession logger] saveLogMessageWithText:logMessage type:nil];
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    __block UIBackgroundTaskIdentifier bgTask;
    
    bgTask = [application beginBackgroundTaskWithExpirationHandler: ^{
        NSLog(@"endBackgroundTaskWithExpirationHandler %d", (unsigned int) bgTask);
        [application endBackgroundTask: bgTask];
    }];
    
    NSLog(@"startBackgroundTaskWithExpirationHandler %d", (unsigned int) bgTask);
    NSLog(@"BackgroundTimeRemaining %d", (unsigned int)[application backgroundTimeRemaining]);
    
    NSString *logMessage = [NSString stringWithFormat:@"applicationDidEnterBackground"];
    [[[STMSessionManager sharedManager].currentSession logger] saveLogMessageWithText:logMessage type:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationDidEnterBackground" object:application];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    NSString *logMessage = [NSString stringWithFormat:@"applicationWillEnterForeground"];
    [[[STMSessionManager sharedManager].currentSession logger] saveLogMessageWithText:logMessage type:nil];
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    NSString *logMessage = [NSString stringWithFormat:@"applicationDidBecomeActive"];
    [[[STMSessionManager sharedManager].currentSession logger] saveLogMessageWithText:logMessage type:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationDidBecomeActive" object:application];

}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    NSString *logMessage = [NSString stringWithFormat:@"applicationWillTerminate"];
    [[[STMSessionManager sharedManager].currentSession logger] saveLogMessageWithText:logMessage type:nil];

    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result)) handler {
    
    NSLog(@"application didReceiveRemoteNotification userInfo: %@", userInfo);
    
    __block UIBackgroundTaskIdentifier bgTask;
    
    bgTask = [application beginBackgroundTaskWithExpirationHandler: ^{
        NSLog(@"endBackgroundTaskWithExpirationHandler %d", (unsigned int) bgTask);
        [application endBackgroundTask: bgTask];
        handler (UIBackgroundFetchResultNewData);
    }];
    
    NSLog(@"startBackgroundTaskWithExpirationHandler %d", (unsigned int) bgTask);
    NSLog(@"BackgroundTimeRemaining %d", (unsigned int)[application backgroundTimeRemaining]);
    
    if ([userInfo objectForKey:@"syncer"]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"syncerDidReceiveRemoteNotification" object:application userInfo:userInfo];

    } else {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationDidReceiveRemoteNotification" object:application userInfo: userInfo];
        
    }

}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSString *logMessage = [NSString stringWithFormat:@"applicationPerformFetchWithCompletionHandler"];
    [[[STMSessionManager sharedManager].currentSession logger] saveLogMessageWithText:logMessage type:nil];

//    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//    localNotification.fireDate = nil;
//    localNotification.timeZone = nil;
//    localNotification.alertAction = @"TEST";
//    localNotification.alertBody = [NSString stringWithFormat:@"%@", [NSDate date]];
//    
//    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    
    __block UIBackgroundTaskIdentifier bgTask;
    
    bgTask = [application beginBackgroundTaskWithExpirationHandler: ^{
        NSLog(@"endBackgroundTaskWithExpirationHandler %d", (unsigned int) bgTask);
        [application endBackgroundTask: bgTask];
        completionHandler(UIBackgroundFetchResultNewData);
    }];
    
    NSLog(@"startBackgroundTaskWithExpirationHandler %d", (unsigned int) bgTask);
    NSLog(@"BackgroundTimeRemaining %d", (unsigned int)[application backgroundTimeRemaining]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationPerformFetchWithCompletionHandler" object:application];

}


@end
