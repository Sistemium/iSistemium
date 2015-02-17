//
//  STMCashing.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 13/02/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMDebt, STMOutlet, STMUncashing;

@interface STMCashing : STMComment

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * isProcessed;
@property (nonatomic, retain) NSDecimalNumber * summ;
@property (nonatomic, retain) NSString * ndoc;
@property (nonatomic, retain) STMDebt *debt;
@property (nonatomic, retain) STMOutlet *outlet;
@property (nonatomic, retain) STMUncashing *uncashing;

@end
