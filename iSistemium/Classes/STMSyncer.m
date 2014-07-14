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
#import "STMPhotoReport.h"
#import "STMFunctions.h"

#define SEND_URL @"https://sistemium.com/api/chest/dev/"

@interface STMSyncer() <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) STMDocument *document;
@property (nonatomic) int fetchLimit;
@property (nonatomic, strong) NSString *restServerURI;
@property (nonatomic, strong) NSString *xmlNamespace;
@property (nonatomic, strong) NSTimer *syncTimer;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, strong) NSMutableDictionary *settings;
@property (nonatomic) BOOL running;
@property (nonatomic, strong) NSMutableDictionary *responses;
@property (nonatomic) NSUInteger entityCount;

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

//- (void)setSyncing:(BOOL)syncing {
//    if (_syncing != syncing) {
//        _syncing = syncing;
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"syncStatusChanged" object:self];
//        NSString *status = _syncing ? @"start" : @"stop";
//        [self.session.logger saveLogMessageWithText:[NSString stringWithFormat:@"Syncer %@ syncing", status] type:@""];
//    }
//}

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

- (void)flushEntitySyncInfo {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"serverDataModel"];
    [defaults synchronize];
    self.entitySyncInfo = nil;
    
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
        
        NSArray *syncStates = @[@"idle", @"sendData", @"recieveData"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"syncStatusChanged" object:self];
        [self.session.logger saveLogMessageWithText:[NSString stringWithFormat:@"Syncer %@", syncStates[syncerState]] type:@""];
        
        switch (syncerState) {
                
            case STMSyncerSendData:
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                [self sendData];
                break;
                
            case STMSyncerRecieveData:
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                [self recieveData];
                break;
                
            case STMSyncerIdle:
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [STMObjectsController dataLoadingFinished];
                break;
                
            default:
                break;
                
        }
        
    }
    
}

- (void)setEntityCount:(NSUInteger)entityCount {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"entityCountdownChange" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:entityCount] forKey:@"countdownValue"]];
    
    _entityCount = entityCount;
    
}

- (NSMutableDictionary *)responses {
    
    if (!_responses) {
        _responses = [NSMutableDictionary dictionary];
    }
    return _responses;
    
}

#pragma mark - syncer methods

- (void)startSyncer {
    
    if (!self.running) {
        
        self.running = YES;
        [STMObjectsController checkPhotos];
        [self.session.logger saveLogMessageWithText:@"Syncer start" type:@""];
        [self initTimer];
        [self addObservers];
        
        NSError *error;
        if (![self.resultsController performFetch:&error]) {
            
            NSLog(@"fetch error %@", error);
            
        } else {
            
        }
        
    }
    
}

- (void)stopSyncer {
    
    if (self.running) {
        
        [self.session.logger saveLogMessageWithText:@"Syncer stop" type:@""];
        self.syncerState = STMSyncerIdle;
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


#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPhotoReport class])];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sqts" ascending:YES selector:@selector(compare:)]];
        [request setIncludesSubentities:YES];
        request.predicate = [NSPredicate predicateWithFormat:@"(lts == %@ || ts > lts) && href != %@", nil, nil];
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _resultsController.delegate = self;
        
    }
    
    return _resultsController;
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
//    NSLog(@"controllerDidChangeContent count %d", self.resultsController.fetchedObjects.count);
//    NSLog(@"controllerDidChangeContent %@", self.resultsController.fetchedObjects);
    
}

#pragma mark - syncing

- (void)sendData {
    
    if (self.syncerState == STMSyncerSendData) {
        
//        NSLog(@"sendData");
      
        if (self.resultsController.fetchedObjects.count > 0) {
            
            NSLog(@"send %d objects", self.resultsController.fetchedObjects.count);
            [self startConnectionForSendData:[self JSONFrom:self.resultsController.fetchedObjects]];

        } else {
        
            NSLog(@"nothing to send");
            self.syncerState = STMSyncerRecieveData;

        }
        
    }
    
}

- (NSData *)JSONFrom:(NSArray *)dataForSyncing {
    
    NSMutableArray *syncDataArray = [NSMutableArray array];
    
    for (NSManagedObject *object in dataForSyncing) {

        NSDate *currentDate = [NSDate date];
        [object setPrimitiveValue:currentDate forKey:@"sts"];
        
        NSMutableDictionary *objectDictionary = [self dictionaryForObject:object];
        NSMutableDictionary *propertiesDictionary = [self propertiesDictionaryForObject:object];
            
        [objectDictionary setObject:propertiesDictionary forKey:@"properties"];
        [syncDataArray addObject:objectDictionary];

    }
    
    NSDictionary *dataDictionary = [NSDictionary dictionaryWithObject:syncDataArray forKey:@"data"];
    
//    NSLog(@"dataDictionary %@", dataDictionary);
    
    NSError *error;
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dataDictionary options:NSJSONWritingPrettyPrinted error:&error];
    
