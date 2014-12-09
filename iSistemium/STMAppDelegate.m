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
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
        (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    if (launchOptions != nil) {
        
        NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        
        if (remoteNotification) {

            [self receiveRemoteNotification:remoteNotification];
            
        }

    }

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [STMRootTBC sharedRootVC];
    [self.window makeKeyAndVisible];

    return YES;
    
}

- (void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    NSLog(@"didReceiveLocalNotification: %@", notification);
    
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
    
	NSLog(@"deviceToken: %@", deviceToken);
    
    [self recieveDeviceToken:deviceToken];

}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
    
	NSLog(@"Failed to register with error : %@", error);
    
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

//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//
//    [self receiveRemoteNotification:userInfo];
//
//}

- (void)receiveRemoteNotification:(NSDictionary *)remoteNotification {
    
    NSString *msg = [NSString stringWithFormat:@"%@", [[remoteNotification objectForKey:@"aps"] objectForKey:@"alert"]];
    NSString *logMessage = [NSString stringWithFormat:@"didReceiveRemoteNotification: %@", msg];
    [[[STMSessionManager sharedManager].currentSession logger] saveLogMessageWithText:logMessage type:nil];
    
    id <STMSession> session = [STMSessionManager sharedManager].currentSession;
    
    if ([[session status] isEqualToString:@"running"]) {
        
        [[session syncer] setSyncerState:STMSyncerSendData];

    }
    
}

/*
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSLog(@"didReceiveRemoteNotification");
    
    application.applicationIconBadgeNumber = 0;
    NSString *msg = [NSString stringWithFormat:@"%@", userInfo];

    NSString *logMessage = [NSString stringWithFormat:@"recieve notification: %@", msg];
    [[[STMSessionManager sharedManager].currentSession logger] saveLogMessageWithText:logMessage type:nil];

    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = nil;
    localNotification.alertAction = @"TEST";
    localNotification.alertBody = @"ALERT!";
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    
    completionHandler(UIBackgroundFetchResultNewData);
    
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSLog(@"performFetchWithCompletionHandler");
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = nil;
    localNotification.timeZone = nil;
    localNotification.alertAction = @"TEST";
    localNotification.alertBody = @"ALERT!";
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];

    completionHandler(UIBackgroundFetchResultNewData);
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {

    [self createAlert:notification.alertBody];
    
}

- (void)createAlert:(NSString *)msg {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message Received" message:[NSString stringWithFormat:@"%@", msg]delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
}
*/

							
- (void)applicationWillResignActive:(UIApplication *)application {
    
    NSString *logMessage = [NSString stringWithFormat:@"applicationWillResignActive"];
    [[[STMSessionManager sharedManager].currentSession logger] saveLogMessageWithText:logMessage type:nil];
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    NSString *logMessage = [NSString stringWithFormat:@"applicationDidEnterBackground"];
    [[[STMSessionManager sharedManager].currentSession logger] saveLogMessageWithText:logMessage type:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationDidEnterBackground" object:application];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    NSString *logMessage = [NSString stringWithFormat:@"applicationWillEnterForeground"];
    [[[STMSessionManager sharedManager].currentSession logger] saveLogMessageWithText:logMessage type:nil];
    [[[STMSessionManager sharedManager].currentSession syncer] setSyncerState:STMSyncerSendData];
    
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
    
    if ([userInfo objectForKey: @"locationTracker"]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"locationTrackerDidReceiveRemoteNotification" object:application userInfo: [userInfo objectForKey: @"locationTracker"]];
        
        handler (UIBackgroundFetchResultNoData);
        
    } else {
    
        id <STMSession> session = [STMSessionManager sharedManager].currentSession;
        
        if ([[session status] isEqualToString:@"running"]) {
            
            [[session syncer] setSyncerState:STMSyncerSendData fetchCompletionHandler: handler];
            
        }
        
    }

}


@end
