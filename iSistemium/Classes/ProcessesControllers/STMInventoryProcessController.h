//
//  STMInventoryProcessController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 05/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMController.h"

#import "STMBarCodeScannerDelegate.h"
#import "STMInventoryControlling.h"


@interface STMInventoryProcessController : STMController

+ (void)receiveBarcode:(NSString *)barcode withType:(STMBarCodeScannedType)type
                source:(id <STMInventoryControlling>)source;

+ (void)selectArticle:(STMArticle *)article
               source:(id <STMInventoryControlling>)source;

+ (void)productionInfo:(NSString *)productionInfo
         setForArticle:(STMArticle *)article
                source:(id <STMInventoryControlling>)source;

+ (void)cancelCurrentInventoryProcessingWithSource:(id <STMInventoryControlling>)source;

+ (void)doneCurrentInventoryProcessingWithSource:(id <STMInventoryControlling>)source;


@end
