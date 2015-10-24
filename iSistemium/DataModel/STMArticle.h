//
//  STMArticle.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 24/10/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMComment.h"

@class STMArticleGroup, STMArticlePicture, STMCampaign, STMPrice, STMSaleOrderPosition, STMShipmentPosition, STMStock;

NS_ASSUME_NONNULL_BEGIN

@interface STMArticle : STMComment

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "STMArticle+CoreDataProperties.h"
