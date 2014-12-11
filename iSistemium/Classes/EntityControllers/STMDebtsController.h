//
//  STMDebtsController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMDebt.h"

@interface STMDebtsController : NSObject

+ (STMDebt *)addNewDebtWithSum:(NSDecimalNumber *)sum
                          ndoc:(NSString *)ndoc
                          date:(NSDate *)date
                        outlet:(STMOutlet *)outlet;

+ (void)removeDebt:(STMDebt *)debt;

@end