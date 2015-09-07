//
//  STMMessageController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 05/04/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMMessageController.h"
#import "STMObjectsController.h"
#import "STMRecordStatusController.h"

#import "STMMessageVC.h"
#import "STMRootTBC.h"

@interface STMMessageController() <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *messagesResultsController;
@property (nonatomic, strong) NSFetchedResultsController *readMessagesResultsController;

@property (nonatomic, strong) NSMutableDictionary *shownPictures;
@property (nonatomic, strong) NSMutableArray *fullscreenPictures;


@end


@implementation STMMessageController

+ (STMMessageController *)sharedInstance {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
    
}

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
           selector:@selector(authStateChanged)
               name:@"authControllerStateChanged"
             object:[STMAuthController authController]];
    
}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)authStateChanged {
    
    if ([STMAuthController authController].controllerState != STMAuthSuccess) {
        [self flushSelf];
    }
    
}

- (void)flushSelf {
    
    self.fullscreenPictures = nil;
    self.shownPictures = nil;
    self.messagesResultsController = nil;
    
}

- (NSMutableArray *)fullscreenPictures {
    
    if (!_fullscreenPictures) {
        _fullscreenPictures = @[].mutableCopy;
    }
    return _fullscreenPictures;
    
}

- (NSMutableDictionary *)shownPictures {
    
    if (!_shownPictures) {
        _shownPictures = @{}.mutableCopy;
    }
    return _shownPictures;
    
}

- (NSFetchedResultsController *)messagesResultsController {
    
    if (!_messagesResultsController) {
        
        NSString *entityName = NSStringFromClass([STMMessage class]);
        
        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:entityName];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)]];
        
        NSFetchedResultsController *resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                                            managedObjectContext:[STMMessageController document].managedObjectContext
                                                                                              sectionNameKeyPath:nil
                                                                                                       cacheName:nil];
        resultsController.delegate = self;
        [resultsController performFetch:nil];

        _messagesResultsController = resultsController;
        
    }
    return _messagesResultsController;
    
}

- (NSFetchedResultsController *)readMessagesResultsController {
    
    if (!_readMessagesResultsController) {
        
        NSString *entityName = NSStringFromClass([STMRecordStatus class]);
        STMEntityDescription *entity = [STMEntityDescription entityForName:entityName inManagedObjectContext:[STMMessageController document].managedObjectContext];
        
        STMFetchRequest *request = [[STMFetchRequest alloc] init];
        request.entity = entity;
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"(objectXid IN %@) && (isRead == YES)", [self.messagesResultsController.fetchedObjects valueForKeyPath:@"xid"]];
//        request.resultType = NSDictionaryResultType;
//        request.returnsDistinctResults = YES;
//        request.propertiesToFetch = @[entity.propertiesByName[@"objectXid"]];
        
        NSFetchedResultsController *resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                                            managedObjectContext:[STMMessageController document].managedObjectContext
                                                                                              sectionNameKeyPath:nil
                                                                                                       cacheName:nil];
        resultsController.delegate = self;
        [resultsController performFetch:nil];
        
        _readMessagesResultsController = resultsController;
        
    }
    return _readMessagesResultsController;
    
}

- (void)pictureDidShown:(STMMessagePicture *)picture {
    
    [self.fullscreenPictures removeObject:picture];
    
    STMMessage *message = picture.message;
    
    if (![STMMessageController messageIsRead:message]) {
        
        NSMutableArray *shownPicturesArray = self.shownPictures[message.xid];
        if (!shownPicturesArray) shownPicturesArray = [@[] mutableCopy];
        [shownPicturesArray addObject:picture.xid];
        self.shownPictures[message.xid] = shownPicturesArray;
        
        NSSet *picturesXids = [message valueForKeyPath:@"pictures.xid"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (self IN %@)", shownPicturesArray];
        NSUInteger unshownPicturesCount = [picturesXids.allObjects filteredArrayUsingPredicate:predicate].count;
        
        if (unshownPicturesCount == 0) {
            
            [STMMessageController markMessageAsRead:message];
            [self.shownPictures removeObjectForKey:message.xid];
            
        }
        
    }
    
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
        case NSFetchedResultsChangeDelete: {
            
            if ([controller isEqual:self.messagesResultsController]) {
                self.readMessagesResultsController = nil;
            } else if ([controller isEqual:self.readMessagesResultsController]) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"readMessageCountIsChanged" object:self];
            }

            [[NSNotificationCenter defaultCenter] postNotificationName:@"readMessageCountIsChanged" object:self];

            break;
        }
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
        default: {
            break;
        }
    }


}


#pragma mark - class methods

+ (NSArray *)sortedPicturesArrayForMessage:(STMMessage *)message {
    
    NSSortDescriptor *ordSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ord" ascending:YES selector:@selector(compare:)];
    NSSortDescriptor *idSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)];
    NSArray *picturesArray = [message.pictures sortedArrayUsingDescriptors:@[ordSortDescriptor, idSortDescriptor]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imageThumbnail != %@", nil];
    picturesArray = [picturesArray filteredArrayUsingPredicate:predicate];

    return picturesArray;
    
}

