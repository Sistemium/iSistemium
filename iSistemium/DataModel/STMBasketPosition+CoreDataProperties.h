//
//  STMBasketPosition+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMBasketPosition.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMBasketPosition (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *volumeOne;
@property (nullable, nonatomic, retain) NSNumber *volumeTwo;
@property (nullable, nonatomic, retain) STMArticle *article;
@property (nullable, nonatomic, retain) STMOutlet *outlet;

@end

NS_ASSUME_NONNULL_END
