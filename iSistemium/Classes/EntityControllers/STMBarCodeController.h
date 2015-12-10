//
//  STMBarCodeController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 05/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMController.h"

@interface STMBarCodeController : STMController

+ (NSArray <STMArticle *> *)articlesForBarcode:(NSString *)barcode;
+ (NSArray <STMStockBatch *> *)stockBatchForBarcode:(NSString *)barcode;


@end
