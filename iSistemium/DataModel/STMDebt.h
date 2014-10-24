//
//  STMDebt.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 24/10/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMCashing, STMOutlet;

@interface STMDebt : STMComment

@property (nonatomic, retain) NSDecimalNumber * calculatedSum;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * ndoc;
@property (nonatomic, retain) NSDecimalNumber * summ;
@property (nonatomic, retain) NSDecimalNumber * summOrigin;
@property (nonatomic, retain) NSDate * dateE;
@property (nonatomic, retain) NSString * responsibility;
@property (nonatomic, retain) NSSet *cashings;
@property (nonatomic, retain) STMOutlet *outlet;
@end

@interface STMDebt (CoreDataGeneratedAccessors)

- (void)addCashingsObject:(STMCashing *)value;
- (void)removeCashingsObject:(STMCashing *)value;
- (void)addCashings:(NSSet *)values;
- (void)removeCashings:(NSSet *)values;

@end
