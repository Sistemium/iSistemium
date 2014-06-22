//
//  STMSyncer.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 06/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMSessionManagement.h"
#import "STMRequestAuthenticatable.h"

@interface STMSyncer : NSObject <STMSyncer>

typedef enum {
    STMSyncerIdle,
    STMSyncerSendData,
    STMSyncerRecieveData
} STMSyncerState;

@property (nonatomic, strong) id <STMSession> session;
@property (nonatomic, strong) id <STMRequestAuthenticatable> authDelegate;
@property (nonatomic, strong) NSMutableDictionary *entitySyncInfo;
@property (nonatomic) STMSyncerState syncerState;

//- (void)syncData;
- (void)prepareToDestroy;
- (void)flushEntitySyncInfo;

@end
