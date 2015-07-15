//
//  STMShippingProcessController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 09/07/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMController.h"

typedef NS_ENUM(NSInteger, STMShippingProcessState) {
    STMShippingProcessIdle,
    STMShippingProcessRunning
};


@interface STMShippingProcessController : STMController

@property (nonatomic) STMShippingProcessState state;

@property (nonatomic, strong) NSMutableArray *shipments;


+ (STMShippingProcessController *)sharedInstance;


- (BOOL)shippingProcessIsRunningWithShipment:(STMShipment *)shipment;

- (void)startShippingWithShipment:(STMShipment *)shipment;
- (void)cancelShippingWithShipment:(STMShipment *)shipment;
- (void)stopShippingWithShipment:(STMShipment *)shipment withCompletionHandler:(void (^)(BOOL success))completionHandler;

- (void)resetPosition:(STMShipmentPosition *)position;

- (NSString *)checkingInfoForPosition:(STMShipmentPosition *)position
                       withDoneVolume:(NSInteger)doneVolume
                       shortageVolume:(NSInteger)shortageVolume
                         excessVolume:(NSInteger)excessVolume
                            badVolume:(NSInteger)badVolume;

- (void)shippingPosition:(STMShipmentPosition *)position
          withDoneVolume:(NSInteger)doneVolume
          shortageVolume:(NSInteger)shortageVolume
            excessVolume:(NSInteger)excessVolume
               badVolume:(NSInteger)badVolume;


- (BOOL)haveProcessedPositionsAtShipment:(STMShipment *)shipment;
- (BOOL)haveUnprocessedPositionsAtShipment:(STMShipment *)shipment;


@end
