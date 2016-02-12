//
//  STMSoundController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 23/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STMSoundController : NSObject

+ (STMSoundController *)sharedController;

+ (void)playAlert;
+ (void)playOk;

+ (void)say:(NSString *)string;
+ (void)alertSay:(NSString *)string;
+ (void)okSay:(NSString *)string;

+ (void)ringWithProperties:(NSDictionary *)ringProperties;
+ (void)stopRinging;


@end
