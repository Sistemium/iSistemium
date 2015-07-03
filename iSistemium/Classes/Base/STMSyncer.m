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
#import "STMClientEntityController.h"
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

@property (nonatomic, strong) NSMutableDictionary *settings;
@property (nonatomic) int fetchLimit;
@property (nonatomic, strong) NSString *restServerURI;
@property (nonatomic, strong) NSString *apiUrlString;
@property (nonatomic, strong) NSString *xmlNamespace;
@property (nonatomic) NSTimeInterval httpTimeoutForeground;
@property (nonatomic) NSTimeInterval httpTimeoutBackground;
@property (nonatomic, strong) NSString *uploadLogType;

@property (nonatomic, strong) NSTimer *syncTimer;

@property (nonatomic, strong) NSFetchedResultsController *resultsController;

@property (nonatomic) BOOL running;
@property (nonatomic) BOOL syncing;
@property (nonatomic) BOOL checkSending;
@property (nonatomic) BOOL sendOnce;
@property (nonatomic) BOOL errorOccured;
@property (nonatomic) BOOL fullSyncWasDone;
@property (nonatomic) BOOL isFirstSyncCycleIteration;

@property (nonatomic, strong) NSMutableDictionary *responses;
@property (nonatomic, strong) NSMutableDictionary *temporaryETag;
@property (nonatomic, strong) NSMutableArray *sendedEntities;
@property (nonatomic, strong) NSArray *receivingEntitiesNames;
@property (nonatomic) NSUInteger entityCount;
@property (nonatomic, strong) NSMutableArray *entitySyncNames;


@property (nonatomic, strong) void (^fetchCompletionHandler) (UIBackgroundFetchResult result);

@property (nonatomic) UIBackgroundFetchResult fetchResult;

- (void)didReceiveRemoteNotification;
- (void)didEnterBackground;

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

- (NSMutableArray *)entitySyncNames {
    if (!_entitySyncNames) {
        _entitySyncNames = [NSMutableArray array];
    }
    return _entitySyncNames;
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
    self.fetchResult = UIBackgroundFetchResultNewData;
    self.syncerState = syncerState;
    
}


