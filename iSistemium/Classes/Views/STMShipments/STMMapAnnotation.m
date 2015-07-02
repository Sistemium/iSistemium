//
//  STMMapAnnotation.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 27/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMMapAnnotation.h"
#import "STMLocationController.h"

@interface STMMapAnnotation()

@property (nonatomic, strong) STMLocation *location;
@property (nonatomic, strong) CLLocation *clLocation;

@end


@implementation STMMapAnnotation

+ (STMMapAnnotation *)createAnnotationForLocation:(STMLocation *)location {
    
    STMMapAnnotation *annotation = [[STMMapAnnotation alloc] init];
    annotation.location = location;

    return annotation;
    
}

+ (STMMapAnnotation *)createAnnotationForCLLocation:(CLLocation *)clLocation {
    
    STMMapAnnotation *annotation = [[STMMapAnnotation alloc] init];
    annotation.clLocation = clLocation;
    
    return annotation;
    
}

- (NSString *)title {

    if ([self.location isKindOfClass:[STMShippingLocation class]]) {
        return [(STMShippingLocation *)self.location name];
    } else {
        return nil;
    }

}

- (NSString *)subtitle {
    
    if ([self.location isKindOfClass:[STMShippingLocation class]]) {
        return [(STMShippingLocation *)self.location address];
    } else {
        return nil;
    }

}

- (CLLocationCoordinate2D)coordinate {
    
    CLLocationCoordinate2D coordinate;
    
    if (self.location) {
        return CLLocationCoordinate2DMake(self.location.latitude.doubleValue, self.location.longitude.doubleValue);
    } else if (self.clLocation) {
        return CLLocationCoordinate2DMake(self.clLocation.coordinate.latitude, self.clLocation.coordinate.longitude);
    }
    return coordinate;
    
}


@end
