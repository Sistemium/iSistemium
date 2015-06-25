//
//  STMArticle.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMArticle.h"
#import "STMArticleGroup.h"
#import "STMArticlePicture.h"
#import "STMCampaign.h"
#import "STMPrice.h"
#import "STMSaleOrderPosition.h"
#import "STMShipmentPosition.h"
#import "STMStock.h"


@implementation STMArticle

@dynamic code;
@dynamic extraLabel;
@dynamic factor;
@dynamic name;
@dynamic packageRel;
@dynamic pieceVolume;
@dynamic price;
@dynamic articleGroup;
@dynamic campaigns;
@dynamic pictures;
@dynamic prices;
@dynamic saleOrderPositions;
@dynamic stock;
@dynamic shipmentPositions;

@end
