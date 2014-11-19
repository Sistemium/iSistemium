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

#import "STMPhotoReport.h"
#import "STMCashing.h"
#import "STMUncashing.h"
#import "STMMessage.h"
#import "STMClientData.h"
#import "STMRecordStatus.h"
#import "STMLocation.h"

//#define SEND_URL @"https://nginx.sistemium.com/api/v1/dev/"
//#define SEND_URL @"https://sistemium.com/api/chest/dev/"

@interface STMSyncer() <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) STMDocument *document;
@property (nonatomic) int fetchLimit;
@property (nonatomic, strong) NSString *restServerURI;
@property (nonatomic, strong) NSString *apiUrlString;
@property (nonatomic, strong) NSString *xmlNamespace;
@property (nonatomic, strong) NSTimer *syncTimer;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, strong) NSMutableDictionary *settings;
@property (nonatomic) BOOL running;
@property (nonatomic, strong) NSMutableDictionary *responses;
@property (nonatomic) NSUInteger entityCount;
@property (nonatomic) BOOL syncing;
@property (nonatomic) BOOL checkSending;
@property (nonatomic, strong) NSData *clientDataXid;
@property (nonatomic, strong) void (^fetchCompletionHandler) (UIBackgroundFetchResult result);

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

- (NSString *)apiUrlString {
    if (!_apiUrlString) {
        _apiUrlString = [self.settings valueForKey:@"API.url"];
    }
    return _apiUrlString;
}

- (NSString *)xmlNamespace {
    if (!_xmlNamespace) {
        _xmlNamespace = [self.settings valueForKey:@"xmlNamespace"];
    }
    return _xmlNamespace;
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

- (void) setSyncerState:(STMSyncerState) syncerState fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result)) handler {
    
    self.fetchCompletionHandler = handler;
    self.syncerState = syncerState;
    
}


- (void)setSyncerState:(STMSyncerState)syncerState {
    
    if (!self.syncing && syncerState != _syncerState) {
        
        _syncerState = syncerState;
        
        NSArray *syncStates = @[@"idle", @"sendData", @"receiveData"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"syncStatusChanged" object:self];
        [self.session.logger saveLogMessageWithText:[NSString stringWithFormat:@"Syncer %@", syncStates[syncerState]] type:@""];
        
        switch (syncerState) {
                
            case STMSyncerSendData:
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                self.syncing = YES;
                [self sendData];
                break;
                
            case STMSyncerReceiveData:
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                self.syncing = YES;
                [self receiveData];
                break;
                
            case STMSyncerIdle:
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                self.syncing = NO;
                [STMObjectsController dataLoadingFinished];
                if (self.fetchCompletionHandler) {
                    self.fetchCompletionHandler(UIBackgroundFetchResultNewData);
                }
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
        
        self.settings = nil;
        self.running = YES;
        [STMObjectsController checkPhotos];
        [STMObjectsController checkDeviceToken];
//        [STMObjectsController checkAppVersion];
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
        self.syncing = NO;
        self.syncerState = STMSyncerIdle;
        [self releaseTimer];
        self.resultsController = nil;
        self.settings = nil;
        self.running = NO;
        
    }
}

- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStatusChanged:) name:@"sessionStatusChanged" object:self.session];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncerSettingsChanged) name:@"syncerSettingsChanged" object:self.session];

    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenReceived:) name:@"tokenReceived" object: self.authDelegate];
    
}

- (void)removeObservers {

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)sessionStatusChanged:(NSNotification *)notification {
    
    //    NSLog(@"session status %@", [(id <STMSession>)notification.object status]);
    
    if ([[(id <STMSession>)notification.object status] isEqualToString:@"finishing"]) {
        [self stopSyncer];
    } else if ([[(id <STMSession>)notification.object status] isEqualToString:@"running"]) {
        [self startSyncer];
    }
    
}

- (void)syncerSettingsChanged {
    
    self.settings = nil;
    
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
    
//    UIBackgroundTaskIdentifier bgTask = 0;
//    UIApplication  *app = [UIApplication sharedApplication];
//    
//    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
//        [app endBackgroundTask:bgTask];
//    }];
//    
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
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMDatum class])];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sqts" ascending:YES selector:@selector(compare:)]];
        [request setIncludesSubentities:YES];
        
        request.predicate = [NSPredicate predicateWithFormat:@"(lts == %@ || deviceTs > lts)", nil];
        
//        request.predicate = [NSPredicate predicateWithFormat:@"(lts == %@ || deviceTs > lts) && href != %@", nil, nil];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _resultsController.delegate = self;
        
    }
    
    return _resultsController;
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
/*
    if ([[(NSManagedObject *)anObject entity].name isEqualToString:@"STMUncashing"]) {
        
        NSLog(@"anObject change %@", anObject);
        
    }
*/
    
}

