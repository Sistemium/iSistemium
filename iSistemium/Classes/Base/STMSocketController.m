//
//  STMSocketController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 10/10/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMSocketController.h"
#import "STMAuthController.h"
#import "STMFunctions.h"

#import "iSistemium-Swift.h"


#define SOCKET_URL @"https://socket.sistemium.com/socket.io-client"


@interface STMSocketController()


@property (nonatomic, strong) SocketIOClient* socket;


@end


@implementation STMSocketController

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
        default: {
            return nil;
            break;
        }
    }
    
}

- (SocketIOClient *)socket {
    
    if (!_socket) {
        
        SocketIOClient* socket = [[SocketIOClient alloc] initWithSocketURL:SOCKET_URL opts:nil];

        [socket onAny:^(SocketAnyEvent *event) {
            
            NSLog(@"SocketIOClient ___ event %@", event.event);
//            NSLog(@"SocketIOClient ___ description %@", event.description);
            NSLog(@"SocketIOClient ___ items %@", event.items);
            
        }];
        
        _socket = socket;
        
    }
    return _socket;
    
}

//- (void)startSocket {
//    
//    [self.socket connect];
//    
//
//    NSString *accessToken = [STMAuthController authController].accessToken;
//    
//    if (accessToken) {
//        
//        NSURL *url = [NSURL URLWithString:SOCKET_URL];
//        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//        [request addValue:accessToken forHTTPHeaderField:@"Authorization"];
//
//        [self sharedInstance].socketRequest = request.copy;
//        
//        [[self sharedInstance].webSocket open];
//
//    } else {
//        
//        [self sharedInstance].webSocket = nil;
//        
//    }
//
//}

+ (void)startSocket {
    [[self sharedInstance].socket connect];
}

+ (void)closeSocket {
    [[self sharedInstance].socket disconnect];
}

+ (void)sendEvent:(STMSocketEvent)event withStringValue:(NSString *)stringValue {
    [[self sharedInstance] sendEvent:event withStringValue:stringValue];
}

- (void)sendEvent:(STMSocketEvent)event withStringValue:(NSString *)stringValue {
    
    NSString *eventStringValue = [[self class] stringValueForEvent:event];
    
    NSDictionary *dataDic = @{@"userId"     : [STMAuthController authController].userID,
                              @"token"      : [STMAuthController authController].accessToken,
                              @"url"        : stringValue};
    
    dataDic = [STMFunctions validJSONDictionaryFromDictionary:dataDic];
    
    if (dataDic) {
        
        NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dataDic
                                                           options:0
                                                             error:nil];

        [self.socket emit:eventStringValue withItems:@[JSONData]];

    } else {
        NSLog(@"no dataDic to send via socket");
    }
    
}



@end
