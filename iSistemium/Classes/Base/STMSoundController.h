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

+ (void)say:(NSString *)string;
+ (void)playAlert;
+ (void)playOk;


@end
