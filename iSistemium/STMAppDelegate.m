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

#import "STMAuthController.h"
#import "STMRemoteController.h"
#import "STMMessageController.h"

#import "STMSessionManager.h"
#import "STMLogger.h"

#import "STMRootTBC.h"

#import "STMAuthNC.h"

#import "STMSocketController.h"
#import "STMSoundController.h"
#import "STMClientDataController.h"

#import <AVFoundation/AVFoundation.h>


@implementation STMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self startCrashlytics];

    NSLog(@"deviceUUID %@", [STMClientDataController deviceUUIDString]);
    
//    STMLogger *logger = [STMLogger sharedLogger];
//    
//    NSString *logMessage = [NSString stringWithFormat:@"application didFinishLaunchingWithOptions: %@", launchOptions.description];
//    [logger saveLogMessageWithText:logMessage
//                           numType:STMLogMessageTypeImportant];

    [STMAuthController authController];
    
    [self registerForNotification];
    
    if (launchOptions != nil) {
        
        NSDictionary *remoteNotification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        
        if (remoteNotification) {

            [self receiveRemoteNotification:remoteNotification];
            
        }

    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(statusChanged)
               name:NOTIFICATION_SESSION_STATUS_CHANGED
             object:[STMSessionManager sharedManager].currentSession];
    
    [STMSoundController initAudioSession];

    [self setupWindow];

    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    return YES;
    
}

- (void)statusChanged {
    
    if ([STMSessionManager sharedManager].currentSession.status == STMSessionRunning) {
        [STMGarbageCollector searchUnusedImages];
    }
    
}

- (void)receiveRemoteNotification:(NSDictionary *)remoteNotification {
    
    NSString *msg = [NSString stringWithFormat:@"%@", remoteNotification[@"aps"][@"alert"]];
    NSString *logMessage = [NSString stringWithFormat:@"didReceiveRemoteNotification: %@", msg];
    [[STMLogger sharedLogger] saveLogMessageWithText:logMessage type:nil];
    
    id <STMSession> session = [STMSessionManager sharedManager].currentSession;
    
    if (session.status == STMSessionRunning) {
        
        [[session syncer] setSyncerState:STMSyncerSendData];
        
    }
    
}

- (void)registerForNotification {

    if (SYSTEM_VERSION >= 8.0) {
        
        UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    }

}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    NSLog(@"didReceiveLocalNotification: %@", notification);
    
//    if ([notification.userInfo.allKeys containsObject:RINGING_LOCAL_NOTIFICATION]) {
//        
//        NSString *soundName = notification.userInfo[RINGING_LOCAL_NOTIFICATION];
//        [STMSoundController ringingLocalNotificationWithMessage:nil andSoundName:soundName];
//        
//    }
    
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


#pragma mark - app state changes

- (void)applicationWillResignActive:(UIApplication *)application {
    
    NSString *logMessage = [NSString stringWithFormat:@"applicationWillResignActive"];
//    [[STMLogger sharedLogger] saveLogMessageWithText:logMessage
//                                             numType:STMLogMessageTypeInfo];
    
    [STMSocketController sendEvent:STMSocketEventStatusChange
                         withValue:logMessage];
    
    [STMSoundController startBackgroundPlay];

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    __block UIBackgroundTaskIdentifier bgTask;
    
    bgTask = [application beginBackgroundTaskWithExpirationHandler: ^{
        [self backgroundTask:bgTask endedInApplication:application];
    }];
    
    [self backgroundTask:bgTask startedInApplication:application];
    
    NSString *logMessage = [NSString stringWithFormat:@"applicationDidEnterBackground"];
    [[STMLogger sharedLogger] saveLogMessageWithText:logMessage
                                             numType:STMLogMessageTypeInfo];
    
    [STMSocketController sendEvent:STMSocketEventStatusChange
                         withValue:logMessage];

//    [self showTestLocalNotification];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    NSString *logMessage = [NSString stringWithFormat:@"applicationWillEnterForeground"];
//    [[STMLogger sharedLogger] saveLogMessageWithText:logMessage
//                                             numType:STMLogMessageTypeInfo];
    
    [STMSocketController sendEvent:STMSocketEventStatusChange
                         withValue:logMessage];

    logMessage = @"cancel scheduled socket close if have one";
    [[STMLogger sharedLogger] saveLogMessageWithText:logMessage
                                             numType:STMLogMessageTypeInfo];

    [STMSocketController cancelPreviousPerformRequestsWithTarget:[STMSocketController sharedInstance]
                                                        selector:@selector(closeSocketInBackground)
                                                          object:nil];
    [STMSocketController checkSocket];

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    NSString *logMessage = [NSString stringWithFormat:@"applicationDidBecomeActive"];
    [[STMLogger sharedLogger] saveLogMessageWithText:logMessage
                                             numType:STMLogMessageTypeInfo];

    [self setupWindow];

    id <STMSession> session = [STMSessionManager sharedManager].currentSession;
    if (session.status == STMSessionRunning) {
        [STMMessageController showMessageVCsIfNeeded];
    }
    
    [STMSocketController sendEvent:STMSocketEventStatusChange
                         withValue:logMessage];

    [STMSoundController stopBackgroundPlay];

}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    
    [[STMLogger sharedLogger] saveLogMessageWithText:@"applicationDidReceiveMemoryWarning"
                                             numType:STMLogMessageTypeImportant];
    [STMFunctions logMemoryStat];
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    [[STMUserDefaults standardUserDefaults] synchronize];
    
    [[STMLogger sharedLogger] saveLogMessageWithText:@"applicationWillTerminate"
                                             numType:STMLogMessageTypeError];
    
    [self sendAppTerminateLocalNotification];
    
}


