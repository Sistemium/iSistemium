//
//  STMSocketController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 10/10/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMSocketController.h"
#import "STMAuthController.h"
#import "STMClientDataController.h"
#import "STMObjectsController.h"
#import "STMRemoteController.h"
#import "STMEntityController.h"

#import "STMSessionManager.h"

#import "STMRootTBC.h"

#import "STMFunctions.h"


#define SOCKET_URL @"https://socket.sistemium.com/socket.io-client"


@interface STMSocketController() <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) SocketIOClient *socket;
@property (nonatomic, strong) NSString *socketUrl;
@property (nonatomic) BOOL shouldStarted;
@property (nonatomic, strong) NSMutableArray *resultsControllers;
@property (nonatomic) BOOL controllersDidChangeContent;
@property (nonatomic) BOOL isAuthorized;
@property (nonatomic) BOOL isSendingData;


@end


@implementation STMSocketController


#pragma mark - class methods

+ (STMSocketController *)sharedInstance {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
    
}

+ (NSString *)stringValueForEvent:(STMSocketEvent)event {
    
    switch (event) {
        case STMSocketEventConnect: {
            return @"connect";
            break;
        }
        case STMSocketEventStatusChange: {
            return @"status:change";
            break;
        }
        case STMSocketEventInfo: {
            return @"info";
            break;
        }
        case STMSocketEventAuthorization: {
            return @"authorization";
            break;
        }
        case STMSocketEventRemoteCommands: {
            return @"remoteCommands";
            break;
        }
        case STMSocketEventData: {
            return @"data:v1";
            break;
        }
        default: {
            return nil;
            break;
        }
    }
    
}

+ (STMSocketEvent)eventForString:(NSString *)stringValue {
    
    if ([stringValue isEqualToString:@"connect"]) {
        return STMSocketEventConnect;
    } else if ([stringValue isEqualToString:@"status:change"]) {
        return STMSocketEventStatusChange;
    } else if ([stringValue isEqualToString:@"info"]) {
        return STMSocketEventInfo;
    } else if ([stringValue isEqualToString:@"authorization"]) {
        return STMSocketEventAuthorization;
    } else if ([stringValue isEqualToString:@"remoteCommands"]) {
        return STMSocketEventRemoteCommands;
    } else if ([stringValue isEqualToString:@"data:v1"]) {
        return STMSocketEventData;
    } else {
        return STMSocketEventInfo;
    }
    
}

+ (STMSyncer *)syncer {
    return [[STMSessionManager sharedManager].currentSession syncer];
}

+ (STMDocument *)document {
    return [[STMSessionManager sharedManager].currentSession document];
}

+ (SocketIOClientStatus)currentSocketStatus {
    return [self sharedInstance].socket.status;
}

+ (BOOL)socketIsAvailable {
    return ([self currentSocketStatus] == SocketIOClientStatusConnected && [self sharedInstance].isAuthorized);
}

+ (void)startSocket {
    
    [self sharedInstance].shouldStarted = YES;
    
    switch ([self sharedInstance].socket.status) {
            
        case SocketIOClientStatusNotConnected:
        case SocketIOClientStatusClosed: {
            [[self sharedInstance].socket connect];
            break;
        }
        case SocketIOClientStatusConnecting: {
            
            break;
        }
        case SocketIOClientStatusConnected: {
            
            break;
        }
        case SocketIOClientStatusReconnecting: {
            
            break;
        }
        default: {
            break;
        }
            
    }

}

+ (void)closeSocket {
    
    [self sharedInstance].shouldStarted = NO;
    [[self sharedInstance].socket disconnect];
    
}

+ (void)reconnectSocket {
    [[self sharedInstance] reconectSocket];
}

+ (void)sendEvent:(STMSocketEvent)event withStringValue:(NSString *)stringValue {
    [self socket:[self sharedInstance].socket sendEvent:event withStringValue:stringValue];
}

+ (void)sendEvent:(STMSocketEvent)event withValue:(id)value {
    [self socket:[self sharedInstance].socket sendEvent:event withValue:value];
}

//+ (void)sendObject:(id)object {
//    [self checkUnsyncedObjectsBeforeSending:object];
//}
//
//+ (void)checkUnsyncedObjectsBeforeSending:(NSManagedObject *)object {
//    
//    NSArray *unsyncedObjectsArray = [[self sharedInstance] unsyncedObjectsArray];
//
//    NSMutableArray *syncDataArray = [self syncDataArrayFromUnsyncedObjects:unsyncedObjectsArray];
//
//    if (object && ![unsyncedObjectsArray containsObject:object]) {
//        [self addObject:object toSyncDataArray:syncDataArray];
//    }
//
//    [self sendEvent:STMSocketEventData withValue:syncDataArray];
//
//}

