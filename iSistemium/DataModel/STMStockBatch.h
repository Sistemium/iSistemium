//
//  STMStockBatch.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 16/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMComment.h"

@class STMArticle, STMBarCode, STMPickingOrderArticlePicked, STMQualityClass;

NS_ASSUME_NONNULL_BEGIN

@interface STMStockBatch : STMComment

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "STMStockBatch+CoreDataProperties.h"
