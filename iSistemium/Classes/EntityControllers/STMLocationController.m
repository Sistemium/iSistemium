//
//  STMLocationController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/07/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMLocationController.h"
#import "STMObjectsController.h"


@implementation STMLocationController

+ (STMLocation *)locationObjectFromCLLocation:(CLLocation *)location {
    
    STMLocation *locationObject = (STMLocation *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMLocation class])];
    locationObject.isFantom = @NO;
    [locationObject setLatitude:@(location.coordinate.latitude)];
    [locationObject setLongitude:@(location.coordinate.longitude)];
    [locationObject setHorizontalAccuracy:@(location.horizontalAccuracy)];
    [locationObject setSpeed:@(location.speed)];
    [locationObject setCourse:@(location.course)];
    [locationObject setAltitude:@(location.altitude)];
    [locationObject setVerticalAccuracy:@(location.verticalAccuracy)];
    [locationObject setTimestamp:location.timestamp];
    return locationObject;
    
}

+ (CLLocation *)locationFromLocationObject:(STMLocation *)locationObject {
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([locationObject.latitude doubleValue], [locationObject.longitude doubleValue]);
    CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate
                                                         altitude:[locationObject.altitude doubleValue]
                                               horizontalAccuracy:[locationObject.horizontalAccuracy doubleValue]
                                                 verticalAccuracy:[locationObject.verticalAccuracy doubleValue]
                                                           course:[locationObject.course doubleValue]
                                                            speed:[locationObject.speed doubleValue]
                                                        timestamp:locationObject.deviceCts];
    return location;
    
}


@end
