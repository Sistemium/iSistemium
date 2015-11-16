//
//  STMPickingOrder+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 16/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
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
@property (nullable, nonatomic, retain) NSSet<STMPickingOrderArticle *> *pickingOrderArticles;

@end

@interface STMPickingOrder (CoreDataGeneratedAccessors)

- (void)addPickingOrderArticlesObject:(STMPickingOrderArticle *)value;
- (void)removePickingOrderArticlesObject:(STMPickingOrderArticle *)value;
- (void)addPickingOrderArticles:(NSSet<STMPickingOrderArticle *> *)values;
- (void)removePickingOrderArticles:(NSSet<STMPickingOrderArticle *> *)values;

@end

NS_ASSUME_NONNULL_END
