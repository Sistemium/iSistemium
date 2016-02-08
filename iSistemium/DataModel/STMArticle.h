//
//  STMArticle.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 24/10/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMDatum.h"

@class STMArticleBarCode, STMArticleDoc, STMArticleGroup, STMArticlePicture, STMArticleProductionInfo, STMBasketPosition, STMCampaign, STMInventoryBatch, STMPickingOrderPosition, STMPickingOrderPositionPicked, STMPrice, STMProductionInfoType, STMSaleOrderPosition, STMShipmentPosition, STMStock, STMStockBatch, STMSupplyOrderArticleDoc;

NS_ASSUME_NONNULL_BEGIN

@interface STMArticle : STMDatum

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "STMArticle+CoreDataProperties.h"
