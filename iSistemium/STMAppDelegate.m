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

#import "STMAuthNC.h"

@implementation STMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [STMAuthController authController];
    
    [self registerForNotification];
    
    if (launchOptions != nil) {
        
        NSDictionary *remoteNotification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        
        if (remoteNotification) {

            [self receiveRemoteNotification:remoteNotification];
            
        }

    }

    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    return YES;
    
}

- (void)registerForNotification {
    
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if (systemVersion >= 8.0) {
        
        UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    } else if (systemVersion >= 3.0 && systemVersion < 8.0) {
        
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        
    }

}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    NSLog(@"didReceiveLocalNotification: %@", notification);
    
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
//    NSLog(@"didRegisterUserNotificationSettings: %@", notificationSettings);
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
    
	NSLog(@"deviceToken: %@", deviceToken);
    self.deviceTokenError = @"";
    [self recieveDeviceToken:deviceToken];

}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
    
	NSLog(@"Failed to register with error: %@", error);
    self.deviceTokenError = error.localizedDescription;
    [self recieveDeviceToken:nil];
    
}

- (void)recieveDeviceToken:(NSData *)deviceToken {

    self.deviceToken = deviceToken;
    
}

- (void)receiveRemoteNotification:(NSDictionary *)remoteNotification {
    
    NSString *msg = [NSString stringWithFormat:@"%@", remoteNotification[@"aps"][@"alert"]];
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
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    NSString *logMessage = [NSString stringWithFormat:@"applicationWillEnterForeground"];
    [[[STMSessionManager sharedManager].currentSession logger] saveLogMessageWithText:logMessage type:nil];
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    NSString *logMessage = [NSString stringWithFormat:@"applicationDidBecomeActive"];
    [[[STMSessionManager sharedManager].currentSession logger] saveLogMessageWithText:logMessage type:nil];
    
    if (!self.window) {

        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.rootViewController = [STMRootTBC sharedRootVC];
//        self.window.rootViewController = [STMAuthNC sharedAuthNC];
        [self.window makeKeyAndVisible];

    }
    
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
    
    if (userInfo[@"syncer"]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"syncerDidReceiveRemoteNotification" object:application userInfo:userInfo];

    } else {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationDidReceiveRemoteNotification" object:application userInfo: userInfo];
        
    }

//    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//    localNotification.alertBody = @"localNotification";
//    localNotification.soundName = UILocalNotificationDefaultSoundName;
//    
//    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];

}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSString *logMessage = [NSString stringWithFormat:@"applicationPerformFetchWithCompletionHandler"];
    [[[STMSessionManager sharedManager].currentSession logger] saveLogMessageWithText:logMessage type:nil];
    
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

- (NSString *)currentNotificationTypes {
    
    NSMutableArray *typesArray = [NSMutableArray array];
    
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if (systemVersion >= 8.0) {

        UIUserNotificationSettings *settings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        UIUserNotificationType types = settings.types;

        if (types & UIUserNotificationTypeAlert) {
            [typesArray addObject:@"alert"];
        }
        if (types & UIUserNotificationTypeBadge) {
            [typesArray addObject:@"badge"];
        }
        if (types & UIUserNotificationTypeSound) {
            [typesArray addObject:@"sound"];
        }
        if (types == UIUserNotificationTypeNone) {
            [typesArray addObject:@"none"];
        }

    } else if (systemVersion >= 3.0 && systemVersion < 8.0) {

        UIRemoteNotificationType types = [UIApplication sharedApplication].enabledRemoteNotificationTypes;
        
        if (types & UIRemoteNotificationTypeAlert) {
            [typesArray addObject:@"alert"];
        }
        if (types & UIRemoteNotificationTypeBadge) {
            [typesArray addObject:@"badge"];
        }
        if (types & UIRemoteNotificationTypeSound) {
            [typesArray addObject:@"sound"];
        }
        if (types & UIRemoteNotificationTypeNewsstandContentAvailability) {
            [typesArray addObject:@"newsstandContentAvailability"];
        }
        if (types == UIRemoteNotificationTypeNone) {
            [typesArray addObject:@"none"];
        }
        
    }
    
    return [typesArray componentsJoinedByString:@", "];
    
}


#pragma mark - variables setters&getters

@synthesize deviceToken = _deviceToken;
@synthesize deviceTokenError = _deviceTokenError;

- (NSData *)deviceToken {

    if (!_deviceToken) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _deviceToken = [defaults objectForKey:@"deviceToken"];

    }
    
    return _deviceToken;

}

- (void)setDeviceToken:(NSData *)deviceToken {
    
    if (_deviceToken != deviceToken) {
        
        _deviceToken = deviceToken;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:deviceToken forKey:@"deviceToken"];
        [defaults synchronize];

    }
    
}

- (NSString *)deviceTokenError {
    
    if (!_deviceTokenError) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _deviceTokenError = [defaults objectForKey:@"deviceTokenError"];

    }

    return _deviceTokenError;
    
}

- (void)setDeviceTokenError:(NSString *)deviceTokenError {
    
    if (_deviceTokenError != deviceTokenError) {

        _deviceTokenError = deviceTokenError;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:deviceTokenError forKey:@"deviceTokenError"];
        [defaults synchronize];
        
    }
    
}

@end
