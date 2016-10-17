//
//  STMSocketController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 10/10/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "iSistemium-Swift.h"
@import SocketIO;



typedef NS_ENUM(NSInteger, STMSocketEvent) {
    STMSocketEventConnect,
    STMSocketEventDisconnect,
    STMSocketEventError,
    STMSocketEventReconnect,
    STMSocketEventReconnectAttempt,
    STMSocketEventStatusChange,
    STMSocketEventInfo,
    STMSocketEventAuthorization,
    STMSocketEventRemoteCommands,
    STMSocketEventData
};


@interface STMSocketController : NSObject

+ (STMSocketController *)sharedInstance;

+ (void)checkSocket;
+ (void)startSocket;
+ (void)closeSocket;

+ (void)reloadResultsControllers;

+ (NSArray *)unsyncedObjects;
+ (NSUInteger)numbersOfUnsyncedObjects;

+ (void)sendEvent:(STMSocketEvent)event withValue:(id)value;
+ (void)sendUnsyncedObjects:(id)sender;

+ (SocketIOClientStatus)currentSocketStatus;
+ (BOOL)socketIsAvailable;
+ (BOOL)isSendingData;

+ (NSDate *)deviceTsForSyncedObjectXid:(NSData *)xid;
+ (void)successfullySyncObjectWithXid:(NSData *)xid;


- (void)closeSocketInBackground;


@end
