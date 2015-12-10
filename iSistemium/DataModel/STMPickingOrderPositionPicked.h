//
//  STMPickingOrderPositionPicked.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMStockBatchOperationAgent.h"

@class STMArticle, STMPickingOrderPosition, STMStockBatch;

NS_ASSUME_NONNULL_BEGIN

@interface STMPickingOrderPositionPicked : STMStockBatchOperationAgent

- (NSString *)displayProductionInfo;


@end

NS_ASSUME_NONNULL_END

#import "STMPickingOrderPositionPicked+CoreDataProperties.h"
