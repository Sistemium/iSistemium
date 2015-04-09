//
//  STMLocationTracker.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 4/3/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STMLocationTracker.h"
#import "STMEntityDescription.h"

#import "STMClientDataController.h"
#import "STMObjectsController.h"

@interface STMLocationTracker() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic) CLLocationAccuracy desiredAccuracy;
@property (nonatomic) double requiredAccuracy;
@property (nonatomic) CLLocationDistance distanceFilter;
@property (nonatomic) NSTimeInterval timeFilter;
@property (nonatomic) NSTimeInterval trackDetectionTime;
@property (nonatomic) CLLocationDistance trackSeparationDistance;
@property (nonatomic) CLLocationSpeed maxSpeedThreshold;
@property (nonatomic) BOOL singlePointMode;
@property (nonatomic) BOOL getLocationsWithNegativeSpeed;


@end

@implementation STMLocationTracker

//@synthesize desiredAccuracy = _desiredAccuracy;
//@synthesize distanceFilter = _distanceFilter;


- (void)customInit {
    
    self.group = @"location";
    [super customInit];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if ([change valueForKey:NSKeyValueChangeNewKey] != [change valueForKey:NSKeyValueChangeOldKey]) {
        
        if ([keyPath isEqualToString:@"distanceFilter"] || [keyPath isEqualToString:@"desiredAccuracy"]) {
            
            self.desiredAccuracy = [[self.settings valueForKey:@"desiredAccuracy"] doubleValue];
            self.locationManager.desiredAccuracy = self.desiredAccuracy;
            
            self.distanceFilter = [[self.settings valueForKey:@"distanceFilter"] doubleValue];
            self.locationManager.distanceFilter = self.distanceFilter;
            
        }
        
    }
    
}

#pragma mark - locationTracker settings

- (CLLocationAccuracy) desiredAccuracy {
    if (!_desiredAccuracy) {
        _desiredAccuracy = [[self.settings valueForKey:@"desiredAccuracy"] doubleValue];
    }
    return _desiredAccuracy;
}

- (double)requiredAccuracy {
    if (!_requiredAccuracy) {
        _requiredAccuracy = [[self.settings valueForKey:@"requiredAccuracy"] doubleValue];
    }
    return _requiredAccuracy;
}

- (CLLocationDistance)distanceFilter {
    if (!_distanceFilter) {
        _distanceFilter = [[self.settings valueForKey:@"distanceFilter"] doubleValue];
    }
    return _desiredAccuracy;
}

- (NSTimeInterval)timeFilter {
    if (!_timeFilter) {
        _timeFilter = [[self.settings valueForKey:@"timeFilter"] doubleValue];
    }
    return _timeFilter;
}

- (NSTimeInterval)trackDetectionTime {
    if (!_trackDetectionTime) {
        _trackDetectionTime = [[self.settings valueForKey:@"trackDetectionTime"] doubleValue];
    }
    return _trackDetectionTime;
}

- (CLLocationDistance)trackSeparationDistance {
    if (!_trackSeparationDistance) {
        _trackSeparationDistance = [[self.settings valueForKey:@"trackSeparationDistance"] doubleValue];
    }
    return _trackSeparationDistance;
}

- (CLLocationSpeed)maxSpeedThreshold {
    if (!_maxSpeedThreshold) {
        _maxSpeedThreshold = [[self.settings valueForKey:@"maxSpeedThreshold"] doubleValue];
    }
    return _maxSpeedThreshold;
}

- (BOOL)getLocationsWithNegativeSpeed {
    if (!_getLocationsWithNegativeSpeed) {
        _getLocationsWithNegativeSpeed = [[self.settings valueForKey:@"getLocationsWithNegativeSpeed"] boolValue];
    }
    return _getLocationsWithNegativeSpeed;
}

- (STMTrack *)currentTrack {
    
//    if (!_currentTrack) {
//        
//        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMTrack class])];
//        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:NO selector:@selector(compare:)]];
//        NSError *error;
//        NSArray *result = [self.document.managedObjectContext executeFetchRequest:request error:&error];
//        
//        if (result.count > 0) {
//            _currentTrack = [result objectAtIndex:0];
//        }
//        
//    }
//    return _currentTrack;
    return nil;
    
}

