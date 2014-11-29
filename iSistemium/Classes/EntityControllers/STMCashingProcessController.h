//
//  STMCashingProcessController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 29/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMSingleton.h"

@interface STMCashingProcessController : NSObject

+ (STMCashingProcessController *)sharedInstance;


- (void)startCashingProcess;
- (void)cancelCashingProcess;
- (void)doneCashingProcess;


@end
