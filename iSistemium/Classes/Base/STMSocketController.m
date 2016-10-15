//
//  STMSocketController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 10/10/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMSocketController.h"
#import "STMAuthController.h"
#import "STMClientDataController.h"
#import "STMObjectsController.h"
#import "STMRemoteController.h"
#import "STMEntityController.h"

#import "STMSessionManager.h"

#import "STMRootTBC.h"

#import "STMFunctions.h"


#define SOCKET_URL @"https://socket.sistemium.com/socket.io-client"
#define CHECK_AUTHORIZATION_DELAY 15
#define CHECK_SENDING_TIME_INTERVAL 600


@interface STMSocketController() <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) SocketIOClient *socket;
@property (nonatomic, strong) NSString *socketUrl;

@property (nonatomic) BOOL isRunning;
@property (nonatomic) BOOL isAuthorized;
@property (nonatomic) BOOL isSendingData;
@property (nonatomic) BOOL isManualReconnecting;
@property (nonatomic) BOOL shouldSendData;
@property (nonatomic) BOOL controllersDidChangeContent;
@property (nonatomic) BOOL wasClosedInBackground;

@property (nonatomic, strong) NSMutableDictionary *syncDataDictionary;
@property (nonatomic, strong) NSMutableArray *resultsControllers;
@property (nonatomic, strong) NSDate *sendingDate;


@end


@implementation STMSocketController


#pragma mark - class methods

+ (STMSocketController *)sharedInstance {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
    
}

+ (NSString *)stringValueForEvent:(STMSocketEvent)event {
    
    switch (event) {
        case STMSocketEventConnect: {
            return @"connect";
            break;
        }
        case STMSocketEventDisconnect: {
            return @"disconnect";
            break;
        }
        case STMSocketEventError: {
            return @"error";
            break;
        }
        case STMSocketEventReconnect: {
            return @"reconnect";
            break;
        }
        case STMSocketEventReconnectAttempt: {
            return @"reconnectAttempt";
            break;
        }
        case STMSocketEventStatusChange: {
            return @"status:change";
            break;
        }
        case STMSocketEventInfo: {
            return @"info";
            break;
        }
        case STMSocketEventAuthorization: {
            return @"authorization";
            break;
        }
        case STMSocketEventRemoteCommands: {
            return @"remoteCommands";
            break;
        }
        case STMSocketEventData: {
            return @"data:v1";
            break;
        }
        default: {
            return nil;
            break;
        }
    }
    
}

+ (STMSocketEvent)eventForString:(NSString *)stringValue {
    
    if ([stringValue isEqualToString:@"connect"]) {
        return STMSocketEventConnect;
    } else if ([stringValue isEqualToString:@"disconnect"]) {
        return STMSocketEventDisconnect;
    } else if ([stringValue isEqualToString:@"error"]) {
        return STMSocketEventError;
    } else if ([stringValue isEqualToString:@"reconnect"]) {
        return STMSocketEventReconnect;
    } else if ([stringValue isEqualToString:@"reconnectAttempt"]) {
        return STMSocketEventReconnectAttempt;
    } else if ([stringValue isEqualToString:@"status:change"]) {
        return STMSocketEventStatusChange;
    } else if ([stringValue isEqualToString:@"info"]) {
        return STMSocketEventInfo;
    } else if ([stringValue isEqualToString:@"authorization"]) {
        return STMSocketEventAuthorization;
    } else if ([stringValue isEqualToString:@"remoteCommands"]) {
        return STMSocketEventRemoteCommands;
    } else if ([stringValue isEqualToString:@"data:v1"]) {
        return STMSocketEventData;
    } else {
        return STMSocketEventInfo;
    }
    
}

+ (STMSyncer *)syncer {
    return [[STMSessionManager sharedManager].currentSession syncer];
}

+ (STMDocument *)document {
    return [[STMSessionManager sharedManager].currentSession document];
}

+ (SocketIOClientStatus)currentSocketStatus {
    return [self sharedInstance].socket.status;
}

+ (BOOL)socketIsAvailable {
    return ([self currentSocketStatus] == SocketIOClientStatusConnected && [self sharedInstance].isAuthorized);
}

+ (BOOL)isSendingData {
    return [self sharedInstance].isSendingData;
}

