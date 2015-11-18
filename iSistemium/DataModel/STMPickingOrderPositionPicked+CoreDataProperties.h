//
//  STMPickingOrderPositionPicked+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMPickingOrderPositionPicked.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMPickingOrderPositionPicked (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) NSString *productionInfo;
@property (nullable, nonatomic, retain) NSNumber *volume;
@property (nullable, nonatomic, retain) STMArticle *article;
@property (nullable, nonatomic, retain) STMBarCode *barCode;
@property (nullable, nonatomic, retain) STMPickingOrderPosition *pickingOrderPosition;
@property (nullable, nonatomic, retain) STMStockBatch *stockBatch;

@end

NS_ASSUME_NONNULL_END