- (void)setSyncerState:(STMSyncerState)syncerState {
    
    self.sendOnce = (syncerState != STMSyncerIdle) && ((self.sendOnce) || (self.syncing && syncerState == STMSyncerSendDataOnce))? YES : NO;
    
    if (!self.syncing && syncerState != _syncerState) {
        
        syncerState = (self.sendOnce) ? STMSyncerSendDataOnce : syncerState;

        STMSyncerState previousState = _syncerState;
        
        _syncerState = syncerState;
        
        NSArray *syncStates = @[@"idle", @"sendData", @"sendDataOnce", @"receiveData"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"syncStatusChanged" object:self userInfo:@{@"from":@(previousState), @"to":@(syncerState)}];
        
        NSString *logMessage = [NSString stringWithFormat:@"Syncer %@", syncStates[syncerState]];
        NSLog(logMessage);
        
        self.isFirstSyncCycleIteration = (previousState == STMSyncerIdle);
        
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
                [self checkNews];
                
                break;
                
                
            case STMSyncerIdle:
                
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                self.syncing = NO;
                self.sendOnce = NO;
                self.checkSending = NO;

                [STMObjectsController dataLoadingFinished];
//                [STMPicturesController checkUploadedPhotos];
                
                self.entitySyncNames = nil;
                if (self.receivingEntitiesNames) self.receivingEntitiesNames = nil;
                if (self.fetchCompletionHandler) self.fetchCompletionHandler(self.fetchResult);
                
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
        
        [STMObjectsController initObjectsCacheWithCompletionHandler:^(BOOL success) {
           
            if (success) {
        
                [STMEntityController checkEntitiesForDuplicates];
//                [STMPicturesController checkPhotos];
                [STMClientDataController checkClientData];
                [self.session.logger saveLogMessageDictionaryToDocument];
                [self.session.logger saveLogMessageWithText:@"Syncer start" type:@""];
                
                NSArray *syncingEntitiesNames = [STMEntityController uploadableEntitiesNames];
                NSLog(@"syncingEntitiesNames %@", syncingEntitiesNames);
                
                if (syncingEntitiesNames.count == 0) {
                    
                    NSString *stcEntityName = NSStringFromClass([STMEntity class]);
                    
                    if ([stcEntityName hasPrefix:ISISTEMIUM_PREFIX]) {
                        stcEntityName = [stcEntityName substringFromIndex:[ISISTEMIUM_PREFIX length]];
                    }
                    
                    STMClientEntity *clientEntity = [STMClientEntityController clientEntityWithName:stcEntityName];
                    clientEntity.eTag = nil;
                    
//                    [self receiveEntities:@[stcEntityName]];
                    
                }
                
                [self initTimer];
                [self addObservers];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Syncer init successfully" object:self];
                
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
    [self setSyncerState:STMSyncerSendData];
}

- (void)receiveEntities:(NSArray *)entitiesNames {
    
    if ([entitiesNames isKindOfClass:[NSArray class]]) {

        NSArray *localDataModelEntityNames = [STMObjectsController localDataModelEntityNames];
        NSMutableArray *existingNames = [@[] mutableCopy];
        
        for (NSString *entityName in entitiesNames) {
            
            NSString *name = ([entityName hasPrefix:ISISTEMIUM_PREFIX]) ? entityName : [ISISTEMIUM_PREFIX stringByAppendingString:entityName];
            
            if ([localDataModelEntityNames containsObject:name]) {
                [existingNames addObject:name];
            }
            
        }
        
        if (existingNames.count > 0) {
            
            self.receivingEntitiesNames = existingNames;
            [self setSyncerState:STMSyncerReceiveData];
            
        }
        
    } else {
        
        NSString *logMessage = @"receiveEntities: argument is not an array";
        [[STMLogger sharedLogger] saveLogMessageWithText:logMessage type:@"error"];
        
    }
    
}

- (void)sendObjects:(NSDictionary *)parameters {
    
    NSError *error;
    NSArray *jsonArray = [STMObjectsController jsonForObjectsWithParameters:parameters error:&error];
    
    if (error) {
        
        [[STMLogger sharedLogger] saveLogMessageWithText:error.localizedDescription type:@"error"];
        
    } else {
        
        if (jsonArray) {

            NSData *JSONData = [NSJSONSerialization dataWithJSONObject:@{@"data": jsonArray}
                                                               options:0
                                                                 error:nil];
            [self startConnectionForSendData:JSONData];
            
        }
        
    }
    
}

- (void)didReceiveRemoteNotification {
    [self upload];
}

- (void)didEnterBackground {
    [self setSyncerState:STMSyncerSendDataOnce];
}

- (void)appDidBecomeActive {
    
#ifdef DEBUG
    [self setSyncerState:STMSyncerSendData];
#else
    [self setSyncerState:STMSyncerSendDataOnce];
#endif

}

- (void)syncerDidReceiveRemoteNotification:(NSNotification *)notification {
    
    if ([(notification.userInfo)[@"syncer"] isEqualToString:@"upload"]) {
        [self setSyncerState:STMSyncerSendDataOnce];
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
    
//    [nc addObserver:self
//           selector:@selector(didReceiveRemoteNotification)
//               name:@"applicationDidReceiveRemoteNotification"
//             object:nil];
    
    [nc addObserver:self
           selector:@selector(appDidBecomeActive)
               name:UIApplicationDidBecomeActiveNotification
             object:nil];
    
//    [nc addObserver:self
//           selector:@selector(didReceiveRemoteNotification)
//               name:@"applicationPerformFetchWithCompletionHandler"
//             object:nil];
    
    [nc addObserver:self
           selector:@selector(didEnterBackground)
               name:UIApplicationDidEnterBackgroundNotification
             object:nil];
    
//    [nc addObserver:self
//           selector:@selector(syncerDidReceiveRemoteNotification:)
//               name:@"syncerDidReceiveRemoteNotification"
//             object:nil];
    
}

- (void)removeObservers {

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)sessionStatusChanged:(NSNotification *)notification {
    
    if ([notification.object isKindOfClass:[STMSession class]]) {
        
        STMSession *session = (STMSession *)notification.object;
    
        if (session == self.session) {
            
            if ([session.status isEqualToString:@"finishing"]) {
                [self stopSyncer];
            } else if ([session.status isEqualToString:@"running"]) {
                [self startSyncer];
            }

        }
        
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
        
        request.predicate = [NSPredicate predicateWithFormat:@"(lts == %@ || deviceTs > lts)", nil];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _resultsController.delegate = self;
        
    }
    
    return _resultsController;
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"syncerDidChangeContent" object:self];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    
}

#pragma mark - syncing
#pragma mark - send

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
    
    [self afterSendFurcation];

}

- (void)afterSendFurcation {
    
    if (!self.syncing) {

        if (self.checkSending || self.syncerState == STMSyncerSendDataOnce) {
            
            self.checkSending = NO;
            self.syncerState = STMSyncerIdle;
            
        } else {
            
            self.checkSending = YES;
            self.syncerState = STMSyncerReceiveData;
            
        }

    }
    
}

- (NSData *)JSONFrom:(NSArray *)dataForSyncing {
    
    NSMutableArray *syncDataArray = [NSMutableArray array];
    
    NSArray *logMessageSyncTypes = [(STMLogger *)self.session.logger syncingTypesForSettingType:self.uploadLogType];
    
    for (NSManagedObject *object in dataForSyncing) {
        
        NSArray *entityNamesForSending = [STMEntityController uploadableEntitiesNames];
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
        
        [self numbersOfUnsyncedObjects];
        
        NSString *logMessage = [NSString stringWithFormat:@"%lu objects to send", (unsigned long)syncDataArray.count];
        NSLog(logMessage);

        NSDictionary *dataDictionary = @{@"data": syncDataArray};
        
        NSError *error;
        NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dataDictionary options:0 error:&error];
        
//        NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dataDictionary options:NSJSONWritingPrettyPrinted error:&error];
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

- (NSUInteger)numbersOfUnsyncedObjects {
    
    if (self.document.managedObjectContext) {
        
        NSArray *unsyncedObjects = self.resultsController.fetchedObjects;
        NSArray *entityNamesForSending = [STMEntityController uploadableEntitiesNames];
        
        NSPredicate *predicate = [STMPredicate predicateWithNoFantomsFromPredicate:[NSPredicate predicateWithFormat:@"entity.name IN %@", entityNamesForSending]];
        unsyncedObjects = [unsyncedObjects filteredArrayUsingPredicate:predicate];
        
        NSArray *logMessageSyncTypes = [(STMLogger *)self.session.logger syncingTypesForSettingType:self.uploadLogType];
        
        predicate = [NSPredicate predicateWithFormat:@"(entity.name != %@) OR (type IN %@)", NSStringFromClass([STMLogMessage class]), logMessageSyncTypes];
        unsyncedObjects = [unsyncedObjects filteredArrayUsingPredicate:predicate];
        
        return unsyncedObjects.count;

    } else {
        return 0;
    }
    
}

- (void)startConnectionForSendData:(NSData *)sendData {
    
    if (self.apiUrlString) {
        
        NSURL *requestURL = [NSURL URLWithString:self.apiUrlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
        
        request = [[self.authDelegate authenticateRequest:request] mutableCopy];
        
        if ([request valueForHTTPHeaderField:@"Authorization"]) {
            
            request.timeoutInterval = [self timeout];
            request.HTTPShouldHandleCookies = NO;
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
//            [request setValue:[[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString] forHTTPHeaderField:@"DeviceUUID"];
            
//            NSLog(@"request %@", request.allHTTPHeaderFields);

            request.HTTPBody = sendData;
            
            NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
            if (!connection) {
                
                [self.session.logger saveLogMessageWithText:@"Syncer: no connection" type:@"error"];
                self.syncing = NO;
                self.fetchResult = UIBackgroundFetchResultFailed;

                self.syncerState = STMSyncerIdle;
                
            } else {
                
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


#pragma mark - receive

- (void)checkNews {
    
    if (self.fullSyncWasDone && !self.receivingEntitiesNames) {
        
        self.errorOccured = NO;
        
        NSURL *newsURL = [[NSURL URLWithString:self.apiUrlString] URLByAppendingPathComponent:@"stc.news"];
        NSMutableURLRequest *request = [[[STMAuthController authController] authenticateRequest:[NSURLRequest requestWithURL:newsURL]] mutableCopy];
        
        request.timeoutInterval = [self timeout];
        request.HTTPShouldHandleCookies = NO;
        [request setHTTPMethod:@"GET"];
        
        [request addValue:[NSString stringWithFormat:@"%d", self.fetchLimit] forHTTPHeaderField:@"page-size"];
//        [request setValue:[[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString] forHTTPHeaderField:@"DeviceUUID"];

//        NSLog(@"request %@", request.allHTTPHeaderFields);

        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
            if (!connectionError) {
                
                NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                
                switch (statusCode) {
                        
                    case 200:
                        self.fetchResult = UIBackgroundFetchResultNewData;
                        [self parseNewsData:data];
                        break;
                        
                    case 204:
                        NSLog(@"    news: 204 No Content");
                        self.fetchResult = UIBackgroundFetchResultNoData;
                        [self receivingDidFinish];
                        break;
                        
                    default:
                        NSLog(@"    news statusCode: %d", statusCode);
                        self.fetchResult = UIBackgroundFetchResultFailed;
                        [self receivingDidFinish];
                        break;
                        
                }
                
            } else {
                
                NSLog(@"connectionError %@", connectionError.localizedDescription);
                self.errorOccured = YES;
                self.fetchResult = UIBackgroundFetchResultFailed;

                [self receivingDidFinish];
                
            }
            
        }];
        
    } else {
        
        [self receiveData];
        
    }
    
    
}

- (void)parseNewsData:(NSData *)newsData {
    
    if (newsData) {
        
        NSError *error;
        NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:newsData options:NSJSONReadingMutableContainers error:&error];
        
        if (!error) {
            
//            NSLog(@"responseJSON %@", responseJSON);

            NSArray *entitiesNames = [responseJSON valueForKeyPath:@"data.@unionOfObjects.properties.name"];
//            NSLog(@"entitiesNames %@", entitiesNames);
            NSArray *objectsCount = [responseJSON valueForKeyPath:@"data.@unionOfObjects.properties.cnt"];
            
            NSDictionary *news = [NSDictionary dictionaryWithObjects:objectsCount forKeys:entitiesNames];

            for (NSString *entityName in entitiesNames) {
                NSLog(@"    news: STM%@ — %@ objects", entityName, news[entityName]);
            }
            
            NSMutableArray *tempArray = [NSMutableArray array];
            
            for (NSString *entityName in entitiesNames) {
                [tempArray addObject:[ISISTEMIUM_PREFIX stringByAppendingString:entityName]];
            }
            
            self.entitySyncNames = tempArray;
            self.entityCount = tempArray.count;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"syncerNewsHaveObjects" object:self userInfo:@{@"totalNumberOfObjects": [objectsCount valueForKeyPath:@"@sum.integerValue"]}];
            
//            [self receiveData];
            [self checkConditionForReceivingEntityWithName:self.entitySyncNames.firstObject];

        } else {
            
            NSLog(@"parse news json error: %@", error.localizedDescription);
            [self receivingDidFinish];
            
        }
        
    } else {
        
        NSLog(@"empty news data received");
        [self receivingDidFinish];
        
    }
    
}

- (void)receiveData {
    
    if (self.syncerState == STMSyncerReceiveData) {
        
        if (!self.receivingEntitiesNames || [self.receivingEntitiesNames containsObject:@"STMEntity"]) {
            
            self.entityCount = 1;
            self.errorOccured = NO;
            
            [self checkConditionForReceivingEntityWithName:@"STMEntity"];
            
        } else {
            
            self.entitySyncNames = self.receivingEntitiesNames.mutableCopy;
            self.receivingEntitiesNames = nil;
            self.entityCount = self.entitySyncNames.count;

            [self checkConditionForReceivingEntityWithName:self.entitySyncNames.firstObject];
            
//            for (NSString *name in self.receivingEntitiesNames) {
//                [self checkConditionForReceivingEntityWithName:name];
//            }
            
        }

    }
    
}

- (void)checkConditionForReceivingEntityWithName:(NSString *)entityName {
    
    if (self.syncerState != STMSyncerIdle) {

        if ([entityName isEqualToString:@"STMShipmentRoutePointShipment"]) {
            
        }
        
        
        STMEntity *entity = (self.stcEntities)[entityName];
        NSString *url = entity.url;
        
        if (url) {
        
            STMClientEntity *clientEntity = [STMClientEntityController clientEntityWithName:entity.name];
            
//            NSLog(@"entity.name %@ entity.eTag %@", entity.name, entity.eTag);
//            NSLog(@"clientEntity.name %@ clientEntity.eTag %@", clientEntity.name, clientEntity.eTag);

            NSString *eTag = clientEntity.eTag;
            eTag = eTag ? eTag : @"*";
            
            NSURL *requestURL = [NSURL URLWithString:url];
            
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
        [request setHTTPMethod:@"GET"];
        
        [request addValue:[NSString stringWithFormat:@"%d", self.fetchLimit] forHTTPHeaderField:@"page-size"];
        [request addValue:eTag forHTTPHeaderField:@"If-none-match"];
//        [request setValue:[[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString] forHTTPHeaderField:@"DeviceUUID"];
        
//        NSLog(@"request %@", request.allHTTPHeaderFields);

        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        if (!connection) {
            
            [self.session.logger saveLogMessageWithText:@"Syncer: no connection" type:@"error"];
            self.syncing = NO;
            self.fetchResult = UIBackgroundFetchResultFailed;

            self.syncerState = STMSyncerIdle;
            
        } else {
            
        }
        
    } else {
        
        [self.session.logger saveLogMessageWithText:@"Syncer: no authorization header" type:@"error"];
        [self notAuthorized];
        
    }
    
}

- (void)notAuthorized {
    
    self.fetchResult = UIBackgroundFetchResultFailed;
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
    
    if (self.entityCount == 0) {

        [self receivingDidFinish];
        
    } else {
        
        [self.entitySyncNames removeObject:self.entitySyncNames.firstObject];

        if (self.entitySyncNames.firstObject) {
            
            [self checkConditionForReceivingEntityWithName:self.entitySyncNames.firstObject];
            
        } else {
            
            [self receivingDidFinish];

        }
        
    }
    
}

- (void)receivingDidFinish {
    
    [self saveReceiveDate];
    
    self.fullSyncWasDone = YES;
    self.isFirstSyncCycleIteration = NO;
    
    [self.document saveDocument:^(BOOL success) {
        
        if (success) {
            self.syncing = NO;
            self.syncerState = (self.errorOccured) ? STMSyncerIdle : STMSyncerSendData;
        }
        
    }];

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
    self.fetchResult = UIBackgroundFetchResultFailed;
    
    self.syncerState = STMSyncerIdle;
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
    NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
    
//    NSLog(@"response %@", response);
    
    NSString *entityName = [self entityNameForConnection:connection];
    
    if (statusCode == 200) {
        
        (self.responses)[entityName] = [NSMutableData data];
        
        NSString *eTag = headers[@"eTag"];
        
        if (eTag) {
            if (entityName && self.syncerState != STMSyncerIdle) self.temporaryETag[entityName] = eTag;
        } else {
            if (![entityName isEqualToString:SEND_DATA_CONNECTION]) [self receiveNoContentStatusForEntityWithName:entityName];
        }
        
    } else if (statusCode == 410) {
        
        NSLog(@"%@: 410 Gone", entityName);
        
        [STMEntityController deleteEntityWithName:entityName];

        [self entityCountDecrease];
        
    }  else if (statusCode == 204) {
        
        NSLog(@"%@: 204 No Content", entityName);
        [self receiveNoContentStatusForEntityWithName:entityName];
        
    } else {
        
        NSLog(@"%@: HTTP status %d", entityName, statusCode);
        
        if ([entityName isEqualToString:@"SEND_DATA"]) {
            
            self.syncing = NO;
            self.syncerState = STMSyncerIdle;
            
        } else if ([entityName isEqualToString:@"STMEntity"]) {

            self.syncing = NO;
            self.syncerState = STMSyncerIdle;

//        } else if (! -- self.entityCount) {
//            
//            self.syncing = NO;
//            self.syncerState = STMSyncerIdle;
            
        } else {
            [self entityCountDecrease];
        }
    }
    
}

- (void)receiveNoContentStatusForEntityWithName:(NSString *)entityName {
    
    [self.responses removeObjectForKey:entityName];
    
    if ([entityName isEqualToString:@"STMEntity"]) {
        
        [STMEntityController flushSelf];
        
        self.stcEntities = nil;
        NSMutableArray *entityNames = [self.stcEntities.allKeys mutableCopy];
        [entityNames removeObject:entityName];
        
        self.entitySyncNames = entityNames;
        
        self.entityCount = entityNames.count;
        
        NSUInteger settingsIndex = [self.entitySyncNames indexOfObject:@"STMSetting"];        
        if (settingsIndex != NSNotFound) [self.entitySyncNames exchangeObjectAtIndex:settingsIndex withObjectAtIndex:0];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"entitiesReceivingDidFinish" object:self];
        
//        for (NSString *name in entityNames) {
            [self checkConditionForReceivingEntityWithName:self.entitySyncNames.firstObject];
//        }
        
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
        
        STMEntity *entity = (self.stcEntities)[connectionEntityName];
        
        if (entity) {
            
            [STMObjectsController processingOfDataArray:dataArray roleName:entity.roleName withCompletionHandler:^(BOOL success) {
                
                if (success) {
                    
                    NSLog(@"    %@: get %d objects", connectionEntityName, dataArray.count);
                    
                    NSUInteger pageRowCount = [responseJSON[@"page-row-count"] integerValue];
                    NSUInteger pageSize = [responseJSON[@"page-size"] integerValue];
                    
                    if (pageRowCount < pageSize) {
                        
                        NSLog(@"    %@: pageRowCount < pageSize / No more content", connectionEntityName);
                        
                        [self fillETagWithTemporaryValueForEntityName:connectionEntityName];
                        [self receiveNoContentStatusForEntityWithName:connectionEntityName];
                        
                    } else {
                    
                        [self nextReceiveEntityWithName:connectionEntityName];

                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"getBunchOfObjects" object:self userInfo:@{@"count":@(dataArray.count)}];
                    
                } else {
                    self.errorOccured = YES;
                    [self entityCountDecrease];
                }
                
            }];
            
        } else {
            
            for (NSDictionary *datum in dataArray) {
                [STMObjectsController syncObject:datum];
            }

            [self saveSendDate];
            
            self.syncing = NO;

//            [self.sendedEntities removeObjectsInArray:@[
//                                                        NSStringFromClass([STMClientEntity class]),
//                                                        NSStringFromClass([STMEntity class]),
//                                                        NSStringFromClass([STMLogMessage class]),
//                                                        NSStringFromClass([STMLocation class]),
//                                                        NSStringFromClass([STMBatteryStatus class])
//                                                        ]];
//            
//            BOOL onlyStcEntitiesWasSend = (self.sendedEntities.count == 0);
//            
//            if (self.syncerState == STMSyncerSendData && (!onlyStcEntitiesWasSend || !self.fullSyncWasDone)) {
//                self.syncerState = STMSyncerReceiveData;
//            } else /*if (self.syncerState == STMSyncerSendDataOnce)*/ {
//                self.syncerState = STMSyncerIdle;
//            }

            self.syncerState = (self.isFirstSyncCycleIteration) ? STMSyncerReceiveData : STMSyncerIdle;

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
    STMClientEntity *clientEntity = [STMClientEntityController clientEntityWithName:entity.name];
    
    clientEntity.eTag = eTag;
    
}

- (void)nextReceiveEntityWithName:(NSString *)entityName {
    
    [self fillETagWithTemporaryValueForEntityName:entityName];
    [self checkConditionForReceivingEntityWithName:entityName];
    
}

- (void)saveSendDate {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *key = [@"sendDate" stringByAppendingString:self.session.uid];
    NSString *sendDateString = [[STMFunctions dateShortTimeShortFormatter] stringFromDate:[NSDate date]];
    
    [defaults setObject:sendDateString forKey:key];
    [defaults synchronize];
    
}

- (void)saveReceiveDate {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *key = [@"receiveDate" stringByAppendingString:self.session.uid];

    NSString *receiveDateString = [[STMFunctions dateShortTimeShortFormatter] stringFromDate:[NSDate date]];
    
    [defaults setObject:receiveDateString forKey:key];
    [defaults synchronize];
    
}

@end
