//
//  STMCashingProcessController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 29/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMController.h"
#import "STMOutlet.h"
#import "STMDebt+Cashing.h"
#import "STMCashingController.h"

typedef NS_ENUM(NSInteger, STMCashingProcessState) {
    STMCashingProcessIdle,
    STMCashingProcessRunning
};


@interface STMCashingProcessController : STMController


+ (STMCashingProcessController *)sharedInstance;


@property (nonatomic) STMCashingProcessState state;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSMutableArray *debtsArray;
@property (nonatomic, strong) NSMutableDictionary *debtsDictionary;
@property (nonatomic, strong) NSMutableDictionary *commentsDictionary;
@property (nonatomic, strong) NSDecimalNumber *remainderSumm;
@property (nonatomic, strong) NSDecimalNumber *cashingSummLimit;
@property (nonatomic) BOOL cashingLimitIsReached;


- (void)startCashingProcessForOutlet:(STMOutlet *)outlet;
- (void)cancelCashingProcess;
- (void)doneCashingProcess;

- (void)addDebt:(STMDebt *)debt;
- (void)removeDebt:(STMDebt *)debt;

- (void)setCashingSum:(NSDecimalNumber *)cashingSum forDebt:(STMDebt *)debt;
- (void)setComment:(NSString *)comment forDebt:(STMDebt *)debt;

- (NSDecimalNumber *)debtsSumm;
- (void)fillingSumProcessing;

@end
