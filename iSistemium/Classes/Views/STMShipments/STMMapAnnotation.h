//
//  STMMapAnnotation.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 27/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "STMDataModel.h"


@interface STMMapAnnotation : NSObject <MKAnnotation>

+ (STMMapAnnotation *)createAnnotationForLocation:(STMLocation *)location;
+ (STMMapAnnotation *)createAnnotationForCLLocation:(CLLocation *)clLocation;

+ (STMMapAnnotation *)createAnnotationForLocation:(STMLocation *)location withTitle:(NSString *)title andSubtitle:(NSString *)subtitle;
+ (STMMapAnnotation *)createAnnotationForCLLocation:(CLLocation *)clLocation withTitle:(NSString *)title andSubtitle:(NSString *)subtitle;

+ (STMMapAnnotation *)createAnnotationForLocation:(STMLocation *)location withTitle:(NSString *)title andSubtitle:(NSString *)subtitle andOrd:(NSNumber *)ord;
+ (STMMapAnnotation *)createAnnotationForCLLocation:(CLLocation *)clLocation withTitle:(NSString *)title andSubtitle:(NSString *)subtitle andOrd:(NSNumber *)ord;

@property (nonatomic ,strong) NSNumber *ord;


@end
