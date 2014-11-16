//
//  STMUncashingPlace.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 16/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMUncashing;

@interface STMUncashingPlace : STMComment

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *uncashings;
@end

@interface STMUncashingPlace (CoreDataGeneratedAccessors)

- (void)addUncashingsObject:(STMUncashing *)value;
- (void)removeUncashingsObject:(STMUncashing *)value;
- (void)addUncashings:(NSSet *)values;
- (void)removeUncashings:(NSSet *)values;

@end
