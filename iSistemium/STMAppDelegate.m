//
//  STMAppDelegate.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 01/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMAppDelegate.h"

#import "STMAuthController.h"
#import "STMRemoteController.h"
#import "STMMessageController.h"

#import "STMSessionManager.h"
#import "STMLogger.h"

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

- (void)receiveRemoteNotification:(NSDictionary *)remoteNotification {
    
    NSString *msg = [NSString stringWithFormat:@"%@", remoteNotification[@"aps"][@"alert"]];
    NSString *logMessage = [NSString stringWithFormat:@"didReceiveRemoteNotification: %@", msg];
    [[STMLogger sharedLogger] saveLogMessageWithText:logMessage type:nil];
    
    id <STMSession> session = [STMSessionManager sharedManager].currentSession;
    
    if ([[session status] isEqualToString:@"running"]) {
        
        [[session syncer] setSyncerState:STMSyncerSendData];
        
    }
    
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

- (void)applicationWillResignActive:(UIApplication *)application {
    
    NSString *logMessage = [NSString stringWithFormat:@"applicationWillResignActive"];
    [[STMLogger sharedLogger] saveLogMessageWithText:logMessage type:nil];
    
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
    [[STMLogger sharedLogger] saveLogMessageWithText:logMessage type:nil];
    
//    [self showLocalNotification];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    NSString *logMessage = [NSString stringWithFormat:@"applicationWillEnterForeground"];
    [[STMLogger sharedLogger] saveLogMessageWithText:logMessage type:nil];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    NSString *logMessage = [NSString stringWithFormat:@"applicationDidBecomeActive"];
    [[STMLogger sharedLogger] saveLogMessageWithText:logMessage type:nil];

    [self setupWindow];

    id <STMSession> session = [STMSessionManager sharedManager].currentSession;
    if ([[session status] isEqualToString:@"running"]) {
        [STMMessageController showMessageVCsIfNeeded];
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    NSString *logMessage = [NSString stringWithFormat:@"applicationWillTerminate"];
    NSLog(logMessage);
    [[STMLogger sharedLogger] saveLogMessageDictionary:@{@"text": logMessage, @"type": @"error"}];
    
    [self sendAppTerminateLocalNotification];
    
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

    [self routeNotificationUserInfo:userInfo];

//    [self showLocalNotification];

}

- (void)routeNotificationUserInfo:(NSDictionary *)userInfo {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    UIApplication *app = [UIApplication sharedApplication];

    BOOL meaningfulUserInfo = NO;
    
    if (userInfo[@"remoteCommands"]) {
        
        [STMRemoteController receiveRemoteCommands:userInfo[@"remoteCommands"]];
        meaningfulUserInfo = YES;
        
    }

    if (userInfo[@"syncer"]) {
        
        [nc postNotificationName:@"syncerDidReceiveRemoteNotification" object:app userInfo:userInfo];
        meaningfulUserInfo = YES;
        
    }
    
    if (userInfo[@"requestInfo"]) {
        
        [nc postNotificationName:@"loggerDidReceiveRemoteNotification" object:app userInfo:userInfo];
        meaningfulUserInfo = YES;
        
    }
    
    if (!meaningfulUserInfo) {
        
        [nc postNotificationName:@"applicationDidReceiveRemoteNotification" object:app userInfo:userInfo];
        
    }

}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSString *logMessage = [NSString stringWithFormat:@"applicationPerformFetchWithCompletionHandler"];
    [[STMLogger sharedLogger] saveLogMessageWithText:logMessage type:nil];
    
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

- (void)setupWindow {
    
    if (!self.window) {
        
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.rootViewController = [STMRootTBC sharedRootVC];
        [self.window makeKeyAndVisible];
        
    }

}

- (void)showLocalNotification {
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = NSLocalizedString(@"APP TERMINATE", nil);;
    localNotification.soundName = UILocalNotificationDefaultSoundName;

    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];

}

- (void)sendAppTerminateLocalNotification {

    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = NSLocalizedString(@"APP TERMINATE", nil);
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];

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