//    NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
//    NSLog(@"JSONString %@", JSONString);
    
    return JSONData;
}

- (NSMutableDictionary *)dictionaryForObject:(NSManagedObject *)object {
    
    NSString *name = @"stc.PhotoReport";
    NSString *xid = [STMFunctions xidStringFromXidData:[object valueForKey:@"xid"]];

    return [NSMutableDictionary dictionaryWithObjectsAndKeys:name, @"name", xid, @"xid", nil];
    
}

- (NSMutableDictionary *)propertiesDictionaryForObject:(NSManagedObject *)object {
    
    NSMutableDictionary *propertiesDictionary = [NSMutableDictionary dictionary];
    
    for (NSString *key in object.entity.attributesByName.allKeys) {
        
        id value = [object valueForKey:key];
        
        if ([value isKindOfClass:[NSDate class]] || [key isEqual:@"href"]) {
            
            [propertiesDictionary setValue:[NSString stringWithFormat:@"%@", value] forKey:key];

        }
        
    }
    
    for (NSString *key in object.entity.relationshipsByName.allKeys) {

        if ([@[@"campaign", @"outlet"] containsObject:key]) {
            
            id value = [object valueForKey:key];
            
            NSString *xid = [STMFunctions xidStringFromXidData:[value valueForKey:@"xid"]];

            [propertiesDictionary setValue:xid forKey:key];

            
        }
        
    }
    
    return propertiesDictionary;
    
}


- (void)startConnectionForSendData:(NSData *)sendData {
    
    NSURL *requestURL = [NSURL URLWithString:SEND_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    
    request = [[self.authDelegate authenticateRequest:request] mutableCopy];
    
    if ([request valueForHTTPHeaderField:@"Authorization"]) {
        
        request.HTTPShouldHandleCookies = NO;
        //        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        [request setHTTPMethod:@"POST"];

        request.HTTPBody = sendData;
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        if (!connection) {
            
            [self.session.logger saveLogMessageWithText:@"Syncer: no connection" type:@"error"];
            self.syncerState = STMSyncerIdle;
            
        } else {
            
//            [self.session.logger saveLogMessageWithText:@"Syncer: send request" type:@""];
            
        }
        
    } else {
        
        [self.session.logger saveLogMessageWithText:@"Syncer: no authorization header" type:@"error"];
        [self notAuthorized];
        
    }
    
}

- (void)recieveData {
    
    if (self.syncerState == STMSyncerRecieveData) {
        
        //        NSLog(@"recieveData");
        [self startConnectionForRecieveEntitiesWithName:@"STMEntity"];
        
    }
    
}

- (void)startConnectionForRecieveEntitiesWithName:(NSString *)entityName {
    
    if (self.syncerState != STMSyncerIdle) {
        
        NSDictionary *entity = [self.entitySyncInfo objectForKey:entityName];
        NSString *url = [entity objectForKey:@"url"];
        NSString *eTag = [entity objectForKey:@"eTag"];
        eTag = eTag ? eTag : @"*";
        
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
                //            self.syncing = NO;
                self.syncerState = STMSyncerIdle;
                
            } else {
                
                //            [self.session.logger saveLogMessageWithText:@"Syncer: send request" type:@""];
                
            }
            
        } else {
            
            [self.session.logger saveLogMessageWithText:@"Syncer: no authorization header" type:@"error"];
            [self notAuthorized];
            
        }
        
    }
    
}

