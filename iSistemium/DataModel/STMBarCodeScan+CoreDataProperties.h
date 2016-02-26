//
//  STMBarCodeScan+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 21/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMBarCodeScan.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMBarCodeScan (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *destinationEntity;
@property (nullable, nonatomic, retain) NSData *destinationXid;

@end

NS_ASSUME_NONNULL_END
