//
//  STMUncashingPlace+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMUncashingPlace.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMUncashingPlace (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *commentText;
@property (nullable, nonatomic, retain) NSDate *deviceCts;
@property (nullable, nonatomic, retain) NSDate *deviceTs;
@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSNumber *isFantom;
@property (nullable, nonatomic, retain) NSDate *lts;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSData *ownerXid;
@property (nullable, nonatomic, retain) NSString *source;
@property (nullable, nonatomic, retain) NSDate *sqts;
@property (nullable, nonatomic, retain) NSDate *sts;
@property (nullable, nonatomic, retain) NSData *xid;
@property (nullable, nonatomic, retain) NSSet<STMUncashing *> *uncashings;

@end

@interface STMUncashingPlace (CoreDataGeneratedAccessors)

- (void)addUncashingsObject:(STMUncashing *)value;
- (void)removeUncashingsObject:(STMUncashing *)value;
- (void)addUncashings:(NSSet<STMUncashing *> *)values;
- (void)removeUncashings:(NSSet<STMUncashing *> *)values;

@end

NS_ASSUME_NONNULL_END
