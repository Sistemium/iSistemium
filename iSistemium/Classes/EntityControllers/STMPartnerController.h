//
//  STMPartnerController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMPartner.h"

@interface STMPartnerController : NSObject

+ (STMPartner *)addPartnerWithName:(NSString *)name;

+ (void)removePartner:(STMPartner *)partner;

@end
