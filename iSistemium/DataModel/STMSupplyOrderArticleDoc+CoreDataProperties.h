//
//  STMSupplyOrderArticleDoc+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 21/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMSupplyOrderArticleDoc.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMSupplyOrderArticleDoc (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) NSNumber *ord;
@property (nullable, nonatomic, retain) NSNumber *volume;
@property (nullable, nonatomic, retain) NSNumber *packageRel;
@property (nullable, nonatomic, retain) STMArticle *article;
@property (nullable, nonatomic, retain) STMArticleDoc *articleDoc;
@property (nullable, nonatomic, retain) STMSupplyOrder *supplyOrder;

@end

NS_ASSUME_NONNULL_END
