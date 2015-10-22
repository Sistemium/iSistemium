//
//  STMCashingController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 13/02/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMCashingController.h"
#import "STMDebt+Cashing.h"
#import "STMObjectsController.h"

@implementation STMCashingController

+ (STMCashing *)addCashingWithSum:(NSDecimalNumber *)sum ndoc:(NSString *)ndoc date:(NSDate *)date comment:(NSString *)comment debt:(STMDebt *)debt outlet:(STMOutlet *)outlet {

    return [self addCashingWithSum:sum ndoc:ndoc date:date comment:comment debt:debt outlet:outlet type:STMCashingEtcetera];

}

+ (STMCashing *)addCashingWithSum:(NSDecimalNumber *)sum ndoc:(NSString *)ndoc date:(NSDate *)date comment:(NSString *)comment debt:(STMDebt *)debt outlet:(STMOutlet *)outlet type:(STMCashingType)type {
    
    STMCashing *cashing = (STMCashing *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMCashing class])];
    cashing.isFantom = @NO;
    
    if (type == STMCashingDeduction) {

        NSDecimalNumber *minusOne = [NSDecimalNumber decimalNumberWithMantissa:1 exponent:0 isNegative:YES];
        sum = [sum decimalNumberByMultiplyingBy:minusOne];
        
    }
    
    cashing.isFantom = @NO;
    cashing.summ = sum;
    cashing.ndoc = ndoc;
    cashing.date = date;
    cashing.commentText = comment;
    cashing.debt = debt;
    cashing.outlet = outlet;
    
    debt.calculatedSum = [debt cashingCalculatedSum];
    
    [[self document] saveDocument:^(BOOL success) {
//        if (success) [[self syncer] setSyncerState:STMSyncerSendDataOnce];
    }];
    
//    NSLog(@"cashing %@", cashing);
    
    return cashing;
    
}

+ (void)removeCashing:(STMCashing *)cashing {
    
    [STMObjectsController createRecordStatusAndRemoveObject:cashing];

}

@end
