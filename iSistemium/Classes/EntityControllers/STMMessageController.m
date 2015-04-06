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

@interface STMMessageController()

@property (nonatomic, strong) NSMutableDictionary *shownPictures;


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


/**
 *  method for testing multiple pictures in messages, should be removed after checking
 */
+ (void)generateTestMessages {
    
    STMMessage *message = (STMMessage *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMMessage class])];
    
    message.body = [NSString stringWithFormat:@"TEST MESSAGE %@", [NSDate date]];
    message.subject = @"Test message subject";
    message.cts = [NSDate date];
    
    NSArray *pictures = [STMObjectsController objectsForEntityName:NSStringFromClass([STMMessagePicture class])];
    STMMessagePicture *picture = pictures.lastObject;
    
    STMMessagePicture *newPicture = (STMMessagePicture *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMMessagePicture class])];
    newPicture.href = picture.href;
    newPicture.isFantom = @NO;
    
    [message addPicturesObject:newPicture];

    STMMessagePicture *newPicture1 = (STMMessagePicture *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMMessagePicture class])];
    newPicture1.href = @"http://i.imgur.com/Z9dCA7D.jpg";
    newPicture1.isFantom = @NO;
    
    [message addPicturesObject:newPicture1];

    STMMessagePicture *newPicture2 = (STMMessagePicture *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMMessagePicture class])];
    newPicture2.href = @"http://upload.wikimedia.org/wikipedia/en/archive/3/3e/20141001152415!IOS_8_Homescreen.png";
    newPicture1.isFantom = @NO;
    
    [message addPicturesObject:newPicture2];

    NSLog(@"add message %@", message);
    
    [[self document] saveDocument:^(BOOL success) {}];
    
}
// ------------------------ end of test method -----------------------


+ (NSArray *)sortedPicturesArrayForMessage:(STMMessage *)message {
    
    NSSortDescriptor *ordSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ord" ascending:YES selector:@selector(compare:)];
    NSSortDescriptor *idSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)];
    NSArray *picturesArray = [message.pictures sortedArrayUsingDescriptors:@[ordSortDescriptor, idSortDescriptor]];

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
    
    NSArray *messages = [[self document].mainContext executeFetchRequest:request error:nil];

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
    
        UIViewController *presenter = [[STMRootTBC sharedRootVC] topmostVC];

        STMMessageVC *messageVC = [self messageVCWithPicture:picture andText:message.body];
        [presenter presentViewController:messageVC animated:NO completion:nil];
        
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
    
    self.syncer.syncerState = STMSyncerSendDataOnce;
    [self.document saveDocument:^(BOOL success) {}];
    
}

+ (BOOL)messageIsRead:(STMMessage *)message {

    STMRecordStatus *recordStatus = [STMRecordStatusController recordStatusForObject:message];

    return [recordStatus.isRead boolValue];
    
}

+ (NSUInteger)unreadMessagesCount {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMMessage class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)]];
    
    NSError *error;
    NSArray *result = [[self document].mainContext executeFetchRequest:request error:&error];
    
    NSArray *messageXids = [result valueForKeyPath:@"xid"];
    
    request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMRecordStatus class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"(objectXid IN %@) && (isRead == YES)", messageXids];
    
    NSUInteger resultCount = [[self document].mainContext countForFetchRequest:request error:&error];
    
    return messageXids.count - resultCount;
    
}


#pragma mark - singletone properties & methods

- (NSMutableDictionary *)shownPictures {
    
    if (!_shownPictures) {
        _shownPictures = [@{} mutableCopy];
    }
    return _shownPictures;
    
}

- (void)pictureDidShown:(STMMessagePicture *)picture {

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


@end
