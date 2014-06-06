//
//  STMSyncer.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 06/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMSyncer.h"
#import "STMDocument.h"


@interface STMSyncer()

@property (nonatomic, strong) STMDocument *document;
@property (nonatomic) double syncInterval;
@property (nonatomic) int fetchLimit;
@property (nonatomic, strong) NSString *syncServerURI;
@property (nonatomic, strong) NSString *xmlNamespace;
@property (nonatomic, strong) NSTimer *syncTimer;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, strong) NSMutableDictionary *settings;
@property (nonatomic) BOOL syncing;

@end

@implementation STMSyncer

@synthesize syncInterval = _syncInterval;


- (id)init {
    
    self = [super init];
    
    if (self) {
        [self customInit];
    }
    
    return self;
    
}

- (void)customInit {
    
    NSLog(@"syncer init");
    
}


#pragma mark - variables setters & getters

- (void)setSession:(id <STMSession>)session {

    if (session != _session) {

        self.document = (STMDocument *)session.document;
        _session = session;
        
//        NSError *error;
//        if (![self.resultsController performFetch:&error]) {
//            
//        } else {
//            
//        }
        [self startSyncer];

    }
    
}


- (NSMutableDictionary *)settings {
    if (!_settings) {
        _settings = [[(id <STMSession>)self.session settingsController] currentSettingsForGroup:@"syncer"];
    }
    return _settings;
}

- (int)fetchLimit {
    if (!_fetchLimit) {
        _fetchLimit = [[self.settings valueForKey:@"fetchLimit"] intValue];
    }
    return _fetchLimit;
}

- (double)syncInterval {
    if (!_syncInterval) {
        _syncInterval = [[self.settings valueForKey:@"syncInterval"] doubleValue];
    }
    return _syncInterval;
}

- (void)setSyncInterval:(double)syncInterval {
    if (_syncInterval != syncInterval) {
        [self releaseTimer];
        _syncInterval = syncInterval;
        [self initTimer];
    }
}

- (NSString *)syncServerURI {
    if (!_syncServerURI) {
        _syncServerURI = [self.settings valueForKey:@"syncServerURI"];
    }
    return _syncServerURI;
}

- (NSString *)xmlNamespace {
    if (!_xmlNamespace) {
        _xmlNamespace = [self.settings valueForKey:@"xmlNamespace"];
    }
    return _xmlNamespace;
}

- (void)setSyncing:(BOOL)syncing {
    if (_syncing != syncing) {
        _syncing = syncing;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"syncStatusChanged" object:self];
        NSString *status = _syncing ? @"start" : @"stop";
        [self.session.logger saveLogMessageWithText:[NSString stringWithFormat:@"Syncer %@ syncing", status] type:@""];
    }
}


#pragma mark - syncer methods

- (void)startSyncer {
    [self.session.logger saveLogMessageWithText:@"Syncer start" type:@""];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStatusChanged:) name:@"sessionStatusChanged" object:self.session];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncerSettingsChanged:) name:[NSString stringWithFormat:@"%@SettingsChanged", @"syncer"] object:[(id <STMSession>)self.session settingsController]];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenReceived:) name:@"tokenReceived" object: self.authDelegate];
    [self initTimer];
//    self.running = YES;
}

- (void)stopSyncer {
    [self.session.logger saveLogMessageWithText:@"Syncer stop" type:@""];
//    self.running = NO;
//    self.syncing = NO;
    [self releaseTimer];
    self.resultsController = nil;
    self.settings = nil;
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"tokenReceived" object:self.authDelegate];
}


#pragma mark - timer

- (NSTimer *)syncTimer {
    if (!_syncTimer) {
        if (!self.syncInterval) {
            _syncTimer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:0 target:self selector:@selector(onTimerTick:) userInfo:nil repeats:NO];
        } else {
            _syncTimer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:self.syncInterval target:self selector:@selector(onTimerTick:) userInfo:nil repeats:YES];
        }
    }
    return _syncTimer;
}

- (void)initTimer {
    UIBackgroundTaskIdentifier bgTask = 0;
    UIApplication  *app = [UIApplication sharedApplication];
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
    }];
    
    [[NSRunLoop currentRunLoop] addTimer:self.syncTimer forMode:NSRunLoopCommonModes];
}

- (void)releaseTimer {
    [self.syncTimer invalidate];
    self.syncTimer = nil;
}

- (void)onTimerTick:(NSTimer *)timer {
    //    NSLog(@"syncTimer tick at %@", [NSDate date]);
//    [self syncData];
}


@end
