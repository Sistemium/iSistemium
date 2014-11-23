//
//  STMUncashingPlaceController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMUncashingPlace.h"

@interface STMUncashingPlaceController : NSObject

+ (STMUncashingPlaceController *)sharedController;

- (NSArray *)uncashingPlaces;

@end
