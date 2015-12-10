//
//  STMStockBatchOperation+CoreDataProperties.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMStockBatchOperation+CoreDataProperties.h"

@implementation STMStockBatchOperation (CoreDataProperties)

@dynamic destinationEntity;
@dynamic destinationXid;
@dynamic isProcessed;
@dynamic sourceEntity;
@dynamic sourceXid;
@dynamic volume;
@dynamic sourceAgent;
@dynamic destinationAgent;

@end