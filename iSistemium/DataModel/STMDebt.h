//
//  STMDebt.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 28/07/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMOutlet;

@interface STMDebt : STMComment

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDecimalNumber * summ;
@property (nonatomic, retain) NSDecimalNumber * summOrigin;
@property (nonatomic, retain) NSString * ndoc;
@property (nonatomic, retain) STMOutlet *outlet;

@end
