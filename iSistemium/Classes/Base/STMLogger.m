//
//  STMLogger.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 06/05/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMLogger.h"
#import "STMDocument.h"
#import "STMEntityDescription.h"
#import "STMFunctions.h"

#import "STMObjectsController.h"


@interface STMLogger() <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) STMDocument *document;
@property (strong, nonatomic) NSFetchedResultsController *resultsController;

@property (nonatomic, strong) NSMutableIndexSet *deletedSectionIndexes;
@property (nonatomic, strong) NSMutableIndexSet *insertedSectionIndexes;
@property (nonatomic, strong) NSMutableArray *deletedRowIndexPaths;
@property (nonatomic, strong) NSMutableArray *insertedRowIndexPaths;
@property (nonatomic, strong) NSMutableArray *updatedRowIndexPaths;

@property (nonatomic, strong) NSArray *uploadTypes;
@property (nonatomic, strong) NSString *uploadLogType;


@end


@implementation STMLogger


#pragma mark - class methods

+ (STMLogger *)sharedLogger {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedLogger = nil;
    
    dispatch_once(&pred, ^{
        _sharedLogger = [[self alloc] init];
    });
    
    return _sharedLogger;
    
}

+ (void)requestInfo:(NSString *)xidString {
    [[self sharedLogger] requestInfo:xidString];
}

+ (void)requestObjects:(NSDictionary *)parameters {
    [[self sharedLogger] requestObjects:parameters];
}

+ (void)requestDefaults {
    [[self sharedLogger] requestDefaults];
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
           selector:@selector(syncerSettingsChanged:)
               name:@"syncerSettingsChanged"
             object:nil];

}

- (void)syncerSettingsChanged:(NSNotification *)notification {
    
    self.uploadTypes = nil;
    self.uploadLogType = nil;
    
}

- (void)requestInfo:(NSString *)xidString {
    
    if (![xidString isEqual:[NSNull null]]) {
        
        NSData *xidData = [STMFunctions xidDataFromXidString:xidString];
        
        NSManagedObject *object = [STMObjectsController objectForXid:xidData];
        
        if (object) {
            
            NSDictionary *objectDic = [STMObjectsController dictionaryForObject:object];
            NSString *JSONString = [STMFunctions jsonStringFromDictionary:objectDic];
            [self saveLogMessageWithText:JSONString
                                 numType:STMLogMessageTypeImportant];
            
        } else {
            
            NSString *logMessage = [NSString stringWithFormat:@"no object with xid %@", xidString];
            [self saveLogMessageWithText:logMessage
                                 numType:STMLogMessageTypeError];
            
        }

    } else {
        
        NSString *logMessage = [NSString stringWithFormat:@"xidSting is NSNull"];
        [self saveLogMessageWithText:logMessage
                             numType:STMLogMessageTypeError];
        
    }
    
    [self.document saveDocument:^(BOOL success) {
//        if (success) [[self.session syncer] setSyncerState:STMSyncerSendDataOnce];
    }];
    
}

- (void)requestObjects:(NSDictionary *)parameters {
    
    NSError *error;
    
    NSArray *jsonArray = [STMObjectsController jsonForObjectsWithParameters:parameters error:&error];

    if (!error) {

        NSDictionary *jsonDic = @{@"objects": jsonArray,
                                  @"requestParameters": parameters};

        NSString *JSONString = [STMFunctions jsonStringFromDictionary:jsonDic];
        [self saveLogMessageWithText:JSONString
                             numType:STMLogMessageTypeImportant];
        
    } else {

        [self saveLogMessageWithText:error.localizedDescription
                             numType:STMLogMessageTypeError];

    }

    [self.document saveDocument:^(BOOL success) {
//        if (success) [[self.session syncer] setSyncerState:STMSyncerSendDataOnce];
    }];

}

- (void)requestDefaults {
    
    NSDictionary *defaultsDic = @{@"userDefault": [[STMUserDefaults standardUserDefaults] dictionaryRepresentation]};

    if (defaultsDic) {
        
        NSString *JSONString = [STMFunctions jsonStringFromDictionary:defaultsDic];
        
        [self saveLogMessageWithText:JSONString
                             numType:STMLogMessageTypeImportant];

        [self.document saveDocument:^(BOOL success) {
//            if (success) [[self.session syncer] setSyncerState:STMSyncerSendDataOnce];
        }];

    }
}

- (void)setSession:(id <STMSession>)session {
    
    if (_session != session) {
        
        _session = session;
        self.document = (STMDocument *)session.document;
        
    }
    
}

- (void)setDocument:(STMDocument *)document {
    
    if (_document != document) {
        
        _document = document;
        self.resultsController = nil;

    }
    
}

- (NSArray *)availableTypes {
    return @[@"important", @"error", @"warning", @"info", @"debug"];
}

- (NSString *)stringTypeForNumType:(STMLogMessageType)numType {
    
    switch (numType) {
        case STMLogMessageTypeImportant: {
            return @"important";
            break;
        }
        case STMLogMessageTypeError: {
            return @"error";
            break;
        }
        case STMLogMessageTypeWarning: {
            return @"warning";
            break;
        }
        case STMLogMessageTypeInfo: {
            return @"info";
            break;
        }
        case STMLogMessageTypeDebug: {
            return @"debug";
            break;
        }
    }
    
}

