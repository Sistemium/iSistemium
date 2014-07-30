//
//  STMLocation.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 30/07/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMPhoto, STMTrack;

@interface STMLocation : STMComment

@property (nonatomic, retain) NSNumber * altitude;
@property (nonatomic, retain) NSNumber * course;
@property (nonatomic, retain) NSNumber * horizontalAccuracy;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * speed;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * verticalAccuracy;
@property (nonatomic, retain) STMTrack *track;
@property (nonatomic, retain) NSSet *photos;
@end

@interface STMLocation (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(STMPhoto *)value;
- (void)removePhotosObject:(STMPhoto *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
