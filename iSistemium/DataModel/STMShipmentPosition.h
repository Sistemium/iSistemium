//
//  STMShipmentPosition.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMArticle, STMShipment;

@interface STMShipmentPosition : STMComment

@property (nonatomic, retain) NSNumber * volume;
@property (nonatomic, retain) NSDecimalNumber * price;
@property (nonatomic, retain) NSDecimalNumber * priceDoc;
@property (nonatomic, retain) STMShipment *shipment;
@property (nonatomic, retain) STMArticle *article;

@end
