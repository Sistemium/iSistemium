//
//  STMInventoryController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 05/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMController.h"

#import "STMBarCodeScannerDelegate.h"


@interface STMInventoryController : STMController

+ (void)receiveBarcode:(NSString *)barcode withType:(STMBarCodeScannedType)type;


@end
