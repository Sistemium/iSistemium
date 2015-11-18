//
//  STMStockBatch+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMStockBatch.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMStockBatch (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *processing;
@property (nullable, nonatomic, retain) NSNumber *volume;
@property (nullable, nonatomic, retain) STMArticle *article;
@property (nullable, nonatomic, retain) NSSet<STMBarCode *> *barCodes;
@property (nullable, nonatomic, retain) NSSet<STMPickingOrderPositionPicked *> *pickingOrderPositionsPicked;
@property (nullable, nonatomic, retain) STMQualityClass *qualityClass;

@end

@interface STMStockBatch (CoreDataGeneratedAccessors)

- (void)addBarCodesObject:(STMBarCode *)value;
- (void)removeBarCodesObject:(STMBarCode *)value;
- (void)addBarCodes:(NSSet<STMBarCode *> *)values;
- (void)removeBarCodes:(NSSet<STMBarCode *> *)values;

- (void)addPickingOrderPositionsPickedObject:(STMPickingOrderPositionPicked *)value;
- (void)removePickingOrderPositionsPickedObject:(STMPickingOrderPositionPicked *)value;
- (void)addPickingOrderPositionsPicked:(NSSet<STMPickingOrderPositionPicked *> *)values;
- (void)removePickingOrderPositionsPicked:(NSSet<STMPickingOrderPositionPicked *> *)values;

@end

NS_ASSUME_NONNULL_END