#pragma mark - syncing

- (void)sendData {
    
    if (self.syncerState == STMSyncerSendData) {
        
        if (self.resultsController.fetchedObjects.count > 0) {
            
            NSData *sendData = [self JSONFrom:self.resultsController.fetchedObjects];

            if (sendData) {
                
                self.checkSending = YES;
                [self startConnectionForSendData:sendData];
                
            } else {
                
                [self nothingToSend];
                
            }

        } else {
        
            [self nothingToSend];
            
        }
        
    }
    
}

- (void)nothingToSend {
    
    [self.session.logger saveLogMessageWithText:@"Syncer nothing to send" type:@""];

    self.syncing = NO;
    
    if (self.checkSending) {
        
        self.checkSending = NO;
        self.syncerState = STMSyncerIdle;
        
    } else {
        
        self.checkSending = YES;
        self.syncerState = STMSyncerReceiveData;
        
    }

}

- (NSData *)JSONFrom:(NSArray *)dataForSyncing {
    
    NSMutableArray *syncDataArray = [NSMutableArray array];
    
    for (NSManagedObject *object in dataForSyncing) {
        
//        NSArray *entityNamesForSending = @[
//                                           NSStringFromClass([STMPhotoReport class]),
//                                           NSStringFromClass([STMCashing class]),
//                                           NSStringFromClass([STMUncashing class]),
//                                           NSStringFromClass([STMMessage class]),
//                                           NSStringFromClass([STMClientData class]),
//                                           NSStringFromClass([STMRecordStatus class]),
//                                           NSStringFromClass([STMLocation class])
//                                           ];
        
        NSArray *entityNamesForSending = [STMObjectsController entityNamesForSyncing];
        
        BOOL isInSyncList = [entityNamesForSending containsObject:object.entity.name];
        
        if (isInSyncList) {
            
            BOOL hasHref = [object.entity.propertiesByName.allKeys containsObject:@"href"];
            
            BOOL hrefIsNil = hasHref ? [[object valueForKey:@"href"] isEqual:nil] : YES;
            
            if (!hasHref || (hasHref && !hrefIsNil)) {
                
                NSDate *currentDate = [NSDate date];
                [object setPrimitiveValue:currentDate forKey:@"sts"];
                
                NSMutableDictionary *objectDictionary = [self dictionaryForObject:object];
                NSMutableDictionary *propertiesDictionary = [self propertiesDictionaryForObject:object];
                
                [objectDictionary setObject:propertiesDictionary forKey:@"properties"];
                [syncDataArray addObject:objectDictionary];
                
            }

        }
        
    }
    
    if (syncDataArray.count == 0) {
        
        return nil;
        
    } else {
        
        [self.session.logger saveLogMessageWithText:[NSString stringWithFormat:@"%lu objects to send", (unsigned long)syncDataArray.count] type:@""];

        NSDictionary *dataDictionary = [NSDictionary dictionaryWithObject:syncDataArray forKey:@"data"];
        
        NSError *error;
        NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dataDictionary options:NSJSONWritingPrettyPrinted error:&error];
        
//        NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
//        NSLog(@"send JSONString %@", JSONString);
        
        return JSONData;

    }
    
}

- (NSMutableDictionary *)dictionaryForObject:(NSManagedObject *)object {
    
    NSString *entityName = object.entity.name;
    NSString *name = [@"stc." stringByAppendingString:[entityName stringByReplacingOccurrencesOfString:@"STM" withString:@""]];
    NSData *xidData = [object valueForKey:@"xid"];
    NSString *xid = [STMFunctions xidStringFromXidData:xidData];

    if ([entityName isEqualToString:NSStringFromClass([STMClientData class])]) {
        self.clientDataXid = xidData;
    }
    
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:name, @"name", xid, @"xid", nil];
    
}

