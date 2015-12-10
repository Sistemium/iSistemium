//
//  STMArticleBarCode+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMArticleBarCode.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMArticleBarCode (CoreDataProperties)

@property (nullable, nonatomic, retain) STMArticle *article;

@end

NS_ASSUME_NONNULL_END
