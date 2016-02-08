//
//  STMComment+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMComment.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMComment (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *commentText;
@property (nullable, nonatomic, retain) NSString *source;
@property (nullable, nonatomic, retain) STMDatum *owner;

@end

NS_ASSUME_NONNULL_END
