//
//  STMPickingOrdersProcessController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 24/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMController.h"

@interface STMPickingOrdersProcessController : STMController

+ (void)position:(STMPickingOrderPosition *)position wasPickedWithVolume:(NSUInteger)volume andProductionInfo:(NSString *)info;

+ (void)pickPosition:(STMPickingOrderPosition *)position fromStockBatch:(STMStockBatch *)stockBatch withBarCode:(NSString *)barcode;

+ (void)deletePickedPosition:(STMPickingOrderPositionPicked *)pickedPosition;

@end
