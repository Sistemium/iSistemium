//
//  STMStockBatch+CoreDataProperties.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMStockBatch+CoreDataProperties.h"

@implementation STMStockBatch (CoreDataProperties)

@dynamic processing;
@dynamic volume;
@dynamic article;
@dynamic barCodes;
@dynamic pickingOrderPositionsPicked;
@dynamic qualityClass;
@dynamic inventoryBatches;

@end
