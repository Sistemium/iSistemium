//
//  STMUncashingController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 19/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMController+category.h"
#import "STMUncashing.h"

@interface STMUncashingController : STMController

+ (STMUncashingController *)sharedInstance;

- (void)removeUncashing:(STMUncashing *)uncashing;

@end
