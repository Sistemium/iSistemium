//
//  STMShipmentRoutePoint+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/04/2017.
//  Copyright © 2017 Sistemium UAB. All rights reserved.
//

#import "STMShipmentRoutePoint.h"


NS_ASSUME_NONNULL_BEGIN

@interface STMShipmentRoutePoint (CoreDataProperties)

+ (NSFetchRequest<STMShipmentRoutePoint *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *address;
@property (nullable, nonatomic, copy) NSString *commentText;
@property (nullable, nonatomic, copy) NSDate *deviceCts;
@property (nullable, nonatomic, copy) NSDate *deviceTs;
@property (nullable, nonatomic, copy) NSNumber *id;
@property (nullable, nonatomic, copy) NSNumber *isFantom;
@property (nullable, nonatomic, copy) NSNumber *isReached;
@property (nullable, nonatomic, copy) NSDate *lts;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSNumber *ord;
@property (nullable, nonatomic, retain) NSData *ownerXid;
@property (nullable, nonatomic, copy) NSString *processing;
@property (nullable, nonatomic, copy) NSString *processingMessage;
@property (nullable, nonatomic, copy) NSString *shortName;
@property (nullable, nonatomic, copy) NSString *source;
@property (nullable, nonatomic, copy) NSDate *sqts;
@property (nullable, nonatomic, copy) NSDate *sts;
@property (nullable, nonatomic, retain) NSData *xid;
@property (nullable, nonatomic, retain) STMLocation *reachedAtLocation;
@property (nullable, nonatomic, retain) STMShipmentRoute *shipmentRoute;
@property (nullable, nonatomic, retain) NSSet<STMShipment *> *shipments;
@property (nullable, nonatomic, retain) STMShippingLocation *shippingLocation;
@property (nullable, nonatomic, retain) NSSet<STMShipmentRoutePointPhoto *> *photos;

@end

@interface STMShipmentRoutePoint (CoreDataGeneratedAccessors)

- (void)addShipmentsObject:(STMShipment *)value;
- (void)removeShipmentsObject:(STMShipment *)value;
- (void)addShipments:(NSSet<STMShipment *> *)values;
- (void)removeShipments:(NSSet<STMShipment *> *)values;

- (void)addPhotosObject:(STMShipmentRoutePointPhoto *)value;
- (void)removePhotosObject:(STMShipmentRoutePointPhoto *)value;
- (void)addPhotos:(NSSet<STMShipmentRoutePointPhoto *> *)values;
- (void)removePhotos:(NSSet<STMShipmentRoutePointPhoto *> *)values;

@end

NS_ASSUME_NONNULL_END
