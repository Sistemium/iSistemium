//
//  STMCashingProcessController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 29/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMCashingProcessController.h"
#import "STMDocument.h"
#import "STMSessionManager.h"
#import "STMSyncer.h"
#import "STMCashing.h"


@interface STMCashingProcessController()

@property (nonatomic, strong) STMDocument *document;
@property (nonatomic, strong) STMOutlet *outlet;
@property (nonatomic, strong) NSMutableDictionary *debtsDictionary;
@property (nonatomic, strong) NSMutableArray *debtsArray;
@property (nonatomic, strong) NSMutableDictionary *commentsDictionary;


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

- (STMDocument *)document {
    
    if (!_document) {
        
        _document = (STMDocument *)[[STMSessionManager sharedManager].currentSession document];
        
    }
    
    return _document;
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

- (void)startCashingProcessForOutlet:(STMOutlet *)outlet {
    
    self.state = STMCashingProcessRunning;
    self.outlet = outlet;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cashingProcessStart" object:self];
    
}

- (void)cancelCashingProcess {

    self.state = STMCashingProcessIdle;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cashingProcessCancel" object:self];

}

- (void)doneCashingProcess {

    self.state = STMCashingProcessIdle;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cashingProcessDone" object:self];

}

- (void)saveCashings {
    
    NSDate *date = self.selectedDate;
    
    for (NSArray *debtArray in [self.debtsDictionary allValues]) {
        
        STMDebt *debt = debtArray[0];
        NSDecimalNumber *summ = debtArray[1];
        NSString *commentText = [self.commentsDictionary objectForKey:debt.xid];
        
        STMCashing *cashing = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STMCashing class]) inManagedObjectContext:self.document.managedObjectContext];
        
        cashing.date = date;
        cashing.summ = summ;
        cashing.debt = debt;
        cashing.commentText = commentText;
        cashing.outlet = self.outlet;
        
        debt.calculatedSum = [debt cashingCalculatedSum];
        
    }
    
    [self.document saveDocument:^(BOOL success) {
        if (success) {
            
            STMSyncer *syncer = [STMSessionManager sharedManager].currentSession.syncer;
            syncer.syncerState = STMSyncerSendDataOnce;
            
        }
    }];
    
    
}


@end
