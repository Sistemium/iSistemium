//
//  STMBarCode+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 06/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMBarCode.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMBarCode (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *barcode;
@property (nullable, nonatomic, retain) STMArticle *article;

@end

NS_ASSUME_NONNULL_END
