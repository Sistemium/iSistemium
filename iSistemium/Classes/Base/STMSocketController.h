//
//  STMSocketController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 10/10/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, STMSocketEvent) {
    STMSocketEventConnect,
    STMSocketEventStatusChange,
    STMSocketEventInfo,
    STMSocketEventAuthorization,
    STMSocketEventRemoteCommands
};


@interface STMSocketController : NSObject

+ (void)startSocket;
+ (void)closeSocket;
+ (void)reconnectSocket;

+ (void)sendEvent:(STMSocketEvent)event withStringValue:(NSString *)stringValue;


@end
