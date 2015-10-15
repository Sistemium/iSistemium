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

#import "STMRootTBC.h"

#import "STMFunctions.h"

#import "iSistemium-Swift.h"


#define SOCKET_URL @"https://socket.sistemium.com/socket.io-client"


@interface STMSocketController()

@property (nonatomic, strong) SocketIOClient *socket;
@property (nonatomic, strong) NSMutableArray *queuedEvents;
@property (nonatomic, strong) NSString *socketUrl;
@property (nonatomic) BOOL shouldStarted;


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
        default: {
            return nil;
            break;
        }
    }
    
}

+ (STMSocketEvent)eventForString:(NSString *)stringValue {
    
    if ([stringValue isEqualToString:@"connect"]) {
        return STMSocketEventConnect;
    } else if ([stringValue isEqualToString:@"status:change"]) {
        return STMSocketEventStatusChange;
    } else if ([stringValue isEqualToString:@"info"]) {
        return STMSocketEventInfo;
    } else if ([stringValue isEqualToString:@"authorization"]) {
        return STMSocketEventAuthorization;
    } else if ([stringValue isEqualToString:@"remoteCommands"]) {
        return STMSocketEventRemoteCommands;
    } else {
        return STMSocketEventInfo;
    }
    
}

+ (void)startSocket {
    
    [self sharedInstance].shouldStarted = YES;
    
    switch ([self sharedInstance].socket.status) {
            
        case SocketIOClientStatusNotConnected:
        case SocketIOClientStatusClosed: {
            [[self sharedInstance].socket connect];
            break;
        }
        case SocketIOClientStatusConnecting: {
            
            break;
        }
        case SocketIOClientStatusConnected: {
            
            break;
        }
        case SocketIOClientStatusReconnecting: {
            
            break;
        }
        default: {
            break;
        }
            
    }

}

+ (void)closeSocket {
    
    [self sharedInstance].shouldStarted = NO;
    [[self sharedInstance].socket disconnect];
    
}

+ (void)reconnectSocket {
    [[self sharedInstance] reconectSocket];
}

+ (void)sendEvent:(STMSocketEvent)event withStringValue:(NSString *)stringValue {
    [self socket:[self sharedInstance].socket sendEvent:event withStringValue:stringValue];
}


#pragma mark - instance methods

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self addObservers];
    }
    return self;

}

- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appSettingsChanged:)
                                                 name:@"appSettingsSettingsChanged"
                                               object:nil];
    
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)appSettingsChanged:(NSNotification *)notification {
    
    if ([notification.userInfo.allKeys containsObject:@"socketUrl"]) {
        [self reconectSocket];
    }
    
}

- (void)reconectSocket {

    [self.socket disconnect];
    
    self.socketUrl = nil;
    self.socket = nil;
    
    [self socket];

}

- (NSString *)socketUrl {
    
    if (!_socketUrl) {
    
        _socketUrl = [STMSettingsController stringValueForSettings:@"socketUrl" forGroup:@"appSettings"];
        
    }
    return _socketUrl;
    
}

- (SocketIOClient *)socket {
    
    if (!_socket && self.socketUrl) {
        
        SocketIOClient *socket = [[SocketIOClient alloc] initWithSocketURL:self.socketUrl opts:nil];

        [self addEventObserversToSocket:socket];
        
        if (self.shouldStarted) {
            [socket connect];
        }

        _socket = socket;
        
    }
    return _socket;
    
}


#pragma mark - socket events

- (void)addEventObserversToSocket:(SocketIOClient *)socket {
    
    [STMSocketController addOnAnyEventToSocket:socket];

    [STMSocketController addEvent:STMSocketEventConnect toSocket:socket];
    [STMSocketController addEvent:STMSocketEventRemoteCommands toSocket:socket];
    
}

