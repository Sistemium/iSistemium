//
//  STMInventoryNC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 05/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMActionPopoverNC.h"

#import "STMInventoryItemsVC.h"


@interface STMInventoryNC : STMActionPopoverNC

@property (nonatomic, strong) STMInventoryItemsVC *itemsVC;
@property (nonatomic) BOOL scanEnabled;
@property (nonatomic, strong) STMInventoryBatch *currentlyProcessedBatch;


- (void)selectArticle:(STMArticle *)article withSearchedBarcode:(NSString *)barcode;
- (void)selectInfo:(STMArticleProductionInfo *)info;

- (void)cancelCurrentInventoryProcessing;
- (void)doneCurrentInventoryProcessing;
- (void)editInventoryBatch:(STMInventoryBatch *)inventoryBatch;
- (void)deleteInventoryBatch:(STMInventoryBatch *)inventoryBatch;


@end