+ (void)sendUnsyncedObjects:(id)sender {

    if ([STMSocketController syncer].syncerState != STMSyncerReceiveData &&
        [self socketIsAvailable] &&
        ![self sharedInstance].isSendingData) {
        
        NSArray *unsyncedObjectsArray = [[self sharedInstance] unsyncedObjectsArray];
        NSMutableArray *syncDataArray = [self syncDataArrayFromUnsyncedObjects:unsyncedObjectsArray];
        
        if (syncDataArray.count > 0) {
            
            NSLog(@"%d objects to send via Socket", syncDataArray.count);
            [self sendEvent:STMSocketEventData withValue:syncDataArray];
            
        } else {
            
            if ([sender isEqual:[self syncer]]) {
                [[self syncer] nothingToSend];
            }
            
        }

    } else {
        
        if ([sender isEqual:[self syncer]]) {
            [[self syncer] nothingToSend];
        }

    }

}

+ (NSMutableArray *)syncDataArrayFromUnsyncedObjects:(NSArray *)unsyncedObjectsArray {
    
    NSMutableArray *syncDataArray = [NSMutableArray array];
    
    for (NSManagedObject *unsyncedObject in unsyncedObjectsArray) {
        
//        if ([unsyncedObject isKindOfClass:[STMLocation class]]) {
            [self addObject:unsyncedObject toSyncDataArray:syncDataArray];
//        }
        
        if (syncDataArray.count >= 100) {
            
            NSLog(@"Syncer JSONFrom break");
            break;
            
        }
        
    }
    
    return syncDataArray;

}

+ (void)addObject:(NSManagedObject *)object toSyncDataArray:(NSMutableArray *)syncDataArray {
    
    NSDate *currentDate = [NSDate date];
    [object setPrimitiveValue:currentDate forKey:@"sts"];
    
    NSDictionary *objectDictionary = [STMObjectsController dictionaryForObject:object];
    
    [syncDataArray addObject:objectDictionary];

}

+ (void)reloadResultsControllers {
    [[self sharedInstance] reloadResultsControllers];
}


#pragma mark - socket events receiveing

- (void)addEventObserversToSocket:(SocketIOClient *)socket {
    
    [STMSocketController addOnAnyEventToSocket:socket];

    [STMSocketController addEvent:STMSocketEventConnect toSocket:socket];
    [STMSocketController addEvent:STMSocketEventRemoteCommands toSocket:socket];
    
}

+ (void)addOnAnyEventToSocket:(SocketIOClient *)socket {
    
    [socket onAny:^(SocketAnyEvent *event) {
        
        NSLog(@"%@ ___ event %@", socket, event.event);
        NSLog(@"%@ ___ items %@", socket, event.items);
        
    }];

}

+ (void)addEvent:(STMSocketEvent)event toSocket:(SocketIOClient *)socket {
    
    NSString *eventString = [STMSocketController stringValueForEvent:event];
    
    [socket on:eventString callback:^(NSArray *data, SocketAckEmitter *ack) {
        
        switch (event) {
            case STMSocketEventConnect: {
                [self connectCallbackWithData:data ack:ack socket:socket];
                break;
            }
            case STMSocketEventStatusChange: {
                
                break;
            }
            case STMSocketEventInfo: {
                
                break;
            }
            case STMSocketEventAuthorization: {
                
                break;
            }
            case STMSocketEventRemoteCommands: {
                [self remoteCommandsCallbackWithData:data ack:ack socket:socket];
                break;
            }
            case STMSocketEventData: {
                [self dataCallbackWithData:data ack:ack socket:socket];
            }
            default: {
                break;
            }
        }

    }];
    
}

+ (void)connectCallbackWithData:(NSArray *)data ack:(SocketAckEmitter *)ack socket:(SocketIOClient *)socket {
    
    //            [self checkQueuedEvent];
    
    STMClientData *clientData = [STMClientDataController clientData];
    NSMutableDictionary *dataDic = [[STMObjectsController dictionaryForObject:clientData][@"properties"] mutableCopy];
    
    NSDictionary *authDic = @{@"userId"         : [STMAuthController authController].userID,
                              @"accessToken"    : [STMAuthController authController].accessToken};
    
    [dataDic addEntriesFromDictionary:authDic];
    
    NSString *event = [STMSocketController stringValueForEvent:STMSocketEventAuthorization];
    [socket emitWithAck:event withItems:@[dataDic]](0, ^(NSArray *data) {
        [self socket:socket receiveAckWithData:data forEvent:event];
    });
    
}