+ (BOOL)isItCurrentSocket:(SocketIOClient *)socket failString:(NSString *)failString {
    
    STMSocketController *ssc = [STMSocketController sharedInstance];

    if ([socket isEqual:ssc.socket]) {
        
        return YES;
        
    } else {
        
        STMLogger *logger = [STMLogger sharedLogger];

        NSString *logMessage = [NSString stringWithFormat:@"socket %@ %@ %@, is not the current socket", socket, socket.sid, failString];
        [logger saveLogMessageWithText:logMessage
                               numType:STMLogMessageTypeError];
        
        logMessage = [NSString stringWithFormat:@"current socket %@ %@", ssc.socket, ssc.socket.sid];
        [logger saveLogMessageWithText:logMessage
                               numType:STMLogMessageTypeInfo];

        if (socket.status != SocketIOClientStatusDisconnected || socket.status != SocketIOClientStatusNotConnected) {
            
            logMessage = [NSString stringWithFormat:@"not current socket disconnect"];
            [logger saveLogMessageWithText:logMessage
                                   numType:STMLogMessageTypeInfo];

            [socket disconnect];
            
        } else {
            
            socket = nil;
            
        }
        
        return NO;

    }

}

+ (void)checkSocket {
    
    STMSocketController *sc = [self sharedInstance];
    
    if (sc.wasClosedInBackground) {
        
        sc.wasClosedInBackground = NO;
        [self startSocket];
        
    }
    
}

+ (void)startSocket {
    
    STMSocketController *sc = [self sharedInstance];
    
    STMLogger *logger = [STMLogger sharedLogger];

    NSString *logFormat = @"SocketController startSocket %@, sc.socketUrl %@, sc.isRunning %@, sc.isManualReconnecting %@, sc.socket.sid %@";
    
    NSString *logMessage = [NSString stringWithFormat:logFormat, sc.socket, sc.socketUrl, @(sc.isRunning), @(sc.isManualReconnecting), sc.socket.sid];
    
    [logger saveLogMessageWithText:logMessage
                           numType:STMLogMessageTypeInfo];

    if (sc.socketUrl && !sc.isRunning && !sc.isManualReconnecting) {

        NSLogMethodName;

        sc.isRunning = YES;

        switch (sc.socket.status) {
                
            case SocketIOClientStatusNotConnected:
            case SocketIOClientStatusDisconnected: {
                [sc.socket connect];
                break;
            }
            case SocketIOClientStatusConnecting: {
                
                break;
            }
            case SocketIOClientStatusConnected: {
                
                break;
            }
//            case SocketIOClientStatusReconnecting: {
//
//                break;
//            }
            default: {
                break;
            }
                
        }

    } else {
        
        [[self syncer] setSyncerState:STMSyncerReceiveData];
        
    }

}

+ (void)closeSocket {
    [[self sharedInstance] closeSocket];
}

+ (void)sendEvent:(STMSocketEvent)event withStringValue:(NSString *)stringValue {
    [self socket:[self sharedInstance].socket sendEvent:event withStringValue:stringValue];
}

+ (void)sendEvent:(STMSocketEvent)event withValue:(id)value {
    [self socket:[self sharedInstance].socket sendEvent:event withValue:value];
}


#pragma mark - sync

+ (NSArray *)unsyncedObjects {
    return [[self sharedInstance] unsyncedObjectsArray];
}

+ (NSUInteger)numbersOfUnsyncedObjects {
    return [self unsyncedObjects].count;
}

+ (void)sendUnsyncedObjects:(id)sender {

    [self checkSendingTimeInterval];
    
    if ([STMSocketController syncer].syncerState != STMSyncerReceiveData &&
        [self socketIsAvailable] &&
        ![self sharedInstance].isSendingData) {
        
        if (![self haveToSyncObjects]) {

            if ([sender isEqual:[self syncer]]) {
                [[self syncer] nothingToSend];
            }
            
        }

    } else {
        
        if ([sender isEqual:[self syncer]]) {
            [[self syncer] nothingToSend];
        }

    }

}

+ (void)checkSendingTimeInterval {
    
    STMSocketController *sc = [self sharedInstance];
    
    if (sc.sendingDate && sc.isSendingData) {
        
        NSTimeInterval sendingInterval = [sc.sendingDate timeIntervalSinceNow];
        
        if (sendingInterval > CHECK_SENDING_TIME_INTERVAL) {

            NSString *errorMessage = @"exceed sending time interval";
            [[STMLogger sharedLogger] saveLogMessageWithText:errorMessage
                                                     numType:STMLogMessageTypeError];
            
            [self sendFinishedWithError:errorMessage];
            
        }
        
    }
    
}

+ (BOOL)haveToSyncObjects {

    NSArray *unsyncedObjectsArray = [self unsyncedObjects];

    NSArray *syncDataArray = [self syncDataArrayFromUnsyncedObjects:unsyncedObjectsArray];

    if (syncDataArray.count > 0) {

        NSLog(@"%d objects to send via Socket", syncDataArray.count);
        [self sendEvent:STMSocketEventData withValue:syncDataArray];
        
        return YES;
        
    } else {
        
        return NO;
        
    }
    
}

