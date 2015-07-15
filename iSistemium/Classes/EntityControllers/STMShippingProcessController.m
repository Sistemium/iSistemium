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

- (NSString *)checkingInfoForPosition:(STMShipmentPosition *)position withDoneVolume:(NSInteger)doneVolume shortageVolume:(NSInteger)shortageVolume excessVolume:(NSInteger)excessVolume badVolume:(NSInteger)badVolume {
    
    NSString *beginningString = NSLocalizedString(@"SHIPPING POSITION ALERT BEGINNING STRING", nil);
    NSString *positionTitle = [NSString stringWithFormat:@"%@: %@", position.article.name, [position volumeText]];
    NSString *middleString = NSLocalizedString(@"SHIPPING POSITION ALERT MIDDLE STRING", nil);
    
    NSInteger packageRel = position.article.packageRel.integerValue;
    
    NSString *parametersString = nil;
    
    if (doneVolume > 0) {
        
        NSString *doneVolumeString = [STMFunctions volumeStringWithVolume:doneVolume andPackageRel:packageRel];
        NSString *doneString = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"DONE VOLUME LABEL", nil), doneVolumeString];

        parametersString = [NSString stringWithFormat:@"%@%@\n", (parametersString) ? parametersString : @"", doneString];
        
    }
    
    if (excessVolume > 0) {
        
        NSString *excessVolumeString = [STMFunctions volumeStringWithVolume:excessVolume andPackageRel:packageRel];
        NSString *excessString = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"EXCESS VOLUME LABEL", nil), excessVolumeString];

        parametersString = [NSString stringWithFormat:@"%@%@\n", (parametersString) ? parametersString : @"", excessString];

    }

    if (shortageVolume > 0) {
        
        NSString *shortageVolumeString = [STMFunctions volumeStringWithVolume:shortageVolume andPackageRel:packageRel];
        NSString *shortageString = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"SHORTAGE VOLUME LABEL", nil), shortageVolumeString];

        parametersString = [NSString stringWithFormat:@"%@%@\n", (parametersString) ? parametersString : @"", shortageString];

    }

    if (badVolume > 0) {
        
        NSString *badVolumeString = [STMFunctions volumeStringWithVolume:badVolume andPackageRel:packageRel];
        NSString *badString = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"BAD VOLUME LABEL", nil), badVolumeString];

        parametersString = [NSString stringWithFormat:@"%@%@\n", (parametersString) ? parametersString : @"", badString];
        
    }

    NSString *endString = @"?";

    NSString *checkingInfo = [NSString stringWithFormat:@"%@\n\n%@\n\n%@\n\n%@\n\n%@", beginningString, positionTitle, middleString, parametersString, endString];
    
    return checkingInfo;
    
}

- (void)shippingPosition:(STMShipmentPosition *)position withDoneVolume:(NSInteger)doneVolume shortageVolume:(NSInteger)shortageVolume excessVolume:(NSInteger)excessVolume badVolume:(NSInteger)badVolume {
    
    position.doneVolume = [NSNumber numberWithInteger:doneVolume];
    position.badVolume = [NSNumber numberWithInteger:badVolume];
    position.excessVolume = [NSNumber numberWithInteger:excessVolume];
    position.shortageVolume = [NSNumber numberWithInteger:shortageVolume];
    position.isProcessed = @YES;
    
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