+ (void)remoteCommandsCallbackWithData:(NSArray *)data ack:(SocketAckEmitter *)ack socket:(SocketIOClient *)socket {
    
    if ([data.firstObject isKindOfClass:[NSDictionary class]]) {
        
        [STMRemoteController receiveRemoteCommands:data.firstObject];
        
    }

}

+ (void)dataCallbackWithData:(NSArray *)data ack:(SocketAckEmitter *)ack socket:(SocketIOClient *)socket {
    
    NSLog(@"data %@", data);
    
}


#pragma mark - socket events sending

+ (void)socket:(SocketIOClient *)socket sendEvent:(STMSocketEvent)event withValue:(id)value {
    
    NSString *primaryKey = @"url";
    
    switch (event) {
        case STMSocketEventConnect:
        case STMSocketEventStatusChange:
        case STMSocketEventInfo:
        case STMSocketEventAuthorization:
        case STMSocketEventRemoteCommands:
            break;
        case STMSocketEventData: {
            primaryKey = @"data";
            break;
        }
        default: {
            break;
        }
    }

    if (value && primaryKey) {

        NSDictionary *dataDic = @{primaryKey : value};
        
        dataDic = [STMFunctions validJSONDictionaryFromDictionary:dataDic];
        
        NSString *eventStringValue = [STMSocketController stringValueForEvent:event];
        
        if (dataDic) {
            
            if (socket.status != SocketIOClientStatusConnected) {
                
            } else {
                
//                NSLog(@"%@ ___ emit: %@, data: %@", socket, eventStringValue, dataDic);
                
                if (event == STMSocketEventData) {
                    
                    [self sharedInstance].isSendingData = YES;
                    
                    [socket emitWithAck:eventStringValue withItems:@[dataDic]](0, ^(NSArray *data) {
                        
                        [self receiveEventDataAckWithData:data];
//                        [self receiveAckWithData:data forEvent:eventStringValue];
                        
                    });
                    
//                } else if (event == STMSocketEventInfo) {
//                
//                    [socket emitWithAck:eventStringValue withItems:@[dataDic]](0, ^(NSArray *data) {
//                        [self receiveAckWithData:data forEvent:eventStringValue];
//                    });
                    
                } else {
                    
                    [socket emit:eventStringValue withItems:@[dataDic]];
                    
                }
                
            }
            
        } else {
            NSLog(@"%@ ___ no dataDic to send via socket for event: %@", socket, eventStringValue);
        }

    }
    
}

+ (void)socket:(SocketIOClient *)socket sendEvent:(STMSocketEvent)event withStringValue:(NSString *)stringValue {
    [self socket:socket sendEvent:event withValue:stringValue];
}

+ (void)socket:(SocketIOClient *)socket receiveAckWithData:(NSArray *)data forEvent:(NSString *)event {
    
    STMSocketEvent socketEvent = [self eventForString:event];
    
    if (socketEvent == STMSocketEventAuthorization) {
        
        if ([data.firstObject isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *dataDic = data.firstObject;
            BOOL isAuthorized = [dataDic[@"isAuthorized"] boolValue];
            
            if (isAuthorized) {
                
                [self sharedInstance].isAuthorized = YES;
                
                [self socket:socket sendEvent:STMSocketEventStatusChange withStringValue:[STMFunctions appStateString]];
                
                if ([[STMFunctions appStateString] isEqualToString:@"UIApplicationStateActive"]) {
                    
                    if ([[STMRootTBC sharedRootVC].selectedViewController class]) {
                        
                        Class _Nonnull rootVCClass = (Class _Nonnull)[[STMRootTBC sharedRootVC].selectedViewController class];
                        
                        NSString *stringValue = [@"selectedViewController: " stringByAppendingString:NSStringFromClass(rootVCClass)];
                        [self socket:socket sendEvent:STMSocketEventStatusChange withStringValue:stringValue];

                    }
                    
                }
                
                [self sendUnsyncedObjects:self];
                
            } else {
                
                [[STMAuthController authController] logout];

            }
            
        } else {
            
            [[STMAuthController authController] logout];

        }
        
    }
    
    NSLog(@"%@ ___ receive Ack, event: %@, data: %@", [self sharedInstance].socket, event, data);
    
}

+ (void)receiveEventDataAckWithData:(NSArray *)data {
    
    NSDictionary *response = data.firstObject;
    
    NSString *errorString = nil;
    
    if ([response isKindOfClass:[NSDictionary class]]) {
        
        errorString = response[@"error"];
        
    } else {
        
        errorString = @"response not a dictionary";
        [self sendEvent:STMSocketEventInfo withStringValue:errorString];
        
    }
    
    if (!errorString) {
    
        NSArray *dataArray = response[@"data"];

        for (NSDictionary *datum in dataArray) {
            [STMObjectsController syncObject:datum];
        }

    } else {
        
        [[STMLogger sharedLogger] saveLogMessageWithText:errorString type:@"error"];
        
        if ([[errorString.lowercaseString stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@"notauthorized"]) {
            [[STMAuthController authController] logout];
        }
            
    }
    
//    NSLog(@"receiveEventDataAckWithData %@", data);

    [[[STMSessionManager sharedManager].currentSession document] saveDocument:^(BOOL success) {
        [self sendFinished];
    }];
    
}

+ (void)sendFinished {
    
    [[self syncer] sendFinished:self];
    [self sharedInstance].isSendingData = NO;

}

#pragma mark - instance methods

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self addObservers];
    }
    return self;
    
}

