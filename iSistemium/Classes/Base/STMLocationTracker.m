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
#import "STMLocationController.h"

#define ACTUAL_LOCATION_CHECK_TIME_INTERVAL 5.0

#warning - it seems this class use almost none of the parent class methods after implemetation of new "desiredAccuracy zero-rule"


@interface STMLocationTracker() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic) CLLocationAccuracy desiredAccuracy;
@property (nonatomic) CLLocationAccuracy foregroundDesiredAccuracy;
@property (nonatomic) CLLocationAccuracy backgroundDesiredAccuracy;
@property (nonatomic) CLLocationAccuracy offtimeDesiredAccuracy;

@property (nonatomic) double requiredAccuracy;
@property (nonatomic) CLLocationDistance distanceFilter;
@property (nonatomic) NSTimeInterval timeFilter;
@property (nonatomic) NSTimeInterval locationWaitingTimeInterval;

@property (nonatomic) NSTimeInterval trackDetectionTime;
@property (nonatomic) CLLocationDistance trackSeparationDistance;
@property (nonatomic) CLLocationSpeed maxSpeedThreshold;

@property (nonatomic) BOOL singlePointMode;
@property (nonatomic) BOOL getLocationsWithNegativeSpeed;
@property (nonatomic, strong) NSTimer *locationWaitingTimer;

@property (nonatomic, strong) NSTimer *startTimer;
@property (nonatomic, strong) NSTimer *finishTimer;


@end


@implementation STMLocationTracker

@synthesize lastLocation = _lastLocation;

- (void)customInit {
    
    self.group = @"location";
    
    [super customInit];
    
    [self initAppStateObservers];
    
}

- (void)initAppStateObservers {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    SEL selector = @selector(appStateDidChange);
    
    [nc addObserver:self
           selector:selector
               name:UIApplicationDidBecomeActiveNotification
             object:nil];

    [nc addObserver:self
           selector:selector
               name:UIApplicationDidEnterBackgroundNotification
             object:nil];
    
}

- (void)appStateDidChange {
    
    self.locationManager.desiredAccuracy = [self currentDesiredAccuracy];
    [self checkTrackerAutoStart];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if ([change valueForKey:NSKeyValueChangeNewKey] != [change valueForKey:NSKeyValueChangeOldKey]) {
        
        if ([keyPath isEqualToString:@"distanceFilter"] ||
            [keyPath isEqualToString:@"desiredAccuracy"] ||
            [keyPath hasSuffix:@"DesiredAccuracy"]) {
            
            self.locationManager.desiredAccuracy = [self currentDesiredAccuracy];
            self.locationManager.distanceFilter = self.distanceFilter;
            [self checkTrackerAutoStart];
            
        }
        
    }
    
}


#pragma mark - locationTracker settings

- (CLLocationAccuracy)currentDesiredAccuracy {
    
    if ([self currentTimeIsInsideOfScheduleLimits]) {
        
        UIApplicationState appState = [UIApplication sharedApplication].applicationState;
        
        switch (appState) {
            case UIApplicationStateActive: {
                return self.foregroundDesiredAccuracy;
                break;
            }
            case UIApplicationStateInactive: {
                return self.foregroundDesiredAccuracy;
                break;
            }
            case UIApplicationStateBackground: {
                return self.backgroundDesiredAccuracy;
                break;
            }
            default: {
                return self.desiredAccuracy;
                break;
            }
        }
        
    } else {
        
        return self.offtimeDesiredAccuracy;
        
    }

}

- (CLLocationAccuracy)desiredAccuracy {
    return [self.settings[@"desiredAccuracy"] doubleValue];
}

- (CLLocationAccuracy)backgroundDesiredAccuracy {
    return [self.settings[@"backgroundDesiredAccuracy"] doubleValue];
}

- (CLLocationAccuracy)foregroundDesiredAccuracy {
    return [self.settings[@"foregroundDesiredAccuracy"] doubleValue];
}

- (CLLocationAccuracy)offtimeDesiredAccuracy {
    return [self.settings[@"offtimeDesiredAccuracy"] doubleValue];
}

- (double)requiredAccuracy {
    return [self.settings[@"requiredAccuracy"] doubleValue];
}

- (CLLocationDistance)distanceFilter {
    return [self.settings[@"distanceFilter"] doubleValue];
}

- (NSTimeInterval)timeFilter {
    return [self.settings[@"timeFilter"] doubleValue];
}

- (NSTimeInterval)locationWaitingTimeInterval {
    return [self.settings[@"locationWaitingTimeInterval"] doubleValue];
}

- (NSTimeInterval)trackDetectionTime {
    return [self.settings[@"trackDetectionTime"] doubleValue];
}

