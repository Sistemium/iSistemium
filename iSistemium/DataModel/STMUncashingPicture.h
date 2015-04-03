//
//  STMUncashingPicture.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 23/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMPhoto.h"

@class STMUncashing;

@interface STMUncashingPicture : STMPhoto

@property (nonatomic, retain) STMUncashing *uncashing;

@end
