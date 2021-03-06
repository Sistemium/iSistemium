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
    if (![self.shipments containsObject:shipment]) [self.shipments addObject:shipment];
    
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
            
//            if (success) {
//                [[STMShippingProcessController syncer] setSyncerState:STMSyncerSendDataOnce];
//            }
            
        }];

        completionHandler(YES);

    }

}

- (void)rejectShippingWithShipment:(STMShipment *)shipment {
    
    shipment.isShipped = @YES;
    
    shipment.isRejected = @YES;
    
}

- (void)cancelRejectShippingWithShipment:(STMShipment *)shipment {
    
    shipment.isShipped = @NO;
    
    shipment.isRejected = @NO;
    
}

- (void)resetPosition:(STMShipmentPosition *)position {
    
    position.articleFact = nil;
    position.doneVolume = nil;
    position.badVolume = nil;
    position.excessVolume = nil;
    position.shortageVolume = nil;
    position.brokenVolume = nil;
    position.isProcessed = nil;
    
    [[STMShippingProcessController document] saveDocument:^(BOOL success) {
    }];

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

- (NSString *)checkingInfoForPosition:(STMShipmentPosition *)position withDoneVolume:(NSInteger)doneVolume badVolume:(NSInteger)badVolume excessVolume:(NSInteger)excessVolume shortageVolume:(NSInteger)shortageVolume regradeVolume:(NSInteger)regradeVolume brokenVolume:(NSInteger)brokenVolume {
    
    NSString *beginningString = NSLocalizedString(@"SHIPPING POSITION ALERT BEGINNING STRING", nil);
    NSString *positionTitle = [NSString stringWithFormat:@"%@: %@", position.article.name, [position volumeText]];
    NSString *middleString = NSLocalizedString(@"SHIPPING POSITION ALERT MIDDLE STRING", nil);
    
    NSInteger packageRel = position.article.packageRel.integerValue;
    
    NSString *parametersString = [self volumesStringWithDoneVolume:doneVolume
                                                         badVolume:badVolume
                                                      excessVolume:excessVolume
                                                    shortageVolume:shortageVolume
                                                     regradeVolume:regradeVolume
                                                      brokenVolume:brokenVolume
                                                        packageRel:packageRel];

    NSString *endString = @"?";

    NSString *checkingInfo = [NSString stringWithFormat:@"%@\n\n%@\n\n%@\n\n%@\n\n%@", beginningString, positionTitle, middleString, parametersString, endString];
    
    return checkingInfo;
    
}

- (NSString *)volumesStringWithDoneVolume:(NSInteger)doneVolume badVolume:(NSInteger)badVolume excessVolume:(NSInteger)excessVolume shortageVolume:(NSInteger)shortageVolume regradeVolume:(NSInteger)regradeVolume brokenVolume:(NSInteger)brokenVolume packageRel:(NSInteger)packageRel {
    
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
    
    if (brokenVolume > 0) {
        
        NSString *brokenVolumeString = [STMFunctions volumeStringWithVolume:brokenVolume andPackageRel:packageRel];
        NSString *brokenString = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"BROKEN VOLUME LABEL", nil), brokenVolumeString];
        
        parametersString = [NSString stringWithFormat:@"%@%@\n", (parametersString) ? parametersString : @"", brokenString];
        
    }

    return parametersString;
    
}

- (NSAttributedString *)volumesAttributedStringWithAttributes:(NSDictionary *)attributes doneVolume:(NSInteger)doneVolume badVolume:(NSInteger)badVolume excessVolume:(NSInteger)excessVolume shortageVolume:(NSInteger)shortageVolume regradeVolume:(NSInteger)regradeVolume brokenVolume:(NSInteger)brokenVolume packageRel:(NSInteger)packageRel {
    
    NSMutableAttributedString *parametersString = [[NSMutableAttributedString alloc] initWithString:@"\n" attributes:attributes];
    
    if (doneVolume > 0) {
        
        NSString *doneVolumeString = [STMFunctions volumeStringWithVolume:doneVolume andPackageRel:packageRel];
        NSString *doneString = [NSString stringWithFormat:@"%@: %@\n", NSLocalizedString(@"DONE VOLUME LABEL", nil), doneVolumeString];

        [parametersString appendAttributedString:[[NSAttributedString alloc] initWithString:doneString attributes:attributes]];
        
    }

    NSMutableDictionary *redColorAttributes = attributes.mutableCopy;
    
    redColorAttributes[NSForegroundColorAttributeName] = [UIColor redColor];
    
    if (badVolume > 0) {
        
        NSString *badVolumeString = [STMFunctions volumeStringWithVolume:badVolume andPackageRel:packageRel];
        NSString *badString = [NSString stringWithFormat:@"%@: %@\n", NSLocalizedString(@"BAD VOLUME LABEL", nil), badVolumeString];
        
        [parametersString appendAttributedString:[[NSAttributedString alloc] initWithString:badString attributes:redColorAttributes]];
        
    }
    
    if (excessVolume > 0) {
        
        NSString *excessVolumeString = [STMFunctions volumeStringWithVolume:excessVolume andPackageRel:packageRel];
        NSString *excessString = [NSString stringWithFormat:@"%@: %@\n", NSLocalizedString(@"EXCESS VOLUME LABEL", nil), excessVolumeString];
        
        [parametersString appendAttributedString:[[NSAttributedString alloc] initWithString:excessString attributes:redColorAttributes]];
        
    }
    
    if (shortageVolume > 0) {
        
        NSString *shortageVolumeString = [STMFunctions volumeStringWithVolume:shortageVolume andPackageRel:packageRel];
        NSString *shortageString = [NSString stringWithFormat:@"%@: %@\n", NSLocalizedString(@"SHORTAGE VOLUME LABEL", nil), shortageVolumeString];
        
        [parametersString appendAttributedString:[[NSAttributedString alloc] initWithString:shortageString attributes:redColorAttributes]];
        
    }
    
    if (regradeVolume > 0) {
        
        NSString *regradeVolumeString = [STMFunctions volumeStringWithVolume:regradeVolume andPackageRel:packageRel];
        NSString *regradeString = [NSString stringWithFormat:@"%@: %@\n", NSLocalizedString(@"REGRADE VOLUME LABEL", nil), regradeVolumeString];
        
        [parametersString appendAttributedString:[[NSAttributedString alloc] initWithString:regradeString attributes:redColorAttributes]];
        
    }
    
    if (brokenVolume > 0) {
        
        NSString *brokenVolumeString = [STMFunctions volumeStringWithVolume:brokenVolume andPackageRel:packageRel];
        NSString *brokenString = [NSString stringWithFormat:@"%@: %@\n", NSLocalizedString(@"BROKEN VOLUME LABEL", nil), brokenVolumeString];
        
        [parametersString appendAttributedString:[[NSAttributedString alloc] initWithString:brokenString attributes:redColorAttributes]];
        
    }
    
    return parametersString;

}

