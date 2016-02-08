//
//  STMInventoryBatch.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMDatum.h"

@class STMArticle, STMInventoryBatchItem, STMStockBatch;

NS_ASSUME_NONNULL_BEGIN

@interface STMInventoryBatch : STMDatum

- (NSString *)displayProductionInfo;
- (STMArticle *)operatingArticle;


@end

NS_ASSUME_NONNULL_END

#import "STMInventoryBatch+CoreDataProperties.h"
