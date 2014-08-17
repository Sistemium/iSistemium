//
//  STMUncashing.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMCashing;

@interface STMUncashing : STMComment

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDecimalNumber * summ;
@property (nonatomic, retain) NSDecimalNumber * summOrigin;
@property (nonatomic, retain) NSSet *cashings;
@end

@interface STMUncashing (CoreDataGeneratedAccessors)

- (void)addCashingsObject:(STMCashing *)value;
- (void)removeCashingsObject:(STMCashing *)value;
- (void)addCashings:(NSSet *)values;
- (void)removeCashings:(NSSet *)values;

@end
