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
@synthesize entitySyncInfo = _entitySyncInfo;
@synthesize syncerState = _syncerState;


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

- (NSMutableDictionary *)entitySyncInfo {
    
    if (!_entitySyncInfo) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        id serverDataModel = [defaults objectForKey:@"serverDataModel"];

        if (!serverDataModel) {
            
            serverDataModel = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.restServerURI, @"url", nil], @"STMEntity", nil];
            [defaults setObject:serverDataModel forKey:@"serverDataModel"];
            [defaults synchronize];

        }
        
        _entitySyncInfo = serverDataModel;
        
    }
    
//    NSLog(@"_serverDataModel %@", _serverDataModel);
    
    return _entitySyncInfo;
    
}

- (void)setEntitySyncInfo:(NSMutableDictionary *)serverDataModel {
    
    if (serverDataModel != _entitySyncInfo) {
    
        _entitySyncInfo = serverDataModel;
        [self saveServerDataModel];
        
    }
    
}

- (void)saveServerDataModel {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.entitySyncInfo forKey:@"serverDataModel"];
    [defaults synchronize];
    
}

- (STMSyncerState)syncerState {
    
    if (!_syncerState) {
        _syncerState = STMSyncerIdle;
    }
    
    return _syncerState;
    
}

- (void)setSyncerState:(STMSyncerState)syncerState {
    
    if (syncerState != _syncerState) {
        
        _syncerState = syncerState;
        
        switch (syncerState) {
                
            case STMSyncerSendData:
                [self sendData];
                break;
                
            case STMSyncerRecieveData:
                [self recieveData];
                break;
                
            default:
                break;
                
        }
        
    }
    
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
    self.syncerState = STMSyncerSendData;
    
}


#pragma mark - syncing

- (void)sendData {
    
    NSLog(@"sendData");
    
    self.syncerState = STMSyncerRecieveData;
    
}

- (void)recieveData {
    
    NSLog(@"recieveData");
    
    if (!self.syncing) {

        self.syncing = YES;
        [self startConnectionForRecieveEntitiesWithName:@"STMEntity"];
//        [self startConnectionWithURL:self.restServerURI pageNumber:nil];
        
    }
    
//    self.syncerState = STMSyncerIdle;
    
}

//- (void)syncData {
//    
////    NSLog(@"self.syncing %d", self.syncing);
//    
//    switch (self.syncerState) {
//            
//        case STMSyncerSendData:
//            [self sendData];
//            break;
//            
//        case STMSyncerRecieveData:
//            [self recieveData];
//            break;
//            
//        default:
//            break;
//            
//    }
//
//}