- (CLLocation *)lastLocation {
    
    if (!_lastLocation) {
        
//        if (self.currentTrack.locations.count > 0) {
//            NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:NO selector:@selector(compare:)]];
//            STMLocation *lastLocation = [[self.currentTrack.locations sortedArrayUsingDescriptors:sortDescriptors] objectAtIndex:0];
//            if (lastLocation) {
//                _lastLocation = [self locationFromLocationObject:lastLocation];
//            }
//        }

        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMLocation class])];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
        NSError *error;
        NSArray *result = [self.document.managedObjectContext executeFetchRequest:request error:&error];
        
        STMLocation *lastLocation = [result lastObject];
        if (lastLocation) {
            _lastLocation = [self locationFromLocationObject:lastLocation];
        }

    }
    return _lastLocation;
    
}

- (NSString *)locationServiceStatus {
    
    NSString *status = nil;
    
    if ([CLLocationManager locationServicesEnabled]) {
        
        switch ([CLLocationManager authorizationStatus]) {
            case kCLAuthorizationStatusNotDetermined:
                status = @"notDetermined";
                break;
            case kCLAuthorizationStatusRestricted:
                status = @"restricted";
                break;
            case kCLAuthorizationStatusDenied:
                status = @"denied";
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
                status = @"authorizedAlways";
                break;
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                status = @"authorizedWhenInUse";
                break;
                
            default:
                break;
        }
        
    } else {
        
        status = @"disabled";
        
    }
    
//    NSLog(@"locationServiceStatus %@", status);
    
    return status;
    
}


#pragma mark - tracking

- (void)startTracking {
    
    [super startTracking];
    
    if (self.tracking) {
        
        float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        
        if (systemVersion >= 8.0) {
            
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
                
                [[self.session logger] saveLogMessageWithText:@"location tracking is not permitted" type:@"error"];
                self.locationManager = nil;
                [super stopTracking];
                
            } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
                
                [self.locationManager requestAlwaysAuthorization];
                
            } else {
                
                if ([CLLocationManager locationServicesEnabled]) {
                    
                    [self startUpdatingLocation];
                    
                } else {
                    
                    [[self.session logger] saveLogMessageWithText:@"location tracking disabled" type:@"error"];
                    [super stopTracking];
                    
                }
                
            }
            
        } else if (systemVersion >= 2.0 && systemVersion < 8.0) {
            
            [self startUpdatingLocation];
            
        }

    }
    
}

- (void)stopTracking {
    
    [[self locationManager] stopUpdatingLocation];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"locationManagerDidPauseLocationUpdates" object:self];
    self.locationManager.delegate = nil;
    self.locationManager = nil;
    [super stopTracking];
    
}

- (void)getLocation {

    if ([[NSDate date] timeIntervalSinceDate:self.lastLocation.timestamp] < self.timeFilter) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"currentLocationWasUpdated" object:self userInfo:@{@"currentLocation":self.lastLocation}];
        
    } else {
        
        self.singlePointMode = YES;
        [self.locationManager startUpdatingLocation];
        
    }
    
}

- (void)startUpdatingLocation {
    
    [self.locationManager startUpdatingLocation];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"locationManagerDidResumeLocationUpdates" object:self];

}

#pragma mark - CLLocationManager

