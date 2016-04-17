//
//  STMSalesmanController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 15/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMController+category.h"

@interface STMSalesmanController : STMController

+ (STMSalesmanController *)sharedInstance;

+ (BOOL)isItOnlyMeAmongSalesman;
+ (NSArray *)salesmansArray;

@end
