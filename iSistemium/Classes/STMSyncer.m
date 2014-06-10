//
//  STMSyncer.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 06/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMSyncer.h"
#import "STMDocument.h"
#import "STMObjectsController.h"

@interface STMSyncer()

//typedef enum STMResponseType {
//    STMEntityType,
//    STMObjectType,
//    STMRelationshipType
//} STMResponseType;

@property (nonatomic, strong) STMDocument *document;
@property (nonatomic) double syncInterval;
@property (nonatomic) int fetchLimit;
@property (nonatomic, strong) NSString *restServerURI;
@property (nonatomic, strong) NSString *xmlNamespace;
@property (nonatomic, strong) NSTimer *syncTimer;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, strong) NSMutableDictionary *settings;
@property (nonatomic) BOOL syncing;
@property (nonatomic) BOOL running;
@property (nonatomic, strong) NSMutableData *responseData;

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

- (NSString *)restServerURI {
    if (!_restServerURI) {
        _restServerURI = [self.settings valueForKey:@"restServerURI"];
    }
    return _restServerURI;
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

- (NSMutableDictionary *)serverDataModel {
    
    if (!_serverDataModel) {
        _serverDataModel = [NSMutableDictionary dictionary];
    }
    
    return _serverDataModel;
    
}


#pragma mark - syncer methods

- (void)startSyncer {
    
    if (!self.running) {
        
        self.running = YES;
        [self.session.logger saveLogMessageWithText:@"Syncer start" type:@""];
        [self initTimer];
        [self addObservers];

    }
    
}

- (void)stopSyncer {
    
    if (self.running) {
        
        [self.session.logger saveLogMessageWithText:@"Syncer stop" type:@""];
        //    self.syncing = NO;
        [self releaseTimer];
        self.resultsController = nil;
        self.settings = nil;
        self.running = NO;

    }
}

- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStatusChanged:) name:@"sessionStatusChanged" object:self.session];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncerSettingsChanged:) name:[NSString stringWithFormat:@"%@SettingsChanged", @"syncer"] object:[(id <STMSession>)self.session settingsController]];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenReceived:) name:@"tokenReceived" object: self.authDelegate];

}

- (void)removeObservers {
    
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"tokenReceived" object:self.authDelegate];

}

- (void)sessionStatusChanged:(NSNotification *)notification {
    
//    NSLog(@"session status %@", [(id <STMSession>)notification.object status]);
    
    if ([[(id <STMSession>)notification.object status] isEqualToString:@"finishing"]) {
        [self stopSyncer];
    } else if ([[(id <STMSession>)notification.object status] isEqualToString:@"running"]) {
        [self startSyncer];
    }
    
}

- (void)prepareToDestroy {
    
    [self removeObservers];
    [self stopSyncer];
    
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
    [self syncData];
    
}


#pragma mark - syncing

- (void)syncData {
    
//    NSLog(@"self.syncing %d", self.syncing);
    
    if (!self.syncing) {
        
        self.syncing = YES;
        [self startConnectionWithURL:self.restServerURI pageNumber:nil];
        
    }
    
}

- (void)startConnectionWithURL:(NSString *)URLString pageNumber:(NSString *)pageNumber {
    
    NSURL *requestURL = [NSURL URLWithString:URLString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    request.HTTPShouldHandleCookies = NO;
    request = [[self.authDelegate authenticateRequest:request] mutableCopy];

    [request setHTTPMethod:@"POST"];
    
    NSString *parameters = pageNumber ? [NSString stringWithFormat:@"page-number:=%@&page-size:=%d", pageNumber, self.fetchLimit] : [NSString stringWithFormat:@"page-size:=%d", self.fetchLimit];

    [request setHTTPBody:[parameters dataUsingEncoding:NSUTF8StringEncoding]];
    
//        [request addValue:pageNumber forHTTPHeaderField:@"page-number"];
    
//    NSLog(@"request.allHTTPHeaderFields %@", request.allHTTPHeaderFields);
    
    if ([request valueForHTTPHeaderField:@"Authorization"]) {
    
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        if (!connection) {
            
            [self.session.logger saveLogMessageWithText:@"Syncer: no connection" type:@"error"];
            self.syncing = NO;
            
        } else {
            
            [self.session.logger saveLogMessageWithText:@"Syncer: send request" type:@""];
            
        }
        
    } else {
        
        [self.session.logger saveLogMessageWithText:@"Syncer: no authorization header" type:@"error"];
        [self notAuthorized];
        
    }

}

- (void)notAuthorized {

    self.syncing = NO;
    [self stopSyncer];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notAuthorized" object:self];

}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.syncing = NO;
    NSString *errorMessage = [NSString stringWithFormat:@"connection did fail with error: %@", error];
    [self.session.logger saveLogMessageWithText:errorMessage type:@"error"];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.responseData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
//    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"json"];
//    self.responseData = [NSData dataWithContentsOfFile:dataPath];

//    NSString *responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
//    NSLog(@"connectionDidFinishLoading responseData %@", responseString);
    
    [self parseResponse:self.responseData fromConnection:connection];
    
}

