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
    
    shipment.isShipped = @NO;
    [self.shipments addObject:shipment];
    
}

- (void)cancelShippingWithShipment:(STMShipment *)shipment {
    
    for (STMShipmentPosition *position in shipment.shipmentPositions) {
        [self resetPosition:position];
    }
    
    shipment.isShipped = @NO;
    
    [self.shipments removeObject:shipment];
    
}

- (void)doneShippingWithShipment:(STMShipment *)shipment withCompletionHandler:(void (^)(BOOL success))completionHandler {

    if ([self haveUnprocessedPositionsAtShipment:shipment]) {
        
        completionHandler(NO);
        
    } else {
        
        shipment.isShipped = @YES;
        [self.shipments removeObject:shipment];
        
        [[STMShippingProcessController document] saveDocument:^(BOOL success) {
            
            if (success) {
                [[STMShippingProcessController syncer] setSyncerState:STMSyncerSendDataOnce];
            }
            
        }];

        completionHandler(YES);

    }

}

- (void)resetPosition:(STMShipmentPosition *)position {
    
    position.articleFact = nil;
    position.doneVolume = nil;
    position.badVolume = nil;
    position.excessVolume = nil;
    position.shortageVolume = nil;
    position.isProcessed = nil;
    
}

- (void)markUnprocessedPositionsAsDoneForShipment:(STMShipment *)shipment {
    
    if ([self shippingProcessIsRunningWithShipment:shipment]) {

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isProcessed.boolValue != YES"];
        NSArray *unprocessedPositions = [shipment.shipmentPositions filteredSetUsingPredicate:predicate].allObjects;
        
        for (STMShipmentPosition *position in unprocessedPositions) {
            [self shippingPosition:position withDoneVolume:position.volume.integerValue];
        }
        
    }
    
}

- (NSString *)checkingInfoForPosition:(STMShipmentPosition *)position withDoneVolume:(NSInteger)doneVolume badVolume:(NSInteger)badVolume excessVolume:(NSInteger)excessVolume shortageVolume:(NSInteger)shortageVolume regradeVolume:(NSInteger)regradeVolume {
    
    NSString *beginningString = NSLocalizedString(@"SHIPPING POSITION ALERT BEGINNING STRING", nil);
    NSString *positionTitle = [NSString stringWithFormat:@"%@: %@", position.article.name, [position volumeText]];
    NSString *middleString = NSLocalizedString(@"SHIPPING POSITION ALERT MIDDLE STRING", nil);
    
    NSInteger packageRel = position.article.packageRel.integerValue;
    
    NSString *parametersString = [self volumesStringWithDoneVolume:doneVolume
                                                         badVolume:badVolume
                                                      excessVolume:excessVolume
                                                    shortageVolume:shortageVolume
                                                     regradeVolume:regradeVolume
                                                        packageRel:packageRel];

    NSString *endString = @"?";

    NSString *checkingInfo = [NSString stringWithFormat:@"%@\n\n%@\n\n%@\n\n%@\n\n%@", beginningString, positionTitle, middleString, parametersString, endString];
    
    return checkingInfo;
    
}

- (NSString *)volumesStringWithDoneVolume:(NSInteger)doneVolume badVolume:(NSInteger)badVolume excessVolume:(NSInteger)excessVolume shortageVolume:(NSInteger)shortageVolume regradeVolume:(NSInteger)regradeVolume packageRel:(NSInteger)packageRel {
    
    NSString *parametersString = nil;
    
    if (doneVolume > 0) {
        
        NSString *doneVolumeString = [STMFunctions volumeStringWithVolume:doneVolume andPackageRel:packageRel];
        NSString *doneString = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"DONE VOLUME LABEL", nil), doneVolumeString];
        
        parametersString = [NSString stringWithFormat:@"%@%@\n", (parametersString) ? parametersString : @"", doneString];
        
    }
    
    if (badVolume > 0) {
        
        NSString *badVolumeString = [STMFunctions volumeStringWithVolume:badVolume andPackageRel:packageRel];
        NSString *badString = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"BAD VOLUME LABEL", nil), badVolumeString];
        
        parametersString = [NSString stringWithFormat:@"%@%@\n", (parametersString) ? parametersString : @"", badString];
        
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
    
    if (regradeVolume > 0) {
        
        NSString *regradeVolumeString = [STMFunctions volumeStringWithVolume:regradeVolume andPackageRel:packageRel];
        NSString *regradeString = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"REGRADE VOLUME LABEL", nil), regradeVolumeString];
        
        parametersString = [NSString stringWithFormat:@"%@%@\n", (parametersString) ? parametersString : @"", regradeString];
        
    }
    
    return parametersString;
    
}

- (void)shippingPosition:(STMShipmentPosition *)position withDoneVolume:(NSInteger)doneVolume {
    [self shippingPosition:position withDoneVolume:doneVolume badVolume:0 excessVolume:0 shortageVolume:0 regradeVolume:0];
}

- (void)shippingPosition:(STMShipmentPosition *)position withDoneVolume:(NSInteger)doneVolume badVolume:(NSInteger)badVolume excessVolume:(NSInteger)excessVolume shortageVolume:(NSInteger)shortageVolume regradeVolume:(NSInteger)regradeVolume {
    
    position.doneVolume = (doneVolume > 0) ? [NSNumber numberWithInteger:doneVolume] : nil;
    position.badVolume = (badVolume > 0) ? [NSNumber numberWithInteger:badVolume] : nil;
    position.excessVolume = (excessVolume > 0) ? [NSNumber numberWithInteger:excessVolume] : nil;
    position.shortageVolume = (shortageVolume > 0) ? [NSNumber numberWithInteger:shortageVolume] : nil;
    position.regradeVolume = (regradeVolume > 0) ? [NSNumber numberWithInteger:regradeVolume] : nil;
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
