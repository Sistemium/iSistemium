//
//  STMInventoryBatchItem+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMInventoryBatchItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMInventoryBatchItem (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) STMInventoryBatch *inventoryBatch;

@end

NS_ASSUME_NONNULL_END
