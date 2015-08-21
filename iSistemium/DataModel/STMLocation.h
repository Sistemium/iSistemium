//
//  STMLocation.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 21/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMPhoto, STMShipmentRoutePoint, STMShippingLocation, STMTrack;

@interface STMLocation : STMComment

@property (nonatomic, retain) NSDecimalNumber * altitude;
@property (nonatomic, retain) NSDecimalNumber * course;
@property (nonatomic, retain) NSDecimalNumber * horizontalAccuracy;
@property (nonatomic, retain) NSDecimalNumber * latitude;
@property (nonatomic, retain) NSDecimalNumber * longitude;
@property (nonatomic, retain) NSDecimalNumber * speed;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSDecimalNumber * verticalAccuracy;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) STMShipmentRoutePoint *shipmentRoutePoint;
@property (nonatomic, retain) NSSet *shippings;
@property (nonatomic, retain) STMTrack *track;
@end

@interface STMLocation (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(STMPhoto *)value;
- (void)removePhotosObject:(STMPhoto *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

- (void)addShippingsObject:(STMShippingLocation *)value;
- (void)removeShippingsObject:(STMShippingLocation *)value;
- (void)addShippings:(NSSet *)values;
- (void)removeShippings:(NSSet *)values;

@end
