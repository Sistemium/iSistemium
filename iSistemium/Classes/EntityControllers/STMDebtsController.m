//
//  STMDebtsController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMDebtsController.h"
#import "STMObjectsController.h"

@implementation STMDebtsController

+ (STMDebt *)addNewDebtWithSum:(NSDecimalNumber *)sum ndoc:(NSString *)ndoc date:(NSDate *)date outlet:(STMOutlet *)outlet {
    return [self addNewDebtWithSum:sum ndoc:ndoc date:date outlet:outlet comment:nil];
}

+ (STMDebt *)addNewDebtWithSum:(NSDecimalNumber *)sum ndoc:(NSString *)ndoc date:(NSDate *)date outlet:(STMOutlet *)outlet comment:(NSString *)commentText {
    
    STMDebt *debt = (STMDebt *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMDebt class])];
    
    debt.isFantom = @NO;
    debt.date = date;
    debt.summ = sum;
    debt.summOrigin = sum;
    debt.ndoc = ndoc;
    debt.outlet = outlet;
    debt.commentText = commentText;
    
    [[self document] saveDocument:^(BOOL success) {
//        if (success) [[self syncer] setSyncerState:STMSyncerSendDataOnce];
    }];
    
//    NSLog(@"debt %@", debt);
    
    return debt;
    
}

+ (void)removeDebt:(STMDebt *)debt {

    [STMObjectsController createRecordStatusAndRemoveObject:debt];

}


@end
