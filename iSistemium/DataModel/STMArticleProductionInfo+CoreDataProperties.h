//
//  STMArticleProductionInfo+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 16/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMArticleProductionInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMArticleProductionInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *info;
@property (nullable, nonatomic, retain) STMArticle *article;
@property (nullable, nonatomic, retain) STMProductionInfoType *productionInfoType;

@end

NS_ASSUME_NONNULL_END
