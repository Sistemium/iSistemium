//
//  STMSyncer.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 06/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <AdSupport/AdSupport.h>

#import "STMSyncer.h"
#import "STMDocument.h"
#import "STMObjectsController.h"
#import "STMPhotoReport.h"
#import "STMFunctions.h"
#import "STMEntityController.h"
#import "STMClientDataController.h"
#import "STMPicturesController.h"

#import "STMPhotoReport.h"
#import "STMCashing.h"
#import "STMUncashing.h"
#import "STMMessage.h"
#import "STMClientData.h"
#import "STMRecordStatus.h"
#import "STMLocation.h"
#import "STMEntity.h"


#define SEND_DATA_CONNECTION @"SEND_DATA"


@interface STMSyncer() <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) STMDocument *document;
@property (nonatomic) int fetchLimit;
@property (nonatomic, strong) NSString *restServerURI;
@property (nonatomic, strong) NSString *apiUrlString;
@property (nonatomic, strong) NSString *xmlNamespace;
@property (nonatomic) NSTimeInterval httpTimeoutForeground;
@property (nonatomic) NSTimeInterval httpTimeoutBackground;
@property (nonatomic, strong) NSString *uploadLogType;
@property (nonatomic, strong) NSTimer *syncTimer;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, strong) NSMutableDictionary *settings;
@property (nonatomic) BOOL running;
@property (nonatomic, strong) NSMutableDictionary *responses;
@property (nonatomic) NSUInteger entityCount;
@property (nonatomic) BOOL syncing;
@property (nonatomic) BOOL checkSending;
@property (nonatomic) BOOL sendOnce;
@property (nonatomic, strong) void (^fetchCompletionHandler) (UIBackgroundFetchResult result);
@property (nonatomic, strong) NSMutableDictionary *temporaryETag;
@property (nonatomic) BOOL errorOccured;
@property (nonatomic, strong) NSMutableArray *sendedEntities;

- (void) didReceiveRemoteNotification;
- (void) didEnterBackground;

@end

@implementation STMSyncer

@synthesize syncInterval = _syncInterval;
@synthesize syncerState = _syncerState;


- (instancetype)init {
    
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
        _fetchLimit = [self.settings[@"fetchLimit"] intValue];
    }
    return _fetchLimit;
}

- (double)syncInterval {
    if (!_syncInterval) {
        _syncInterval = [self.settings[@"syncInterval"] doubleValue];
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
        _restServerURI = self.settings[@"restServerURI"];
    }
    return _restServerURI;
}

- (NSString *)apiUrlString {
    if (!_apiUrlString) {
        _apiUrlString = self.settings[@"API.url"];
    }
    return _apiUrlString;
}

- (NSString *)xmlNamespace {
    if (!_xmlNamespace) {
        _xmlNamespace = self.settings[@"xmlNamespace"];
    }
    return _xmlNamespace;
}

- (NSTimeInterval)httpTimeoutForeground {
    if (!_httpTimeoutForeground) {
        _httpTimeoutForeground = [self.settings[@"http.timeout.foreground"] doubleValue];
    }
    return _httpTimeoutForeground;
}

- (NSTimeInterval)httpTimeoutBackground {
    if (!_httpTimeoutBackground) {
        _httpTimeoutBackground = [self.settings[@"http.timeout.background"] doubleValue];
    }
    return _httpTimeoutBackground;
}

- (NSString *)uploadLogType {
    if (!_uploadLogType) {
        _uploadLogType = self.settings[@"uploadLog.type"];
    }
    return _uploadLogType;
}

- (NSTimeInterval)timeout {
    
    NSTimeInterval timeout = ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) ? self.httpTimeoutBackground : self.httpTimeoutForeground;
    
    return timeout;
    
}

- (NSMutableArray *)sendedEntities {
    
    if (!_sendedEntities) {
        _sendedEntities = [NSMutableArray array];
    }
    return _sendedEntities;
    
}

