//
//  STMInventoryControlling.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 06/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STMDataModel.h"


@protocol STMInventoryControlling <NSObject>

@required

- (void)requestForArticleBarcode;
- (void)didSelectInventoryBatch:(STMInventoryBatch *)inventoryBatch;

- (void)shouldSelectArticleFromArray:(NSArray <STMArticle *>*)articles
                   lookingForBarcode:(NSString *)barcode;

- (void)shouldSetProductionInfoForArticle:(STMArticle *)article;

- (void)didSuccessfullySelectArticle:(STMArticle *)article
                  withProductionInfo:(NSString *)productionInfo;


// old

- (void)itemWasAdded:(STMInventoryBatchItem *)item;

- (void)finishInventoryBatch:(STMInventoryBatch *)inventoryBatch
              withStockBatch:(STMStockBatch *)stockBatch;

- (void)shouldConfirmArticleMismatchForStockBatch:(STMStockBatch *)stockBatch
                               withInventoryBatch:(STMInventoryBatch *)inventoryBatch;


@end
