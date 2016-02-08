//
//  STMSaleOrderPosition+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMSaleOrderPosition.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMSaleOrderPosition (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDecimalNumber *price;
@property (nullable, nonatomic, retain) NSDecimalNumber *priceDoc;
@property (nullable, nonatomic, retain) NSDecimalNumber *priceOrigin;
@property (nullable, nonatomic, retain) NSNumber *volume;
@property (nullable, nonatomic, retain) STMArticle *article;
@property (nullable, nonatomic, retain) STMSaleOrder *saleOrder;

@end

NS_ASSUME_NONNULL_END
