//
//  STMWebSocketController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 10/10/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMWebSocketController.h"
#import "STMAuthController.h"

#import <SocketRocket/SRWebSocket.h>

#define SOCKET_URL @"ws://maxbook.local:8081"


@interface STMWebSocketController() <SRWebSocketDelegate>

@property (nonatomic, strong) SRWebSocket *webSocket;
@property (nonatomic, strong) NSURLRequest *socketRequest;

@end

@implementation STMWebSocketController

+ (STMWebSocketController *)sharedInstance {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
    
}

- (SRWebSocket *)webSocket {
    
    if (!_webSocket) {
        
        if (self.socketRequest) {
            
            SRWebSocket *webSocket = [[SRWebSocket alloc] initWithURLRequest:self.socketRequest];
            webSocket.delegate = self;
            _webSocket = webSocket;

        }
        
    }
    
    return _webSocket;
    
}

+ (void)startSocket {

    NSString *accessToken = [STMAuthController authController].accessToken;
    
    if (accessToken) {
        
        NSURL *url = [NSURL URLWithString:SOCKET_URL];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request addValue:accessToken forHTTPHeaderField:@"Authorization"];

        [self sharedInstance].socketRequest = request.copy;
        
        [[self sharedInstance].webSocket open];

    } else {
        
        [self sharedInstance].webSocket = nil;
        
    }

}

+ (void)closeSocket {
    
    [[self sharedInstance].webSocket close];
    [self sharedInstance].webSocket = nil;
    
}

+ (void)sendData:(id)data {
    [[self sharedInstance] sendData:data];
}

- (void)sendData:(id)data {
    
    if (self.webSocket.readyState == SR_OPEN) {
        
        [self.webSocket send:data];
        
    }

}


#pragma mark - SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"%@ receive message: %@", webSocket, message);
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"%@ did open", webSocket);
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"%@ didFailWithError: %@", webSocket, error.localizedDescription);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"%@ didCloseWithCode: %d reason: %@ wasClean: %d", webSocket, code, reason, wasClean);
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    NSLog(@"%@ didReceivePong: %@", webSocket, pongPayload);
}


@end
