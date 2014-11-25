//
//  STMUncashingProcessController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 24/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMSingleton.h"
#import "STMCashing.h"
#import "STMUncashing.h"
#import "STMUncashingPlace.h"

@interface STMUncashingProcessController : STMSingleton

//+ (STMUncashingProcessController *)sharedInstance;

- (void)startWithCashings:(NSArray *)cashings;
- (void)cancelProcess;
- (STMUncashing *)uncashingDoneWithSum:(NSDecimalNumber *)summ image:(UIImage *)image type:(NSString *)type comment:(NSString *)comment place:(STMUncashingPlace *)place;

- (void)addCashing:(STMCashing *)cashing;
- (void)removeCashingWithXid:(NSData *)xid;
- (BOOL)hasCashingWithXid:(NSData *)xid;

@end
