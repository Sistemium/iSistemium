//
//  STMUncashingProcessController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 24/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMUncashingProcessController.h"
#import "STMUncashingPicture.h"
#import "STMPicturesController.h"
#import "STMSessionManager.h"

@interface STMUncashingProcessController ()

@end


@implementation STMUncashingProcessController

+ (STMUncashingProcessController *)sharedInstance {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
    
}

- (NSMutableDictionary *)cashingDictionary {

    if (!_cashingDictionary) {

        _cashingDictionary = [NSMutableDictionary dictionary];

    }

    return _cashingDictionary;

}

- (STMUncashingProcessState)state {
    
    if (!_state) {
        _state = STMUncashingProcessIdle;
    }
    return _state;
    
}

- (void)startWithCashings:(NSArray *)cashings {
    
    self.cashingDictionary = nil;
    
    for (STMCashing *cashing in cashings) {
        
        (self.cashingDictionary)[cashing.xid] = cashing;
        
    }
    
    self.state = STMUncashingProcessRunning;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"uncashingProcessStart" object:self];
    
}

- (void)cancelProcess {
    
    self.cashingDictionary = nil;
    self.state = STMUncashingProcessIdle;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"uncashingProcessCancel" object:self];

}

- (void)uncashingDone {
    
    [self uncashingDoneWithSum:self.uncashingSum
                         image:self.pictureImage
                          type:self.uncashingType
                       comment:self.commentText
                         place:self.currentUncashingPlace];
    
}

- (STMUncashing *)uncashingDoneWithSum:(NSDecimalNumber *)summ image:(UIImage *)image type:(NSString *)type comment:(NSString *)comment place:(STMUncashingPlace *)place {
    
    if ([self.uncashingType isEqualToString:BANK_OFFICE_TYPE]) {
        
        self.currentUncashingPlace = nil;
        
    } else if ([self.uncashingType isEqualToString:CASH_DESK_TYPE]) {
        
        self.pictureImage = nil;
        
    }
    
    STMUncashing *uncashing = [STMEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STMUncashing class]) inManagedObjectContext:[STMController document].managedObjectContext];
    
    NSArray *cashings = [self.cashingDictionary allValues];
    
    for (STMCashing *cashing in cashings) {
        
        cashing.uncashing = uncashing;
        
    }

    uncashing.summOrigin = self.summOrigin;
    uncashing.summ = summ;
    uncashing.date = [NSDate date];
    
    if (image) {
        
        STMUncashingPicture *picture = [STMEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STMUncashingPicture class]) inManagedObjectContext:[STMController document].managedObjectContext];
        
        [STMPicturesController setImagesFromData:UIImageJPEGRepresentation(image, 0.0) forPicture:picture];
        
        [uncashing addPicturesObject:picture];
        
    }
    
    if (place) {
        
        uncashing.uncashingPlace = place;
        
    }
    
    uncashing.type = type;
    uncashing.commentText = comment;
    
    [[STMController document] saveDocument:^(BOOL success) {
        if (success) {
            
            [[[[STMSessionManager sharedManager] currentSession] syncer] setSyncerState:STMSyncerSendDataOnce];
            
        }
    }];

    self.state = STMUncashingProcessIdle;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"uncashingProcessDone" object:self];

    self.cashingDictionary = nil;
    
    return uncashing;
    
}

- (void)addCashing:(STMCashing *)cashing {

    if (cashing && cashing.xid) {
        
        (self.cashingDictionary)[cashing.xid] = cashing;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cashingDictionaryChanged" object:self];

    }
    
}

- (BOOL)hasCashingWithXid:(NSData *)xid {
    
    return [[self.cashingDictionary allKeys] containsObject:xid];
    
}

- (void)removeCashing:(STMCashing *)cashing {
    
    if (cashing.xid) {
        
        [self.cashingDictionary removeObjectForKey:cashing.xid];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cashingDictionaryChanged" object:self];

    }
    
}

- (void)checkUncashing {
    
    if ([self uncashingIsValid]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"uncashingIsValid" object:self];
        
    }

}

- (BOOL)uncashingIsValid {
    
    if (self.uncashingSum.doubleValue <= 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil)
                                                        message:NSLocalizedString(@"UNCASHING SUM NOT VALID", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                              otherButtonTitles:nil];
        [alert show];
        
        return NO;
        
    } else if (!self.uncashingType) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil)
                                                        message:NSLocalizedString(@"NO UNCASHING TYPE", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                              otherButtonTitles:nil];
        [alert show];
        
        return NO;
        
    } else if ([self.uncashingType isEqualToString:BANK_OFFICE_TYPE] && !self.pictureImage) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil)
                                                        message:NSLocalizedString(@"NO CHECK IMAGE", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                              otherButtonTitles:nil];
        [alert show];
        
        return NO;
        
    } else if ([self.uncashingType isEqualToString:CASH_DESK_TYPE] && !self.currentUncashingPlace) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil)
                                                        message:NSLocalizedString(@"NO CASH DESK CHOOSEN", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                              otherButtonTitles:nil];
        [alert show];
        
        return NO;
        
    } else {
        
        return YES;
        
    }
    
}

@end
