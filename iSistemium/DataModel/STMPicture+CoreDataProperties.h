//
//  STMPicture+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMPicture.h"

NS_ASSUME_NONNULL_BEGIN

@interface STMPicture (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *href;
@property (nullable, nonatomic, retain) NSString *imageFormat;
@property (nullable, nonatomic, retain) NSString *imagePath;
@property (nullable, nonatomic, retain) NSData *imageThumbnail;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *picturesInfo;
@property (nullable, nonatomic, retain) NSString *resizedImagePath;

@end

NS_ASSUME_NONNULL_END
