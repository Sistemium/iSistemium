//
//  STMCashingProcessController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 29/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMSingleton.h"


typedef enum {
    STMCashingProcessIdle,
    STMCashingProcessRunning
} STMCashingProcessState;


@interface STMCashingProcessController : NSObject


+ (STMCashingProcessController *)sharedInstance;


@property (nonatomic) STMCashingProcessState state;


- (void)startCashingProcess;
- (void)cancelCashingProcess;
- (void)doneCashingProcess;


@end
