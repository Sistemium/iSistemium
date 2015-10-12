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
    STMSocketEventStatusChange
};


@interface STMSocketController : NSObject

+ (void)startSocket;
+ (void)closeSocket;

//+ (void)sendData:(id)data;

+ (void)sendEvent:(STMSocketEvent)event withStringValue:(NSString *)stringValue;


@end
