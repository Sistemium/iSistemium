//
//  STMSaleOrderPosition.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 22/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMArticle, STMSaleOrder;

@interface STMSaleOrderPosition : STMComment

@property (nonatomic, retain) NSDecimalNumber * price;
@property (nonatomic, retain) NSDecimalNumber * priceDoc;
@property (nonatomic, retain) NSDecimalNumber * priceOrigin;
@property (nonatomic, retain) NSNumber * volume;
@property (nonatomic, retain) STMArticle *article;
@property (nonatomic, retain) STMSaleOrder *saleOrder;

@end
