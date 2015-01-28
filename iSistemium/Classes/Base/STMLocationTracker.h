//
//  STMLocationTracker.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 4/3/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STMTracker.h"
#import "STMLocation.h"
#import "STMTrack+dayAsString.h"

@interface STMLocationTracker : STMTracker

@property (nonatomic) CLLocationAccuracy currentAccuracy;
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, strong) STMTrack *currentTrack;

- (void)getLocation;
- (STMLocation *)locationObjectFromCLLocation:(CLLocation *)location;
- (NSString *)locationServiceStatus;

@end