- (void)parseResponse:(NSData *)responseData fromConnection:(NSURLConnection *)connection {
    
//    NSLog(@"connection URL %@", connection.currentRequest.URL);
    
    NSError *error;
    NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];

//    NSLog(@"responseJSON %@", responseJSON);
    
    NSString *errorString = [responseJSON objectForKey:@"error"];
    
    if (!errorString) {

        int pageSize = [[responseJSON objectForKey:@"pageSize"] intValue];
        int pageRowCount = [[responseJSON objectForKey:@"pageRowCount"] intValue];
        
//        NSString *entityName = [responseJSON objectForKey:@"entityName"];
//        NSLog(@"pageSize %d", pageSize);
//        NSLog(@"pageRowCount %d", pageRowCount);
//        NSLog(@"entityName %@", entityName);
        
        if (pageRowCount >= pageSize) {
            
            int pageNumber = [[responseJSON objectForKey:@"pageNumber"] intValue] + 1;
            
            [self startConnectionWithURL:connection.currentRequest.URL.absoluteString pageNumber:[NSString stringWithFormat:@"%d", pageNumber]];
            
        }
        
        NSArray *dataArray = [responseJSON objectForKey:@"data"];
//        NSLog(@"dataArray %@", dataArray);
        
        for (NSDictionary *datum in dataArray) {
            
            NSDictionary *entityProperties = [datum objectForKey:@"properties"];
//            NSLog(@"entityProperties %@", entityProperties);

            if ([[datum objectForKey:@"name"] isEqualToString:@"stc.entity"]) {
                
                NSString *entityName = [@"STM" stringByAppendingString:[entityProperties objectForKey:@"name"]];
                NSString *entityURLString = [entityProperties objectForKey:@"url"];
                
                [self.serverDataModel setObject:entityProperties forKey:entityName];
                
//                if ([entityName isEqualToString:@"STMCampaignArticle"]) {
                    [self startConnectionWithURL:entityURLString pageNumber:nil];
//                }

            } else {

                NSString *name = [datum objectForKey:@"name"];
                NSArray *nameExplode = [name componentsSeparatedByString:@"."];
                NSString *entityName = [@"STM" stringByAppendingString:[nameExplode objectAtIndex:1]];

                NSDictionary *entityModel = [self.serverDataModel objectForKey:entityName];
                
                if ([entityModel objectForKey:@"roleName"]) {
                    
                    [STMObjectsController setRelationshipFromDictionary:datum];
                    
                } else {
                    
                    [STMObjectsController insertObjectFromDictionary:datum];
                    
                }
                
            }
            
        }
        
    } else {
        
        [self.session.logger saveLogMessageWithText:errorString type:@"error"];

        if ([errorString isEqualToString:@"Not authorized"]) {
            
            [self notAuthorized];
            
        } else {

            NSString *requestBody = [[NSString alloc] initWithData:connection.originalRequest.HTTPBody encoding:NSUTF8StringEncoding];
            NSLog(@"originalRequest %@", connection.originalRequest);
            NSLog(@"requestBody %@", requestBody);
            NSLog(@"responseJSON %@", responseJSON);

        }
        
    }

}

@end
