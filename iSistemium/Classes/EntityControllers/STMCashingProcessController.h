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


- (void)startCashingProcessForOutlet:(STMOutlet *)outlet;
- (void)cancelCashingProcess;
- (void)doneCashingProcess;

- (void)addCashing:(STMDebt *)debt;
- (void)removeCashing:(STMDebt *)debt;


@end
