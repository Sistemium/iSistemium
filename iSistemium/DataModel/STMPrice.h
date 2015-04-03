//
//  STMPrice.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 22/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMArticle, STMPriceType;

@interface STMPrice : STMComment

@property (nonatomic, retain) NSDecimalNumber * price;
@property (nonatomic, retain) STMArticle *article;
@property (nonatomic, retain) STMPriceType *priceType;

@end