+ (NSMutableArray *)syncDataArrayFromUnsyncedObjects:(NSArray *)unsyncedObjectsArray {
    
    NSMutableArray *syncDataArray = [NSMutableArray array];
    
    for (STMDatum *unsyncedObject in unsyncedObjectsArray) {

        if (unsyncedObject.xid) {
            
            NSData *xid = unsyncedObject.xid;
            
            if (![[self sharedInstance].syncDataDictionary.allKeys containsObject:xid]) {
                
                [self addObject:unsyncedObject toSyncDataArray:syncDataArray];
                
                if (unsyncedObject.deviceTs) {
                    [self sharedInstance].syncDataDictionary[xid] = unsyncedObject.deviceTs;
                }
                
            }

        }
        
        if (syncDataArray.count >= 100) {
            
            NSLog(@"syncDataArray is full");
            break;
            
        }
        
    }
    
    return syncDataArray;

}

+ (void)addObject:(NSManagedObject *)object toSyncDataArray:(NSMutableArray *)syncDataArray {
    
//    NSDate *currentDate = [NSDate date];
//    [object setValue:currentDate forKey:@"sts"];
    
    NSDictionary *objectDictionary = [STMObjectsController dictionaryForObject:object];
    
    [syncDataArray addObject:objectDictionary];

}

+ (NSDate *)deviceTsForSyncedObjectXid:(NSData *)xid {

    NSDate *deviceTs = [self sharedInstance].syncDataDictionary[xid];
    return deviceTs;
    
}

+ (void)successfullySyncObjectWithXid:(NSData *)xid {
    if (xid) [[self sharedInstance].syncDataDictionary removeObjectForKey:xid];
}


+ (void)reloadResultsControllers {
    [[self sharedInstance] reloadResultsControllers];
}


#pragma mark - socket events receiveing

- (void)addEventObserversToSocket:(SocketIOClient *)socket {
    
    [socket removeAllHandlers];
    
    NSLog(@"addEventObserversToSocket %@", socket);
    
    [STMSocketController addOnAnyEventToSocket:socket];

    [STMSocketController addEvent:STMSocketEventConnect toSocket:socket];
    [STMSocketController addEvent:STMSocketEventDisconnect toSocket:socket];
    [STMSocketController addEvent:STMSocketEventError toSocket:socket];
    [STMSocketController addEvent:STMSocketEventReconnect toSocket:socket];
    [STMSocketController addEvent:STMSocketEventReconnectAttempt toSocket:socket];
    [STMSocketController addEvent:STMSocketEventRemoteCommands toSocket:socket];
    [STMSocketController addEvent:STMSocketEventData toSocket:socket];
    
}

+ (void)addOnAnyEventToSocket:(SocketIOClient *)socket {
    
    [socket onAny:^(SocketAnyEvent *event) {
        
        NSLog(@"%@ %@ ___ event %@", socket, socket.sid, event.event);
        NSLog(@"%@ %@ ___ items (", socket, socket.sid);

        for (id item in event.items) NSLog(@"    %@", item);

        NSLog(@"%@ %@           )", socket, socket.sid);

    }];

}

+ (void)addEvent:(STMSocketEvent)event toSocket:(SocketIOClient *)socket {
    
    NSString *eventString = [STMSocketController stringValueForEvent:event];
    
    [socket on:eventString callback:^(NSArray *data, SocketAckEmitter *ack) {
        
        switch (event) {
            case STMSocketEventConnect: {
                [self connectCallbackWithData:data ack:ack socket:socket];
                break;
            }
            case STMSocketEventDisconnect: {
                [self disconnectCallbackWithData:data ack:ack socket:socket];
                break;
            }
            case STMSocketEventError: {
                [self errorCallbackWithData:data ack:ack socket:socket];
                break;
            }
            case STMSocketEventReconnect: {
                [self reconnectCallbackWithData:data ack:ack socket:socket];
                break;
            }
            case STMSocketEventReconnectAttempt: {
                [self reconnectAttemptCallbackWithData:data ack:ack socket:socket];
                break;
            }
            case STMSocketEventStatusChange: {
                
                break;
            }
            case STMSocketEventInfo: {
                
                break;
            }
            case STMSocketEventAuthorization: {
                
                break;
            }
            case STMSocketEventRemoteCommands: {
                [self remoteCommandsCallbackWithData:data ack:ack socket:socket];
                break;
            }
            case STMSocketEventData: {
                [self dataCallbackWithData:data ack:ack socket:socket];
            }
            default: {
                break;
            }
        }

    }];
    
}

