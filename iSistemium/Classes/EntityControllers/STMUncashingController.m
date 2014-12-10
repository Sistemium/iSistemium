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

+ (STMUncashingController *)sharedInstance {
    
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

- (void)removeUncashing:(STMUncashing *)uncashing {

    for (STMUncashingPicture *picture in uncashing.pictures) [STMObjectsController removeObject:picture];

    [STMObjectsController removeObject:uncashing];
        
}

@end
