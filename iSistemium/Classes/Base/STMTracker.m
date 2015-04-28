//
//  STMTracker.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 3/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STMTracker.h"
#import "STMSession.h"

@interface STMTracker()


@property (nonatomic, strong) NSTimer *startTimer;
@property (nonatomic, strong) NSTimer *finishTimer;

@property (nonatomic) double trackerStartTime;
@property (nonatomic) double trackerFinishTime;


@end

@implementation STMTracker

@synthesize trackerAutoStart = _trackerAutoStart;
@synthesize trackerStartTime = _trackerStartTime;
@synthesize trackerFinishTime = _trackerFinishTime;


- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        [self customInit];
    }
    
    return self;
    
}

- (void)customInit {
    
    [self addObservers];
    NSLog(@"%@ tracker init", self.group);
    
}

- (void)addObservers {
    
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(sessionStatusChanged:)
               name:@"sessionStatusChanged"
             object:self.session];
    
    [nc addObserver:self
           selector:@selector(trackerSettingsChanged:)
               name:[NSString stringWithFormat:@"%@SettingsChanged", self.group]
             object:self.session];
    
    [nc addObserver:self
           selector:@selector(checkTimeForTracking)
               name:UIApplicationDidBecomeActiveNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(checkTimeForTracking)
               name:@"applicationPerformFetchWithCompletionHandler"
             object:nil];
    
    [nc addObserver:self
           selector:@selector(didReceiveRemoteNotification:)
               name:@"applicationDidReceiveRemoteNotification"
             object: nil];

}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sessionStatusChanged" object:self.session];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[NSString stringWithFormat:@"%@SettingsChanged", self.group] object:self.session];
    
}

- (void)prepareToDestroy {
    
    [self stopTracking];
    [self removeObservers];
    
}

- (void)setSession:(id<STMSession>)session {
    
    _session = session;
    self.document = (STMDocument *)[(id <STMSession>)session document];
    
}

- (NSMutableDictionary *)settings {
    
    if (!_settings) {
        
        _settings = [[(id <STMSession>)self.session settingsController] currentSettingsForGroup:self.group];
        for (NSString *settingName in [_settings allKeys]) {
            [_settings addObserver:self forKeyPath:settingName options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
        }
    
//        NSLog(@"_settings %@", _settings);

    }
    
    return _settings;
    
}

- (void)trackerSettingsChanged:(NSNotification *)notification {
    
    [self.settings addEntriesFromDictionary:notification.userInfo];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([change valueForKey:NSKeyValueChangeNewKey] != [change valueForKey:NSKeyValueChangeOldKey]) {
        if ([keyPath hasSuffix:@"TrackerAutoStart"] || [keyPath hasSuffix:@"TrackerStartTime"] || [keyPath hasSuffix:@"TrackerFinishTime"]) {
            [self checkTrackerAutoStart];
        }
    }
    
}


- (void)sessionStatusChanged:(NSNotification *)notification {
    
    if ([[(id <STMSession>)notification.object status] isEqualToString:@"finishing"]) {
        [self releaseTimers];
        [self stopTracking];
    } else if ([[(id <STMSession>)notification.object status] isEqualToString:@"running"]) {
        [self checkTrackerAutoStart];
//        [self startTracking];
    }
    
}

- (void)didReceiveRemoteNotification:(NSNotification *) notification {
    
    id command = [notification userInfo][[[self class] description]];
    
    if ([command isEqual:@"stop"]) {
        [self stopTracking];
    } else if ([command isEqual:@"start"]) {
        [self startTracking];
    }
    
}

#pragma mark - tracker settings

- (BOOL)trackerAutoStart {
    
    return [[self.settings valueForKey:[NSString stringWithFormat:@"%@TrackerAutoStart", self.group]] boolValue];
    
}

- (double)trackerStartTime {
    
    return [[self.settings valueForKey:[NSString stringWithFormat:@"%@TrackerStartTime", self.group]] doubleValue];
    
}

- (double)trackerFinishTime {
    
    return [[self.settings valueForKey:[NSString stringWithFormat:@"%@TrackerFinishTime", self.group]] doubleValue];
    
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
        
        if (self.trackerStartTime) {
            
            NSDate *startTime = [self dateFromDouble:self.trackerStartTime];
            
            if ([startTime compare:[NSDate date]] == NSOrderedAscending) {
                startTime = [NSDate dateWithTimeInterval:24*3600 sinceDate:startTime];
            }
            
//            NSLog(@"%@ startTime %@", [[self class] description], startTime);
            _startTimer = [[NSTimer alloc] initWithFireDate:startTime interval:24*3600 target:self selector:@selector(startTracking) userInfo:nil repeats:YES];
            
        }
        
    }
    
//    NSLog(@"_startTimer %@", _startTimer);
    return _startTimer;
    
}