+ (void)connectCallbackWithData:(NSArray *)data ack:(SocketAckEmitter *)ack socket:(SocketIOClient *)socket {
    
    if ([self isItCurrentSocket:socket failString:@"connectCallback"]) {
        
        STMSocketController *ssc = [STMSocketController sharedInstance];
        STMLogger *logger = [STMLogger sharedLogger];

        NSString *logMessage = [NSString stringWithFormat:@"connectCallback socket %@ with sid: %@", socket, socket.sid];
        [logger saveLogMessageWithText:logMessage
                               numType:STMLogMessageTypeDebug];
        
        ssc.isAuthorized = NO;

        [ssc startDelayedAuthorizationCheckForSocket:socket];
        
        STMClientData *clientData = [STMClientDataController clientData];
        NSMutableDictionary *dataDic = [[STMObjectsController dictionaryForObject:clientData][@"properties"] mutableCopy];
        
        NSDictionary *authDic = @{@"userId"         : [STMAuthController authController].userID,
                                  @"accessToken"    : [STMAuthController authController].accessToken};
        
        [dataDic addEntriesFromDictionary:authDic];
        
//        logMessage = [NSString stringWithFormat:@"send authorization data %@ with socket %@ %@", dataDic, socket, socket.sid];
//        [logger saveLogMessageWithText:logMessage
//                               numType:STMLogMessageTypeInfo];
        
        NSString *event = [STMSocketController stringValueForEvent:STMSocketEventAuthorization];
        
        [socket emitWithAck:event withItems:@[dataDic]](0, ^(NSArray *data) {
            [self socket:socket receiveAckWithData:data forEvent:event];
        });

    }
    
}

+ (void)disconnectCallbackWithData:(NSArray *)data ack:(SocketAckEmitter *)ack socket:(SocketIOClient *)socket {
    
    if ([self isItCurrentSocket:socket failString:@"disconnectCallback"]) {
        
        STMSocketController *sc = [STMSocketController sharedInstance];
        STMLogger *logger = [STMLogger sharedLogger];

        NSString *logMessage = [NSString stringWithFormat:@"disconnectCallback socket %@ %@", socket, socket.sid];
        [logger saveLogMessageWithText:logMessage
                               numType:STMLogMessageTypeDebug];
        
        if (sc.isManualReconnecting) {
            
            logMessage = [NSString stringWithFormat:@"socket %@ %@ isManualReconnecting, start socket now", socket, socket.sid];
            [logger saveLogMessageWithText:logMessage
                                   numType:STMLogMessageTypeDebug];
            
            sc.isManualReconnecting = NO;
            [self startSocket];
            
        } else {
            
            logMessage = [NSString stringWithFormat:@"socket %@ %@ is not reconnecting, do nothing", socket, socket.sid];
            [logger saveLogMessageWithText:logMessage
                                   numType:STMLogMessageTypeDebug];
            
        }

    }
    
}

+ (void)errorCallbackWithData:(NSArray *)data ack:(SocketAckEmitter *)ack socket:(SocketIOClient *)socket {
    
    STMLogger *logger = [STMLogger sharedLogger];
    
    NSString *logMessage = [NSString stringWithFormat:@"errorCallback socket %@ %@ with data: %@", socket, socket.sid, data.description];
    [logger saveLogMessageWithText:logMessage
                           numType:STMLogMessageTypeDebug];
    
}

+ (void)reconnectAttemptCallbackWithData:(NSArray *)data ack:(SocketAckEmitter *)ack socket:(SocketIOClient *)socket {
    
    STMLogger *logger = [STMLogger sharedLogger];
    
    NSString *logMessage = [NSString stringWithFormat:@"reconnectAttemptCallback socket %@ %@", socket, socket.sid];
    [logger saveLogMessageWithText:logMessage
                           numType:STMLogMessageTypeDebug];
    
}

+ (void)reconnectCallbackWithData:(NSArray *)data ack:(SocketAckEmitter *)ack socket:(SocketIOClient *)socket {
    
    STMLogger *logger = [STMLogger sharedLogger];
    
    NSString *logMessage = [NSString stringWithFormat:@"reconnectCallback socket %@ %@", socket, socket.sid];
    [logger saveLogMessageWithText:logMessage
                           numType:STMLogMessageTypeDebug];
    
}

+ (void)remoteCommandsCallbackWithData:(NSArray *)data ack:(SocketAckEmitter *)ack socket:(SocketIOClient *)socket {
    
    NSLog(@"remoteCommandsCallback socket %@", socket);

    if ([data.firstObject isKindOfClass:[NSDictionary class]]) {
        [STMRemoteController receiveRemoteCommands:data.firstObject];
    }

}

+ (void)dataCallbackWithData:(NSArray *)data ack:(SocketAckEmitter *)ack socket:(SocketIOClient *)socket {
    
    NSLog(@"dataCallback socket %@ data %@", socket, data);
    
}


#pragma mark - socket events sending

+ (NSString *)primaryKeyForEvent:(STMSocketEvent)event {
    
    NSString *primaryKey = @"url";
    
    switch (event) {
        case STMSocketEventConnect:
        case STMSocketEventStatusChange:
        case STMSocketEventInfo:
        case STMSocketEventAuthorization:
        case STMSocketEventRemoteCommands:
            break;
        case STMSocketEventData: {
            primaryKey = @"data";
            break;
        }
        default: {
            break;
        }
    }
    return primaryKey;

}

