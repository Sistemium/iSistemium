//
//  STMPickingOrder+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMPickingOrder.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMPickingOrder (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSString *ndoc;
@property (nullable, nonatomic, retain) NSString *processing;
@property (nullable, nonatomic, retain) STMPicker *picker;
@property (nullable, nonatomic, retain) NSSet<STMPickingOrderPosition *> *pickingOrderPositions;

@end

@interface STMPickingOrder (CoreDataGeneratedAccessors)

- (void)addPickingOrderPositionsObject:(STMPickingOrderPosition *)value;
- (void)removePickingOrderPositionsObject:(STMPickingOrderPosition *)value;
- (void)addPickingOrderPositions:(NSSet<STMPickingOrderPosition *> *)values;
- (void)removePickingOrderPositions:(NSSet<STMPickingOrderPosition *> *)values;

@end

NS_ASSUME_NONNULL_END
