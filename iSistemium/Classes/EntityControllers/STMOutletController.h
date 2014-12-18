//
//  STMOutletController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMOutlet.h"
#import "STMPartner.h"

@interface STMOutletController : NSObject

+ (STMOutlet *)addOutletWithShortName:(NSString *)shortName forPartner:(STMPartner *)partner;

+ (void)removeOutlet:(STMOutlet *)outlet;

@end
