//
//  STMCashingController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 13/02/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMController+category.h"
#import "STMCashing.h"

typedef NS_ENUM(NSInteger, STMCashingType) {
    STMCashingEtcetera,
    STMCashingDeduction
};

@interface STMCashingController : STMController

+ (STMCashing *)addCashingWithSum:(NSDecimalNumber *)sum
                             ndoc:(NSString *)ndoc
                             date:(NSDate *)date
                          comment:(NSString *)comment
                             debt:(STMDebt *)debt
                           outlet:(STMOutlet *)outlet;

+ (STMCashing *)addCashingWithSum:(NSDecimalNumber *)sum
                             ndoc:(NSString *)ndoc
                             date:(NSDate *)date
                          comment:(NSString *)comment
                             debt:(STMDebt *)debt
                           outlet:(STMOutlet *)outlet
                             type:(STMCashingType)type;

+ (void)removeCashing:(STMCashing *)cashing;

@end