+ (void)showMessageVCsIfNeeded {
    
    NSArray *messages = [self messagesWithShowOnEnterForeground];
    
    NSArray *messagesXids = [messages valueForKeyPath:@"xid"];
    
    NSArray *recordStatuses = [STMRecordStatusController recordStatusesForXids:messagesXids];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isRead == YES"];
    recordStatuses = [recordStatuses filteredArrayUsingPredicate:predicate];
    
    NSArray *xids = [recordStatuses valueForKeyPath:@"objectXid"];
    
    predicate = [NSPredicate predicateWithFormat:@"NOT (xid IN %@)", xids];
    messages = [messages filteredArrayUsingPredicate:predicate];
    
    [self showMessageVCsForMessages:messages];
    
}

+ (NSArray *)messagesWithShowOnEnterForeground {
    
    STMFetchRequest *request = [[STMFetchRequest alloc] initWithEntityName:NSStringFromClass([STMMessage class])];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"showOnEnterForeground == YES"];
    
    request.sortDescriptors = @[sortDescriptor];
    request.predicate = predicate;
    
    NSArray *messages = [[self document].managedObjectContext executeFetchRequest:request error:nil];

    return messages;
    
}

+ (void)showMessageVCsForMessages:(NSArray *)messages {
    
    for (STMMessage *message in messages) {
        [self showMessageVCsForMessage:message];
    }
    
}

+ (void)showMessageVCsForMessage:(STMMessage *)message {

    NSArray *picturesArray = [self sortedPicturesArrayForMessage:message];
    
    for (STMMessagePicture *picture in picturesArray) {
        
        if (![[self sharedInstance].fullscreenPictures containsObject:picture]) {
            
            [[self sharedInstance].fullscreenPictures addObject:picture];
            
            UIViewController *presenter = [[STMRootTBC sharedRootVC] topmostVC];
            
            STMMessageVC *messageVC = [self messageVCWithPicture:picture andText:message.body];
            [presenter presentViewController:messageVC animated:NO completion:nil];

        }
        
    }
    
}

+ (STMMessageVC *)messageVCWithPicture:(STMMessagePicture *)picture andText:(NSString *)text {
    
    UIStoryboard *messageVCStoryboard = [UIStoryboard storyboardWithName:@"STMMessageVC" bundle:nil];
    STMMessageVC *messageVC = [messageVCStoryboard instantiateInitialViewController];
    
    messageVC.picture = picture;
    messageVC.text = text;
    
    return messageVC;

}

+ (void)pictureDidShown:(STMMessagePicture *)picture {
    [[self sharedInstance] pictureDidShown:picture];
}

+ (void)markMessageAsRead:(STMMessage *)message {
    
    STMRecordStatus *recordStatus = [STMRecordStatusController recordStatusForObject:message];
    recordStatus.isRead = @YES;
    
    [self.document saveDocument:^(BOOL success) {
        
        if (success) {
            
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"messageIsRead" object:nil];
             self.syncer.syncerState = STMSyncerSendDataOnce;

        }
        
    }];
    
}

+ (BOOL)messageIsRead:(STMMessage *)message {

    STMRecordStatus *recordStatus = [STMRecordStatusController existingRecordStatusForXid:message.xid];

    return [recordStatus.isRead boolValue];
    
}

+ (NSUInteger)unreadMessagesCount {
    
    return [self unreadMessagesCountInContext:nil];
    
}

+ (NSUInteger)unreadMessagesCountInContext:(NSManagedObjectContext *)context {
    
    NSArray *messageArray = [self sharedInstance].messagesResultsController.fetchedObjects;
    NSArray *readMessageArray = [self sharedInstance].readMessagesResultsController.fetchedObjects;
    
    return messageArray.count - readMessageArray.count;
    
//    if (!context) context = [self document].managedObjectContext;
//    
//    NSString *entityName = NSStringFromClass([STMMessage class]);
//    
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
//    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)]];
//    
//    NSError *error;
//    NSArray *result = [context executeFetchRequest:request error:&error];
//    
//    NSArray *messageXids = [result valueForKeyPath:@"xid"];
//    
//    entityName = NSStringFromClass([STMRecordStatus class]);
//    STMEntityDescription *entity = [STMEntityDescription entityForName:entityName inManagedObjectContext:context];
//
//    request.entity = entity;
//    request.predicate = [NSPredicate predicateWithFormat:@"(objectXid IN %@) && (isRead == YES)", messageXids];
//    request.resultType = NSDictionaryResultType;
//    request.returnsDistinctResults = YES;
//    request.propertiesToFetch = @[entity.propertiesByName[@"objectXid"]];
//    
//    result = [context executeFetchRequest:request error:&error];
//    
//    NSUInteger recordStatusesCount = result.count;
//    
//    NSInteger unreadMessageCount = messageXids.count - recordStatusesCount;
//    
//    if (unreadMessageCount <= 0) unreadMessageCount = 0;
//    
//    return (NSUInteger)unreadMessageCount;

}


@end