+ (void)socket:(SocketIOClient *)socket sendEvent:(STMSocketEvent)event withValue:(id)value {

// Log
// ----------
    
#ifdef DEBUG
        
        if (event == STMSocketEventData && [value isKindOfClass:[NSArray class]]) {
            
            NSArray *valueArray = [(NSArray *)value valueForKeyPath:@"name"];
            
            NSLog(@"socket:%@ %@ sendEvent:%@ withObjects:%@", socket, socket.sid, [self stringValueForEvent:event], valueArray);
            
        } else {
            
            NSLog(@"socket:%@ %@ sendEvent:%@ withValue:%@", socket, socket.sid, [self stringValueForEvent:event], value);
            
        }
#endif
    
// ----------
// End of log
    
    if (socket.status == SocketIOClientStatusConnected) {
        
        NSString *primaryKey = [self primaryKeyForEvent:event];
        
        if (value && primaryKey) {
            
            NSDictionary *dataDic = @{primaryKey : value};
            
            dataDic = [STMFunctions validJSONDictionaryFromDictionary:dataDic];
            
            NSString *eventStringValue = [STMSocketController stringValueForEvent:event];
            
            if (dataDic) {
                
                if (socket.status != SocketIOClientStatusConnected) {
                    
                } else {
                    
//                NSLog(@"%@ ___ emit: %@, data: %@", socket, eventStringValue, dataDic);
                    
                    if (event == STMSocketEventData) {
                        
                        [self sharedInstance].isSendingData = YES;
                        [self sharedInstance].sendingDate = [NSDate date];
                        
                        [socket emitWithAck:eventStringValue withItems:@[dataDic]](0, ^(NSArray *data) {
                            [self receiveEventDataAckWithData:data];
                        });
                        
                    } else {
                        [socket emit:eventStringValue withItems:@[dataDic]];
                    }
                    
                }
                
            } else {
                NSLog(@"%@ ___ no dataDic to send via socket for event: %@", socket, eventStringValue);
            }
            
        }

    } else {
        
        NSLog(@"socket not connected");
        
        if ([self syncer].syncerState == STMSyncerSendData || [self syncer].syncerState == STMSyncerSendDataOnce) {
            [self sendFinishedWithError:@"socket not connected"];
        }
        
    }
    
}

+ (void)socket:(SocketIOClient *)socket sendEvent:(STMSocketEvent)event withStringValue:(NSString *)stringValue {
    [self socket:socket sendEvent:event withValue:stringValue];
}

+ (void)socket:(SocketIOClient *)socket receiveAckWithData:(NSArray *)data forEvent:(NSString *)event {
    
    NSLog(@"%@ %@ ___ receive Ack, event: %@, data: %@", socket, socket.sid, event, data);

    STMSocketEvent socketEvent = [self eventForString:event];
    
    if (socketEvent == STMSocketEventAuthorization) {
        [self socket:socket receiveAuthorizationAckWithData:data];
    }
    
}

+ (void)socket:(SocketIOClient *)socket receiveAuthorizationAckWithData:(NSArray *)data {
    
    if ([self isItCurrentSocket:socket failString:@"receiveAuthorizationAck"]) {
     
        STMLogger *logger = [STMLogger sharedLogger];
        
        NSString *logMessage = [NSString stringWithFormat:@"socket %@ %@ receiveAuthorizationAckWithData %@", socket, socket.sid, data];
        [logger saveLogMessageWithText:logMessage
                               numType:STMLogMessageTypeInfo];
        
        if (socket.status != SocketIOClientStatusConnected) {
            return;
        }
        
        if ([data.firstObject isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *dataDic = data.firstObject;
            BOOL isAuthorized = [dataDic[@"isAuthorized"] boolValue];
            
            if (isAuthorized) {
                
//                logMessage = [NSString stringWithFormat:@"socket %@ %@ authorized", socket, socket.sid];
//                [logger saveLogMessageWithText:logMessage
//                                       numType:STMLogMessageTypeInfo];
                
                [self sharedInstance].isAuthorized = YES;
                [self sharedInstance].isSendingData = NO;
                [[self syncer] socketReceiveAuthorization];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"socketAuthorizationSuccess" object:self];
                
                [self socket:socket sendEvent:STMSocketEventStatusChange withStringValue:[STMFunctions appStateString]];
                
                if ([[STMFunctions appStateString] isEqualToString:@"UIApplicationStateActive"]) {
                    
                    if ([[STMRootTBC sharedRootVC].selectedViewController class]) {
                        
                        Class _Nonnull rootVCClass = (Class _Nonnull)[[STMRootTBC sharedRootVC].selectedViewController class];
                        
                        NSString *stringValue = [@"selectedViewController: " stringByAppendingString:NSStringFromClass(rootVCClass)];
                        [self socket:socket sendEvent:STMSocketEventStatusChange withStringValue:stringValue];
                        
                    }
                    
                }
                
            } else {
                [self notAuthorizedSocket:socket
                                withError:@"socket receiveAuthorizationAck with dataDic.isAuthorized.boolValue == NO"];
            }
            
        } else {
            [self notAuthorizedSocket:socket
                            withError:@"socket receiveAuthorizationAck with data.firstObject is not a NSDictionary"];
        }
        
    }

}

