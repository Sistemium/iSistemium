//
//  STMCampaignController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 30/04/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMCampaignController.h"
#import "STMRecordStatusController.h"
#import "STMObjectsController.h"

@interface STMCampaignController() <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *campaignsResultController;
@property (nonatomic, strong) NSFetchedResultsController *readCampaignPicturesResultController;


@end


@implementation STMCampaignController

+ (STMCampaignController *)sharedInstance {
    
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
    
}

- (NSFetchedResultsController *)campaignsResultController {
    
    if (!_campaignsResultController) {
        
        NSString *entityName = NSStringFromClass([STMCampaign class]);
        
        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:entityName];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)]];
        
        NSFetchedResultsController *resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                                            managedObjectContext:[STMCampaignController document].managedObjectContext
                                                                                              sectionNameKeyPath:nil
                                                                                                       cacheName:nil];
        resultsController.delegate = self;
        [resultsController performFetch:nil];
        
        _campaignsResultController = resultsController;
        
    }
    return _campaignsResultController;
    
}

- (NSFetchedResultsController *)readCampaignPicturesResultController {
    
    if (!_readCampaignPicturesResultController) {
        
        NSString *entityName = NSStringFromClass([STMRecordStatus class]);
        
        STMFetchRequest *request = [[STMFetchRequest alloc] initWithEntityName:entityName];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"(objectXid IN %@) && (isRead == YES)", [self.campaignsResultController.fetchedObjects valueForKeyPath:@"@distinctUnionOfSets.pictures.xid"]];
        
        NSFetchedResultsController *resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                                            managedObjectContext:[STMCampaignController document].managedObjectContext
                                                                                              sectionNameKeyPath:nil
                                                                                                       cacheName:nil];
        resultsController.delegate = self;
        [resultsController performFetch:nil];
        
        _readCampaignPicturesResultController = resultsController;
        
    }
    return _readCampaignPicturesResultController;
    
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {

    if ([controller isEqual:self.campaignsResultController]) {
        self.readCampaignPicturesResultController = nil;
    } else if ([controller isEqual:self.readCampaignPicturesResultController]) {
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"readCampaignsCountIsChanged" object:self];
    
}



#pragma mark - class methods

+ (BOOL)hasUnreadPicturesInCampaign:(STMCampaign *)campaign {
    
    BOOL result = NO;
    
    NSArray *readCampaignPicturesArray = [[self sharedInstance].readCampaignPicturesResultController.fetchedObjects valueForKeyPath:@"@distinctUnionOfObjects.objectXid"];

    for (STMCampaignPicture *picture in campaign.pictures) {
        
        if (![readCampaignPicturesArray containsObject:picture.xid]) {
            
            result = YES;
            break;

        }
        
//        STMRecordStatus *recordStatus = [STMRecordStatusController existingRecordStatusForXid:picture.xid];
//        
//        if (![recordStatus.isRead boolValue]) {
//            
//            result = YES;
//            break;
//            
//        }
        
    }
    
    return result;

}

+ (NSUInteger)numberOfUnreadCampaign {
    
    NSUInteger result = 0;
    
//    NSArray *campaigns = [STMObjectsController objectsForEntityName:NSStringFromClass([STMCampaign class])];
//    NSPredicate *notFantomPredicate = [STMPredicate predicateWithNoFantoms];
//    campaigns = [campaigns filteredArrayUsingPredicate:notFantomPredicate];
//    
//    for (STMCampaign *campaign in campaigns) {
//        
//        if ([self hasUnreadPicturesInCampaign:campaign]) result++;
//        
//    }
//    
//    return result;

    NSArray *campaignsArray = [self sharedInstance].campaignsResultController.fetchedObjects;
    
    for (STMCampaign *campaign in campaignsArray) {
        
        if ([self hasUnreadPicturesInCampaign:campaign]) result++;
        
    }
    
    return result;

}


@end
