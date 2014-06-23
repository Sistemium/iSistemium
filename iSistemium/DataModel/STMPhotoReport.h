//
//  STMPhotoReport.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 22/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMCampaign, STMOutlet, STMPhoto, STMSalesman;

@interface STMPhotoReport : STMComment

@property (nonatomic, retain) STMCampaign *campaign;
@property (nonatomic, retain) STMOutlet *outlet;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) STMSalesman *salesman;
@end

@interface STMPhotoReport (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(STMPhoto *)value;
- (void)removePhotosObject:(STMPhoto *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