- (NSMutableDictionary *)propertiesDictionaryForObject:(NSManagedObject *)object {
    
    NSMutableDictionary *propertiesDictionary = [NSMutableDictionary dictionary];
    
    for (NSString *key in object.entity.attributesByName.allKeys) {
        
        if (![key isEqualToString:@"xid"]) {
        
            id value = [object valueForKey:key];
            
            if (value) {
                
                if ([value isKindOfClass:[NSDate class]]) {
                    
                    value = [[STMFunctions dateFormatter] stringFromDate:value];
                    
                } else if ([value isKindOfClass:[NSData class]]) {
                    
                    if ([key isEqualToString:@"objectXid"]) {
                        
                        value = [STMFunctions xidStringFromXidData:value];
                        
                    } else {
                        
                        value = [STMFunctions hexStringFromData:value];

                    }
                    
                }
                
                [propertiesDictionary setValue:[NSString stringWithFormat:@"%@", value] forKey:key];
                
            }

        }
        
    }
    
    for (NSString *key in object.entity.relationshipsByName.allKeys) {
        
        NSRelationshipDescription *relationshipDescription = [object.entity.relationshipsByName valueForKey:key];
        
        if (![relationshipDescription isToMany]) {
        
            NSManagedObject *relationshipObject = [object valueForKey:key];
            
            if (relationshipObject) {
                
                NSData *xidData = [relationshipObject valueForKey:@"xid"];
                
                if (xidData.length != 0) {
                    
                    NSString *xid = [STMFunctions xidStringFromXidData:xidData];
        
//                    NSString *entityName = [@"stc." stringByAppendingString:[relationshipObject.entity.name stringByReplacingOccurrencesOfString:@"STM" withString:@""]];
                    
                    NSString *entityName = key;
                    
                    [propertiesDictionary setValue:[NSDictionary dictionaryWithObjectsAndKeys:entityName, @"name", xid, @"xid", nil] forKey:key];
                    
                }
                
            }

        }
        
    }
    
    return propertiesDictionary;
    
}


- (void)startConnectionForSendData:(NSData *)sendData {
    
    if (self.apiUrlString) {
        
//        self.noApiUrl = NO;
        
        NSURL *requestURL = [NSURL URLWithString:self.apiUrlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
        
        request = [[self.authDelegate authenticateRequest:request] mutableCopy];
        
        if ([request valueForHTTPHeaderField:@"Authorization"]) {
            
            request.HTTPShouldHandleCookies = NO;
            //        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
            
            request.HTTPBody = sendData;
            
            NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
            if (!connection) {
                
                [self.session.logger saveLogMessageWithText:@"Syncer: no connection" type:@"error"];
                self.syncing = NO;
                self.syncerState = STMSyncerIdle;
                
            } else {
                
//                NSLog(@"connection %@", connection);
//                [self.session.logger saveLogMessageWithText:@"Syncer: send request" type:@""];
                
            }
            
        } else {
            
            [self.session.logger saveLogMessageWithText:@"Syncer: no authorization header" type:@"error"];
            [self notAuthorized];
            
        }

    } else {
        
        [self.session.logger saveLogMessageWithText:@"Syncer: no API.url" type:@"error"];
        
        self.syncing = NO;
        self.syncerState = STMSyncerReceiveData;
        
    }
    
    
}

- (void)receiveData {
    
    if (self.syncerState == STMSyncerReceiveData) {
        
        //        NSLog(@"receiveData");
        [self startConnectionForReceiveEntitiesWithName:@"STMEntity"];
        
    }
    
}

- (void)startConnectionForReceiveEntitiesWithName:(NSString *)entityName {
    
    if (self.syncerState != STMSyncerIdle) {
        
        NSDictionary *entity = [self.entitySyncInfo objectForKey:entityName];
        NSString *url = [entity objectForKey:@"url"];
        NSString *eTag = [entity objectForKey:@"eTag"];
        eTag = eTag ? eTag : @"*";
        
//        if ([entityName isEqualToString:@"STMUncashingPlace"]) {
//            NSLog(@"eTag %@", eTag);
//        }
//        
//        NSLog(@"entityName %@", entityName);
//        NSLog(@"url %@", url);
        
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
    
    if ([connection.currentRequest.URL.absoluteString isEqualToString:self.apiUrlString]) {
        entityName = @"SEND_DATA";
    }
    
    return entityName;
    
}

- (void)entityCountDecrease {
    
    self.entityCount -= 1;
    
    NSLog(@"self.entityCount %d", self.entityCount);
    
    if (self.entityCount == 0) {
        
        self.syncing = NO;
        self.syncerState = STMSyncerSendData;
        
    }
    
}


#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSString *errorMessage = [NSString stringWithFormat:@"connection did fail with error: %@", error];
    [self.session.logger saveLogMessageWithText:errorMessage type:@"error"];

    self.syncing = NO;
    
    if (self.syncerState == STMSyncerSendData) {
        
        self.syncerState = STMSyncerReceiveData;

    } else {
        
        self.syncerState = STMSyncerIdle;
        
    }
    
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
            
//            NSLog(@"entityName %@", entityName);
//            NSLog(@"dataModelEntityNames %@", [STMObjectsController dataModelEntityNames]);
//            
//            BOOL entityIsInLocalDataModel = [[STMObjectsController dataModelEntityNames] containsObject:entityName];
//            
//            NSLog(@"entityIsInLocalDataModel %d", entityIsInLocalDataModel);
//            
//            NSMutableSet *entityNames = [NSMutableSet setWithArray:[STMObjectsController dataModelEntityNames]];
//            
//            NSLog(@"entityNames.count %d", entityNames.count);
//            NSLog(@"entityNames %@", entityNames);
//            NSLog(@"self.entitySyncInfo.allKeys.count %d", self.entitySyncInfo.allKeys.count);
//            NSLog(@"self.entitySyncInfo.allKeys %@", self.entitySyncInfo.allKeys);
//            
//            [entityNames intersectSet:[NSSet setWithArray:self.entitySyncInfo.allKeys]];
//            
//            NSLog(@"entityNames.count %d", entityNames.count);
//            NSLog(@"entityNames %@", entityNames);
//            
//            self.entityCount = entityNames.count;
//            
//            NSMutableArray *entityNames = [self.entitySyncInfo.allKeys mutableCopy];
//            [entityNames removeObject:entityName];
            
            NSMutableArray *entityNames = [self.entitySyncInfo.allKeys mutableCopy];
            [entityNames removeObject:entityName];

            self.entityCount = entityNames.count;

            for (NSString *name in entityNames) {
                [self startConnectionForReceiveEntitiesWithName:name];
            }
            
        } else {

            [self entityCountDecrease];
            
        }
        
    } else {
        
        NSLog(@"%@: HTTP status %d", entityName, statusCode);
        
        if ([entityName isEqualToString:@"SEND_DATA"]) {
            
            self.syncing = NO;
            self.syncerState = STMSyncerIdle;
            
        } else if ([entityName isEqualToString:@"STMEntity"]) {

            self.syncing = NO;
            self.syncerState = STMSyncerIdle;

        } else if (! -- self.entityCount) {
            
            self.syncing = NO;
            self.syncerState = STMSyncerSendData;
            
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

    NSString *errorString = nil;
    
    if ([responseJSON isKindOfClass:[NSDictionary class]]) {
        
        errorString = [responseJSON objectForKey:@"error"];

    } else {
        
        errorString = @"response not a dictionary";
        
    }
    
    if (!errorString) {
        
        NSString *connectionEntityName = [self entityNameForConnection:connection];
        NSArray *dataArray = [responseJSON objectForKey:@"data"];
        
        if ([connectionEntityName isEqualToString:@"STMEntity"]) {
            
//            NSLog(@"responseJSON %@", responseJSON);
            
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
                        
                    } else {
                        
                        [self entityCountDecrease];
                        
                    }
                    
                }];
                
            } else if (entityModel) {
                
                [STMObjectsController insertObjectsFromArray:dataArray withCompletionHandler:^(BOOL success) {
                    
                    if (success) {
                        
                        //                        NSLog(@"%d objects successefully added", dataArray.count);
                        [self fillETagWithTemporaryValueForEntityName:connectionEntityName];
                        
                    } else {
                        
                        [self entityCountDecrease];
                        
                    }
                    
                }];
                
            } else {
                
                for (NSDictionary *datum in dataArray) {
                    [self syncObject:datum];
                }
                
                self.syncing = NO;
                self.syncerState = STMSyncerReceiveData;
                
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
            
//            if (self.syncerState == STMSyncerSendData) {
//                
//                self.syncing = NO;
//                self.syncerState = STMSyncerIdle;
//                
//            }
            
        }
        
    }
    
}

