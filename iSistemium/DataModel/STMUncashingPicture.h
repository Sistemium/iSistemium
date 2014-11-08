//
//  STMUncashingPicture.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMPicture.h"

@class STMUncashing;

@interface STMUncashingPicture : STMPicture

@property (nonatomic, retain) STMUncashing *uncashing;

@end
