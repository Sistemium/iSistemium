//
//  STMCashingProcessController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 29/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMSingleton.h"
#import "STMOutlet.h"
#import "STMDebt+Cashing.h"


typedef enum {
    STMCashingProcessIdle,
    STMCashingProcessRunning
} STMCashingProcessState;


@interface STMCashingProcessController : NSObject


+ (STMCashingProcessController *)sharedInstance;


@property (nonatomic) STMCashingProcessState state;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSMutableArray *debtsArray;
@property (nonatomic, strong) NSMutableDictionary *debtsDictionary;
@property (nonatomic, strong) NSMutableDictionary *commentsDictionary;
@property (nonatomic, strong) NSDecimalNumber *remainderSumm;
@property (nonatomic, strong) NSDecimalNumber *cashingSummLimit;


- (void)startCashingProcessForOutlet:(STMOutlet *)outlet;
- (void)cancelCashingProcess;
- (void)doneCashingProcess;

- (void)addDebt:(STMDebt *)debt;
- (void)removeDebt:(STMDebt *)debt;

- (void)setCashingSum:(NSDecimalNumber *)cashingSum forDebt:(STMDebt *)debt;
- (void)setComment:(NSString *)comment forDebt:(STMDebt *)debt;

- (NSDecimalNumber *)debtsSumm;
- (NSDecimalNumber *)fillingSumProcessing;

@end