- (NSTimer *)finishTimer {
    
    if (!_finishTimer) {
        
        if (self.trackerFinishTime) {
            
            NSDate *finishTime = [self dateFromDouble:self.trackerFinishTime];
            
            if ([finishTime compare:[NSDate date]] == NSOrderedAscending) {
                finishTime = [NSDate dateWithTimeInterval:24*3600 sinceDate:finishTime];
            }
            
//            NSLog(@"%@ finishTime %@", [[self class] description], finishTime);
            _finishTimer = [[NSTimer alloc] initWithFireDate:finishTime interval:24*3600 target:self selector:@selector(stopTracking) userInfo:nil repeats:YES];
            
        }
        
    }
    
//    NSLog(@"_finishTimer %@", _finishTimer);
    return _finishTimer;
    
}

- (void)checkTrackerAutoStart {
    
    if (self.trackerAutoStart) {
        
        if (self.trackerStartTime && self.trackerFinishTime) {
            
            [self releaseTimers];
            [self checkTimeForTracking];
            [self initTimers];
            
        } else {
            
            [self releaseTimers];
            NSLog(@"trackerStartTime OR trackerFinishTime not set");
            
        }
        
    } else {
        
        [self releaseTimers];
        [self stopTracking];
        
    }
    
}

- (void)checkTimeForTracking {
    
    double currentTime = [self currentTimeInDouble];
    
    if (!self.trackerAutoStart) return;
    
    if (self.trackerStartTime < self.trackerFinishTime) {
        
        if (currentTime > self.trackerStartTime && currentTime < self.trackerFinishTime) {
            if (!self.tracking) {
                [self startTracking];
            }
        } else {
            if (self.tracking) {
                [self stopTracking];
            }
        }
        
    } else {
        
        if (currentTime < self.trackerStartTime && currentTime > self.trackerFinishTime) {
            if (self.tracking) {
                [self stopTracking];
            }
        } else {
            if (!self.tracking) {
                [self startTracking];
            }
        }
        
    }
    
}

- (NSDate *)dateFromDouble:(double)time {
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    double seconds = time * 3600;
    currentDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:currentDate]];
    return [NSDate dateWithTimeInterval:seconds sinceDate:currentDate];
    
}

- (double)currentTimeInDouble {
    
    NSDate *localDate = [NSDate date];
    NSDateFormatter *hourFormatter = [[NSDateFormatter alloc] init];
    hourFormatter.dateFormat = @"HH";
    double hour = [[hourFormatter stringFromDate:localDate] doubleValue];
    NSDateFormatter *minuteFormatter = [[NSDateFormatter alloc] init];
    minuteFormatter.dateFormat = @"mm";
    double minute = [[minuteFormatter stringFromDate:localDate] doubleValue];
    double currentTime = hour + minute/60;
    return currentTime;
    
}

#pragma mark - tracking

- (void)startTracking {
    
//    NSLog(@"%@ startTracking %@", self.group, [NSDate date]);
    
    if ([[(id <STMSession>)self.session status] isEqualToString:@"running"] && !self.tracking) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@TrackingStart", self.group] object:self];
        self.tracking = YES;
        [[STMLogger sharedLogger] saveLogMessageWithText:[NSString stringWithFormat:@"Start tracking %@", self.group] type:@"important"];
        
    } else {
        NSLog(@"%@ tracker already started", self.group);
    }
    
}

- (void)stopTracking {
    
//    NSLog(@"%@ stopTracking %@", self.group, [NSDate date]);

    if (self.tracking) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@TrackingStop", self.group] object:self];
        self.tracking = NO;
        [[STMLogger sharedLogger] saveLogMessageWithText:[NSString stringWithFormat:@"Stop tracking %@", self.group] type:@"important"];

    } else {
        NSLog(@"%@ tracker already stopped", self.group);
    }
    
}


@end
