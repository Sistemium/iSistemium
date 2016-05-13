//
//  STMBarCodeController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 13/05/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMCoreBarCodeController.h"

#import "STMDataModel.h"


@interface STMBarCodeController : STMCoreBarCodeController

+ (NSArray <STMArticle *> *)articlesForBarcode:(NSString *)barcode;
+ (NSArray <STMStockBatch *> *)stockBatchForBarcode:(NSString *)barcode;

+ (void)addBarcode:(NSString *)barcode toArticle:(STMArticle *)article;


@end
