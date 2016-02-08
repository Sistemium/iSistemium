//
//  STMLocation+CoreDataProperties.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "STMLocation+CoreDataProperties.h"

@implementation STMLocation (CoreDataProperties)

@dynamic altitude;
@dynamic course;
@dynamic horizontalAccuracy;
@dynamic lastSeenAt;
@dynamic latitude;
@dynamic longitude;
@dynamic speed;
@dynamic timestamp;
@dynamic verticalAccuracy;
@dynamic photos;
@dynamic shipmentRoutePoint;
@dynamic shippings;
@dynamic track;

@end
