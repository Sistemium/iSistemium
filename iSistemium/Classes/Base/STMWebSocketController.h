//
//  STMWebSocketController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 10/10/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STMWebSocketController : NSObject

+ (void)startSocket;
+ (void)closeSocket;
+ (void)sendData:(id)data;


@end
