//
//  STMSupplyOrder+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 14/01/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMSupplyOrder.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMSupplyOrder (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSString *ndoc;
@property (nullable, nonatomic, retain) NSString *processing;
@property (nullable, nonatomic, retain) NSSet<STMSupplyOrderArticleDoc *> *supplyOrderArticleDocs;
@property (nullable, nonatomic, retain) STMPartner *partner;

@end

@interface STMSupplyOrder (CoreDataGeneratedAccessors)

- (void)addSupplyOrderArticleDocsObject:(STMSupplyOrderArticleDoc *)value;
- (void)removeSupplyOrderArticleDocsObject:(STMSupplyOrderArticleDoc *)value;
- (void)addSupplyOrderArticleDocs:(NSSet<STMSupplyOrderArticleDoc *> *)values;
- (void)removeSupplyOrderArticleDocs:(NSSet<STMSupplyOrderArticleDoc *> *)values;

@end

NS_ASSUME_NONNULL_END
