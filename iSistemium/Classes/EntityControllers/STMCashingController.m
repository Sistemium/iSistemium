//
//  STMCashingController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 13/02/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMCashingController.h"
#import "STMDebt+Cashing.h"

@implementation STMCashingController

+ (STMCashing *)addCashingWithSum:(NSDecimalNumber *)sum ndoc:(NSString *)ndoc date:(NSDate *)date comment:(NSString *)comment debt:(STMDebt *)debt outlet:(STMOutlet *)outlet {
    
    STMCashing *cashing = [STMEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STMCashing class]) inManagedObjectContext:[STMController document].managedObjectContext];
    
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
    
    return cashing;
    
}


@end
