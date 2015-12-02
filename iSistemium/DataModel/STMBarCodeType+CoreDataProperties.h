//
//  STMBarCodeType+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMBarCodeType.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMBarCodeType (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSString *symbology;
@property (nullable, nonatomic, retain) NSString *mask;

@end

NS_ASSUME_NONNULL_END
