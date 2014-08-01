//
//  STMCashing.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 01/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMDebt, STMOutlet;

@interface STMCashing : STMComment

@property (nonatomic, retain) NSDecimalNumber * summ;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) STMDebt *debt;
@property (nonatomic, retain) STMOutlet *outlet;

@end
