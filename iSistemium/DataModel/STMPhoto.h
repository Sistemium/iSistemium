//
//  STMPhoto.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 30/07/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMPicture.h"

@class STMLocation;

@interface STMPhoto : STMPicture

@property (nonatomic, retain) STMLocation *location;

@end
