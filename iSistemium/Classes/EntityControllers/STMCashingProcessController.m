//
//  STMCashingProcessController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 29/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMCashingProcessController.h"
#import "STMSessionManager.h"
#import "STMSyncer.h"
#import "STMCashing.h"
#import "STMEntityDescription.h"


@interface STMCashingProcessController()

@property (nonatomic, weak) STMOutlet *outlet;


@end


@implementation STMCashingProcessController

+ (STMCashingProcessController *)sharedInstance {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;

}

- (NSMutableDictionary *)debtsDictionary {
    
    if (!_debtsDictionary) {
        
        _debtsDictionary = [NSMutableDictionary dictionary];
        
    }
    
    return _debtsDictionary;
    
}

- (NSMutableDictionary *)commentsDictionary {
    
    if (!_commentsDictionary) {
        
        _commentsDictionary = [NSMutableDictionary dictionary];
        
    }
    
    return _commentsDictionary;
    
}

- (NSMutableArray *)debtsArray {
    
    if (!_debtsArray) {
        
        _debtsArray = [NSMutableArray array];
        
    }
    
    return _debtsArray;
    
}

- (void)setCashingSummLimit:(NSDecimalNumber *)cashingSummLimit {
    
    if (_cashingSummLimit != cashingSummLimit) {

        _cashingSummLimit = cashingSummLimit;
        
        if ([cashingSummLimit doubleValue] <= 0) {
            
            self.cashingLimitIsReached = NO;
            self.remainderSumm = nil;
            
        } else {
            
            self.remainderSumm = [cashingSummLimit decimalNumberBySubtracting:[self debtsSumm]];

        }
        
    }
    
}

- (void)setRemainderSumm:(NSDecimalNumber *)remainderSumm {
    
    if (_remainderSumm != remainderSumm) {
        
        _remainderSumm = remainderSumm;
        
        if (remainderSumm) {
         
            if ([remainderSumm doubleValue] < 0) {
                
                self.cashingLimitIsReached = YES;
                [self fillingSumProcessing];
                
            } else if ([remainderSumm doubleValue] == 0) {
                
                self.cashingLimitIsReached = YES;
                
            } else {
                
                self.cashingLimitIsReached = NO;
                
            }

        }
        
    }
    
}

- (void)startCashingProcessForOutlet:(STMOutlet *)outlet {
    
    self.state = STMCashingProcessRunning;
    self.outlet = outlet;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cashingProcessStart" object:self];
    
}

- (void)cancelCashingProcess {

    [self flushSelf];
    self.state = STMCashingProcessIdle;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cashingProcessCancel" object:self];

}

- (void)doneCashingProcess {

    if ([self.remainderSumm doubleValue] != 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil) message:NSLocalizedString(@"REM SUM NOT NULL", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
        
    } else {

        if ([[self debtsSumm] doubleValue] == 0) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil) message:NSLocalizedString(@"CASHING SUM IS NULL", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
            
        } else {
        
            [self saveCashings];
            [self flushSelf];
            self.state = STMCashingProcessIdle;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"cashingProcessDone" object:self];

        }
        
    }

}

- (void)flushSelf {

    self.debtsArray = nil;
    self.debtsDictionary = nil;
    self.commentsDictionary = nil;
    self.remainderSumm = nil;
    self.cashingSummLimit = nil;
    
}

- (void)addDebt:(STMDebt *)debt {
    
//    NSLog(@"addDebt %@ %@", debt.summ, debt.calculatedSum);
    
    if (![self.debtsArray containsObject:debt]) {
        
        if (debt.xid) {
            
            STMDebt *previousDebt = (self.debtsArray.lastObject) ? self.debtsArray.lastObject : [NSNull null];
            
            [self.debtsDictionary setObject:@[debt, debt.calculatedSum] forKey:debt.xid];
            [self.debtsArray addObject:debt];
            
            if ([self.cashingSummLimit doubleValue] > 0) {
                self.remainderSumm = [self.remainderSumm decimalNumberBySubtracting:debt.calculatedSum];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"debtAdded"
                                                                object:self
                                                              userInfo:@{@"debt": debt, @"previousDebt": previousDebt}];

        }
        
    } else {
        
        [self.debtsArray removeObject:debt];
        [self.debtsArray addObject:debt];
        
    }
    
}

