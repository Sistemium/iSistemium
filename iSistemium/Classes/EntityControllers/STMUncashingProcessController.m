//
//  STMUncashingProcessController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 24/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMUncashingProcessController.h"
#import "STMUncashingPicture.h"

@interface STMUncashingProcessController ()

@property (nonatomic, strong) NSMutableDictionary *cashingDictionary;

@end

@implementation STMUncashingProcessController

//+ (STMUncashingProcessController *)sharedInstance {
//    
//    return [super sharedInstance];
//    
//}

- (NSMutableDictionary *)cashingDictionary {

    if (!_cashingDictionary) {

        _cashingDictionary = [NSMutableDictionary dictionary];

    }

    return _cashingDictionary;

}

- (void)startWithCashings:(NSArray *)cashings {
    
    for (STMCashing *cashing in cashings) {
        
        [self.cashingDictionary setObject:cashing forKey:cashing.xid];
        
    }
    
}

- (void)cancelProcess {
    
    self.cashingDictionary = nil;
    
}

- (STMUncashing *)uncashingDoneWithSum:(NSDecimalNumber *)summ image:(UIImage *)image type:(NSString *)type comment:(NSString *)comment place:(STMUncashingPlace *)place {
    
    STMUncashing *uncashing = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STMUncashing class]) inManagedObjectContext:self.document.managedObjectContext];
    
    NSArray *cashings = [self.cashingDictionary allValues];
    
    for (STMCashing *cashing in cashings) {
        
        cashing.uncashing = uncashing;
        
    }
    
//    uncashing.summOrigin = self.splitVC.masterVC.cashingSum;
    uncashing.summ = summ;
    uncashing.date = [NSDate date];
    
    if (image) {
        
        STMUncashingPicture *picture = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STMUncashingPicture class]) inManagedObjectContext:self.document.managedObjectContext];
        
        [STMObjectsController setImagesFromData:UIImageJPEGRepresentation(image, 0.0) forPicture:picture];
        
        [uncashing addPicturesObject:picture];
        
    }
    
    if (place) {
        
        uncashing.uncashingPlace = place;
        
    }
    
    uncashing.type = type;
    uncashing.commentText = comment;
    
    [self.document saveDocument:^(BOOL success) {
        if (success) {
            
            [[[[STMSessionManager sharedManager] currentSession] syncer] setSyncerState:STMSyncerSendDataOnce];
            
//            STMSyncer *syncer = [STMSessionManager sharedManager].currentSession.syncer;
//            syncer.syncerState = STMSyncerSendDataOnce;
            
        }
    }];

    return uncashing;
    
}

- (BOOL)hasCashingWithXid:(NSData *)xid {
    
    return [[self.cashingDictionary allKeys] containsObject:xid];
    
}

- (void)addCashing:(STMCashing *)cashing {
    
    [self.cashingDictionary setObject:cashing forKey:cashing.xid];
    
}

@end
