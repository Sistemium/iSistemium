//
//  STMPriceType.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 22/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMPrice;

@interface STMPriceType : STMComment

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *prices;
@end

@interface STMPriceType (CoreDataGeneratedAccessors)

- (void)addPricesObject:(STMPrice *)value;
- (void)removePricesObject:(STMPrice *)value;
- (void)addPrices:(NSSet *)values;
- (void)removePrices:(NSSet *)values;

@end
