//
//  STMShipmentPosition.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 10/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMArticle, STMShipment;

@interface STMShipmentPosition : STMComment

@property (nonatomic, retain) NSNumber * badVolume;
@property (nonatomic, retain) NSNumber * doneVolume;
@property (nonatomic, retain) NSNumber * excessVolume;
@property (nonatomic, retain) NSNumber * isProcessed;
@property (nonatomic, retain) NSDecimalNumber * price;
@property (nonatomic, retain) NSDecimalNumber * priceDoc;
@property (nonatomic, retain) NSNumber * regradeVolume;
@property (nonatomic, retain) NSNumber * shortageVolume;
@property (nonatomic, retain) NSNumber * volume;
@property (nonatomic, retain) NSNumber * ord;
@property (nonatomic, retain) STMArticle *article;
@property (nonatomic, retain) STMArticle *articleFact;
@property (nonatomic, retain) STMShipment *shipment;

@end