- (NSArray *)syncingTypesForSettingType:(NSString *)settingType {
    
    NSMutableArray *types = [self availableTypes].mutableCopy;
    
    if ([settingType isEqualToString:@"debug"]) {
        return types;
    } else {
        [types removeObject:@"debug"];
        
        if ([settingType isEqualToString:@"info"]) {
            return types;
        } else {
            [types removeObject:@"info"];
            
            if ([settingType isEqualToString:@"warning"]) {
                return types;
            } else {
                [types removeObject:@"warning"];
                
                if ([settingType isEqualToString:@"error"]) {
                    return types;
                } else {
                    [types removeObject:@"error"];
                    return types;
                    
                }
                
            }
            
        }
        
    }
    
// type @"important" sync always
    
}

- (NSArray *)uploadTypes {
    
    if (!_uploadTypes) {
        _uploadTypes = [self syncingTypesForSettingType:self.uploadLogType];
    }
    return _uploadTypes;
    
}

- (NSString *)uploadLogType {
    
    if (!_uploadLogType) {

        NSString *uploadLogType = [STMSettingsController stringValueForSettings:@"uploadLog.type"
                                                                       forGroup:@"syncer"];
        _uploadLogType = uploadLogType;

    }
    return _uploadLogType;
    
}

- (void)saveLogMessageWithText:(NSString *)text
                       numType:(STMLogMessageType)numType{
    
    NSString *stringType = [self stringTypeForNumType:numType];
    
    [self saveLogMessageWithText:text
                            type:stringType];
    
}

- (void)saveLogMessageWithText:(NSString *)text {
    [self saveLogMessageWithText:text numType:STMLogMessageTypeInfo];
}

- (void)saveLogMessageWithText:(NSString *)text type:(NSString *)type {
    [self saveLogMessageWithText:text type:type owner:nil];
}

- (void)saveLogMessageWithText:(NSString *)text type:(NSString *)type owner:(STMDatum *)owner {
    
    // owner is unused property
    owner = nil; // have to check owner.managedObjectsContext before use it
    
    if (![[self availableTypes] containsObject:type]) type = @"info";
    
    NSLog(@"Log %@: %@", type, text);

#ifdef DEBUG
//    [self sendLogMessageToLocalServerForDebugWithType:type andText:text];
#endif
    
    if ([self.uploadTypes containsObject:type]) {
    
        BOOL sessionIsRunning = (self.session.status == STMSessionRunning);
        
        NSMutableDictionary *logMessageDic = @{}.mutableCopy;
        
        logMessageDic[@"text"] = text;
        logMessageDic[@"type"] = type;
        
        if (sessionIsRunning && self.document) {
            
            [self createAndSaveLogMessageFromDictionary:logMessageDic];
            
        } else {
            
            logMessageDic[@"deviceCts"] = [NSDate date];
            
            [self performSelector:@selector(saveLogMessageDictionary:)
                       withObject:logMessageDic
                       afterDelay:0];
            
        }

    }
    
}

- (void)saveLogMessageDictionary:(NSDictionary *)logMessageDic {

    STMUserDefaults *defaults = [STMUserDefaults standardUserDefaults];
    
    NSArray *loggerDefaults = [defaults arrayForKey:[self loggerKey]];
    NSMutableArray *loggerDefaultsMutable = (loggerDefaults) ? loggerDefaults.mutableCopy : @[].mutableCopy;
    
    [loggerDefaultsMutable addObject:logMessageDic];
    
    [defaults setObject:loggerDefaultsMutable forKey:[self loggerKey]];
    [defaults synchronize];
    
}

- (void)saveLogMessageDictionaryToDocument {
    
    NSLog(@"saveLogMessageDictionaryToDocument");
    
    STMUserDefaults *defaults = [STMUserDefaults standardUserDefaults];
    
    NSArray *loggerDefaults = [defaults arrayForKey:[self loggerKey]];

    for (NSDictionary *logMessageDic in loggerDefaults) {
        [self createAndSaveLogMessageFromDictionary:logMessageDic];
    }

    [defaults removeObjectForKey:[self loggerKey]];
    [defaults synchronize];

}

- (void)createAndSaveLogMessageFromDictionary:(NSDictionary *)logMessageDic {
    
    [self.document.managedObjectContext performBlock:^{
    
        STMLogMessage *logMessage = (STMLogMessage *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMLogMessage class])
                                                                                         isFantom:NO];
        
        for (NSString *key in logMessageDic.allKeys) {
            
            if ([logMessage.entity.propertiesByName.allKeys containsObject:key]) {
                [logMessage setValue:logMessageDic[key] forKey:key];
            }
            
        }
        
        [self.document saveDocument:^(BOOL success) {
        }];

    }];
    
}

- (void)sendLogMessageToLocalServerForDebugWithType:(NSString *)type andText:(NSString *)text {
    
    NSURL *url = [NSURL URLWithString:@"http://maxbook.local:8888"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    
    NSString *bodyString = [NSString stringWithFormat:@"%@ %@: %@", [dateFormatter stringFromDate:[NSDate date]], type, text];
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        //            NSLog(@"%@", response);
    }];
    
}

