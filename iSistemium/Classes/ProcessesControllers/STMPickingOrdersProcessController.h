//
//  STMPickingOrdersProcessController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 24/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMController.h"

@interface STMPickingOrdersProcessController : STMController

+ (void)   position:(STMPickingOrderPosition *)position
wasPickedWithVolume:(NSUInteger)volume
  andProductionInfo:(NSString *)info
         andBarCode:(NSString *)barcode;

+ (void)pickPosition:(STMPickingOrderPosition *)position
      fromStockBatch:(STMStockBatch *)stockBatch
         withBarCode:(NSString *)barcode;

+ (void)pickedPosition:(STMPickingOrderPositionPicked *)pickedPosition
             newVolume:(NSUInteger)volume
     andProductionInfo:(NSString *)info;

+ (void)deletePickedPosition:(STMPickingOrderPositionPicked *)pickedPosition;


@end
