//
//  STMSupplyOrderOperationsTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 12/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"

@interface STMSupplyOrderOperationsTVC : STMVariableCellsHeightTVC

@property (nonatomic, strong) STMSupplyOrderArticleDoc *supplyOrderArticleDoc;

@property (nonatomic) BOOL repeatLastOperation;

- (void)orderProcessingChanged;
- (void)confirmArticle:(STMArticle *)article;
- (void)processStockBatchBarcode:(NSString *)barcode;


@end
