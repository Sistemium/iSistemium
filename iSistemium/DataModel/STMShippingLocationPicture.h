//
//  STMShippingLocationPicture.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMPhoto.h"

@class STMShippingLocation;

@interface STMShippingLocationPicture : STMPhoto

@property (nonatomic, retain) STMShippingLocation *shippingLocation;

@end
