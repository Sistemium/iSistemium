//
//  STMDebt+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMDebt.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMDebt (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDecimalNumber *calculatedSum;
@property (nullable, nonatomic, retain) NSString *checksum;
@property (nullable, nonatomic, retain) NSString *commentText;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSDate *dateE;
@property (nullable, nonatomic, retain) NSDate *deviceCts;
@property (nullable, nonatomic, retain) NSDate *deviceTs;
@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSNumber *isFantom;
@property (nullable, nonatomic, retain) NSDate *lts;
@property (nullable, nonatomic, retain) NSString *ndoc;
@property (nullable, nonatomic, retain) NSData *ownerXid;
@property (nullable, nonatomic, retain) NSString *responsibility;
@property (nullable, nonatomic, retain) NSString *source;
@property (nullable, nonatomic, retain) NSDate *sqts;
@property (nullable, nonatomic, retain) NSDate *sts;
@property (nullable, nonatomic, retain) NSDecimalNumber *summ;
@property (nullable, nonatomic, retain) NSDecimalNumber *summOrigin;
@property (nullable, nonatomic, retain) NSData *xid;
@property (nullable, nonatomic, retain) NSSet<STMCashing *> *cashings;
@property (nullable, nonatomic, retain) STMOutlet *outlet;

@end

@interface STMDebt (CoreDataGeneratedAccessors)

- (void)addCashingsObject:(STMCashing *)value;
- (void)removeCashingsObject:(STMCashing *)value;
- (void)addCashings:(NSSet<STMCashing *> *)values;
- (void)removeCashings:(NSSet<STMCashing *> *)values;

@end

NS_ASSUME_NONNULL_END
