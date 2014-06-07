//
//  STMTrack.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMLocation;

@interface STMTrack : STMComment

@property (nonatomic, retain) NSDate * finishTime;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSSet *locations;
@end

@interface STMTrack (CoreDataGeneratedAccessors)

- (void)addLocationsObject:(STMLocation *)value;
- (void)removeLocationsObject:(STMLocation *)value;
- (void)addLocations:(NSSet *)values;
- (void)removeLocations:(NSSet *)values;

@end
