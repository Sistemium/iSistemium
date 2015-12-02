//
//  STMStockBatchOperationAgent+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMStockBatchOperationAgent.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMStockBatchOperationAgent (CoreDataProperties)

@property (nullable, nonatomic, retain) NSSet<STMStockBatchOperation *> *sourceOperations;
@property (nullable, nonatomic, retain) NSSet<STMStockBatchOperation *> *destinationOperations;

@end

@interface STMStockBatchOperationAgent (CoreDataGeneratedAccessors)

- (void)addSourceOperationsObject:(STMStockBatchOperation *)value;
- (void)removeSourceOperationsObject:(STMStockBatchOperation *)value;
- (void)addSourceOperations:(NSSet<STMStockBatchOperation *> *)values;
- (void)removeSourceOperations:(NSSet<STMStockBatchOperation *> *)values;

- (void)addDestinationOperationsObject:(STMStockBatchOperation *)value;
- (void)removeDestinationOperationsObject:(STMStockBatchOperation *)value;
- (void)addDestinationOperations:(NSSet<STMStockBatchOperation *> *)values;
- (void)removeDestinationOperations:(NSSet<STMStockBatchOperation *> *)values;

@end

NS_ASSUME_NONNULL_END
