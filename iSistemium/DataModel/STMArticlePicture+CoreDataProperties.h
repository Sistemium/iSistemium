//
//  STMArticlePicture+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMArticlePicture.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMArticlePicture (CoreDataProperties)

@property (nullable, nonatomic, retain) NSSet<STMArticle *> *articles;

@end

@interface STMArticlePicture (CoreDataGeneratedAccessors)

- (void)addArticlesObject:(STMArticle *)value;
- (void)removeArticlesObject:(STMArticle *)value;
- (void)addArticles:(NSSet<STMArticle *> *)values;
- (void)removeArticles:(NSSet<STMArticle *> *)values;

@end

NS_ASSUME_NONNULL_END