- (CLLocationDistance)trackSeparationDistance {
    return [self.settings[@"trackSeparationDistance"] doubleValue];
}

- (CLLocationSpeed)maxSpeedThreshold {
    return [self.settings[@"maxSpeedThreshold"] doubleValue];
}

- (BOOL)getLocationsWithNegativeSpeed {
    return [self.settings[@"getLocationsWithNegativeSpeed"] boolValue];
}

- (STMLocation *)lastLocationObject {
    
    if (!_lastLocationObject) {

        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMLocation class])];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
        NSError *error;
        NSArray *result = [self.document.managedObjectContext executeFetchRequest:request error:&error];
        
        _lastLocationObject = result.lastObject;

    }
    return _lastLocationObject;
    
}

- (CLLocation *)lastLocation {
    
    if (!_lastLocation) {
        
        if (self.lastLocationObject) {
            
            _lastLocation = [STMLocationController locationFromLocationObject:self.lastLocationObject];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"lastLocationUpdated" object:self];

        }

    }
    return _lastLocation;
    
}

- (void)setLastLocation:(CLLocation *)lastLocation {
    
    _lastLocation = lastLocation;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"lastLocationUpdated" object:self];
    
}

- (void)setCurrentAccuracy:(CLLocationAccuracy)currentAccuracy {
    
    if (_currentAccuracy != currentAccuracy) {
        
        _currentAccuracy = currentAccuracy;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"currentAccuracyUpdated"
                                                            object:self 
                                                          userInfo:@{@"isAccuracySufficient":@(self.isAccuracySufficient)}];

    }
    
}

- (BOOL)isAccuracySufficient {
    return (self.currentAccuracy <= self.requiredAccuracy);
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
                
                [super stopTracking];
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
    
    [self flushLocationManager];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"locationManagerDidPauseLocationUpdates" object:self];
    [super stopTracking];
    
}

- (void)flushLocationManager {
    
    [self resetLocationWaitingTimer];
    [[self locationManager] stopUpdatingLocation];
    self.locationManager.delegate = nil;
    self.locationManager = nil;
    
}

- (void)getLocation {
    
    CLLocation *lastLocation = self.locationManager.location;
    NSTimeInterval locationAge = -[lastLocation.timestamp timeIntervalSinceNow];

    if (self.tracking && locationAge < ACTUAL_LOCATION_CHECK_TIME_INTERVAL) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"currentLocationWasUpdated" object:self userInfo:@{@"currentLocation":lastLocation}];
        
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
        _locationManager.desiredAccuracy = [self currentDesiredAccuracy];
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        
    }
    
    return _locationManager;
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *newLocation = [locations lastObject];
    
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    
    CLLocationAccuracy previousAccuracy = self.currentAccuracy;
    self.currentAccuracy = newLocation.horizontalAccuracy;
    
    if (locationAge < ACTUAL_LOCATION_CHECK_TIME_INTERVAL &&
        self.currentAccuracy > 0) {
        
        if ([self isAccuracySufficient]) {
            
            if (!self.getLocationsWithNegativeSpeed && newLocation.speed < 0) {
                
                [self.session.logger saveLogMessageWithText:@"location w/negative speed recieved" type:@""];
                
            } else {
                
                NSTimeInterval time = [newLocation.timestamp timeIntervalSinceDate:self.lastLocation.timestamp];
                
                if (!self.lastLocation || time > self.timeFilter || self.currentAccuracy < previousAccuracy) {
                    
                    if (self.tracking) {
                        
                        [self addLocation:newLocation];
                        
                    }
                    
                }
                
            }

        }
        
        
        if (self.singlePointMode) {
            
            if (!self.tracking) {
                [self flushLocationManager];
            }
            
            self.singlePointMode = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"currentLocationWasUpdated"
                                                                object:self
                                                              userInfo:@{@"currentLocation":newLocation}];
            
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


#pragma mark - timeFilterTimer

- (NSTimer *)locationWaitingTimer {
    
    if (!_locationWaitingTimer) {
        
        NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:self.locationWaitingTimeInterval];
//        NSLog(@"fireDate %@", fireDate);
        
        _locationWaitingTimer = [[NSTimer alloc] initWithFireDate:fireDate
                                                    interval:0
                                                      target:self
                                                    selector:@selector(locationWaitingTimerTick)
                                                    userInfo:nil
                                                     repeats:NO];
        
//        NSLog(@"timer %@ fireDate %@", _timeFilterTimer, _timeFilterTimer.fireDate);
        
    }
    
    //    NSLog(@"_startTimer %@", _startTimer);
    return _locationWaitingTimer;
    
}

- (void)startLocationWaitingTimer {
    [[NSRunLoop currentRunLoop] addTimer:self.locationWaitingTimer forMode:NSRunLoopCommonModes];
}

