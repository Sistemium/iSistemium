//
//  STMTrack+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMTrack.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMTrack (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *finishTime;
@property (nullable, nonatomic, retain) NSDate *startTime;
@property (nullable, nonatomic, retain) NSSet<STMLocation *> *locations;

@end

@interface STMTrack (CoreDataGeneratedAccessors)

- (void)addLocationsObject:(STMLocation *)value;
- (void)removeLocationsObject:(STMLocation *)value;
- (void)addLocations:(NSSet<STMLocation *> *)values;
- (void)removeLocations:(NSSet<STMLocation *> *)values;

@end

NS_ASSUME_NONNULL_END