#pragma mark - app fetching

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler {
    
    NSLog(@"application didReceiveRemoteNotification userInfo: %@", userInfo);
    
    __block UIBackgroundTaskIdentifier bgTask;
    
    __block BOOL handlerCompleted = NO;
    
    bgTask = [application beginBackgroundTaskWithExpirationHandler: ^{
        
        [self backgroundTask:bgTask endedInApplication:application];

        if (!handlerCompleted) {
            
            NSString *methodName = [NSString stringWithFormat:@"%@ in beginBackgroundTaskWithExpirationHandler:", NSStringFromSelector(_cmd)];
            [self tryCatchFetchResultHandler:handler
                                  withResult:UIBackgroundFetchResultFailed
                                  methodName:methodName];
            
        }
        
    }];
    
    [self backgroundTask:bgTask startedInApplication:application];

    [self routeNotificationUserInfo:userInfo completionHandler:^(UIBackgroundFetchResult result) {
        
        handlerCompleted = YES;

        NSString *methodName = [NSString stringWithFormat:@"%@ in routeNotificationUserInfo:completionHandler:", NSStringFromSelector(_cmd)];
        [self tryCatchFetchResultHandler:handler
                              withResult:result
                              methodName:methodName];
        
    }];

//    [self showTestLocalNotification];

}


#pragma mark - backgrounds

- (void)backgroundTask:(UIBackgroundTaskIdentifier)bgTask startedInApplication:(UIApplication *)application {
    
    STMLogger *logger = [STMLogger sharedLogger];
    
    NSString *logMessage = [NSString stringWithFormat:@"startBackgroundTaskWithExpirationHandler %d", (unsigned int) bgTask];
    [logger saveLogMessageWithText:logMessage];
    
    NSTimeInterval timeRemaining = application.backgroundTimeRemaining;
    
    logMessage = [NSString stringWithFormat:@"BackgroundTimeRemaining %@", @(timeRemaining)];
    [logger saveLogMessageWithText:logMessage];
    
    if (timeRemaining < DBL_MAX / 10) {
        
        timeRemaining -= 10; // is 10 sec enough for closing socket?
        
        NSTimeInterval delayInterval = timeRemaining >= 0 ? timeRemaining : 0;
        
        logMessage = [NSString stringWithFormat:@"socket will be closed in %@ sec due to background condition", @(timeRemaining)];
        [logger saveLogMessageWithText:logMessage
                               numType:STMLogMessageTypeInfo];
        
        [[STMSocketController sharedInstance] performSelector:@selector(closeSocketInBackground)
                                                   withObject:nil
                                                   afterDelay:delayInterval];
        
    }
    
}

- (void)backgroundTask:(UIBackgroundTaskIdentifier)bgTask endedInApplication:(UIApplication *)application {
    
    STMLogger *logger = [STMLogger sharedLogger];
    
    NSString *logMessage = [NSString stringWithFormat:@"endBackgroundTaskWithExpirationHandler %d", (unsigned int) bgTask];
    [logger saveLogMessageWithText:logMessage];
    
    [application endBackgroundTask:bgTask];
    bgTask = UIBackgroundTaskInvalid;
    
}


#pragma mark -

