//
//  STMDocument.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 06/05/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMDocument.h"
#import "STMObjectsController.h"

@interface STMDocument()

@property (nonatomic, strong) NSString *dataModelName;
@property (nonatomic) BOOL saving;

@end


@implementation STMDocument

@synthesize myManagedObjectModel = _myManagedObjectModel;
@synthesize mainContext = _mainContext;
@synthesize privateContext = _privateContext;

- (NSManagedObjectModel *)myManagedObjectModel {
    
    if (!_myManagedObjectModel) {
        
        NSString *path = [[NSBundle mainBundle] pathForResource:self.dataModelName ofType:@"momd"];
        
        if (!path) {
            path = [[NSBundle mainBundle] pathForResource:self.dataModelName ofType:@"mom"];
        }
        
        NSURL *url = [NSURL fileURLWithPath:path];

        //        NSLog(@"path %@", path);
        //        NSLog(@"url %@", url);

        _myManagedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
        
    }
    
    return _myManagedObjectModel;
    
}

- (NSManagedObjectModel *)managedObjectModel {
    return self.myManagedObjectModel;
}

- (NSManagedObjectContext *)mainContext {
    
    if (!_mainContext) {
        _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainContext.persistentStoreCoordinator = self.managedObjectContext.persistentStoreCoordinator;
    }
    return _mainContext;
    
}

- (NSManagedObjectContext *)privateContext {
    
    if (!_privateContext) {
        _privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _privateContext.persistentStoreCoordinator = self.managedObjectContext.persistentStoreCoordinator;
    }
    return _privateContext;
    
}

- (void)saveContexts {
    
    [self.mainContext performBlock:^{
        if (self.mainContext.hasChanges) [self.mainContext save:nil];
    }];
    
    [self.privateContext performBlock:^{
        if (self.privateContext.hasChanges) [self.privateContext save:nil];
    }];
    
}

- (void)saveDocument:(void (^)(BOOL success))completionHandler {

    [self saveContexts];
    
    if (!self.saving) {

        if (self.documentState == UIDocumentStateNormal) {
            
            self.saving = YES;
            
            [self saveToURL:self.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                
                if (success) {
                    
                    completionHandler(YES);
                    
                } else {
                    
                    NSLog(@"UIDocumentSaveForOverwriting not success");
                    completionHandler(NO);
                    
                }
                
                self.saving = NO;
                
            }];
            
        } else {
            
            NSLog(@"documentState != UIDocumentStateNormal for document: %@", self);
            NSLog(@"documentState is %u", (int)self.documentState);
            
            completionHandler(NO);
            
        }

    } else {
        
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

            [self saveDocument:^(BOOL success) {
                
                completionHandler(success);
                
            }];
            
        });

    }

}

- (void)contextDidSaveMainContext:(NSNotification *)notification {
    
    @synchronized(self) {
        [self.privateContext performBlock:^{
            [self.privateContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
    
}

- (void)contextDidSavePrivateContext:(NSNotification *)notification {
    
    @synchronized(self) {
        [self.mainContext performBlock:^{
            [self.mainContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
    
}

- (void)addObservers {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(applicationDidEnterBackground)
               name:@"applicationDidEnterBackground"
             object:nil];
    
    [nc addObserver:self
           selector:@selector(contextDidSaveMainContext:)
               name:NSManagedObjectContextDidSaveNotification
             object:self.mainContext];
    
    [nc addObserver:self
           selector:@selector(contextDidSavePrivateContext:)
               name:NSManagedObjectContextDidSaveNotification
             object:self.privateContext];
    
}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)applicationDidEnterBackground {
    
    [STMObjectsController checkObjectsForFlushing];
    
}

+ (STMDocument *)initWithFileURL:(NSURL *)url andDataModelName:(NSString *)dataModelName {
    
    STMDocument *document = [STMDocument alloc];
    [document setDataModelName:dataModelName];
    return [document initWithFileURL:url];
    
}

+ (STMDocument *)documentWithUID:(NSString *)uid dataModelName:(NSString *)dataModelName prefix:(NSString *)prefix {
    
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.%@", prefix, uid, @"sqlite"]];
    
    STMDocument *document = [STMDocument initWithFileURL:url andDataModelName:dataModelName];
    
    document.persistentStoreOptions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[document.fileURL path]]) {

        [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            
            if (success) {
                NSLog(@"document UIDocumentSaveForCreating success");
                [self document:document readyWithUID:uid];
            } else {
                [self document:document notReadyWithUID:uid];
            }
            
        }];
        
    } else if (document.documentState == UIDocumentStateClosed) {
        
        [document openWithCompletionHandler:^(BOOL success) {
            
            if (success) {
                NSLog(@"document openWithCompletionHandler success");
                [self document:document readyWithUID:uid];
            } else {
                [self document:document notReadyWithUID:uid];
            }
            
        }];
        
    } else if (document.documentState == UIDocumentStateNormal) {
        
        [self document:document readyWithUID:uid];
        
    }
    
    [document addObservers];

    return document;
    
}

+ (void)document:(STMDocument *)document readyWithUID:(NSString *)uid {

    [[NSNotificationCenter defaultCenter] postNotificationName:@"documentReady" object:document userInfo:[NSDictionary dictionaryWithObject:uid forKey:@"uid"]];

}

+ (void)document:(STMDocument *)document notReadyWithUID:(NSString *)uid {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"documentNotReady" object:document userInfo:[NSDictionary dictionaryWithObject:uid forKey:@"uid"]];
    
}


@end
