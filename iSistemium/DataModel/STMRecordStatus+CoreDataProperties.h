//
//  STMRecordStatus+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMRecordStatus.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMRecordStatus (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *isRead;
@property (nullable, nonatomic, retain) NSNumber *isRemoved;
@property (nullable, nonatomic, retain) NSNumber *isTemporary;
@property (nullable, nonatomic, retain) NSData *objectXid;

@end

NS_ASSUME_NONNULL_END
