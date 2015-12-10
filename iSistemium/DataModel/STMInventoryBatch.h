//
//  STMInventoryBatch.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMComment.h"

@class STMArticle, STMInventoryBatchItem, STMStockBatch;

NS_ASSUME_NONNULL_BEGIN

@interface STMInventoryBatch : STMComment

- (NSString *)displayProductionInfo;


@end

NS_ASSUME_NONNULL_END

#import "STMInventoryBatch+CoreDataProperties.h"
