//
//  STMMessageController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 05/04/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMController.h"

@interface STMMessageController : STMController

+ (void)generateTestMessages;

+ (NSArray *)sortedPicturesArrayForMessage:(STMMessage *)message;

+ (void)showMessageVCsIfNeeded;
+ (void)showMessageVCsForMessages:(NSArray *)messages;
+ (void)showMessageVCsForMessage:(STMMessage *)message;

+ (NSUInteger)unreadMessagesCount;

@end
