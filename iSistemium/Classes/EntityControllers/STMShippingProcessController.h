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
- (void)doneShippingWithShipment:(STMShipment *)shipment withCompletionHandler:(void (^)(BOOL success))completionHandler;

- (void)resetPosition:(STMShipmentPosition *)position;

- (void)markUnprocessedPositionsAsDoneForShipment:(STMShipment *)shipment;

- (NSString *)checkingInfoForPosition:(STMShipmentPosition *)position
                       withDoneVolume:(NSInteger)doneVolume
                            badVolume:(NSInteger)badVolume
                         excessVolume:(NSInteger)excessVolume
                       shortageVolume:(NSInteger)shortageVolume
                        regradeVolume:(NSInteger)regradeVolume;

- (NSString *)volumesStringWithDoneVolume:(NSInteger)doneVolume
                                badVolume:(NSInteger)badVolume
                             excessVolume:(NSInteger)excessVolume
                           shortageVolume:(NSInteger)shortageVolume
                            regradeVolume:(NSInteger)regradeVolume
                               packageRel:(NSInteger)packageRel;

- (NSAttributedString *)volumesAttributedStringWithAttributes:(NSDictionary *)attributes
                                                   doneVolume:(NSInteger)doneVolume
                                                    badVolume:(NSInteger)badVolume
                                                 excessVolume:(NSInteger)excessVolume
                                               shortageVolume:(NSInteger)shortageVolume
                                                regradeVolume:(NSInteger)regradeVolume
                                                   packageRel:(NSInteger)packageRel;

- (void)shippingPosition:(STMShipmentPosition *)position
          withDoneVolume:(NSInteger)doneVolume;

- (void)shippingPosition:(STMShipmentPosition *)position
           withBadVolume:(NSInteger)badVolume;

- (void)shippingPosition:(STMShipmentPosition *)position
        withExcessVolume:(NSInteger)excessVolume;

- (void)shippingPosition:(STMShipmentPosition *)position
      withShortageVolume:(NSInteger)shortageVolume;

- (void)shippingPosition:(STMShipmentPosition *)position
       withRegradeVolume:(NSInteger)regradeVolume;

- (void)shippingPosition:(STMShipmentPosition *)position
          withDoneVolume:(NSInteger)doneVolume
               badVolume:(NSInteger)badVolume
            excessVolume:(NSInteger)excessVolume
          shortageVolume:(NSInteger)shortageVolume
           regradeVolume:(NSInteger)regradeVolume;

- (BOOL)haveProcessedPositionsAtShipment:(STMShipment *)shipment;
- (BOOL)haveUnprocessedPositionsAtShipment:(STMShipment *)shipment;
- (NSUInteger)unprocessedPositionsCountForShipment:(STMShipment *)shipment;
- (NSSet *)unprocessedPositionsForShipment:(STMShipment *)shipment;


@end
