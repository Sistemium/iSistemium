//
//  STMSessionManagement.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 3/24/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMRequestAuthenticatable.h"


typedef enum {
    STMSyncerIdle,
    STMSyncerSendData,
    STMSyncerReceiveData
} STMSyncerState;


@protocol STMLogger <NSObject, UITableViewDataSource, UITableViewDelegate>

- (void)saveLogMessageWithText:(NSString *)text type:(NSString *)type;

@property (nonatomic, weak) UITableView *tableView;

@end


@protocol STMSyncer <NSObject>

@property (nonatomic) STMSyncerState syncerState;

@end


@protocol STMSettingsController <NSObject>

- (NSArray *)currentSettings;
- (NSMutableDictionary *)currentSettingsForGroup:(NSString *)group;
- (NSString *)setNewSettings:(NSDictionary *)newSettings forGroup:(NSString *)group;

@end


@protocol STMSession <NSObject>

+ (id <STMSession>)initWithUID:(NSString *)uid authDelegate:(id <STMRequestAuthenticatable>)authDelegate trackers:(NSArray *)trackers startSettings:(NSDictionary *)startSettings documentPrefix:(NSString *)prefix;

@property (nonatomic, strong) UIManagedDocument *document;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) id <STMSettingsController> settingsController;
@property (nonatomic, strong) NSDictionary *settingsControls;
@property (nonatomic, strong) NSDictionary *defaultSettings;
@property (nonatomic, strong) id <STMLogger> logger;
@property (nonatomic, strong) id <STMSyncer> syncer;

@end


@protocol STMSessionManager <NSObject>

- (id <STMSession>)startSessionForUID:(NSString *)uid authDelegate:(id <STMRequestAuthenticatable>)authDelegate trackers:(NSArray *)trackers startSettings:(NSDictionary *)startSettings defaultSettingsFileName:(NSString *)defualtSettingsFileName documentPrefix:(NSString *)prefix;
- (void)stopSessionForUID:(NSString *)uid;
- (void)sessionStopped:(id)session;
- (void)cleanStoppedSessions;
- (void)removeSessionForUID:(NSString *)uid;

@end
