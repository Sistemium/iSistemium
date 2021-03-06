//
//  STMDocument.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 06/05/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMDocument.h"
#import "STMObjectsController.h"
#import "STMFunctions.h"


@interface STMDocument()

@property (nonatomic, strong) NSString *dataModelName;
@property (nonatomic) BOOL saving;
@property (nonatomic) BOOL savingHaveToRepeat;
@property (nonatomic) int savingQueue;

@end


@implementation STMDocument

@synthesize myManagedObjectModel = _myManagedObjectModel;

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

- (void)saveDocument:(void (^)(BOOL success))completionHandler {
    
    if (!self.saving) {

        if (self.documentState == UIDocumentStateNormal) {
            
            self.saving = YES;
            
            [self saveToURL:self.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                
                self.saving = NO;
                
                if (success) {

                    NSLog(@"--- documentSavedSuccessfully ---");
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"documentSavedSuccessfully" object:self];
                    
                    completionHandler(YES);

                    if (self.savingHaveToRepeat) {
                        
                        NSLog(@"--- repeat of document saving ---");
                        self.savingHaveToRepeat = NO;
                        
                        [self saveDocument:^(BOOL success) {
                        }];
                        
                    }

                } else {
                    
                    NSLog(@"--- UIDocumentSaveForOverwriting not success ---");
                    completionHandler(NO);
                    
                    self.savingHaveToRepeat = NO;

                }
                
            }];
            
        } else {
            
            NSLog(@"documentState != UIDocumentStateNormal for document: %@", self);
            NSLog(@"documentState is %u", (int)self.documentState);
            
            completionHandler(NO);
            
        }

    } else {

//        NSLog(@"Document currently is saving");
        
        self.savingHaveToRepeat = YES;
        
        completionHandler(YES);

//        double delayInSeconds = 3;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//
//            [self saveDocument:^(BOOL success) {
//                
//                completionHandler(success);
//                
//            }];
//            
//        });

    }

}

- (void)addObservers {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(applicationDidEnterBackground)
               name:UIApplicationDidEnterBackgroundNotification
             object:nil];
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

+ (STMDocument *)documentWithUID:(NSString *)uid iSisDB:(NSString *)iSisDB dataModelName:(NSString *)dataModelName prefix:(NSString *)prefix {

    NSURL *documentDirectoryUrl = [STMFunctions documentsDirectoryURL];
    NSString *documentID = (iSisDB) ? iSisDB : uid;

//    from now we delete old document with STMDataModel data model and use new STMDataModel2
    NSURL *url = [documentDirectoryUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.%@", prefix, documentID, @"sqlite"]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:(NSString *)url.path]) {

        NSString *logMessage = [NSString stringWithFormat:@"delete old document with filename: %@ for uid: %@", url.lastPathComponent, uid];
        [[STMLogger sharedLogger] saveLogMessageWithText:logMessage type:@"info"];
        
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        
    }
//    ———————————————————————
    
    NSString *filename = [@[prefix, documentID, dataModelName] componentsJoinedByString:@"_"];
    url = [documentDirectoryUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", filename, @"sqlite"]];

    NSString *logMessage = [NSString stringWithFormat:@"prepare document with filename: %@ for uid: %@", url.lastPathComponent, uid];
    [[STMLogger sharedLogger] saveLogMessageWithText:logMessage type:@"info"];

    STMDocument *document = [STMDocument initWithFileURL:url andDataModelName:dataModelName];
    document.uid = uid;
    
    document.persistentStoreOptions = @{NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES};
    
    if (document.fileURL.path && ![[NSFileManager defaultManager] fileExistsAtPath:(NSString * _Nonnull)document.fileURL.path]) {

        [self createDocument:document];
        
    } else if (document.documentState == UIDocumentStateClosed) {
        
        [self openDocument:document];
        
    } else if (document.documentState == UIDocumentStateNormal) {
        
        [self documentReady:document];
        
    }
    
    [document addObservers];
    
    [[document undoManager] disableUndoRegistration];

    return document;
    
}

+ (void)createDocument:(STMDocument *)document {
    
    [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
        
        [self handleHandlerForDocument:document
                               message:@"UIDocumentSaveForCreating"
                               success:success];

    }];

}

+ (void)openDocument:(STMDocument *)document {
    
    [document openWithCompletionHandler:^(BOOL success) {
        
        [self handleHandlerForDocument:document
                               message:@"openWithCompletionHandler"
                               success:success];
        
    }];
    
}

+ (void)handleHandlerForDocument:(STMDocument *)document message:(NSString *)message success:(BOOL)success {
    
    if (success) {
        
        NSString *logMessage = [NSString stringWithFormat:@"document %@ success", message];
        [[STMLogger sharedLogger] saveLogMessageWithText:logMessage];
        
        [self documentReady:document];
        
    } else {
        [self documentNotReady:document];
    }

}

+ (void)documentReady:(STMDocument *)document {

    [[NSNotificationCenter defaultCenter] postNotificationName:@"documentReady"
                                                        object:document
                                                      userInfo:@{@"uid": document.uid}];

}

+ (void)documentNotReady:(STMDocument *)document {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"documentNotReady"
                                                        object:document
                                                      userInfo:@{@"uid": document.uid}];
    
}


@end
