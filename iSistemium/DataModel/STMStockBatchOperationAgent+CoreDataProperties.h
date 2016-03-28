//
//  STMStockBatchOperationAgent+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMStockBatchOperationAgent.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMStockBatchOperationAgent (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *commentText;
@property (nullable, nonatomic, retain) NSDate *deviceCts;
@property (nullable, nonatomic, retain) NSDate *deviceTs;
@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSNumber *isFantom;
@property (nullable, nonatomic, retain) NSDate *lts;
@property (nullable, nonatomic, retain) NSData *ownerXid;
@property (nullable, nonatomic, retain) NSString *source;
@property (nullable, nonatomic, retain) NSDate *sqts;
@property (nullable, nonatomic, retain) NSDate *sts;
@property (nullable, nonatomic, retain) NSData *xid;
@property (nullable, nonatomic, retain) NSSet<STMStockBatchOperation *> *destinationOperations;
@property (nullable, nonatomic, retain) NSSet<STMStockBatchOperation *> *sourceOperations;

@end

@interface STMStockBatchOperationAgent (CoreDataGeneratedAccessors)

- (void)addDestinationOperationsObject:(STMStockBatchOperation *)value;
- (void)removeDestinationOperationsObject:(STMStockBatchOperation *)value;
- (void)addDestinationOperations:(NSSet<STMStockBatchOperation *> *)values;
- (void)removeDestinationOperations:(NSSet<STMStockBatchOperation *> *)values;

- (void)addSourceOperationsObject:(STMStockBatchOperation *)value;
- (void)removeSourceOperationsObject:(STMStockBatchOperation *)value;
- (void)addSourceOperations:(NSSet<STMStockBatchOperation *> *)values;
- (void)removeSourceOperations:(NSSet<STMStockBatchOperation *> *)values;

@end

NS_ASSUME_NONNULL_END