- (void)shippingPosition:(STMShipmentPosition *)position withDoneVolume:(NSInteger)doneVolume {
    [self shippingPosition:position withDoneVolume:doneVolume badVolume:0 excessVolume:0 shortageVolume:0 regradeVolume:0 brokenVolume:0];
}

- (void)shippingPosition:(STMShipmentPosition *)position withBadVolume:(NSInteger)badVolume {
    [self shippingPosition:position withDoneVolume:0 badVolume:badVolume excessVolume:0 shortageVolume:0 regradeVolume:0 brokenVolume:0];
}

- (void)shippingPosition:(STMShipmentPosition *)position withExcessVolume:(NSInteger)excessVolume {
    [self shippingPosition:position withDoneVolume:0 badVolume:0 excessVolume:excessVolume shortageVolume:0 regradeVolume:0 brokenVolume:0];
}

- (void)shippingPosition:(STMShipmentPosition *)position withShortageVolume:(NSInteger)shortageVolume {
    [self shippingPosition:position withDoneVolume:0 badVolume:0 excessVolume:0 shortageVolume:shortageVolume regradeVolume:0 brokenVolume:0];
}

- (void)shippingPosition:(STMShipmentPosition *)position withRegradeVolume:(NSInteger)regradeVolume {
    [self shippingPosition:position withDoneVolume:0 badVolume:0 excessVolume:0 shortageVolume:0 regradeVolume:regradeVolume brokenVolume:0];
}

- (void)shippingPosition:(STMShipmentPosition *)position withBrokenVolume:(NSInteger)brokenVolume {
    [self shippingPosition:position withDoneVolume:0 badVolume:0 excessVolume:0 shortageVolume:0 regradeVolume:0 brokenVolume:brokenVolume];
}

- (void)shippingPosition:(STMShipmentPosition *)position withDoneVolume:(NSInteger)doneVolume badVolume:(NSInteger)badVolume excessVolume:(NSInteger)excessVolume shortageVolume:(NSInteger)shortageVolume regradeVolume:(NSInteger)regradeVolume brokenVolume:(NSInteger)brokenVolume {
    
    position.doneVolume = (doneVolume > 0) ? @(doneVolume) : nil;
    position.badVolume = (badVolume > 0) ? @(badVolume) : nil;
    position.excessVolume = (excessVolume > 0) ? @(excessVolume) : nil;
    position.shortageVolume = (shortageVolume > 0) ? @(shortageVolume) : nil;
    position.regradeVolume = (regradeVolume > 0) ? @(regradeVolume) : nil;
    position.brokenVolume = (brokenVolume > 0) ? @(brokenVolume) : nil;
    position.isProcessed = @YES;
    
    [[STMShippingProcessController document] saveDocument:^(BOOL success) {
    }];
    
}


#pragma mark - shipment info

- (BOOL)haveProcessedPositionsAtShipment:(STMShipment *)shipment {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isProcessed.boolValue == YES"];
    return ([shipment.shipmentPositions filteredSetUsingPredicate:predicate].count > 0);
    
}

- (BOOL)haveUnprocessedPositionsAtShipment:(STMShipment *)shipment {
    return ([self unprocessedPositionsCountForShipment:shipment] > 0);
}

- (NSUInteger)unprocessedPositionsCountForShipment:(STMShipment *)shipment {
    return [self unprocessedPositionsForShipment:shipment].count;
}

- (NSSet *)unprocessedPositionsForShipment:(STMShipment *)shipment {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isProcessed.boolValue != YES"];
    return [shipment.shipmentPositions filteredSetUsingPredicate:predicate];

}


@end
