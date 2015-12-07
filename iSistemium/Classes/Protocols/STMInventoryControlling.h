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

- (void)shouldSelectArticleFromArray:(NSArray <STMArticle *>*)articles lookingForBarcode:(NSString *)barcode;

- (void)shouldSetProductionInfoForArticle:(STMArticle *)article;

- (void)didSuccessfullySelectArticle:(STMArticle *)article
                  withProductionInfo:(NSString *)productionInfo;

- (void)itemWasAdded:(STMInventoryBatchItem *)item;

- (void)finishInventoryBatch:(STMInventoryBatch *)inventoryBatch withStockBatch:(STMStockBatch *)stockBatch;


@end