- (CLLocationManager *)locationManager {
    
    if (!_locationManager) {
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = self.distanceFilter;
        _locationManager.desiredAccuracy = self.desiredAccuracy;
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        
    }
    
    return _locationManager;
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *newLocation = [locations lastObject];
    
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    self.currentAccuracy = newLocation.horizontalAccuracy;
    
    if (locationAge < 5.0 &&
        
        newLocation.horizontalAccuracy > 0 &&
        newLocation.horizontalAccuracy <= self.requiredAccuracy) {
        
        
        if (!self.getLocationsWithNegativeSpeed && newLocation.speed < 0) {
            
            [self.session.logger saveLogMessageWithText:@"location w/negative speed recieved" type:@""];
            
        } else {
            
//            CLLocationDistance distance = [self.lastLocation distanceFromLocation:newLocation];
            NSTimeInterval time = [newLocation.timestamp timeIntervalSinceDate:self.lastLocation.timestamp];
//            CLLocationSpeed speed = 3.6 * distance / time; // km/h
//            CLLocationSpeed speed = distance / time; // m/s
//
//            if (speed > self.maxSpeedThreshold) {
//                
//                self.lastLocation = newLocation;
//                [self.session.logger saveLogMessageWithText:@"maxSpeedThreshold exceeded" type:@""];
//                
//            } else {

                if (!self.lastLocation || time > self.timeFilter) {
                    
                    if (self.tracking) {
                        
                        [self addLocation:newLocation];
                        
                    }
                    
                    if (self.singlePointMode) {
                        
                        if (!self.tracking) {
                            [self stopTracking];
                        }
                        
                        self.singlePointMode = NO;
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"currentLocationWasUpdated" object:self userInfo:@{@"currentLocation":newLocation}];
                        self.lastLocation = newLocation;

                    }
                    
                }
//
//            }
            
        }
            
    }
    
}


- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    [self.session.logger saveLogMessageWithText:@"locationManagerDidResumeLocationUpdates" type:@""];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"locationManagerDidResumeLocationUpdates" object:self];
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    [self.session.logger saveLogMessageWithText:@"locationManagerDidPauseLocationUpdates" type:@""];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"locationManagerDidPauseLocationUpdates" object:self];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    [STMClientDataController checkClientData];
    
    if (status == kCLAuthorizationStatusAuthorizedAlways && self.tracking) {
        
        if ([CLLocationManager locationServicesEnabled]) {
            [self startUpdatingLocation];
        } else {
            [[self.session logger] saveLogMessageWithText:@"location tracking disabled" type:@"error"];
            [super stopTracking];
        }
        
    }
    
}

#pragma mark - track management

- (void)addLocation:(CLLocation *)currentLocation {
    
//    if (!self.currentTrack) {
//        [self startNewTrack];
//    }
//    
//    NSDate *timestamp = currentLocation.timestamp;
//    
//    if ([currentLocation.timestamp timeIntervalSinceDate:self.lastLocation.timestamp] > self.trackDetectionTime && self.currentTrack.locations.count != 0) {
//        
//        [self startNewTrack];
//        
//    }
//    
//    //    NSLog(@"addLocation %@", [NSDate date]);
//    
//    if (self.currentTrack.locations.count == 0) {
//        self.currentTrack.startTime = timestamp;
//    }
//    
//    [self.currentTrack addLocationsObject:[self locationObjectFromCLLocation:currentLocation]];
//    self.currentTrack.finishTime = timestamp;
    
    [self locationObjectFromCLLocation:currentLocation];
    
    self.lastLocation = currentLocation;
    
    NSLog(@"location %@", self.lastLocation);

    [self.document saveDocument:^(BOOL success) {
        
        if (success) {
//            NSLog(@"save newLocation success");
        }
        
    }];
    
}

- (void)startNewTrack {
    
    STMTrack *track = (STMTrack *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMTrack class])];
    track.isFantom = @NO;
    track.startTime = [NSDate date];
    self.currentTrack = track;
    //    NSLog(@"track %@", track);
    
    [self.document saveDocument:^(BOOL success) {
        //        NSLog(@"save newTrack");
        if (success) {
            NSLog(@"save newTrack success");
        } else {
            NSLog(@"save newTrack NOT success");
        }
    }];
    
}

- (void)deleteTrack:(STMTrack *)track {
    
    [STMObjectsController removeObject:track];
    [self.document saveDocument:^(BOOL success) {
        if (success) {
            NSLog(@"deleteTrack success");
        }
    }];
    
}

- (void)splitTrack {
    
    self.currentTrack.finishTime = self.lastLocation.timestamp;
    [self startNewTrack];
    STMLocation *location = [self locationObjectFromCLLocation:self.lastLocation];
    [self.currentTrack addLocationsObject:location];
    self.lastLocation = [self locationFromLocationObject:location];
    
}

- (STMLocation *)locationObjectFromCLLocation:(CLLocation *)location {
    
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

- (CLLocation *)locationFromLocationObject:(STMLocation *)locationObject {
    
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
