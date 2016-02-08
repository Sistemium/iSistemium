//
//  STMPriceType+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMPriceType.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMPriceType (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<STMPrice *> *prices;

@end

@interface STMPriceType (CoreDataGeneratedAccessors)

- (void)addPricesObject:(STMPrice *)value;
- (void)removePricesObject:(STMPrice *)value;
- (void)addPrices:(NSSet<STMPrice *> *)values;
- (void)removePrices:(NSSet<STMPrice *> *)values;

@end

NS_ASSUME_NONNULL_END