- (STMSyncerState)syncerState {
    
    if (!_syncerState) {
        _syncerState = STMSyncerIdle;
    }
    
    return _syncerState;
    
}

- (void)setSyncerState:(STMSyncerState) syncerState fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result)) handler {
    
    self.fetchCompletionHandler = handler;
    self.syncerState = syncerState;
    
}


- (void)setSyncerState:(STMSyncerState)syncerState {
    
    self.sendOnce = (syncerState != STMSyncerIdle) && ((self.sendOnce) || (self.syncing && syncerState == STMSyncerSendDataOnce))? YES : NO;
    
//    NSLog(@"self.sendOnce %d", self.sendOnce);
    
    if (!self.syncing && syncerState != _syncerState) {
        
        syncerState = (self.sendOnce) ? STMSyncerSendDataOnce : syncerState;

        STMSyncerState previousState = _syncerState;
        
        _syncerState = syncerState;
        
        NSArray *syncStates = @[@"idle", @"sendData", @"sendDataOnce", @"receiveData"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"syncStatusChanged" object:self userInfo:@{@"from":@(previousState), @"to":@(syncerState)}];
        
        NSString *logMessage = [NSString stringWithFormat:@"Syncer %@", syncStates[syncerState]];
//        [(STMLogger *)self.session.logger saveLogMessageWithText:logMessage];
        NSLog(logMessage);
        
        switch (syncerState) {
                
            case STMSyncerSendData:
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                [STMClientDataController checkClientData];
                self.syncing = YES;
                [self sendData];
                break;

            case STMSyncerSendDataOnce:
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                [STMClientDataController checkClientData];
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
                self.sendOnce = NO;
                [STMObjectsController dataLoadingFinished];
                [STMPicturesController checkUploadedPhotos];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"entityCountdownChange"
                                                        object:self
                                                      userInfo:@{@"countdownValue": @((int)entityCount)}];
    
    _entityCount = entityCount;
    
}

- (NSMutableDictionary *)responses {
    
    if (!_responses) {
        _responses = [NSMutableDictionary dictionary];
    }
    return _responses;
    
}

- (NSMutableDictionary *)stcEntities {
    
    if (!_stcEntities) {
        
        NSDictionary *stcEntities = [STMEntityController stcEntities];
        
        if (!stcEntities[@"STMEntity"]) {
            
            NSDictionary *coreEntityDic = @{
                                            @"name": @"stc.entity",
                                            @"properties": @{
                                                    @"name": @"Entity",
                                                    @"url": self.restServerURI
                                                    }
                                            };
            
            [STMObjectsController insertObjectFromDictionary:coreEntityDic withCompletionHandler:^(BOOL success) {

            }];
            
            stcEntities = [STMEntityController stcEntities];
            
        }
        
        _stcEntities = [stcEntities mutableCopy];
        
    }
    
    return _stcEntities;
    
}

- (NSMutableDictionary *)temporaryETag {
    
    if (!_temporaryETag) {
        _temporaryETag = [NSMutableDictionary dictionary];
    }
    return _temporaryETag;
    
}

#pragma mark - syncer methods

- (void)startSyncer {
    
    if (!self.running) {
        
        self.settings = nil;
        self.running = YES;
        
//        [STMObjectsController initObjectsCache];
        [STMObjectsController initObjectsCacheWithCompletionHandler:^(BOOL success) {
           
            if (success) {
        
                [STMEntityController checkEntitiesForDuplicates];
                [STMPicturesController checkPhotos];
                [STMClientDataController checkClientData];
                [STMEntityController checkEntitiesForDuplicates];
                [self.session.logger saveLogMessageDictionaryToDocument];
                [self.session.logger saveLogMessageWithText:@"Syncer start" type:@""];
                [self initTimer];
                [self addObservers];
                
                NSError *error;
                if (![self.resultsController performFetch:&error]) {
                    
                    NSLog(@"fetch error %@", error);
                    
                } else {
                    
                }

            }
            
        }];
        
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

- (void)upload {
    [self setSyncerState: STMSyncerSendData];
}

- (void)didReceiveRemoteNotification {
    [self upload];
}

- (void)didEnterBackground {
    [self setSyncerState: STMSyncerSendDataOnce];
}

- (void)appDidBecomeActive {
    
#ifdef DEBUG
    [self setSyncerState: STMSyncerSendData];
#else
    [self setSyncerState: STMSyncerSendDataOnce];
#endif

}

- (void)syncerDidReceiveRemoteNotification:(NSNotification *)notification {
    
    if ([(notification.userInfo)[@"syncer"] isEqualToString:@"upload"]) {
        [self setSyncerState: STMSyncerSendDataOnce];
    }
    
}

- (void)addObservers {
    
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(sessionStatusChanged:)
               name:@"sessionStatusChanged"
             object:self.session];
    
    [nc addObserver:self
           selector:@selector(syncerSettingsChanged)
               name:@"syncerSettingsChanged"
             object:self.session];
    
    [nc addObserver:self
           selector:@selector(didReceiveRemoteNotification)
               name:@"applicationDidReceiveRemoteNotification"
             object: nil];
    
    [nc addObserver:self
           selector:@selector(appDidBecomeActive)
               name:UIApplicationDidBecomeActiveNotification
             object: nil];
    
    [nc addObserver:self
           selector:@selector(didReceiveRemoteNotification)
               name:@"applicationPerformFetchWithCompletionHandler"
             object:nil];
    
    [nc addObserver:self
           selector:@selector(didEnterBackground)
               name:UIApplicationDidEnterBackgroundNotification
             object: nil];
    
    [nc addObserver:self
           selector:@selector(syncerDidReceiveRemoteNotification:)
               name:@"syncerDidReceiveRemoteNotification"
             object:nil];
    
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
    
    [self flushSettings];
    
}

- (void)flushSettings {
    
    self.settings = nil;

    self.fetchLimit = 0;
    self.restServerURI = nil;
    self.apiUrlString = nil;
    self.xmlNamespace = nil;
    self.httpTimeoutForeground = 0;
    self.httpTimeoutBackground = 0;
    self.syncInterval = 0;
    self.uploadLogType = nil;

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
    
    if (self.syncTimer) {
        [self releaseTimer];
    }
    
    [[NSRunLoop currentRunLoop] addTimer:self.syncTimer forMode: NSRunLoopCommonModes];
    
}

- (void)releaseTimer {
    
    [self.syncTimer invalidate];
    self.syncTimer = nil;
    
}

- (void)onTimerTick:(NSTimer *)timer {
    
#ifdef DEBUG
    NSTimeInterval bgTR = [[UIApplication sharedApplication] backgroundTimeRemaining];
    NSLog(@"syncTimer tick at %@, bgTimeRemaining %.0f", [NSDate date], bgTR > 3600 ? -1 : bgTR);
#endif
    
    self.syncerState = STMSyncerSendData;
    
}


#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMDatum class])];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sqts" ascending:YES selector:@selector(compare:)]];
        request.includesSubentities = YES;
//        request.includesPendingChanges = YES;
        
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
    
    
}

#pragma mark - syncing

- (void)sendData {
    
    if (self.syncerState == STMSyncerSendData || self.syncerState == STMSyncerSendDataOnce) {
        
        if (self.resultsController.fetchedObjects.count > 0) {
            
            self.sendedEntities = nil;
            
            NSData *sendData = [self JSONFrom:self.resultsController.fetchedObjects];

            if (sendData) {
                
                self.checkSending = (self.syncerState == STMSyncerSendData);
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
    
    if (self.checkSending || self.syncerState == STMSyncerSendDataOnce) {
        
        self.checkSending = NO;
        self.syncerState = STMSyncerIdle;
        
    } else {
        
        self.checkSending = YES;
        self.syncerState = STMSyncerReceiveData;
        
    }

}

- (NSData *)JSONFrom:(NSArray *)dataForSyncing {
    
    NSMutableArray *syncDataArray = [NSMutableArray array];
    
    NSArray *logMessageSyncTypes = [(STMLogger *)self.session.logger syncingTypesForSettingType:self.uploadLogType];
    
    for (NSManagedObject *object in dataForSyncing) {
        
        NSArray *entityNamesForSending = [STMObjectsController entityNamesForSyncing];
        NSString *entityName = object.entity.name;
        BOOL isInSyncList = [entityNamesForSending containsObject:entityName];
        BOOL isFantom = [[object valueForKey:@"isFantom"] boolValue];
        
        if (isInSyncList && !isFantom) {
            
            if ([entityName isEqualToString:NSStringFromClass([STMLogMessage class])]) {

                NSString *type = [object valueForKey:@"type"];
                
                if ([logMessageSyncTypes containsObject:type]) {                    
                    [self addObject:object toSyncDataArray:syncDataArray];
                }
                
            } else {
                [self addObject:object toSyncDataArray:syncDataArray];
            }
            
        }
        
    }
    
    self.sendedEntities = [[[NSSet setWithArray:self.sendedEntities] allObjects] mutableCopy];
    
    if (syncDataArray.count == 0) {
        
        return nil;
        
    } else {
        
        NSString *logMessage = [NSString stringWithFormat:@"%lu objects to send", (unsigned long)syncDataArray.count];
//        [(STMLogger *)self.session.logger saveLogMessageWithText:logMessage];
        NSLog(logMessage);

        NSDictionary *dataDictionary = @{@"data": syncDataArray};
        
        NSError *error;
        NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dataDictionary options:NSJSONWritingPrettyPrinted error:&error];
        
//        NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
//        NSLog(@"send JSONString %@", JSONString);
        
        return JSONData;

    }
    
}

- (void)addObject:(NSManagedObject *)object toSyncDataArray:(NSMutableArray *)syncDataArray {
    
    NSDate *currentDate = [NSDate date];
    [object setPrimitiveValue:currentDate forKey:@"sts"];
    
    NSDictionary *objectDictionary = [STMObjectsController dictionaryForObject:object];

    [syncDataArray addObject:objectDictionary];
    
    [self.sendedEntities addObject:object.entity.name];

}

- (void)startConnectionForSendData:(NSData *)sendData {
    
    if (self.apiUrlString) {
        
//        NSLog(@"self.apiUrlString %@", self.apiUrlString);
        
        NSURL *requestURL = [NSURL URLWithString:self.apiUrlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
        
        request = [[self.authDelegate authenticateRequest:request] mutableCopy];
        
        if ([request valueForHTTPHeaderField:@"Authorization"]) {
            
            request.timeoutInterval = [self timeout];
            request.HTTPShouldHandleCookies = NO;
            //        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
//            [request setValue:[[UIDevice currentDevice].identifierForVendor UUIDString] forHTTPHeaderField:@"DeviceUUID"];
            [request setValue:[[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString] forHTTPHeaderField:@"DeviceUUID"];
            
            request.HTTPBody = sendData;
            
//            NSLog(@"request.allHTTPHeaderFields %@", request.allHTTPHeaderFields);
            
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
        
        self.entityCount = 1;
        self.errorOccured = NO;

//        NSDate *start = [NSDate date];
//        NSString *startString = [[STMFunctions dateFormatter] stringFromDate:start];
//        NSLog(@"--------------------S %@", startString);
        
        [self checkConditionForReceivingEntityWithName:@"STMEntity"];
        
    }
    
}

- (void)checkConditionForReceivingEntityWithName:(NSString *)entityName {
    
    if (self.syncerState != STMSyncerIdle) {

        STMEntity *entity = (self.stcEntities)[entityName];
        NSString *url = entity.url;
        
        if (url) {
            
            NSString *eTag = entity.eTag;
            eTag = eTag ? eTag : @"*";
            
            NSURL *requestURL = [NSURL URLWithString:url];
            
//            NSLog(@"receiving %@ with eTag %@", entityName, eTag);
            
            [self startReceiveDataFromURL:requestURL withETag:eTag];
            
        } else {
            
            NSLog(@"have no url for %@", entityName);
            [self entityCountDecrease];
            
        }
        
    }
    
}

- (void)startReceiveDataFromURL:(NSURL *)requestURL withETag:(NSString *)eTag {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    
    request = [[self.authDelegate authenticateRequest:request] mutableCopy];
    
    if ([request valueForHTTPHeaderField:@"Authorization"]) {
        
        request.timeoutInterval = [self timeout];
        request.HTTPShouldHandleCookies = NO;
        //        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        [request setHTTPMethod:@"GET"];
        
        [request addValue:[NSString stringWithFormat:@"%d", self.fetchLimit] forHTTPHeaderField:@"page-size"];
        [request addValue:eTag forHTTPHeaderField:@"If-none-match"];
//        [request setValue:[[UIDevice currentDevice].identifierForVendor UUIDString] forHTTPHeaderField:@"DeviceUUID"];
        [request setValue:[[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString] forHTTPHeaderField:@"DeviceUUID"];

//        NSLog(@"requestURL %@", requestURL);
//        NSLog(@"eTag %@", eTag);
//        NSLog(@"request.allHTTPHeaderFields %@", request.allHTTPHeaderFields);
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        if (!connection) {
            
            [self.session.logger saveLogMessageWithText:@"Syncer: no connection" type:@"error"];
            self.syncing = NO;
            self.syncerState = STMSyncerIdle;
            
        } else {
            
//            NSDate *start = [NSDate date];
//            NSString *startString = [[STMFunctions dateFormatter] stringFromDate:start];
//            NSLog(@"--------------------S %@ %@", startString, eTag);
            
//            [self.session.logger saveLogMessageWithText:@"Syncer: send request" type:@""];
        }
        
    } else {
        
        [self.session.logger saveLogMessageWithText:@"Syncer: no authorization header" type:@"error"];
        [self notAuthorized];
        
    }
    
}

- (void)notAuthorized {
    
    [self stopSyncer];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notAuthorized" object:self];
    
}

- (NSString *)entityNameForConnection:(NSURLConnection *)connection {
    return [self entityNameForRequest:connection.currentRequest];
}

- (NSString *)entityNameForRequest:(NSURLRequest *)request {
    return [self entityNameForURLString:request.URL.absoluteString];
}

- (NSString *)entityNameForURLString:(NSString *)urlString {
    
    if ([urlString isEqualToString:self.apiUrlString]) {
        
        return SEND_DATA_CONNECTION;
        
    } else {
        
        for (STMEntity *entity in [self.stcEntities allValues]) {
            
            if ([entity.url isEqualToString:urlString]) {
                
                return [[self.stcEntities allKeysForObject:entity] lastObject];
                
            }
            
        }
        
    }
    
    return nil;

}

- (void)entityCountDecrease {
    
    self.entityCount -= 1;
    
//    NSLog(@"self.entityCount %d", self.entityCount);
    
    if (self.entityCount == 0) {
        
        [self saveReceiveDate];

        [self.document saveDocument:^(BOOL success) {
        
            if (success) {
                self.syncing = NO;
                self.syncerState = (self.errorOccured) ? STMSyncerIdle : STMSyncerSendData;
            }
            
        }];
        
    }
    
}


#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSString *errorMessage = [NSString stringWithFormat:@"connection did fail with error: %@", error.localizedDescription];
    [self.session.logger saveLogMessageWithText:errorMessage type:@"warning"];

    if (error.code == NSURLErrorTimedOut) {
        
        self.timeoutErrorSyncerState = (self.syncerState != STMSyncerIdle) ? self.syncerState : self.timeoutErrorSyncerState;
        
        NSLog(@"NSURLErrorFailingURLStringErrorKey %@", [error.userInfo valueForKey:NSURLErrorFailingURLStringErrorKey]);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NSURLErrorTimedOut" object:self userInfo:error.userInfo];
        
    }
    
    self.syncing = NO;
    self.syncerState = STMSyncerIdle;
    
//    if (self.syncerState == STMSyncerSendData) {
//        
//        self.syncerState = STMSyncerReceiveData;
//
//    } else {
//        
//        self.syncerState = STMSyncerIdle;
//        
//    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
    NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
    //    NSLog(@"headers %@", headers);
    
//    NSLog(@"!!!!!!! expectedContentLength %d", response.expectedContentLength);
    
    NSString *entityName = [self entityNameForConnection:connection];
    
    if (statusCode == 200) {
        
        (self.responses)[entityName] = [NSMutableData data];
        
        NSString *eTag = headers[@"eTag"];
        
        if (eTag) {
            
            if (entityName && self.syncerState != STMSyncerIdle) self.temporaryETag[entityName] = eTag;
            
        } else {
            
            if (![entityName isEqualToString:SEND_DATA_CONNECTION]) [self receiveNoContentStatusForEntityWithName:entityName];
            
        }
        
        
//        STMEntity *entity = (self.stcEntities)[entityName];
//        NSDate *middle = [NSDate date];
//        NSString *middleString = [[STMFunctions dateFormatter] stringFromDate:middle];
//        NSLog(@"--------------------M %@ %@", middleString, entity.eTag);

        
        
    } else if (statusCode == 410) {
        
        NSLog(@"%@: 410 Gone", entityName);
        
        [STMEntityController deleteEntityWithName:entityName];

        [self entityCountDecrease];
        
    }  else if (statusCode == 204) {
        
        NSLog(@"%@: 204 No Content", entityName);
        [self receiveNoContentStatusForEntityWithName:entityName];
        
    } else {
        
        NSLog(@"%@: HTTP status %d", entityName, statusCode);
        
//        NSLog(@"connection.originalRequest %@", connection.originalRequest);
//        NSLog(@"allHTTPHeaderFields %@", [connection.originalRequest allHTTPHeaderFields]);
        
        if ([entityName isEqualToString:@"SEND_DATA"]) {
            
            self.syncing = NO;
            self.syncerState = STMSyncerIdle;
            
        } else if ([entityName isEqualToString:@"STMEntity"]) {

            self.syncing = NO;
            self.syncerState = STMSyncerIdle;

        } else if (! -- self.entityCount) {
            
            self.syncing = NO;
            self.syncerState = STMSyncerIdle;
            
        }
    }
    
}

- (void)receiveNoContentStatusForEntityWithName:(NSString *)entityName {
    
    [self.responses removeObjectForKey:entityName];
    
    if ([entityName isEqualToString:@"STMEntity"]) {
        
        self.stcEntities = nil;
        NSMutableArray *entityNames = [self.stcEntities.allKeys mutableCopy];
        [entityNames removeObject:entityName];
        
        self.entityCount = entityNames.count;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"entitiesReceivingDidFinish" object:self];
        
        for (NSString *name in entityNames) {
            [self checkConditionForReceivingEntityWithName:name];
        }
        
    } else {
        [self entityCountDecrease];
    }

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSString *entityName = [self entityNameForConnection:connection];
    NSMutableData *responseData = (self.responses)[entityName];
    [responseData appendData:data];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSString *entityName = [self entityNameForConnection:connection];
    NSMutableData *responseData = (self.responses)[entityName];
    
//    NSLog(@"!!!!!! responseData.length %d", responseData.length);
    
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
        errorString = responseJSON[@"error"];
    } else {
        errorString = @"response not a dictionary";
    }
    
    if (!errorString) {
        
        NSString *connectionEntityName = [self entityNameForConnection:connection];
        NSArray *dataArray = responseJSON[@"data"];
        
//        if ([connectionEntityName isEqualToString:@"STMSaleOrder"]) {
//            NSLog(@"responseJSON %@", responseJSON);
//        }
        
        STMEntity *entity = (self.stcEntities)[connectionEntityName];
        
        if (entity) {
            
//            NSDate *start = [NSDate date];
//            NSString *startString = [[STMFunctions dateFormatter] stringFromDate:start];
//            NSLog(@"--------------------S %@", startString);
            
            [STMObjectsController processingOfDataArray:dataArray roleName:entity.roleName withCompletionHandler:^(BOOL success) {

                if (success) {
                    
//                    if ([connectionEntityName isEqualToString:@"STMSalesman"]) {
//                        NSLog(@"temporaryETag %@", self.temporaryETag);
//                    }
                    
                    NSLog(@"    %@: get %d objects", connectionEntityName, dataArray.count);
                    
                    [self fillETagWithTemporaryValueForEntityName:connectionEntityName];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"getBunchOfObjects" object:self userInfo:@{@"count":@(dataArray.count)}];
                    
                } else {
                    self.errorOccured = YES;
                    [self entityCountDecrease];
                }

            }];
            
        } else {
            
//            NSLog(@"dataArray %@", dataArray);
            
            for (NSDictionary *datum in dataArray) {
                [STMObjectsController syncObject:datum];
            }

            [self saveSendDate];
            
            self.syncing = NO;

//TODO: Check if STMEntity was changed — receive data againg
            
            [self.sendedEntities removeObjectsInArray:@[NSStringFromClass([STMEntity class])]];
            
            BOOL onlyStcEntitiesWasSend = (self.sendedEntities.count == 0);
            
            if (self.syncerState == STMSyncerSendData && !onlyStcEntitiesWasSend) {
                self.syncerState = STMSyncerReceiveData;
            } else /*if (self.syncerState == STMSyncerSendDataOnce)*/ {
                self.syncerState = STMSyncerIdle;
            }
            
        }
        
    } else {
        
        [self.session.logger saveLogMessageWithText:errorString type:@"error"];
        
        if ([errorString isEqualToString:@"Not authorized"]) {
            
            [self notAuthorized];
            
        } else {

#ifdef DEBUG
            NSString *requestBody = [[NSString alloc] initWithData:connection.originalRequest.HTTPBody encoding:NSUTF8StringEncoding];
            NSLog(@"originalRequest %@", connection.originalRequest);
            NSLog(@"requestBody %@", requestBody);
            NSLog(@"responseJSON %@", responseJSON);
#endif
            [self entityCountDecrease];

        }
        
    }
    
}

- (void)fillETagWithTemporaryValueForEntityName:(NSString *)entityName {
    
    NSString *eTag = [self.temporaryETag valueForKey:entityName];
    STMEntity *entity = (self.stcEntities)[entityName];
    
//    NSDate *finish = [NSDate date];
//    NSString *finishString = [[STMFunctions dateFormatter] stringFromDate:finish];
//    NSLog(@"--------------------F %@ %@", finishString, entity.eTag);
    
    entity.eTag = eTag;

//    NSLog(@"set eTag %@ for %@", eTag, entityName);
    
    [self checkConditionForReceivingEntityWithName:entityName];
    
}

- (void)saveSendDate {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *key = [@"sendDate" stringByAppendingString:self.session.uid];
    NSString *sendDateString = [[STMFunctions dateMediumTimeMediumFormatter] stringFromDate:[NSDate date]];
    
    [defaults setObject:sendDateString forKey:key];
    [defaults synchronize];
    
}

- (void)saveReceiveDate {
    
//    NSDate *finish = [NSDate date];
//    NSString *finishString = [[STMFunctions dateFormatter] stringFromDate:finish];
//    NSLog(@"--------------------F %@", finishString);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *key = [@"receiveDate" stringByAppendingString:self.session.uid];

    NSString *receiveDateString = [[STMFunctions dateMediumTimeMediumFormatter] stringFromDate:[NSDate date]];
    
    [defaults setObject:receiveDateString forKey:key];
    [defaults synchronize];
    
}

@end
