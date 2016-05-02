//
//  STMPhotoReport+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMPhotoReport.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMPhotoReport (CoreDataProperties)

@property (nullable, nonatomic, retain) STMCampaign *campaign;
@property (nullable, nonatomic, retain) STMOutlet *outlet;
@property (nullable, nonatomic, retain) STMSalesman *salesman;

@end

NS_ASSUME_NONNULL_END
