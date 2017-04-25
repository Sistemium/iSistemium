//
//  STMShipmentRoutePointPhoto+CoreDataProperties.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/04/2017.
//  Copyright © 2017 Sistemium UAB. All rights reserved.
//

#import "STMShipmentRoutePointPhoto+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface STMShipmentRoutePointPhoto (CoreDataProperties)

+ (NSFetchRequest<STMShipmentRoutePointPhoto *> *)fetchRequest;

@property (nullable, nonatomic, retain) STMShipmentRoutePoint *shipmentRoutePoint;

@end

NS_ASSUME_NONNULL_END