+ (void)notAuthorizedSocket:(SocketIOClient *)socket withError:(NSString *)errorString {
    
    NSString *logMessage = [NSString stringWithFormat:@"socket %@ %@ not authorized\n%@", socket, socket.sid, errorString];
    [[STMLogger sharedLogger] saveLogMessageWithText:logMessage
                                             numType:STMLogMessageTypeError];
    
    [self sharedInstance].isAuthorized = NO;
    [[STMAuthController authController] logout];
    
}


+ (void)receiveEventDataAckWithData:(NSArray *)data {

    NSDictionary *response = data.firstObject;
    
    NSString *errorString = nil;
    
    if ([response isKindOfClass:[NSDictionary class]]) {
        
        errorString = response[@"error"];
        
    } else {
        
        errorString = @"response not a dictionary";
        NSLog(@"error: %@", data);
        
    }
    
    if (errorString) {
    
        NSLog(@"error: %@", errorString);
        
        [[STMLogger sharedLogger] saveLogMessageWithText:@"socket receiveEventDataAckWithData got errorString"
                                                    numType:STMLogMessageTypeError];
        [[STMLogger sharedLogger] saveLogMessageWithText:errorString
                                                    numType:STMLogMessageTypeError];

        [self sendEvent:STMSocketEventInfo withStringValue:errorString];
        
        if ([[errorString.lowercaseString stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@"notauthorized"]) {
            
            [[STMAuthController authController] logout];
            
        }

    } else {
        
        NSArray *dataArray = response[@"data"];
        
        for (NSDictionary *datum in dataArray) {
            
            [[self document].managedObjectContext performBlockAndWait:^{
                [STMObjectsController syncObject:datum];
            }];
            
        }

    }

    [[[STMSessionManager sharedManager].currentSession document] saveDocument:^(BOOL success) {
        [self performSelector:@selector(sendFinishedWithError:) withObject:errorString afterDelay:0];
    }];

}

+ (void)sendFinishedWithError:(NSString *)errorString {
    
    if (errorString) {
        
        [self sendingCleanupWithError:errorString];

    } else {

        if ([self haveToSyncObjects]) {
            
            [[self syncer] bunchOfObjectsSended];
            
        } else {
            
            [self sendingCleanupWithError:nil];

        }

    }

}

+ (void)sendingCleanupWithError:(NSString *)errorString {
    
    STMSocketController *sc = [self sharedInstance];
    
    sc.isSendingData = NO;
    [[self syncer] sendFinishedWithError:errorString];
    sc.syncDataDictionary = nil;
    sc.sendingDate = nil;

}


#pragma mark - instance methods

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        [self addObservers];
//        [self checkSocketStatus];

    }
    return self;
    
}

- (void)addObservers {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(appSettingsChanged:)
               name:@"appSettingsSettingsChanged"
             object:nil];
    
    [nc addObserver:self
           selector:@selector(sessionStatusChanged:)
               name:NOTIFICATION_SESSION_STATUS_CHANGED
             object:nil];

    
    [nc addObserver:self
           selector:@selector(objectContextDidSave:)
               name:NSManagedObjectContextDidSaveNotification
             object:nil];

    [nc addObserver:self
           selector:@selector(documentSavedSuccessfully:)
               name:@"documentSavedSuccessfully"
             object:nil];

}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)checkSocketStatus {
    
#ifdef DEBUG
    STMLogger *logger = [STMLogger sharedLogger];
    
    NSString *logMessage = [NSString stringWithFormat:@"socket %@ status %@", self.socket, @(self.socket.status)];
    [logger saveLogMessageWithText:logMessage
                           numType:STMLogMessageTypeDebug];
    
    [self performSelector:@selector(checkSocketStatus)
               withObject:nil
               afterDelay:10];
#endif
    
}

- (void)appSettingsChanged:(NSNotification *)notification {
    
    STMSession *currentSession = [STMSessionManager sharedManager].currentSession;
    
    if (currentSession.status == STMSessionRunning) {
        
        NSString *key = @"socketUrl";
        
        if ([notification.userInfo.allKeys containsObject:key]) {
            
            self.socketUrl = nil;
            
            if (self.isRunning) {
                
                if (![self.socket.socketURL.absoluteString isEqualToString:self.socketUrl]) {
                    [self reconnectSocket];
                }
                
            } else {
                
                [STMSocketController startSocket];
                
            }
            
        }

    }
    
}

