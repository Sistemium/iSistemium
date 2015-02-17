//
//  STMDebtsController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMController.h"
#import "STMDebt.h"

@interface STMDebtsController : STMController

+ (STMDebt *)addNewDebtWithSum:(NSDecimalNumber *)sum
                          ndoc:(NSString *)ndoc
                          date:(NSDate *)date
                        outlet:(STMOutlet *)outlet;

+ (STMDebt *)addNewDebtWithSum:(NSDecimalNumber *)sum
                          ndoc:(NSString *)ndoc
                          date:(NSDate *)date
                        outlet:(STMOutlet *)outlet
                       comment:(NSString *)commentText;

+ (void)removeDebt:(STMDebt *)debt;

@end
