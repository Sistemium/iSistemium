//
//  STMDatum+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 01/01/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMDatum.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMDatum (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *deviceCts;
@property (nullable, nonatomic, retain) NSDate *deviceTs;
@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSNumber *isFantom;
@property (nullable, nonatomic, retain) NSDate *lts;
@property (nullable, nonatomic, retain) NSDate *sqts;
@property (nullable, nonatomic, retain) NSDate *sts;
@property (nullable, nonatomic, retain) NSData *xid;
@property (nullable, nonatomic, retain) NSString *checksum;
@property (nullable, nonatomic, retain) NSSet<STMComment *> *comments;

@end

@interface STMDatum (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(STMComment *)value;
- (void)removeCommentsObject:(STMComment *)value;
- (void)addComments:(NSSet<STMComment *> *)values;
- (void)removeComments:(NSSet<STMComment *> *)values;

@end

NS_ASSUME_NONNULL_END
