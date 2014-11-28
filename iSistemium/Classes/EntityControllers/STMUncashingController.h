//
//  STMUncashingController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 19/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMSingleton.h"
#import "STMUncashing.h"

@interface STMUncashingController : STMSingleton

+ (STMUncashingController *)sharedInstance;

- (void)removeUncashing:(STMUncashing *)uncashing;

@end
