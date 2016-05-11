//
//  STMBarCodeController+category.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/04/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMBarCodeController.h"

#import "STMController.h"


@interface STMBarCodeController (category)

+ (NSArray <STMArticle *> *)articlesForBarcode:(NSString *)barcode;
+ (NSArray <STMStockBatch *> *)stockBatchForBarcode:(NSString *)barcode;

+ (void)addBarcode:(NSString *)barcode toArticle:(STMArticle *)article;


@end
