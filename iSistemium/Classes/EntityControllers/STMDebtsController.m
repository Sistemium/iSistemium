//
//  STMDebtsController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMDebtsController.h"
#import "STMDocument.h"
#import "STMSessionManager.h"
#import "STMObjectsController.h"

@implementation STMDebtsController

+ (STMDebt *)addNewDebtWithSum:(NSDecimalNumber *)sum ndoc:(NSString *)ndoc date:(NSDate *)date outlet:(STMOutlet *)outlet {
    
    STMDebt *debt = (STMDebt *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMDebt class])];
    
    debt.isFantom = [NSNumber numberWithBool:NO];
    debt.date = date;
    debt.summ = sum;
    debt.summOrigin = sum;
    debt.ndoc = ndoc;
    debt.outlet = outlet;
    
    STMDocument *document = (STMDocument *)[[STMSessionManager sharedManager].currentSession document];
    [document saveDocument:^(BOOL success) {
        
    }];
    
    [[[STMSessionManager sharedManager].currentSession syncer] setSyncerState:STMSyncerSendDataOnce];
    
//    NSLog(@"debt %@", debt);
    
    return debt;
    
}


@end