+ (void)addOnAnyEventToSocket:(SocketIOClient *)socket {
    
    [socket onAny:^(SocketAnyEvent *event) {
        
        NSLog(@"%@ ___ event %@", socket, event.event);
        NSLog(@"%@ ___ items %@", socket, event.items);
        
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
            default: {
                break;
            }
        }

    }];
    
}

+ (void)connectCallbackWithData:(NSArray *)data ack:(SocketAckEmitter *)ack socket:(SocketIOClient *)socket {
    
    //            [self checkQueuedEvent];
    
    STMClientData *clientData = [STMClientDataController clientData];
    NSMutableDictionary *dataDic = [[STMObjectsController dictionaryForObject:clientData][@"properties"] mutableCopy];
    
    NSDictionary *authDic = @{@"userId"         : [STMAuthController authController].userID,
                              @"accessToken"    : [STMAuthController authController].accessToken};
    
    [dataDic addEntriesFromDictionary:authDic];
    
    NSString *event = [STMSocketController stringValueForEvent:STMSocketEventAuthorization];
    [socket emitWithAck:event withItems:@[dataDic]](0, ^(NSArray *data) {
        [self receiveAckWithData:data forEvent:event];
    });
    
    [self socket:socket sendEvent:STMSocketEventStatusChange withStringValue:[STMFunctions appStateString]];
    
    if ([[STMFunctions appStateString] isEqualToString:@"UIApplicationStateActive"]) {
        
        NSString *stringValue = [@"selectedViewController: " stringByAppendingString:NSStringFromClass([[STMRootTBC sharedRootVC].selectedViewController class])];
        [self socket:socket sendEvent:STMSocketEventStatusChange withStringValue:stringValue];
        
    }

}

+ (void)remoteCommandsCallbackWithData:(NSArray *)data ack:(SocketAckEmitter *)ack socket:(SocketIOClient *)socket {
    
    if ([data.firstObject isKindOfClass:[NSDictionary class]]) {
        
        [STMRemoteController receiveRemoteCommands:data.firstObject];
        
    }

}


+ (void)socket:(SocketIOClient *)socket sendEvent:(STMSocketEvent)event withStringValue:(NSString *)stringValue {
    
    NSString *eventStringValue = [STMSocketController stringValueForEvent:event];
    
    NSDictionary *dataDic = @{@"url" : stringValue};
    
    dataDic = [STMFunctions validJSONDictionaryFromDictionary:dataDic];
    
    if (dataDic) {
        
        if (socket.status != SocketIOClientStatusConnected) {
            
        } else {
            
            NSLog(@"%@ ___ emit: %@, data: %@", socket, eventStringValue, dataDic);
            
            [socket emit:eventStringValue withItems:@[dataDic]];
            
//            [socket emitWithAck:eventStringValue withItems:@[dataDic]](0, ^(NSArray *data) {
//                [self receiveAckWithData:data forEvent:eventStringValue];
//            });
            
        }
        
    } else {
        NSLog(@"%@ ___ no dataDic to send via socket for event: %@", socket, eventStringValue);
    }
    
}

+ (void)receiveAckWithData:(NSArray *)data forEvent:(NSString *)event {
    NSLog(@"%@ ___ receive Ack, event: %@, data: %@", [self sharedInstance].socket, event, data);
}



#pragma mark - queue

- (NSMutableArray *)queuedEvents {
    
    if (!_queuedEvents) {
        _queuedEvents = @[].mutableCopy;
    }
    return _queuedEvents;
    
}

- (void)checkQueuedEvent {
    
    if (self.queuedEvents.count > 1) {
        
        NSArray *queuedEvents = self.queuedEvents.copy;
        
        for (NSDictionary *event in queuedEvents) {
            
            for (NSString *eventStringValue in event.allKeys) {
                
                NSData *data = event[eventStringValue];
                
                [self.socket emit:eventStringValue withItems:@[data]];
                
                [self.queuedEvents removeObject:event];
                
            }
            
        }
        
    }

}


@end
