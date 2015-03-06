//
//  STMSaleOrderPosition.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 06/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMArticle, STMSaleOrder;

@interface STMSaleOrderPosition : STMComment

@property (nonatomic, retain) NSNumber * volume;
@property (nonatomic, retain) NSDecimalNumber * price0;
@property (nonatomic, retain) NSDecimalNumber * price1;
@property (nonatomic, retain) NSDecimalNumber * priceOrigin;
@property (nonatomic, retain) STMSaleOrder *saleOrder;
@property (nonatomic, retain) STMArticle *article;

@end