- (void)startConnectionForRecieveEntitiesWithName:(NSString *)entityName {
    
    NSDictionary *entity = [self.entitySyncInfo objectForKey:entityName];
    NSString *url = [entity objectForKey:@"url"];
    NSString *eTag = [entity objectForKey:@"eTag"];
    eTag = eTag ? eTag : @"*";
    NSLog(@"entityName %@, eTag %@", entityName, eTag);
    
    NSURL *requestURL = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    request = [[self.authDelegate authenticateRequest:request] mutableCopy];
    
    if ([request valueForHTTPHeaderField:@"Authorization"]) {
        
        request.HTTPShouldHandleCookies = NO;
//        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        [request setHTTPMethod:@"GET"];
        
        [request addValue:[NSString stringWithFormat:@"%d", self.fetchLimit] forHTTPHeaderField:@"page-size"];
        [request addValue:eTag forHTTPHeaderField:@"If-none-match"];
    
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

/*
- (void)startConnectionWithURL:(NSString *)URLString pageNumber:(NSString *)pageNumber {
    
    NSURL *requestURL = [NSURL URLWithString:URLString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    request.HTTPShouldHandleCookies = NO;
    request = [[self.authDelegate authenticateRequest:request] mutableCopy];

    [request setHTTPMethod:@"POST"];
    
    NSString *parameters = pageNumber ? [NSString stringWithFormat:@"page-number:=%@&page-size:=%d", pageNumber, self.fetchLimit] : [NSString stringWithFormat:@"page-size:=%d", self.fetchLimit];

    [request setHTTPBody:[parameters dataUsingEncoding:NSUTF8StringEncoding]];
    
//    [request addValue:pageNumber forHTTPHeaderField:@"If-Modified-Since"];
    
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
*/

- (void)notAuthorized {

    self.syncing = NO;
    [self stopSyncer];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notAuthorized" object:self];

}

- (NSString *)entityNameForConnection:(NSURLConnection *)connection {
    
    NSString *entityName = nil;
    
    for (NSString *name in self.entitySyncInfo.allKeys) {
        
        NSDictionary *entityDic = [self.entitySyncInfo objectForKey:name];
        
        if ([[entityDic objectForKey:@"url"] isEqualToString:connection.currentRequest.URL.absoluteString]) {
            
            entityName = name;
            
        }
        
    }
    
    return entityName;

    
    // 2nd option to get entity name — require headers from NSURLResponse
    /*
     NSString *entityName = [headers objectForKey:@"Title"];
     NSArray *nameExplode = [entityName componentsSeparatedByString:@"."];
     entityName = [@"STM" stringByAppendingString:[nameExplode objectAtIndex:1]];
     
     NSString *capString = [[entityName substringToIndex:4] uppercaseString];
     entityName = [entityName stringByReplacingCharactersInRange:NSMakeRange(0,4) withString:capString];
     
     [[self.serverDataModel objectForKey:entityName] setValue:eTag forKey:@"eTag"];
     [self saveServerDataModel];
     */
    // end of 2nd option

}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.syncing = NO;
    NSString *errorMessage = [NSString stringWithFormat:@"connection did fail with error: %@", error];
    [self.session.logger saveLogMessageWithText:errorMessage type:@"error"];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
    NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
//    NSLog(@"headers %@", headers);
    
    NSString *entityName = [self entityNameForConnection:connection];
    
    if (statusCode == 200) {
        
        self.responseData = [NSMutableData data];
        
        NSString *eTag = [headers objectForKey:@"eTag"];
//        NSLog(@"eTag %@", eTag);
        
        if (eTag && entityName) {
        
            [[self.entitySyncInfo objectForKey:entityName] setValue:eTag forKey:@"eTag"];
            [self saveServerDataModel];
            [self startConnectionForRecieveEntitiesWithName:entityName];
            
        }
        
    } else if (statusCode == 304) {
        
        NSLog(@"304 Not Modified");
        
    }  else if (statusCode == 204) {
        
        NSLog(@"%@: 204 No Content", entityName);
        
        if ([entityName isEqualToString:@"STMEntity"]) {
            
            NSMutableArray *entityNames = [self.entitySyncInfo.allKeys mutableCopy];
            [entityNames removeObject:entityName];
            
            for (NSString *name in entityNames) {
                [self startConnectionForRecieveEntitiesWithName:name];
            }
            
        }
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
//    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"json"];
//    self.responseData = [NSData dataWithContentsOfFile:dataPath];
//
//    NSString *responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
//    NSLog(@"connectionDidFinishLoading responseData %@", responseString);
    
    if (self.responseData) {
        [self parseResponse:self.responseData fromConnection:connection];
    }
    
}

- (void)parseResponse:(NSData *)responseData fromConnection:(NSURLConnection *)connection {
    
//    NSLog(@"connection URL %@", connection.currentRequest.URL);
    
    NSError *error;
    NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];

//    NSLog(@"responseJSON %@", responseJSON);
    
    NSString *errorString = [responseJSON objectForKey:@"error"];
    
    if (!errorString) {

//        int pageSize = [[responseJSON objectForKey:@"pageSize"] intValue];
//        int pageRowCount = [[responseJSON objectForKey:@"pageRowCount"] intValue];
//        
//        NSString *entityName = [responseJSON objectForKey:@"entityName"];
//        NSLog(@"pageSize %d", pageSize);
//        NSLog(@"pageRowCount %d", pageRowCount);
//        NSLog(@"entityName %@", entityName);
//        
//        if (pageRowCount >= pageSize) {
//            
//            int pageNumber = [[responseJSON objectForKey:@"pageNumber"] intValue] + 1;
//            
//            [self startConnectionWithURL:connection.currentRequest.URL.absoluteString pageNumber:[NSString stringWithFormat:@"%d", pageNumber]];
//            
//        }
        
        NSArray *dataArray = [responseJSON objectForKey:@"data"];
//        NSLog(@"dataArray %@", dataArray);
        
        for (NSDictionary *datum in dataArray) {
            
            NSMutableDictionary *entityProperties = [datum objectForKey:@"properties"];
//            NSLog(@"entityProperties %@", entityProperties);

            NSString *connectionEntityName = [self entityNameForConnection:connection];
            
            if ([connectionEntityName isEqualToString:@"STMEntity"]) {
                
                NSString *entityName = [@"STM" stringByAppendingString:[entityProperties objectForKey:@"name"]];
//                NSString *entityURLString = [entityProperties objectForKey:@"url"];
                
                [self.entitySyncInfo setObject:entityProperties forKey:entityName];
                [self saveServerDataModel];
                NSLog(@"self.serverDataModel %@", self.entitySyncInfo);
                
//                if ([entityName isEqualToString:@"STMCampaignArticle"]) {
//                    [self startConnectionWithURL:entityURLString pageNumber:nil];
//                }

            } else {

//                NSString *name = [datum objectForKey:@"name"];
//                NSArray *nameExplode = [name componentsSeparatedByString:@"."];
//                NSString *entityName = [@"STM" stringByAppendingString:[nameExplode objectAtIndex:1]];
//
//                NSDictionary *entityModel = [self.entitySyncInfo objectForKey:entityName];
//                
//                if ([entityModel objectForKey:@"roleName"]) {
//                    
//                    [STMObjectsController setRelationshipFromDictionary:datum];
//                    
//                } else {
//                    
//                    [STMObjectsController insertObjectFromDictionary:datum];
//                    
//                }
                
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
