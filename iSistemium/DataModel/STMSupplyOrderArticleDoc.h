//
//  STMSupplyOrderArticleDoc.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMStockBatchOperationAgent.h"

@class STMArticle, STMArticleDoc, STMSupplyOrder;

NS_ASSUME_NONNULL_BEGIN

@interface STMSupplyOrderArticleDoc : STMStockBatchOperationAgent

- (NSString *)volumeText;
- (STMArticle *)operatingArticle;

- (NSInteger)volumeRemainingToSupply;

- (NSInteger)lastSourceOperationVolume;
- (NSInteger)lastSourceOperationNumberOfBarcodes;


@end

NS_ASSUME_NONNULL_END

#import "STMSupplyOrderArticleDoc+CoreDataProperties.h"
