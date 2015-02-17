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
    
    STMCashing *cashing = [STMEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STMCashing class]) inManagedObjectContext:[STMController document].managedObjectContext];
    
    if (type == STMCashingDeduction) {

        NSDecimalNumber *minusOne = [NSDecimalNumber decimalNumberWithMantissa:1 exponent:0 isNegative:YES];
        sum = [sum decimalNumberByMultiplyingBy:minusOne];
        
    }
    
    cashing.summ = sum;
    cashing.ndoc = ndoc;
    cashing.date = date;
    cashing.commentText = comment;
    cashing.debt = debt;
    cashing.outlet = outlet;
    
    debt.calculatedSum = [debt cashingCalculatedSum];
    
    [[self document] saveDocument:^(BOOL success) {
        
    }];
    
    [[self syncer] setSyncerState:STMSyncerSendDataOnce];
    
    NSLog(@"cashing %@", cashing);
    
    return cashing;
    
}

+ (void)removeCashing:(STMCashing *)cashing {
    
    [STMObjectsController removeObject:cashing];

}

@end