- (void)notAuthorized {
    
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
    
    if ([connection.currentRequest.URL.absoluteString isEqualToString:SEND_URL]) {
        entityName = @"SEND_DATA";
    }
    
//    NSLog(@"URL.absoluteString %@", connection.currentRequest.URL.absoluteString);
//    NSLog(@"entityName %@", entityName);
    
    return entityName;
    
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    self.syncerState = STMSyncerIdle;
    NSString *errorMessage = [NSString stringWithFormat:@"connection did fail with error: %@", error];
    [self.session.logger saveLogMessageWithText:errorMessage type:@"error"];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
    NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
    //    NSLog(@"headers %@", headers);
    
    NSString *entityName = [self entityNameForConnection:connection];
    
    if (statusCode == 200) {
        
        [self.responses setObject:[NSMutableData data] forKey:entityName];
        
        NSString *eTag = [headers objectForKey:@"eTag"];
        
        if (eTag && entityName && self.syncerState != STMSyncerIdle) {
            
            [[self.entitySyncInfo objectForKey:entityName] setValue:eTag forKey:@"temporaryETag"];
            [self saveServerDataModel];
            
        }
        
    } else if (statusCode == 304) {
        
        NSLog(@"304 Not Modified");
        
    }  else if (statusCode == 204) {
        
        NSLog(@"%@: 204 No Content", entityName);
        
        [self.responses removeObjectForKey:entityName];
        
        if ([entityName isEqualToString:@"STMEntity"]) {
            
            self.entityCount = self.entitySyncInfo.allKeys.count - 1;
            
            NSMutableArray *entityNames = [self.entitySyncInfo.allKeys mutableCopy];
            [entityNames removeObject:entityName];
            
            for (NSString *name in entityNames) {
                [self startConnectionForRecieveEntitiesWithName:name];
            }
            
        } else {
            
            self.entityCount -= 1;
            
            if (self.entityCount == 0) {
                self.syncerState = STMSyncerIdle;
            }
            
        }
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSString *entityName = [self entityNameForConnection:connection];
    NSMutableData *responseData = [self.responses objectForKey:entityName];
    [responseData appendData:data];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSString *entityName = [self entityNameForConnection:connection];
    NSMutableData *responseData = [self.responses objectForKey:entityName];
    
    if (responseData) {
        [self parseResponse:responseData fromConnection:connection];
    }
    
}

- (void)parseResponse:(NSData *)responseData fromConnection:(NSURLConnection *)connection {
    
    NSError *error;
    NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    
//    NSLog(@"responseJSON %@", responseJSON);
    
    NSString *errorString = [responseJSON objectForKey:@"error"];
    
    if (!errorString) {
        
        NSString *connectionEntityName = [self entityNameForConnection:connection];
        NSArray *dataArray = [responseJSON objectForKey:@"data"];
        
        if ([connectionEntityName isEqualToString:@"STMEntity"]) {
            
            for (NSDictionary *datum in dataArray) {
                
                NSMutableDictionary *entityProperties = [datum objectForKey:@"properties"];
                NSString *entityName = [@"STM" stringByAppendingString:[entityProperties objectForKey:@"name"]];
                [self.entitySyncInfo setObject:entityProperties forKey:entityName];
                [self saveServerDataModel];
                
            }
            
            [self fillETagWithTemporaryValueForEntityName:connectionEntityName];
            
            
        } else {
            
            NSDictionary *entityModel = [self.entitySyncInfo objectForKey:connectionEntityName];
            
            if ([entityModel objectForKey:@"roleName"]) {
                
                [STMObjectsController setRelationshipsFromArray:dataArray withCompletionHandler:^(BOOL success) {
                    
                    if (success) {
                        
                        //                        NSLog(@"%d relationships successefully added", dataArray.count);
                        [self fillETagWithTemporaryValueForEntityName:connectionEntityName];
                        
                    }
                    
                }];
                
            } else if (entityModel) {
                
                [STMObjectsController insertObjectsFromArray:dataArray withCompletionHandler:^(BOOL success) {
                    
                    if (success) {
                        
                        //                        NSLog(@"%d objects successefully added", dataArray.count);
                        [self fillETagWithTemporaryValueForEntityName:connectionEntityName];
                        
                    }
                    
                }];
                
            } else {
                
                for (NSDictionary *datum in dataArray) {
                    [self syncObject:datum];
                }
                
                self.syncerState = STMSyncerRecieveData;
                
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

- (void)fillETagWithTemporaryValueForEntityName:(NSString *)entityName {
    
    NSString *eTag = [[self.entitySyncInfo objectForKey:entityName] objectForKey:@"temporaryETag"];
    [[self.entitySyncInfo objectForKey:entityName] setValue:eTag forKey:@"eTag"];
    [self saveServerDataModel];
    [self startConnectionForRecieveEntitiesWithName:entityName];
    
}

- (void)syncObject:(NSDictionary *)object {
    
    NSString *result = [object valueForKey:@"result"];
    NSString *xid = [(NSDictionary *)object valueForKey:@"xid"];
    NSString *xidString = [xid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSData *xidData = [STMFunctions dataFromString:xidString];
    
    if (!result || ![result isEqualToString:@"ok"]) {
        
        NSString *errorMessage = [NSString stringWithFormat:@"Sync result not ok xid: %@", xid];
        [self.session.logger saveLogMessageWithText:errorMessage type:@"error"];
        
    } else {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMDatum class])];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"ts" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"xid == %@", xidData];
        
        NSError *error;
        NSArray *fetchResult = [self.session.document.managedObjectContext executeFetchRequest:request error:&error];
        
        NSManagedObject *object = [fetchResult lastObject];
        
        if (object) {
            
            [object setValue:[object valueForKey:@"sts"] forKey:@"lts"];
            NSLog(@"successefully sync object with xid %@", xid);
//            NSLog(@"object %@", object);
            
        } else {
            
            [self.session.logger saveLogMessageWithText:[NSString stringWithFormat:@"Sync: no object with xid: %@", xid] type:@"error"];
            
        }
    
    }
    
}


@end