- (NSString *)loggerKey {
    
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *loggerKey = [bundleIdentifier stringByAppendingString:@".logger"];

    return loggerKey;
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMLogMessage class])];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"deviceCts"
                                                                  ascending:NO
                                                                   selector:@selector(compare:)]];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                 managedObjectContext:self.document.managedObjectContext
                                                                   sectionNameKeyPath:@"dayAsString"
                                                                            cacheName:nil];
        _resultsController.delegate = self;
        
        NSError *error;
        if (![_resultsController performFetch:&error]) NSLog(@"performFetch error %@", error);
        
    }
    
    return _resultsController;
    
}

- (NSMutableIndexSet *)deletedSectionIndexes {
    
    if (!_deletedSectionIndexes) {
        _deletedSectionIndexes = [NSMutableIndexSet indexSet];
    }
    
    return _deletedSectionIndexes;
    
}

- (NSMutableIndexSet *)insertedSectionIndexes {
    
    if (!_insertedSectionIndexes) {
        _insertedSectionIndexes = [NSMutableIndexSet indexSet];
    }
    
    return _insertedSectionIndexes;
    
}

- (NSMutableArray *)deletedRowIndexPaths {
    
    if (!_deletedRowIndexPaths) {
        _deletedRowIndexPaths = [NSMutableArray array];
    }
    
    return _deletedRowIndexPaths;
    
}

- (NSMutableArray *)insertedRowIndexPaths {
    
    if (!_insertedRowIndexPaths) {
        _insertedRowIndexPaths = [NSMutableArray array];
    }
    
    return _insertedRowIndexPaths;
    
}

- (NSMutableArray *)updatedRowIndexPaths {
    
    if (!_updatedRowIndexPaths) {
        _updatedRowIndexPaths = [NSMutableArray array];
    }
    
    return _updatedRowIndexPaths;
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [[self.resultsController sections] count];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.resultsController sections][section];
    return [sectionInfo numberOfObjects];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.resultsController sections][section];
    
    NSDateFormatter *dateFormatter = [STMFunctions dateNumbersFormatter];

    NSDate *date = [dateFormatter dateFromString:[sectionInfo name]];
    
    dateFormatter = [STMFunctions dateLongNoTimeFormatter];
    
    return [dateFormatter stringFromDate:date];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"logCell";
//    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
  
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSDateFormatter *startDateFormatter = [STMFunctions dateMediumTimeMediumFormatter];
    
    STMLogMessage *logMessage = [self.resultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = logMessage.text;
    
    if ([logMessage.type isEqualToString:@"error"]) {
        cell.textLabel.textColor = [UIColor redColor];
    } else if ([logMessage.type isEqualToString:@"blue"]) {
        cell.textLabel.textColor = [UIColor blueColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    cell.detailTextLabel.text = (logMessage.deviceCts) ? [startDateFormatter stringFromDate:(NSDate * _Nonnull)logMessage.deviceCts] : @"";
    
    return cell;

}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleNone;
    
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath;
    
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return nil;
    
}



#pragma mark - NSFetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView beginUpdates];
    
    [self.tableView deleteSections:self.deletedSectionIndexes withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView insertSections:self.insertedSectionIndexes withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView deleteRowsAtIndexPaths:self.deletedRowIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView insertRowsAtIndexPaths:self.insertedRowIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadRowsAtIndexPaths:self.updatedRowIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView endUpdates];
    
    self.insertedSectionIndexes = nil;
    self.deletedSectionIndexes = nil;
    self.deletedRowIndexPaths = nil;
    self.insertedRowIndexPaths = nil;
    self.updatedRowIndexPaths = nil;
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch (type) {
            
        case NSFetchedResultsChangeInsert:
            [self.insertedSectionIndexes addIndex:sectionIndex];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.deletedSectionIndexes addIndex:sectionIndex];
            break;
            
        default:
            ; // Shouldn't have a default
            break;
            
    }
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (type == NSFetchedResultsChangeInsert) {
        
        if ([self.insertedSectionIndexes containsIndex:newIndexPath.section]) {
            return;
        }
        
        [self.insertedRowIndexPaths addObject:newIndexPath];
        
    } else if (type == NSFetchedResultsChangeDelete) {
        
        if ([self.deletedSectionIndexes containsIndex:indexPath.section]) {
            return;
        }
        
        [self.deletedRowIndexPaths addObject:indexPath];
        
    } else if (type == NSFetchedResultsChangeMove) {
        
        if (![self.insertedSectionIndexes containsIndex:newIndexPath.section]) {
            [self.insertedRowIndexPaths addObject:newIndexPath];
        }
        
        if (![self.deletedSectionIndexes containsIndex:indexPath.section]) {
            [self.deletedRowIndexPaths addObject:indexPath];
        }
        
    } else if (type == NSFetchedResultsChangeUpdate) {
        
        [self.updatedRowIndexPaths addObject:indexPath];
        
    }
    
}

@end