- (void)sessionStatusChanged:(NSNotification *)notification {
    
    STMSession *session = [STMSessionManager sharedManager].currentSession;
    
    if (notification.object == session) {
        
        if (session.status == STMSessionRunning) {
            
            [self performFetches];
            
        } else {
            
            self.resultsControllers = nil;
            
        }
        
    }
    
}

- (void)objectContextDidSave:(NSNotification *)notification {
    
//    NSLogMethodName;
    
//    if (self.controllersDidChangeContent && [notification.object isKindOfClass:[NSManagedObjectContext class]]) {
//        
//        NSManagedObjectContext *context = (NSManagedObjectContext *)notification.object;
//        
//        if ([context isEqual:[STMSocketController document].managedObjectContext]) {
//
//            [[STMSocketController sharedInstance] performSelector:@selector(sendUnsyncedObjects) withObject:nil afterDelay:0];
//
//        }
//        
//    }
    
}

- (void)documentSavedSuccessfully:(NSNotification *)notification {
    
//    NSLogMethodName;

    if (self.controllersDidChangeContent && [notification.object isKindOfClass:[STMDocument class]]) {
        
        NSManagedObjectContext *context = [(STMDocument *)notification.object managedObjectContext];

        if ([context isEqual:[STMSocketController document].managedObjectContext]) {
            
            [[STMSocketController sharedInstance] performSelector:@selector(sendUnsyncedObjects) withObject:nil afterDelay:0];
            
        }
        
    }

}

- (void)sendUnsyncedObjects {

    self.controllersDidChangeContent = NO;
    [STMSocketController sendUnsyncedObjects:self];
    
}

- (void)performFetches {

    NSArray *entityNamesForSending = [STMEntityController uploadableEntitiesNames];

    self.resultsControllers = @[].mutableCopy;
    
    for (NSString *entityName in entityNamesForSending) {
        
        NSFetchedResultsController *rc = [self resultsControllerForEntityName:entityName];
        
        if (rc) {
            
            [self.resultsControllers addObject:rc];
            [rc performFetch:nil];
            
        }

    }
    
}

- (void)reloadResultsControllers {
    
    self.resultsControllers = nil;
    [self performFetches];
    
}

- (NSMutableDictionary *)syncDataDictionary {
    
    if (!_syncDataDictionary) {
        _syncDataDictionary = @{}.mutableCopy;
    }
    return _syncDataDictionary;
    
}


#pragma mark - NSFetchedResultsController

- (nullable NSFetchedResultsController *)resultsControllerForEntityName:(NSString *)entityName {
    
    if ([[STMObjectsController localDataModelEntityNames] containsObject:entityName]) {
        
        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:entityName];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)]];
        request.includesSubentities = YES;
        
        NSMutableArray *subpredicates = @[].mutableCopy;
        
        if ([entityName isEqualToString:NSStringFromClass([STMLogMessage class])]) {
            
            STMLogger *logger = [[STMSessionManager sharedManager].currentSession logger];
            
            NSArray *logMessageSyncTypes = [logger syncingTypesForSettingType:[self uploadLogType]];
            
            [subpredicates addObject:[NSPredicate predicateWithFormat:@"type IN %@", logMessageSyncTypes]];
            
        }
        
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"(lts == %@ || deviceTs > lts)", nil]];
        
        request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
        
        NSFetchedResultsController *rc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                             managedObjectContext:[STMSocketController document].managedObjectContext
                                                                               sectionNameKeyPath:nil
                                                                                        cacheName:nil];
        rc.delegate = self;
        
        return rc;
        
    } else {
        
        return nil;
        
    }

}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"syncerDidChangeContent" object:self];
    
    self.controllersDidChangeContent = YES;
    
//    NSArray *fetchedObjects = [self.resultsControllers valueForKeyPath:@"@distinctUnionOfArrays.fetchedObjects"];
//
//    NSLog(@"fetchedObjects.count %@", @(fetchedObjects.count));
    
    [[STMSocketController document] saveDocument:^(BOOL success) {
        
    }];
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
//    NSLog(@"didChangeObject %@", [anObject entity].name);
    
}

- (NSString *)uploadLogType {
    
    NSString *uploadLogType = [STMSettingsController stringValueForSettings:@"uploadLog.type"
                                                                   forGroup:@"syncer"];
    return uploadLogType;
    
}

- (NSArray *)unsyncedObjectsArray {
    
    if (self.isAuthorized && [STMSocketController document].managedObjectContext) {
        
        NSArray *fetchedObjects = [self.resultsControllers valueForKeyPath:@"@distinctUnionOfArrays.fetchedObjects"];
        
        return fetchedObjects;
        
    } else {
        return nil;
    }
    
}


#pragma mark - socket

