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

- (void)finishInventoryBatch;


@end
