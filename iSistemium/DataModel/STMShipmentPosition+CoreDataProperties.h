//
//  STMShipmentPosition+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMShipmentPosition.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMShipmentPosition (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *badVolume;
@property (nullable, nonatomic, retain) NSNumber *brokenVolume;
@property (nullable, nonatomic, retain) NSNumber *doneVolume;
@property (nullable, nonatomic, retain) NSNumber *excessVolume;
@property (nullable, nonatomic, retain) NSNumber *isProcessed;
@property (nullable, nonatomic, retain) NSNumber *ord;
@property (nullable, nonatomic, retain) NSDecimalNumber *price;
@property (nullable, nonatomic, retain) NSDecimalNumber *priceDoc;
@property (nullable, nonatomic, retain) NSNumber *regradeVolume;
@property (nullable, nonatomic, retain) NSNumber *shortageVolume;
@property (nullable, nonatomic, retain) NSNumber *volume;
@property (nullable, nonatomic, retain) STMArticle *article;
@property (nullable, nonatomic, retain) STMArticle *articleFact;
@property (nullable, nonatomic, retain) STMShipment *shipment;

@end

NS_ASSUME_NONNULL_END
