//
//  STMSession.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 06/05/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMSession.h"

@interface STMSession()

@property (nonatomic, strong) NSDictionary *startSettings;
@property (nonatomic, strong) NSArray *startTrackers;

@end

@implementation STMSession

+(STMSession *)initWithUID:(NSString *)uid iSisDB:(NSString *)iSisDB authDelegate:(id<STMRequestAuthenticatable>)authDelegate trackers:(NSArray *)trackers startSettings:(NSDictionary *)startSettings documentPrefix:(NSString *)prefix {
    
    if (uid) {
        
        STMSession *session = [[STMSession alloc] init];
        session.uid = uid;
        session.iSisDB = iSisDB;
        session.status = STMSessionStarting;
        session.startSettings = startSettings;
        session.authDelegate = authDelegate;
        session.startTrackers = trackers;
                
        [session addObservers];

        NSString *dataModelName = [startSettings valueForKey:@"dataModelName"];
        
        if (!dataModelName) {
            dataModelName = @"STMDataModel";
        }

        session.document = [STMDocument documentWithUID:session.uid
                                                 iSisDB:session.iSisDB
                                          dataModelName:dataModelName
                                                 prefix:prefix];

        return session;
        
    } else {
        
        NSLog(@"no uid");
        return nil;
        
    }

}

- (void)stopSession {
    
    self.status = (self.status == STMSessionRemoving) ? self.status : STMSessionFinishing;

    self.logger.session = nil;
    
    if (self.document.documentState == UIDocumentStateNormal) {
        
        [self.document saveDocument:^(BOOL success) {

            if (success) {
                self.status = (self.status == STMSessionRemoving) ? self.status : STMSessionStopped;
                [self.manager sessionStopped:self];
            } else {
                NSLog(@"Can not stop session with uid %@", self.uid);
            }

        }];
        
    }
    
}

- (void)dismissSession {
    
    if (self.status == STMSessionStopped) {
        
        [self removeObservers];
        
        if (self.document.documentState != UIDocumentStateClosed) {
            
            [self.document closeWithCompletionHandler:^(BOOL success) {
                
                if (success) {
                    
                    for (STMTracker *tracker in self.trackers.allValues) {
                        [tracker prepareToDestroy];
                    }
                    [self.syncer prepareToDestroy];
                    [self.document.managedObjectContext reset];
                    [self.manager removeSessionForUID:self.uid];
                    
                }
                
            }];
            
        }
        
    }
    
}


- (void)addObservers {

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(documentReady:)
               name:@"documentReady"
             object:nil];
    
    [nc addObserver:self
           selector:@selector(documentNotReady:)
               name:@"documentNotReady"
             object:nil];
    
    [nc addObserver:self
           selector:@selector(settingsLoadComplete:)
               name:@"settingsLoadComplete"
             object:self.settingsController];
    
    [nc addObserver:self
           selector:@selector(applicationDidEnterBackground)
               name:UIApplicationDidEnterBackgroundNotification
             object:nil];

}

- (void)removeObservers {

    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (void)documentReady:(NSNotification *)notification {
    
    if ([[notification.userInfo valueForKey:@"uid"] isEqualToString:self.uid]) {
    
        [[STMLogger sharedLogger] saveLogMessageWithText:@"document ready"];

        self.settingsController = [STMSettingsController initWithSettings:self.startSettings];
        self.trackers = [NSMutableDictionary dictionary];
        self.syncer = [[STMSyncer alloc] init];
        
        if ([self.startTrackers containsObject:@"location"]) {
            
            self.locationTracker = [[STMLocationTracker alloc] init];
            (self.trackers)[self.locationTracker.group] = self.locationTracker;
            
        }
        
        if ([self.startTrackers containsObject:@"battery"]) {
            
            self.batteryTracker = [[STMBatteryTracker alloc] init];
            (self.trackers)[self.batteryTracker.group] = self.batteryTracker;
            
        }
        
        self.logger = [STMLogger sharedLogger];
        self.logger.session = self;
        self.settingsController.session = self;

    }
    
}

- (void)documentNotReady:(NSNotification *)notification {
    
    if ([[notification.userInfo valueForKey:@"uid"] isEqualToString:self.uid]) {
        NSLog(@"document not ready");
    }
    
}

- (void)settingsLoadComplete:(NSNotification *)notification {
    
    if (notification.object == self.settingsController) {
    
        //    NSLog(@"currentSettings %@", [self.settingsController currentSettings]);
        self.locationTracker.session = self;
        self.batteryTracker.session = self;
        self.syncer.authDelegate = self.authDelegate;
        self.syncer.session = self;
        self.status = STMSessionRunning;

    }
    
}

- (void)applicationDidEnterBackground {
    
}

- (void)setAuthDelegate:(id<STMRequestAuthenticatable>)authDelegate {
    
    if (_authDelegate != authDelegate) {
        _authDelegate = authDelegate;
    }
    
}

- (void)setStatus:(STMSessionStatus)status {
    
    if (_status != status) {
        
        _status = status;
        
        NSString *statusString = nil;
        
        switch (_status) {
            case STMSessionIdle: {
                statusString = @"STMSessionIdle";
                break;
            }
            case STMSessionStarting: {
                statusString = @"STMSessionStarting";
                break;
            }
            case STMSessionRunning: {
                statusString = @"STMSessionRunning";
                break;
            }
            case STMSessionFinishing: {
                statusString = @"STMSessionFinishing";
                break;
            }
            case STMSessionStopped: {
                statusString = @"STMSessionStopped";
                break;
            }
            case STMSessionRemoving: {
                statusString = @"STMSessionRemoving";
                break;
            }
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SESSION_STATUS_CHANGED
                                                            object:self];
        
        NSString *logMessage = [NSString stringWithFormat:@"Session #%@ status changed to %@", self.uid, statusString];
        [[STMLogger sharedLogger] saveLogMessageWithText:logMessage];

    }
    
}


@end
