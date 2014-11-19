//
//  STMUncashingController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 19/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMUncashing.h"

@interface STMUncashingController : NSObject

+ (STMUncashingController *)sharedController;

- (void)removeUncashing:(STMUncashing *)uncashing;

@end
