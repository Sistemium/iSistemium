//
//  STMStockBatchOperation+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMStockBatchOperation.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMStockBatchOperation (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *destinationEntity;
@property (nullable, nonatomic, retain) NSData *destinationXid;
@property (nullable, nonatomic, retain) NSNumber *isProcessed;
@property (nullable, nonatomic, retain) NSString *sourceEntity;
@property (nullable, nonatomic, retain) NSData *sourceXid;
@property (nullable, nonatomic, retain) NSNumber *volume;
@property (nullable, nonatomic, retain) STMStockBatchOperationAgent *sourceAgent;
@property (nullable, nonatomic, retain) STMStockBatchOperationAgent *destinationAgent;

@end

NS_ASSUME_NONNULL_END
