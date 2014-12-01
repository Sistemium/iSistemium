//
//  STMUncashingController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 19/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMUncashingController.h"
#import "STMSessionManager.h"
#import "STMDocument.h"
#import "STMRecordStatus.h"
#import "STMObjectsController.h"
#import "STMUncashingPicture.h"

@interface STMUncashingController()

@property (nonatomic, strong) STMDocument *document;


@end


@implementation STMUncashingController

+ (STMUncashingController *)sharedController {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedController = nil;
    
    dispatch_once(&pred, ^{
        _sharedController = [[self alloc] init];
    });
    
    return _sharedController;
    
}

- (STMDocument *)document {
    
    if (!_document) {
        
        _document = (STMDocument *)[[STMSessionManager sharedManager].currentSession document];
        
    }
    
    return _document;
}

- (void)removeUncashing:(STMUncashing *)uncashing {

    STMRecordStatus *uncashingRecordStatus = [STMObjectsController recordStatusForObject:uncashing];
    uncashingRecordStatus.isRemoved = [NSNumber numberWithBool:YES];
    
    for (STMUncashingPicture *picture in uncashing.pictures) {
        
        STMRecordStatus *pictureRecordStatus = [STMObjectsController recordStatusForObject:picture];
        pictureRecordStatus.isRemoved = [NSNumber numberWithBool:YES];
        
        [self.document.managedObjectContext deleteObject:picture];
        
    }
    
    [self.document.managedObjectContext deleteObject:uncashing];
    [self.document saveDocument:^(BOOL success) {
        
        if (success) {
            
            [STMSessionManager sharedManager].currentSession.syncer.syncerState = STMSyncerSendDataOnce;
            
        }
        
    }];
    
}

@end
