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
        default: {
            return nil;
            break;
        }
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

+ (void)sendEvent:(STMSocketEvent)event withStringValue:(NSString *)stringValue {
    [[self sharedInstance] sendEvent:event withStringValue:stringValue];
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
        
        [self.socket disconnect];
        self.socket = nil;
        
        if (self.shouldStarted) [self.socket connect];
        
    }
    
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

        [socket onAny:^(SocketAnyEvent *event) {
            
            NSLog(@"SocketIOClient ___ event %@", event.event);
            NSLog(@"SocketIOClient ___ items %@", event.items);
            
        }];

        NSString *connectEvent = [[self class] stringValueForEvent:STMSocketEventConnect];
        
        [socket on:connectEvent callback:^(NSArray* data, SocketAckEmitter* ack) {

//            [self checkQueuedEvent];
            
            STMClientData *clientData = [STMClientDataController clientData];
            NSMutableDictionary *dataDic = [[STMObjectsController dictionaryForObject:clientData][@"properties"] mutableCopy];
            NSDictionary *authDic = @{@"userId"         : [STMAuthController authController].userID,
                                      @"accessToken"    : [STMAuthController authController].accessToken};
            
            [dataDic addEntriesFromDictionary:authDic];
            
            NSString *event = [STMSocketController stringValueForEvent:STMSocketEventAuthorization];
            
            [self.socket emitWithAck:event withItems:@[dataDic]](0, ^(NSArray *data) {
                [self receiveAckWithData:data forEvent:event];
            });
            
        }];
        
        if (self.shouldStarted) {
            [socket connect];
        }

        _socket = socket;
        
    }
    return _socket;
    
}

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

- (void)sendEvent:(STMSocketEvent)event withStringValue:(NSString *)stringValue {
    
    NSString *eventStringValue = [STMSocketController stringValueForEvent:event];
//    NSString *infoEvent = [STMSocketController stringValueForEvent:STMSocketEventInfo];
    
    NSDictionary *dataDic = @{@"url" : stringValue};
    
    dataDic = [STMFunctions validJSONDictionaryFromDictionary:dataDic];
    
    if (dataDic) {

        if (self.socket.status != SocketIOClientStatusConnected) {
            
//            [self.queuedEvents addObject:@{eventStringValue : dataDic}];
            
        } else {

            [self.socket emitWithAck:eventStringValue withItems:@[dataDic]](0, ^(NSArray *data) {
                [self receiveAckWithData:data forEvent:eventStringValue];
            });
            
//            [self.socket emit:infoEvent withItems:@[dataDic]];
//            [self.socket emitWithAck:infoEvent withItems:@[dataDic]](0, ^(NSArray* data) {
//                [self receiveAckWithData:data forEvent:infoEvent];
//            });


        }

    } else {
        NSLog(@"SocketIOClient ___ no dataDic to send via socket for event: %@", eventStringValue);
    }

}

- (void)receiveAckWithData:(NSArray *)data forEvent:(NSString *)event {
    NSLog(@"SocketIOClient ___ receive Ack, event: %@, data: %@", event, data);
}


@end
