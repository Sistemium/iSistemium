//
//  STMStockBatch.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 16/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMStockBatchOperationAgent.h"

@class STMArticle, STMPickingOrderPositionPicked, STMQualityClass, STMStockBatchBarCode;

NS_ASSUME_NONNULL_BEGIN

@interface STMStockBatch : STMStockBatchOperationAgent

- (NSInteger)localVolume;


@end

NS_ASSUME_NONNULL_END

#import "STMStockBatch+CoreDataProperties.h"
