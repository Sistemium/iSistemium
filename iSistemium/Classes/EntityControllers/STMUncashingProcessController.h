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

#define BANK_OFFICE_TYPE @"bankOffice"
#define CASH_DESK_TYPE @"cashDesk"

typedef enum {
    STMUncashingProcessIdle,
    STMUncashingProcessRunning
} STMUncashingProcessState;


@interface STMUncashingProcessController : NSObject


+ (STMUncashingProcessController *)sharedInstance;


@property (nonatomic, strong) NSMutableDictionary *cashingDictionary;
@property (nonatomic) STMUncashingProcessState state;

@property (nonatomic, strong) NSDecimalNumber *uncashingSum;
@property (nonatomic, strong) NSString *uncashingType;
@property (nonatomic, strong) NSString *commentText;
@property (nonatomic, strong) UIImage *pictureImage;
@property (nonatomic, strong) STMUncashingPlace *currentUncashingPlace;
@property (nonatomic, strong) NSDecimalNumber *summOrigin;

- (void)startWithCashings:(NSArray *)cashings;
- (void)cancelProcess;
- (void)uncashingDone;

- (void)addCashing:(STMCashing *)cashing;
- (void)removeCashing:(STMCashing *)cashing;
- (BOOL)hasCashingWithXid:(NSData *)xid;
- (void)checkUncashing;

@end