- (void)addObservers {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(appSettingsChanged:)
               name:@"appSettingsSettingsChanged"
             object:nil];
    
    [nc addObserver:self
           selector:@selector(sessionStatusChanged:)
               name:@"sessionStatusChanged"
             object:nil];

    
    [nc addObserver:self
           selector:@selector(objectContextDidSave:)
               name:NSManagedObjectContextDidSaveNotification
             object:nil];

}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)appSettingsChanged:(NSNotification *)notification {
    
    if ([notification.userInfo.allKeys containsObject:@"socketUrl"]) {
        
        self.socketUrl = nil;
        
        if (![self.socket.socketURL isEqualToString:self.socketUrl]) {
            [self reconectSocket];
        }
        
    }
    
}

- (void)sessionStatusChanged:(NSNotification *)notification {
    
    STMSession *session = [STMSessionManager sharedManager].currentSession;
    
    if (notification.object == session) {
        
        if ([session.status isEqualToString:@"running"]) {
            
            [self performFetches];
            
        } else {
            
            self.resultsControllers = nil;
            
        }
        
    }
    
}

- (void)objectContextDidSave:(NSNotification *)notification {
    
    if (self.controllersDidChangeContent && [notification.object isKindOfClass:[NSManagedObjectContext class]]) {
        
        NSManagedObjectContext *context = (NSManagedObjectContext *)notification.object;
        
        if ([context isEqual:[STMSocketController document].managedObjectContext]) {
            
            self.controllersDidChangeContent = NO;
            [[STMSocketController sharedInstance] performSelector:@selector(sendUnsyncedObjects) withObject:nil afterDelay:0];

        }
        
    }
    
}

- (void)sendUnsyncedObjects {
    [STMSocketController sendUnsyncedObjects:self];
}

- (void)performFetches {

    NSArray *entityNamesForSending = [STMEntityController uploadableEntitiesNames];

    self.resultsControllers = @[].mutableCopy;
    
    for (NSString *entityName in entityNamesForSending) {
        
        NSFetchedResultsController *rc = [self resultsControllerForEntityName:entityName];
        [self.resultsControllers addObject:rc];
        [rc performFetch:nil];

    }
    
}

- (void)reloadResultsControllers {
    
    self.resultsControllers = nil;
    [self performFetches];
    
}


#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)resultsControllerForEntityName:(NSString *)entityName {
    
    STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:entityName];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)]];
    request.includesSubentities = YES;

    NSMutableArray *subpredicates = @[].mutableCopy;
    
    if ([entityName isEqualToString:NSStringFromClass([STMLogMessage class])]) {
        
        STMLogger *logger = [[STMSessionManager sharedManager].currentSession logger];
        
        NSArray *logMessageSyncTypes = [logger syncingTypesForSettingType:[self uploadLogType]];
        
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"type IN %@", logMessageSyncTypes]];

    }

    [subpredicates addObject:[NSPredicate predicateWithFormat:@"(lts == %@ || deviceTs > lts)", nil]];

    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
    
    NSFetchedResultsController *rc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                         managedObjectContext:[STMSocketController document].managedObjectContext
                                                                           sectionNameKeyPath:nil
                                                                                    cacheName:nil];
    rc.delegate = self;
    
    return rc;

}

