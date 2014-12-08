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

@end

@implementation STMSession

+(STMSession *)initWithUID:(NSString *)uid authDelegate:(id<STMRequestAuthenticatable>)authDelegate trackers:(NSArray *)trackers startSettings:(NSDictionary *)startSettings documentPrefix:(NSString *)prefix {
    
    if (uid) {
        
        STMSession *session = [[STMSession alloc] init];
        session.status = @"starting";
        session.uid = uid;
        session.startSettings = startSettings;
        session.authDelegate = authDelegate;
        session.settingsController = [STMSettingsController initWithSettings:startSettings];
        session.trackers = [NSMutableDictionary dictionary];
        session.syncer = [[STMSyncer alloc] init];

        if ([trackers containsObject:@"location"]) {
            
            session.locationTracker = [[STMLocationTracker alloc] init];
            [session.trackers setObject:session.locationTracker forKey:session.locationTracker.group];

        }
        
        if ([trackers containsObject:@"battery"]) {
            
            session.batteryTracker = [[STMBatteryTracker alloc] init];
            [session.trackers setObject:session.batteryTracker forKey:session.batteryTracker.group];

        }
        
        [session addObservers];

        NSString *dataModelName = [startSettings valueForKey:@"dataModelName"];
        
        if (!dataModelName) {
            dataModelName = @"STMDataModel";
        }

        session.document = [STMDocument documentWithUID:session.uid dataModelName:dataModelName prefix:prefix];

        return session;
        
    } else {
        
        NSLog(@"no uid");
        return nil;
        
    }

}

- (void)stopSession {
    
    self.status = [self.status isEqualToString:@"removing"] ? self.status : @"finishing";

    if (self.document.documentState == UIDocumentStateNormal) {
        
        [self.document saveDocument:^(BOOL success) {
            
            if (success) {
                self.status = [self.status isEqualToString:@"removing"] ? self.status : @"stopped";
                [self.manager sessionStopped:self];
            } else {
                NSLog(@"Can not stop session with uid %@", self.uid);
            }
            
        }];
        
    }
    
}

- (void)dismissSession {
    
    if ([self.status isEqualToString:@"stopped"]) {
        
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentReady:) name:@"documentReady" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentNotReady:) name:@"documentNotReady" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsLoadComplete) name:@"settingsLoadComplete" object:self.settingsController];
    if (self.locationTracker) {
        [[NSNotificationCenter defaultCenter] addObserver:self.locationTracker selector:@selector(didReceiveRemoteNotification:) name:@"locationTrackerDidReceiveRemoteNotification" object: nil];
    }

}

- (void)removeObservers {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"documentReady" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"documentNotReady" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"settingsLoadComplete" object:self.settingsController];

}

- (void)documentReady:(NSNotification *)notification {
    
    if ([[notification.userInfo valueForKey:@"uid"] isEqualToString:self.uid]) {
        
        self.logger = [[STMLogger alloc] init];
        self.logger.session = self;
        self.settingsController.session = self;

//        [self.logger saveLogMessageWithText:[NSString stringWithFormat:@"document ready: %@", notification.object] type:nil];
        [self.logger saveLogMessageWithText:@"document ready" type:@"blue"];

    }
    
}

- (void)documentNotReady:(NSNotification *)notification {
    
    if ([[notification.userInfo valueForKey:@"uid"] isEqualToString:self.uid]) {
        NSLog(@"document not ready");
    }
    
}

- (void)settingsLoadComplete {
    
//    NSLog(@"currentSettings %@", [self.settingsController currentSettings]);
    self.locationTracker.session = self;
    self.batteryTracker.session = self;
    self.syncer.session = self;
    self.syncer.authDelegate = self.authDelegate;
    self.status = @"running";
    
}


- (void)setAuthDelegate:(id<STMRequestAuthenticatable>)authDelegate {
    
    if (_authDelegate != authDelegate) {
        _authDelegate = authDelegate;
    }
    
}

- (void)setStatus:(NSString *)status {
    
    if (_status != status) {
        
        _status = status;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionStatusChanged" object:self];
        [self.logger saveLogMessageWithText:[NSString stringWithFormat:@"Session status changed to %@", self.status] type:nil];
        
    }
    
}



@end