- (void)locationWaitingTimerTick {
    [self updateLastSeenTimestamp];
}

- (void)resetLocationWaitingTimer {
    
    [[NSRunLoop currentRunLoop] performSelector:@selector(invalidate)
                                         target:self.locationWaitingTimer
                                       argument:nil
                                          order:0
                                          modes:@[NSRunLoopCommonModes]];
    self.locationWaitingTimer = nil;
    
}


#pragma mark - checking start tracking conditions

- (void)checkTrackerAutoStart {
    
    if (self.tracking) [self stopTracking];
    
    [self initTimers];

    if ([self currentDesiredAccuracy] != 0) {
        
        [self startTracking];
        
    } else {
        
        [self stopTracking];
        
    }

}

- (BOOL)isValidTimeValue:(double)timeValue {
    return (timeValue >= 0 && timeValue <= 24);
}

- (BOOL)currentTimeIsInsideOfScheduleLimits {
    
    double currentTime = [STMFunctions currentTimeInDouble];
    
    if (self.trackerStartTime < self.trackerFinishTime) {
        
        return (currentTime > self.trackerStartTime && currentTime < self.trackerFinishTime);
        
    } else {
        
        return !(currentTime < self.trackerStartTime && currentTime > self.trackerFinishTime);
        
    }
    
}


#pragma mark - timers

- (void)initTimers {
    
    if (self.startTimer || self.finishTimer) {
        [self releaseTimers];
    }
    
    [[NSRunLoop currentRunLoop] addTimer:self.startTimer forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] addTimer:self.finishTimer forMode:NSRunLoopCommonModes];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@TimersInit", self.group] object:self];
    
}

- (void)releaseTimers {
    
    [self.startTimer invalidate];
    [self.finishTimer invalidate];
    self.startTimer = nil;
    self.finishTimer = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@TimersRelease", self.group] object:self];
    
}

- (NSTimer *)startTimer {
    
    if (!_startTimer) {
        
        if ([self isValidTimeValue:self.trackerStartTime]) {
            
            NSDate *startTime = [self timerTimeFromDoubleTime:self.trackerStartTime];
            
            _startTimer = [[NSTimer alloc] initWithFireDate:startTime
                                                   interval:24*3600
                                                     target:self
                                                   selector:@selector(checkTrackerAutoStart)
                                                   userInfo:nil
                                                    repeats:YES];
        }
        
    }

    return _startTimer;
    
}

- (NSTimer *)finishTimer {
    
    if (!_finishTimer) {
        
        if ([self isValidTimeValue:self.trackerFinishTime]) {
            
            NSDate *finishTime = [self timerTimeFromDoubleTime:self.trackerFinishTime];
            
            _finishTimer = [[NSTimer alloc] initWithFireDate:finishTime
                                                    interval:24*3600
                                                      target:self
                                                    selector:@selector(checkTrackerAutoStart)
                                                    userInfo:nil
                                                     repeats:YES];
        }
        
    }

    return _finishTimer;
    
}

- (NSDate *)timerTimeFromDoubleTime:(double)time {

    NSDate *timerTime = [STMFunctions dateFromDouble:time];
    
    if ([timerTime compare:[NSDate date]] == NSOrderedAscending) {
        timerTime = [NSDate dateWithTimeInterval:24*3600 sinceDate:timerTime];
    }

    return timerTime;
    
}


#pragma mark - track management

- (void)addLocation:(CLLocation *)location {

//    [self tracksManagementWithLocation:currentLocation];

    [self resetLocationWaitingTimer];
    [self startLocationWaitingTimer];
    
    STMLocation *locationObject = [STMLocationController locationObjectFromCLLocation:location];
    locationObject.lastSeenAt = locationObject.timestamp;
    
    self.lastLocation = location;
    self.lastLocationObject = locationObject;
    
    NSLog(@"location %@", self.lastLocation);
    
    [self.document saveDocument:^(BOOL success) {
        
        if (success) {
            //            NSLog(@"save newLocation success");
        }
        
    }];
    
}

- (void)updateLastSeenTimestamp {
    
    [self resetLocationWaitingTimer];
    [self startLocationWaitingTimer];

    if (self.lastLocationObject) {
        
        NSLog(@"UPDATE LAST SEEN TIMESTAMP FOR LOCATION: %@", self.lastLocation);
        self.lastLocationObject.lastSeenAt = [NSDate date];
        
    }
    
}


#pragma mark - unused track methods

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

- (void)tracksManagementWithLocation:(CLLocation *)currentLocation {
    
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
    STMLocation *location = [STMLocationController locationObjectFromCLLocation:self.lastLocation];
    [self.currentTrack addLocationsObject:location];
    self.lastLocation = [STMLocationController locationFromLocationObject:location];
    
}


@end