- (SocketIOClient *)socket {
    
    if (!_socket && self.socketUrl && self.isRunning) {
        
        NSURL *socketUrl = [NSURL URLWithString:self.socketUrl];
        NSString *path = [socketUrl.path stringByAppendingString:@"/"];

        SocketIOClient *socket = [[SocketIOClient alloc] initWithSocketURL:socketUrl config:@{@"voipEnabled"       : @YES,
                                                                                              @"log"               : @NO,
                                                                                              @"forceWebsockets"   : @NO,
                                                                                              @"path"              : path}];

        STMLogger *logger = [STMLogger sharedLogger];
        
        NSString *logMessage = [NSString stringWithFormat:@"init socket %@", socket];
        [logger saveLogMessageWithText:logMessage
                               numType:STMLogMessageTypeInfo];
        

        [self addEventObserversToSocket:socket];

        _socket = socket;
        
    }
    return _socket;
    
}

- (void)closeSocketInBackground {
    
    STMLogger *logger = [STMLogger sharedLogger];
    
    [logger saveLogMessageWithText:@"close socket in background"
                           numType:STMLogMessageTypeInfo];
    
    self.wasClosedInBackground = YES;

    [self closeSocket];
    
}

- (void)closeSocket {
    
    NSLogMethodName;
    
    if (self.isRunning) {
        
        STMLogger *logger = [STMLogger sharedLogger];
        
        NSString *logMessage = [NSString stringWithFormat:@"close socket %@ %@", self.socket, self.socket.sid];
        [logger saveLogMessageWithText:logMessage
                               numType:STMLogMessageTypeInfo];
        
        [self.socket disconnect];
        
        if (!self.isManualReconnecting) {
            self.socket = nil;
        }
        
        self.socketUrl = nil;
        self.isSendingData = NO;
        self.isAuthorized = NO;
        self.isRunning = NO;
        self.syncDataDictionary = nil;
        self.sendingDate = nil;
        
    }
    
}

- (void)reconnectSocket {

//    NSLogMethodName;
    
    STMLogger *logger = [STMLogger sharedLogger];
    
    NSString *logMessage = [NSString stringWithFormat:@"reconnectSocket %@ %@", self.socket, self.socket.sid];
    [logger saveLogMessageWithText:logMessage
                           numType:STMLogMessageTypeInfo];
    
    if (self.isRunning) {
        
        logMessage = [NSString stringWithFormat:@"socket %@ %@ isRunning, close socket first", self.socket, self.socket.sid];
        [logger saveLogMessageWithText:logMessage
                               numType:STMLogMessageTypeInfo];

        self.isManualReconnecting = YES;
        [STMSocketController closeSocket];
        
    } else {
    
        [STMSocketController startSocket];

    }
    
}

- (NSString *)socketUrl {
    
    if (!_socketUrl) {
        
        _socketUrl = [STMSettingsController stringValueForSettings:@"socketUrl" forGroup:@"appSettings"];
        
    }
    return _socketUrl;
    
}

- (void)checkAuthorizationForSocket:(SocketIOClient *)socket {

    if ([STMSocketController isItCurrentSocket:socket failString:@"checkAuthorization"]) {
     
        STMLogger *logger = [STMLogger sharedLogger];
        
        NSString *logMessage = [NSString stringWithFormat:@"checkAuthorizationForSocket: %@ %@", socket, socket.sid];
        [logger saveLogMessageWithText:logMessage
                               numType:STMLogMessageTypeInfo];
        
        if (socket.status == SocketIOClientStatusConnected) {

            if (self.isAuthorized) {
                
                logMessage = [NSString stringWithFormat:@"socket %@ %@ is authorized", socket, socket.sid];
                [logger saveLogMessageWithText:logMessage
                                       numType:STMLogMessageTypeInfo];
                
            } else {
                
                logMessage = [NSString stringWithFormat:@"socket %@ %@ is connected but don't receive authorization ack, reconnecting", socket, socket.sid];
                [logger saveLogMessageWithText:logMessage
                                       numType:STMLogMessageTypeError];
                
                [self reconnectSocket];
                
            }
            
        } else {
            
            logMessage = [NSString stringWithFormat:@"socket %@ %@ is not connected", socket, socket.sid];
            [logger saveLogMessageWithText:logMessage
                                   numType:STMLogMessageTypeInfo];
            
//            [self startDelayedAuthorizationCheckForSocket:socket];
            
        }
        
    }
    
}

- (void)startDelayedAuthorizationCheckForSocket:(SocketIOClient *)socket {
    
    SEL checkAuthSel = @selector(checkAuthorizationForSocket:);
    
    [STMSocketController cancelPreviousPerformRequestsWithTarget:self
                                                        selector:checkAuthSel
                                                          object:socket];
    
    [self performSelector:checkAuthSel
               withObject:socket
               afterDelay:CHECK_AUTHORIZATION_DELAY];
    
}


@end