- (void)fillETagWithTemporaryValueForEntityName:(NSString *)entityName {
    
    NSString *eTag = [[self.entitySyncInfo objectForKey:entityName] objectForKey:@"temporaryETag"];
    [[self.entitySyncInfo objectForKey:entityName] setValue:eTag forKey:@"eTag"];
    [self saveServerDataModel];
    [self startConnectionForReceiveEntitiesWithName:entityName];
    
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
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"deviceTs" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"xid == %@", xidData];
        
        NSError *error;
        NSArray *fetchResult = [self.session.document.managedObjectContext executeFetchRequest:request error:&error];
        
        NSManagedObject *object = [fetchResult lastObject];
        
        if (object) {
            
            if ([object isKindOfClass:[STMRecordStatus class]] && [[(STMRecordStatus *)object valueForKey:@"isRemoved"] boolValue]) {

                [self.session.document.managedObjectContext deleteObject:object];
                
            } else {
            
                [object setValue:[object valueForKey:@"sts"] forKey:@"lts"];
                
                if ([xidData isEqualToData:self.clientDataXid]) {
                    
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:[NSNumber numberWithBool:NO] forKey:@"clientDataWaitingForSync"];
                    [defaults synchronize];
                    
                }

            }
            
            [self.session.logger saveLogMessageWithText:[NSString stringWithFormat:@"successefully sync %@ with xid %@", object.entity.name, xid] type:@""];

            
        } else {
            
            [self.session.logger saveLogMessageWithText:[NSString stringWithFormat:@"Sync: no %@ with xid: %@", object.entity.name, xid] type:@"error"];
            
        }
    
    }
    
}


@end