//- (NSFetchedResultsController *)resultsController {
//    
//    if (!_resultsController) {
//        
//        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMDatum class])];
//        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)]];
//        request.includesSubentities = YES;
//        
//        request.predicate = [STMPredicate predicateWithNoFantomsFromPredicate:[NSPredicate predicateWithFormat:@"(lts == %@ || deviceTs > lts)", nil]];
//        
//        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
//                                                                 managedObjectContext:[STMSocketController document].managedObjectContext
//                                                                   sectionNameKeyPath:nil
//                                                                            cacheName:nil];
//        _resultsController.delegate = self;
//        
//    }
//    
//    return _resultsController;
//    
//}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
//    NSLog(@"%@ ____ controllerDidChangeContent", self);
//    
//    if ([STMSocketController syncer].syncerState != STMSyncerReceiveData) {
//        
//    }
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"syncerDidChangeContent" object:self];
    
    self.controllersDidChangeContent = YES;
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
//    
//    switch (type) {
//        case NSFetchedResultsChangeInsert: {
//            NSLog(@"NSFetchedResultsChangeInsert");
//            break;
//        }
//        case NSFetchedResultsChangeDelete: {
//            NSLog(@"NSFetchedResultsChangeDelete");
//            break;
//        }
//        case NSFetchedResultsChangeMove: {
//            NSLog(@"NSFetchedResultsChangeMove");
//            break;
//        }
//        case NSFetchedResultsChangeUpdate: {
//            NSLog(@"NSFetchedResultsChangeUpdate");
//            break;
//        }
//        default: {
//            break;
//        }
//    }
//    
//    NSLog(@"%@, %@", NSStringFromClass([anObject class]), [anObject valueForKey:@"xid"]);
//    
//    NSDate *deviceTs = [anObject valueForKey:@"deviceTs"];
//    
//    if (deviceTs) {
//        
//        NSLog(@"deviceTs %@", [[STMFunctions dateFormatter] stringFromDate:deviceTs]);
//
//    } else {
//        
//        NSLog(@"deviceTs is nil");
//        
//    }
    
//    NSLog(@"indexPath %@, newIndexPath %@", indexPath, newIndexPath);
    
}

- (NSString *)uploadLogType {
        NSString *uploadLogType = [STMSettingsController stringValueForSettings:@"uploadLog.type" forGroup:@"syncer"];
    return uploadLogType;
}

- (NSArray *)unsyncedObjectsArray {
    
    if (self.isAuthorized && [STMSocketController document].managedObjectContext) {
        
        NSArray *unsyncedObjects = [self.resultsControllers valueForKeyPath:@"@distinctUnionOfArrays.fetchedObjects"];
        
//        NSArray *entityNamesForSending = [STMEntityController uploadableEntitiesNames];
//        
//        NSPredicate *predicate = [STMPredicate predicateWithNoFantomsFromPredicate:[NSPredicate predicateWithFormat:@"entity.name IN %@", entityNamesForSending]];
//        unsyncedObjects = [unsyncedObjects filteredArrayUsingPredicate:predicate];
//        
//        STMLogger *logger = [[STMSessionManager sharedManager].currentSession logger];
//        
//        NSArray *logMessageSyncTypes = [logger syncingTypesForSettingType:[self uploadLogType]];
//        
//        predicate = [NSPredicate predicateWithFormat:@"(entity.name != %@) OR (type IN %@)", NSStringFromClass([STMLogMessage class]), logMessageSyncTypes];
//        unsyncedObjects = [unsyncedObjects filteredArrayUsingPredicate:predicate];
        
        return unsyncedObjects;
        
    } else {
        return nil;
    }
    
}


#pragma mark - socket

- (SocketIOClient *)socket {
    
    if (!_socket && self.socketUrl) {
        
        SocketIOClient *socket = [[SocketIOClient alloc] initWithSocketURL:self.socketUrl opts:nil];
        
        [self addEventObserversToSocket:socket];
        
        if (self.shouldStarted) {
            [socket connect];
        }
        
        _socket = socket;
        
    }
    return _socket;
    
}

- (void)reconectSocket {
    
    [self.socket disconnect];
    
    self.socketUrl = nil;
    self.socket = nil;
    
    [self socket];
    
}

- (NSString *)socketUrl {
    
    if (!_socketUrl) {
        
        _socketUrl = [STMSettingsController stringValueForSettings:@"socketUrl" forGroup:@"appSettings"];
        
    }
    return _socketUrl;
    
}


@end
