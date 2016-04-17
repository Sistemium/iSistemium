//
//  STMPartnerController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMController+category.h"
#import "STMPartner.h"

@interface STMPartnerController : STMController

+ (STMPartner *)addPartnerWithName:(NSString *)name;

+ (void)removePartner:(STMPartner *)partner;

@end
