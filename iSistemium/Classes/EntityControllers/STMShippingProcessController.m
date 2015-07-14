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


#pragma mark - shipping process

- (BOOL)shippingProcessIsRunningWithShipment:(STMShipment *)shipment {
    return [self.shipments containsObject:shipment];
}

- (void)startShippingWithShipment:(STMShipment *)shipment {
    [self.shipments addObject:shipment];
}

- (void)cancelShippingWithShipment:(STMShipment *)shipment {
    
    for (STMShipmentPosition *position in shipment.shipmentPositions) {
        [self resetPosition:position];
    }
    
    shipment.isProcessed = @NO;
    
}

- (void)stopShippingWithShipment:(STMShipment *)shipment  withCompletionHandler:(void (^)(BOOL success))completionHandler {

    if ([self haveUnprocessedPositionsAtShipment:shipment]) {
        
        completionHandler(NO);
        
    } else {
        
        shipment.isProcessed = @YES;
        [self.shipments removeObject:shipment];
        completionHandler(YES);
        
    }

}

- (void)resetPosition:(STMShipmentPosition *)position {
    
    position.doneVolume = nil;
    position.badVolume = nil;
    position.excessVolume = nil;
    position.shortageVolume = nil;
    position.isProcessed = nil;
    
}


#pragma mark - shipment info

- (BOOL)haveProcessedPositionsAtShipment:(STMShipment *)shipment {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isProcessed.boolValue == YES"];
    return ([shipment.shipmentPositions filteredSetUsingPredicate:predicate].count > 0);
    
}

- (BOOL)haveUnprocessedPositionsAtShipment:(STMShipment *)shipment {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isProcessed.boolValue != YES"];
    return ([shipment.shipmentPositions filteredSetUsingPredicate:predicate].count > 0);
    
}


@end