- (void)setCashingSum:(NSDecimalNumber *)cashingSum forDebt:(STMDebt *)debt {
    
    [self.debtsDictionary setObject:@[debt, cashingSum] forKey:debt.xid];
    
    if ([self.cashingSummLimit doubleValue] > 0) {
        self.remainderSumm = [self.cashingSummLimit decimalNumberBySubtracting:[self debtsSumm]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cashingSumChanged"
                                                        object:self
                                                      userInfo:@{@"debt": debt, @"cashingSum": cashingSum}];
    
}

- (void)removeDebt:(STMDebt *)debt {

//    NSLog(@"removeDebt %@", debt.summ);

    if (debt.xid && [self.debtsArray containsObject:debt]) {
        
        [self.debtsDictionary removeObjectForKey:debt.xid];
        [self.debtsArray removeObject:debt];
        
        STMDebt *selectedDebt = (self.debtsArray.lastObject) ? self.debtsArray.lastObject : [NSNull null];
        
        if ([self.cashingSummLimit doubleValue] > 0) {
            self.remainderSumm = [self.cashingSummLimit decimalNumberBySubtracting:[self debtsSumm]];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"debtRemoved"
                                                            object:self
                                                          userInfo:@{@"debt": debt, @"selectedDebt": selectedDebt}];

    }
    
}

- (NSDecimalNumber *)debtsSumm {
    
    NSDecimalNumber *sum = [NSDecimalNumber zero];
    
    for (NSArray *debtValues in [self.debtsDictionary allValues]) {
        
        NSDecimalNumber *cashing = debtValues[1];
        
        sum = [sum decimalNumberByAdding:cashing];
        
    }
    
    return sum;
    
}

- (void)saveCashings {
    
    NSDate *date = self.selectedDate;
    
    for (NSArray *debtArray in [self.debtsDictionary allValues]) {
        
        STMDebt *debt = debtArray[0];
        NSDecimalNumber *summ = debtArray[1];
        NSString *commentText = [self.commentsDictionary objectForKey:debt.xid];
        
        STMCashing *cashing = [STMEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STMCashing class]) inManagedObjectContext:[STMController document].managedObjectContext];
        
        cashing.date = date;
        cashing.summ = summ;
        cashing.debt = debt;
        cashing.commentText = commentText;
        cashing.outlet = self.outlet;
        
        debt.calculatedSum = [debt cashingCalculatedSum];
        
    }
    
    [[STMController document] saveDocument:^(BOOL success) {
        if (success) {
            
            STMSyncer *syncer = [STMSessionManager sharedManager].currentSession.syncer;
            syncer.syncerState = STMSyncerSendDataOnce;
            
        }
    }];
    
    
}

- (void)setComment:(NSString *)comment forDebt:(STMDebt *)debt {
    
    if (debt.xid) {

        if (comment) {
            
            [self.commentsDictionary setObject:comment forKey:debt.xid];
            
        } else {

            [self.commentsDictionary removeObjectForKey:debt.xid];

        }

    }

}

- (void)fillingSumProcessing {
    
    NSDecimalNumber *fillingSumm = [NSDecimalNumber zero];
    
    STMDebt *lastDebt = [self.debtsArray lastObject];
    
    if (lastDebt) {
        
        NSDecimalNumber *cashingSum = [self.debtsDictionary objectForKey:lastDebt.xid][1];
        fillingSumm = [self.remainderSumm decimalNumberByAdding:cashingSum];
    
        if ([fillingSumm doubleValue] < 0) {
            
            [self removeDebt:lastDebt];
            
        } else {
            
            [self setCashingSum:fillingSumm forDebt:lastDebt];
            
        }

    }
    
}


@end