- (void)routeNotificationUserInfo:(NSDictionary *)userInfo completionHandler:(void (^)(UIBackgroundFetchResult result))handler {
    
    __block BOOL handlerCompleted = NO;

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

            [[STMSessionManager sharedManager].currentSession.syncer setSyncerState:STMSyncerSendDataOnce
                                                             fetchCompletionHandler:^(UIBackgroundFetchResult result) {
                
                if (!handlerCompleted) {
                    
                    handlerCompleted = YES;
                    
                    NSString *methodName = [NSString stringWithFormat:@"%@ in setSyncerState:fetchCompletionHandler:1", NSStringFromSelector(_cmd)];
                    [self tryCatchFetchResultHandler:handler
                                          withResult:result
                                          methodName:methodName];
                    
                }
                
            }];

        }

        meaningfulUserInfo = YES;
        
    }
        
    if (!meaningfulUserInfo) {
        
        [nc postNotificationName:@"applicationDidReceiveRemoteNotification" object:app userInfo:userInfo];

        [[STMSessionManager sharedManager].currentSession.syncer setSyncerState:STMSyncerSendData fetchCompletionHandler:^(UIBackgroundFetchResult result) {
            
            if (!handlerCompleted) {
                
                handlerCompleted = YES;

                NSString *methodName = [NSString stringWithFormat:@"%@ in setSyncerState:fetchCompletionHandler:2", NSStringFromSelector(_cmd)];
                [self tryCatchFetchResultHandler:handler
                                      withResult:result
                                      methodName:methodName];

            }
            
        }];

    }

}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSString *logMessage = [NSString stringWithFormat:@"applicationPerformFetchWithCompletionHandler"];
    [[STMLogger sharedLogger] saveLogMessageWithText:logMessage type:nil];
    
    __block UIBackgroundTaskIdentifier bgTask;
    
    bgTask = [application beginBackgroundTaskWithExpirationHandler: ^{
        
        [self backgroundTask:bgTask endedInApplication:application];
        
        NSString *methodName = [NSString stringWithFormat:@"%@ in beginBackgroundTaskWithExpirationHandler:", NSStringFromSelector(_cmd)];
        [self tryCatchFetchResultHandler:completionHandler
                              withResult:UIBackgroundFetchResultFailed
                              methodName:methodName];
        
    }];

    [self backgroundTask:bgTask startedInApplication:application];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationPerformFetchWithCompletionHandler"
                                                        object:application];
    
    if ([STMSocketController socketIsAvailable]) {
        
        [[[STMSessionManager sharedManager].currentSession syncer] setSyncerState:STMSyncerSendData
                                                           fetchCompletionHandler:completionHandler];
        
    } else {
        
        [STMSocketController checkSocket];
        
    }

}

- (void)tryCatchFetchResultHandler:(void (^)(UIBackgroundFetchResult result))handler withResult:(UIBackgroundFetchResult)result methodName:(NSString *)methodName {
    
    NSLogMethodName;
    
    @try {
        
        handler(result);
        
    } @catch (NSException *exception) {
        
        NSString *logMessage = [NSString stringWithFormat:@"tryCatchFetchResultHandler\n%@\nException: %@\nStack trace: %@", methodName, exception.description, exception.callStackSymbols];
        [[STMLogger sharedLogger] saveLogMessageWithText:logMessage numType:STMLogMessageTypeError];
        
    }

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

    if (SYSTEM_VERSION >= 8.0) {

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

    }
    
    return [typesArray componentsJoinedByString:@", "];
    
}


#pragma mark - variables setters&getters

@synthesize deviceToken = _deviceToken;
@synthesize deviceTokenError = _deviceTokenError;

- (NSData *)deviceToken {

    if (!_deviceToken) {
        
        STMUserDefaults *defaults = [STMUserDefaults standardUserDefaults];
        _deviceToken = [defaults objectForKey:@"deviceToken"];

    }
    
    return _deviceToken;

}

- (void)setDeviceToken:(NSData *)deviceToken {
    
    if (_deviceToken != deviceToken) {
        
        _deviceToken = deviceToken;
        
        STMUserDefaults *defaults = [STMUserDefaults standardUserDefaults];
        [defaults setObject:deviceToken forKey:@"deviceToken"];
        [defaults synchronize];
        
        [[Crashlytics sharedInstance] setObjectValue:deviceToken forKey:@"deviceToken"];

    }
    
}

- (NSString *)deviceTokenError {
    
    if (!_deviceTokenError) {
        
        STMUserDefaults *defaults = [STMUserDefaults standardUserDefaults];
        _deviceTokenError = [defaults objectForKey:@"deviceTokenError"];

    }

    return _deviceTokenError;
    
}

- (void)setDeviceTokenError:(NSString *)deviceTokenError {
    
    if (_deviceTokenError != deviceTokenError) {

        _deviceTokenError = deviceTokenError;
        
        STMUserDefaults *defaults = [STMUserDefaults standardUserDefaults];
        [defaults setObject:deviceTokenError forKey:@"deviceTokenError"];
        [defaults synchronize];
        
    }
    
}


#pragma mark - Crashlytics

- (void)startCrashlytics {
    
//    [[Crashlytics sharedInstance] setDebugMode:YES];
    
    [Fabric with:@[CrashlyticsKit]];
    
    [[Crashlytics sharedInstance] setObjectValue:[[UIDevice currentDevice] name]
                                          forKey:@"deviceName"];
    [[Crashlytics sharedInstance] setObjectValue:[STMFunctions devicePlatform]
                                          forKey:@"devicePlatform"];
    [[Crashlytics sharedInstance] setObjectValue:[STMClientDataController deviceUUIDString]
                                          forKey:@"deviceUUID"];
    [[Crashlytics sharedInstance] setObjectValue:[STMAuthController authController].userID
                                          forKey:@"userID"];
    [[Crashlytics sharedInstance] setObjectValue:[STMAuthController authController].userName
                                          forKey:@"userName"];
    [[Crashlytics sharedInstance] setObjectValue:[STMAuthController authController].phoneNumber
                                          forKey:@"phoneNumber"];
    
}

- (void)testCrash {
    [[Crashlytics sharedInstance] crash];
}

@end
