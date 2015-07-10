//
//  STMShippingProcessController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 09/07/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShippingProcessController.h"

@implementation STMShippingProcessController

+ (STMShippingProcessController *)sharedInstance {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
    
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) [self addObservers];
    return self;
    
}

- (void)addObservers {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(authStateChanged)
               name:@"authControllerStateChanged"
             object:[STMAuthController authController]];
    
}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)authStateChanged {
    
    if ([STMAuthController authController].controllerState != STMAuthSuccess) {
        [self flushSelf];
    }
    
}

- (void)setState:(STMShippingProcessState)state {
    
    _state = state;
    
    if (_state == STMShippingProcessIdle) {
        [self flushSelf];
    }
    
}

- (NSMutableArray *)shipments {
    
    if (!_shipments) {
        _shipments = [NSMutableArray array];
    }
    return _shipments;
    
}

- (void)flushSelf {

    self.shipments = nil;

}

@end
