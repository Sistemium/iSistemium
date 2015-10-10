//
//  STMAppDelegate.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 01/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMAppDelegate.h"

#import <AdSupport/AdSupport.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <AVFoundation/AVFoundation.h>

#import "STMAuthController.h"
#import "STMRemoteController.h"
#import "STMMessageController.h"

#import "STMSessionManager.h"
#import "STMLogger.h"

#import "STMRootTBC.h"

#import "STMAuthNC.h"

#import "STMWebSocketController.h"


@implementation STMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self startCrashlytics];

    NSString *logMessage = [NSString stringWithFormat:@"application didFinishLaunchingWithOptions"];
    [[STMLogger sharedLogger] saveLogMessageWithText:logMessage type:@"info"];

    [STMAuthController authController];
    
    [self registerForNotification];
    
    if (launchOptions != nil) {
        
        NSDictionary *remoteNotification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        
        if (remoteNotification) {

            [self receiveRemoteNotification:remoteNotification];
            
        }

    }
    
    [self setupWindow];

    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

//    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
//    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:@"Добро пожаловать в Sistemium!"];
//    utterance.rate = AVSpeechUtteranceMinimumSpeechRate;
//    [synthesizer speakUtterance:utterance];
    
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
    
    [STMWebSocketController sendData:logMessage];
    
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
    
    [STMWebSocketController sendData:logMessage];

//    [self showTestLocalNotification];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    NSString *logMessage = [NSString stringWithFormat:@"applicationWillEnterForeground"];
    [[STMLogger sharedLogger] saveLogMessageWithText:logMessage type:nil];
    
    [STMWebSocketController sendData:logMessage];

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    NSString *logMessage = [NSString stringWithFormat:@"applicationDidBecomeActive"];
    [[STMLogger sharedLogger] saveLogMessageWithText:logMessage type:nil];

    [self setupWindow];

    id <STMSession> session = [STMSessionManager sharedManager].currentSession;
    if ([[session status] isEqualToString:@"running"]) {
        [STMMessageController showMessageVCsIfNeeded];
    }
    
    [STMWebSocketController sendData:logMessage];

}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    
    [[STMLogger sharedLogger] saveLogMessageWithText:@"applicationDidReceiveMemoryWarning" type:@"important"];
    [STMFunctions logMemoryStat];
    
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
        handler(UIBackgroundFetchResultFailed);
        
    }];
    
    NSLog(@"startBackgroundTaskWithExpirationHandler %d", (unsigned int) bgTask);
    NSLog(@"BackgroundTimeRemaining %d", (unsigned int)[application backgroundTimeRemaining]);

    [self routeNotificationUserInfo:userInfo completionHandler:handler];

//    [self showTestLocalNotification];

}

- (void)routeNotificationUserInfo:(NSDictionary *)userInfo completionHandler:(void (^)(UIBackgroundFetchResult result)) handler {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    UIApplication *app = [UIApplication sharedApplication];

    BOOL meaningfulUserInfo = NO;
    
    if (userInfo[@"remoteCommands"]) {
        
        [STMRemoteController receiveRemoteCommands:userInfo[@"remoteCommands"]];
        meaningfulUserInfo = YES;
        
    }

    if (userInfo[@"syncer"]) {
        
//        [nc postNotificationName:@"syncerDidReceiveRemoteNotification" object:app userInfo:userInfo];

        if ([userInfo[@"syncer"] isEqualToString:@"upload"]) {
            [[[STMSessionManager sharedManager].currentSession syncer] setSyncerState:STMSyncerSendDataOnce fetchCompletionHandler:handler];
        }

        meaningfulUserInfo = YES;
        
    }
        
    if (!meaningfulUserInfo) {
        
        [nc postNotificationName:@"applicationDidReceiveRemoteNotification" object:app userInfo:userInfo];
        [[[STMSessionManager sharedManager].currentSession syncer] setSyncerState:STMSyncerSendData fetchCompletionHandler:handler];
        
    }

}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSString *logMessage = [NSString stringWithFormat:@"applicationPerformFetchWithCompletionHandler"];
    [[STMLogger sharedLogger] saveLogMessageWithText:logMessage type:nil];
    
    __block UIBackgroundTaskIdentifier bgTask;
    
    bgTask = [application beginBackgroundTaskWithExpirationHandler: ^{
        
        NSLog(@"endBackgroundTaskWithExpirationHandler %d", (unsigned int) bgTask);
        [application endBackgroundTask: bgTask];
        completionHandler(UIBackgroundFetchResultFailed);
        
    }];
    
    NSLog(@"startBackgroundTaskWithExpirationHandler %d", (unsigned int) bgTask);
    NSLog(@"BackgroundTimeRemaining %d", (unsigned int)[application backgroundTimeRemaining]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationPerformFetchWithCompletionHandler" object:application];
    
    [[[STMSessionManager sharedManager].currentSession syncer] setSyncerState:STMSyncerSendData fetchCompletionHandler:completionHandler];

}

- (void)setupWindow {
    
    if (!self.window) {
        
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.rootViewController = [STMRootTBC sharedRootVC];
        [self.window makeKeyAndVisible];
        
    }

}

- (void)showTestLocalNotification {
    
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
        
        [[Crashlytics sharedInstance] setObjectValue:deviceToken forKey:@"deviceToken"];

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

- (void)testCrash {
    [[Crashlytics sharedInstance] crash];
}

@end
