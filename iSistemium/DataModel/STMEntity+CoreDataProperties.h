//
//  STMEntity+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *eTag;
@property (nullable, nonatomic, retain) NSNumber *isUploadable;
@property (nullable, nonatomic, retain) NSNumber *lifeTime;
@property (nullable, nonatomic, retain) NSString *lifeTimeDateField;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *roleName;
@property (nullable, nonatomic, retain) NSString *roleOwner;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) NSString *workflow;
@property (nullable, nonatomic, retain) STMWorkflow *wf;

@end

NS_ASSUME_NONNULL_END
