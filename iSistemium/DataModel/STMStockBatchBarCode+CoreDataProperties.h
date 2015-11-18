//
//  STMStockBatchBarCode+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMStockBatchBarCode.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMStockBatchBarCode (CoreDataProperties)

@property (nullable, nonatomic, retain) STMStockBatch *stockBatch;

@end

NS_ASSUME_NONNULL_END
