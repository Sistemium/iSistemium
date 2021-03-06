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
@property (nonatomic ,strong) NSString *annotationTitle;
@property (nonatomic, strong) NSString *annotationSubtitle;


@end


@implementation STMMapAnnotation

+ (STMMapAnnotation *)createAnnotationForLocation:(STMLocation *)location {
    return [self createAnnotationForLocation:location withTitle:nil andSubtitle:nil];
}

+ (STMMapAnnotation *)createAnnotationForLocation:(STMLocation *)location withTitle:(NSString *)title andSubtitle:(NSString *)subtitle {
    return [self createAnnotationForLocation:location withTitle:title andSubtitle:subtitle andOrd:nil];
}

+ (STMMapAnnotation *)createAnnotationForLocation:(STMLocation *)location withTitle:(NSString *)title andSubtitle:(NSString *)subtitle andOrd:(NSNumber *)ord {
    
    STMMapAnnotation *annotation = [[STMMapAnnotation alloc] init];
    annotation.location = location;
    annotation.annotationTitle = title;
    annotation.annotationSubtitle = subtitle;
    annotation.ord = ord;
    
    return annotation;
    
}

+ (STMMapAnnotation *)createAnnotationForPoint:(STMShipmentRoutePoint *)point {
    
    STMMapAnnotation *annotation = [[STMMapAnnotation alloc] init];
    annotation.location = point.shippingLocation.location;
    annotation.annotationTitle = point.shortName;
    annotation.annotationSubtitle = point.address;
    annotation.ord = point.ord;
    annotation.point = point;
    
    return annotation;
    
}

+ (STMMapAnnotation *)createAnnotationForCLLocation:(CLLocation *)clLocation {
    return [self createAnnotationForCLLocation:clLocation withTitle:nil andSubtitle:nil];
}

+ (STMMapAnnotation *)createAnnotationForCLLocation:(CLLocation *)clLocation withTitle:(NSString *)title andSubtitle:(NSString *)subtitle {
    return [self createAnnotationForCLLocation:clLocation withTitle:title andSubtitle:subtitle andOrd:nil];
}

+ (STMMapAnnotation *)createAnnotationForCLLocation:(CLLocation *)clLocation withTitle:(NSString *)title andSubtitle:(NSString *)subtitle andOrd:(NSNumber *)ord {
    
    STMMapAnnotation *annotation = [[STMMapAnnotation alloc] init];
    annotation.clLocation = clLocation;
    annotation.annotationTitle = title;
    annotation.annotationSubtitle = subtitle;
    annotation.ord = ord;
    
    return annotation;

}


- (NSString *)title {
    return self.annotationTitle;
}

- (NSString *)subtitle {
    return self.annotationSubtitle;
}

- (CLLocationCoordinate2D)coordinate {
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(0.0, 0.0);
    
    if (self.location) {
        coordinate = CLLocationCoordinate2DMake(self.location.latitude.doubleValue, self.location.longitude.doubleValue);
    } else if (self.clLocation) {
        coordinate = CLLocationCoordinate2DMake(self.clLocation.coordinate.latitude, self.clLocation.coordinate.longitude);
    }
    return coordinate;
    
}


@end
